output "this" {
  value = openstack_compute_instance_v2.this
}

output "floating_ip" {
  value = var.floating_ip ? openstack_networking_floatingip_v2.this : null
}