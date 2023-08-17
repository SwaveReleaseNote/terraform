# network

variable "public_network_cidr" {
  type = string
  default = ""
}

variable "private_network_cidr" {
  type = string
  default = ""
}

# key

variable "sshkey" {
  type = string
}

#provider

variable "region" {
  type = string
}

variable "auth_url" {
  type = string
}

variable "application_credential_id" {
  type = string
}

variable "application_credential_secret" {
  type = string
}

# default

variable default_image {
  type    = string
  default = "Ubuntu 20.04"
}

variable "prefix" {
  type = string
  default = "urnr"
}

# bastion-var

variable bastion_instance_name {
  type    = string
  default = "bastion"
}

variable bastion_flavor {
  type    = string
  default = "m1i.xlarge"
  description = "4 vcpu, 16gb ram"
}

# cluster 

variable cluster_id {
  type    = list(string)
}

# token

variable "X-Auth-Token" {
  type    = string
}

# bastion ip

variable "bastion_ip" {
  type    = string
}
