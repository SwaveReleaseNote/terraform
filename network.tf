# VPC -> KIC 기준 콘솔에서 미리 생성해야함
data "openstack_networking_network_v2" "gcu-academy" {
  matching_subnet_cidr = data.openstack_networking_subnet_v2.main.cidr
}

# subnet -> KIC 기준 콘솔에서 미리 생성해야함
data "openstack_networking_subnet_v2" "main" {
  cidr = var.public_network_cidr
}

data "openstack_networking_subnet_v2" "subnet" {
  cidr = var.private_network_cidr
}

data "openstack_networking_network_v2" "floating_network" {
  external = true
}

# 네트워크 포트 생성
resource "openstack_networking_port_v2" "bastion_port" {
  name = "${var.prefix}-${var.bastion_instance_name}"
  network_id = data.openstack_networking_network_v2.gcu-academy.id
  admin_state_up = true
  security_group_ids = [openstack_networking_secgroup_v2.bastion_sg.id]
}

# floating_ip 연결
resource "openstack_networking_floatingip_associate_v2" "bastion_floating_ip_associate" {
  floating_ip = openstack_networking_floatingip_v2.bastion_floating_ip.address
  port_id = openstack_networking_port_v2.bastion_port.id
}

# floating_ip 생성
resource "openstack_networking_floatingip_v2" "bastion_floating_ip" {
  pool = data.openstack_networking_network_v2.floating_network.name
  # address = var.bastion_ip 권한 없을시 불가능
  port_id = openstack_networking_port_v2.bastion_port.id
}