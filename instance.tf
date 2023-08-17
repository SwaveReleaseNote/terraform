resource "openstack_compute_instance_v2" "bastion_instance" {
  name = "${var.prefix}-${var.bastion_instance_name}"
  flavor_name = var.bastion_flavor
  key_pair = data.openstack_compute_keypair_v2.sshkey.id
  user_data = <<EOF
#cloud-config
write_files:
- content: |
    ${indent(4, data.template_file.bastion_init.rendered)}
  path: "/tmp/bastion-init.sh"
  owner: root:root
  permissions: '0755'
runcmd:
- [bash, /tmp/bastion-init.sh]
EOF

  block_device {
    uuid                  = data.openstack_images_image_v2.default_image.id
    source_type           = "image"
    volume_size           = 50
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.bastion_port.id
  }

}

data "openstack_compute_instance_v2" "cluster"{
  for_each = toset(var.cluster_id)
  id = each.key
}