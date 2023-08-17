# 이미 생성된 서브넷 정보
# 실습환경의 이유 상 존재 했음 
public_network_cidr=""
private_network_cidr=""

# sshkey 쌍
sshkey="seong-guk_Kim"

# kic 리전 정보
region = "kr-gov-central-1"
auth_url = "https://iam.kakaoicloud-kr-gov.com/identity/v3"

# kic 엑세스 토큰
application_credential_id = ""
application_credential_secret = ""

# bastion host의 ip
bastion_ip = ""

# api 엑세스 토큰 => 설정파일의 object storage로부터의 다운로드를 위함 필요없을시 관련코드와 함께 삭제 바람
X-Auth-Token = ""

# K8s engine 인스턴스들의 ip 리스트
# kic의 K8s engine은 테라폼으로 제어가 불가능하기 떄문
cluster_id = ["", "", ""]