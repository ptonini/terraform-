variable "name" {}

variable "instance_count" {
  default = 1
}

variable "image_id" {}

variable "flavor_id" {}

variable "key_pair" {}

variable "security_groups" {}

variable "metadata" {
  default = {}
}

variable "network_name" {}

variable "floating_ip" {
  default = true
}

variable "floating_ip_pool" {
  default = null
}

variable "volumes" {
  type = map(object({
    size                 = number
    enable_online_resize = optional(bool, true)
  }))
  default = {}
}