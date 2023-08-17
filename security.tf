resource "openstack_networking_secgroup_v2" "bastion_sg" {
  name = "${var.prefix}-bastion-sg"
  description = "security group for ${var.prefix}-${var.bastion_instance_name}"
}

# ssh
resource "openstack_networking_secgroup_rule_v2" "bastion-ssh-sg-rule" {
  description       = "Port for SSH connections to bastion host"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.bastion_sg.id
}

# nginx-proxy-manager
resource "openstack_networking_secgroup_rule_v2" "bastion-mgmt-sg-rule" {
  description       = "Port for nginx-proxy-manager on the bastion host"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 81
  port_range_max    = 81
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.bastion_sg.id
}

# jenkins
resource "openstack_networking_secgroup_rule_v2" "bastion-jenkins-sg-rule" {
  description       = "Port for Jenskins access on the bastion host"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8080
  port_range_max    = 8080
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.bastion_sg.id
}

# cluster
resource "openstack_networking_secgroup_rule_v2" "bastion-tunnel-sg-rule" {
  description       = "Proxy ports for K8S SSH connections (up to 5 connections dynamically with autoscaling)"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10000
  port_range_max    = 10004
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.bastion_sg.id
}

# pods
resource "openstack_networking_secgroup_rule_v2" "bastion-tunnel-sg-rule-2" {
  description       = "Proxy ports for K8S pod connections (opensearch dashboard, alertmanager, prometheus, grafana, argocd)"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 30004
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.bastion_sg.id
}

# KIC k8s 자동생성 시큐리티 그룹
data "openstack_networking_secgroup_v2" "cluster_sg" {
  name = tolist(data.openstack_compute_instance_v2.cluster[var.cluster_id[0]].security_groups)[0]
}

# KIC k8s 자동생성 시큐리티 그룹에 bastion에서 오는 ssh 커넥션은 허용하는 내용 추가
resource "openstack_networking_secgroup_rule_v2" "cluster-ssh-sg-rule" {
  description       = "Ports from the bastion host to the k8s nodes"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = openstack_compute_instance_v2.bastion_instance.access_ip_v4
  security_group_id = data.openstack_networking_secgroup_v2.cluster_sg.id
}

# KIC k8s 자동생성 시큐리티 그룹에 bastion에서 웹 콘솔에 접근하는 커넥션은 허용하는 내용 추가
resource "openstack_networking_secgroup_rule_v2" "cluster-tunnel-sg-rule-3" {
  description       = "Ports from the bastion host to the k8s nodes"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 30004
  remote_ip_prefix  = openstack_compute_instance_v2.bastion_instance.access_ip_v4
  security_group_id = data.openstack_networking_secgroup_v2.cluster_sg.id
}