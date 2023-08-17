#!/bin/bash

# install docker / docker-compose

sudo apt-get update
sudo apt-get -y install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo apt-get -y install docker-compose

# run docker compose

mkdir ~/nginx-proxy-manager
cat << EOF > ~/nginx-proxy-manager/docker-compose.yaml
version: "3"
services:
  nginx-proxy-manager:
    image: 'jc21/nginx-proxy-manager:2.9.20'
    container_name: nginx-proxy-manager
    restart: unless-stopped
    ports:
      # These ports are in format <host-port>:<container-port>
      - '81:81' # Admin Web Port
      - '10000-10004:10000-10004' # cluster port
      - '3306:3306'
      # Add any other Stream port you want to expose
      # - '21:21' # FTP
    environment:
      DB_MYSQL_HOST: "db"
      DB_MYSQL_PORT: 3306
      DB_MYSQL_USER: "npm"
      DB_MYSQL_PASSWORD: "npm"
      DB_MYSQL_NAME: "npm"
      # Uncomment this if IPv6 is not enabled on your host
      # DISABLE_IPV6: 'true'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
    depends_on:
      - db

  db:
    image: 'jc21/mariadb-aria:latest'
    container_name: mariadb
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: 'npm'
      MYSQL_DATABASE: 'npm'
      MYSQL_USER: 'npm'
      MYSQL_PASSWORD: 'npm'
    volumes:
      - ./data/mysql:/var/lib/mysql

  jenkins:
    image: 'hamgeonwook/jenkins_dood'
    container_name: jenkins
    restart: unless-stopped
    ports:
      - '8080:8080'
    volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - /jenkins:/var/jenkins_home
    privileged: true
    user: root

EOF

sudo docker-compose -f ~/nginx-proxy-manager/docker-compose.yaml up -d

sleep 30

# update stream

TOKEN=$(curl -XPOST http://localhost:81/api/tokens \
    -H 'Content-Type: application/json' \
    -d '{"identity":"admin@example.com", "secret":"changeme"}' | \
      python3 -m json.tool | \
      grep '"token":' | \
      sed 's/^.*"token": "\(.*\)".*$/\1/')

IFS=',' read -ra INSTANCE_IPS <<< "${instance_ip}"

for i in "$${!INSTANCE_IPS[@]}"
do
  incoming_port=$((10000 + i))
  curl -XPOST -H "Authorization: Bearer $TOKEN" \
      "http://localhost:81/api/nginx/streams" \
      -H 'Content-Type: application/json' \
      -d "{\"incoming_port\":$incoming_port, \"forwarding_host\":\"$${INSTANCE_IPS[$i]}\", \"forwarding_port\":22, \"tcp_forwarding\":true}"
done

for i in 0..5
do
  incoming_port=$((30000 + i))
  forwarding_port=$((30000 + i))
  curl -XPOST -H "Authorization: Bearer $TOKEN" \
      "http://localhost:81/api/nginx/streams" \
      -H 'Content-Type: application/json' \
      -d "{\"incoming_port\":$incoming_port, \"forwarding_host\":\"$${INSTANCE_IPS[1]}\", \"forwarding_port\":$forwarding_port, \"tcp_forwarding\":true}"
done

# config

curl -OL -X GET -H "X-Auth-Token: ${X-Auth-Token}" \
"https://objectstorage.kr-gov-central-1.kakaoicloud-kr-gov.com/v1/394defd6bb464430a47f1ede2bf87a4e/config/config"

curl -OL -X GET -H "X-Auth-Token: ${X-Auth-Token}" \
"https://objectstorage.kr-gov-central-1.kakaoicloud-kr-gov.com/v1/394defd6bb464430a47f1ede2bf87a4e/config/kic-iam-auth"

curl -OL -X GET -H "X-Auth-Token: ${X-Auth-Token}" \
"https://objectstorage.kr-gov-central-1.kakaoicloud-kr-gov.com/v1/394defd6bb464430a47f1ede2bf87a4e/config/seong-guk_Kim.pem"

cat /seong-guk_Kim.pem >> ~/.ssh/authorized_keys

sudo mv seong-guk_Kim.pem ~/.ssh/seong-guk_Kim.pem

chmod 400 ~/.ssh/seong-guk_Kim.pem

echo 'export KUBE_CONFIG="/config"' >> /etc/bash.bashrc

chmod +x kic-iam-auth

echo 'export PATH="/:$PATH"' >> /etc/bash.bashrc

source /etc/bash.bashrc

for i in "$${!INSTANCE_IPS[@]}"
do
  ssh-keyscan -t rsa $${INSTANCE_IPS[$i]} >> ~/.ssh/known_hosts
done

eval $(ssh-agent)

ssh-add ~/.ssh/seong-guk_Kim.pem

# ansible

sudo apt-get install -y ansible

output_file="/etc/ansible/hosts"

echo "[k8s]" > "$output_file"

for i in "$${!INSTANCE_IPS[@]}"
do
  echo $${INSTANCE_IPS[$i]} >> "$output_file"
done

cat << EOF > setup_instance.yml
---
- hosts: k8s
  gather_facts: no
  become: true
  become_method: sudo

  vars:
    admin_password: "admin"

  tasks:
    - name: Set root password
      user:
        name: root
        password: "{{ admin_password | password_hash('sha512') }}"
        update_password: always

    - name: Update timezone to KST
      shell: timedatectl set-timezone Asia/Seoul

    - name: Install net-tools
      apt:
        name: net-tools

    - name: set vm.max_map_count
      shell: echo 'vm.max_map_count=262144' >> /etc/sysctl.conf

    - name: apply vm.max_map_count
      shell: sysctl -p
EOF

ansible-playbook setup_instance.yml

# k8s

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

helm repo add urnr https://swavereleasenote.github.io/release-note/
helm install urnr --namespace urnr --create-namespace urnr/urnr
