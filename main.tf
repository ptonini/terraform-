locals {
  volumes = { for v in flatten([
    for i in range(var.instance_count) : [
      for k, v in var.volumes : {
        key                  = "${var.name}${format("%04.0f", i + 1)}-${k}"
        instance_index       = i
        name                 = k
        size                 = v.size
        enable_online_resize = v.enable_online_resize
      }
    ]
  ]) : v.key => v }
}

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

resource "openstack_blockstorage_volume_v3" "this" {
  for_each             = local.volumes
  name                 = each.key
  size                 = each.value.size
  enable_online_resize = each.value.enable_online_resize
}

resource "openstack_compute_volume_attach_v2" "va_1" {
  for_each    = local.volumes
  instance_id = openstack_compute_instance_v2.this[each.value.instance_index].id
  volume_id   = openstack_blockstorage_volume_v3.this[each.key].id
}