data "openstack_images_image_v2" default_image {
  name = var.default_image
  visibility = "public"
  most_recent = true
}

# Key

data "openstack_compute_keypair_v2" "sshkey" {
  name = var.sshkey
}

/*
data "template_file" "web_env" {
  template = file("./templates/web-env.sh")
  vars = {
    APP_ENDPOINT = "http://${openstack_lb_loadbalancer_v2.app_lb.vip_address}:8080"
  }
}
*/

data "template_file" "bastion_init" {
  template = file("./scripts/bastion-init.sh")
  vars = {
    instance_ip = join(",", values(data.openstack_compute_instance_v2.cluster)[*].access_ip_v4)
    X-Auth-Token = var.X-Auth-Token
  }
}