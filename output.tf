output "k8s_cluster_ip_v4" {
  value = values(data.openstack_compute_instance_v2.cluster)[*].access_ip_v4
}

output "test" {
  value = tolist(data.openstack_compute_instance_v2.cluster[var.cluster_id[0]].security_groups)[0]
}