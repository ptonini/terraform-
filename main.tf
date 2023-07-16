resource "openstack_compute_instance_v2" "this" {
  count           = var.instance_count
  name            = "${var.name}${format("%04.0f", count.index + 1)}"
  image_id        = var.image_id
  flavor_id       = var.flavor_id
  key_pair        = var.key_pair
  security_groups = var.security_groups
  metadata        = var.metadata
  network {
    name = var.network_name
  }
}

resource "openstack_networking_floatingip_v2" "this" {
  count = var.floating_ip ? var.instance_count : 0
  pool  = var.floating_ip_pool
}

resource "openstack_compute_floatingip_associate_v2" "this" {
  count       = var.floating_ip ? var.instance_count : 0
  floating_ip = openstack_networking_floatingip_v2.this[count.index].address
  instance_id = openstack_compute_instance_v2.this[count.index].id
}