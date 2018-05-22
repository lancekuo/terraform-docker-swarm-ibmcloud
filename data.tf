# VLANs are not able to provision on the fly, it is dead cloud. Sake.
provider "ibm" {
  bluemix_api_key    = "${var.ibm_bmx_api_key}"
  softlayer_username = "${var.ibm_sl_username}"
  softlayer_api_key  = "${var.ibm_sl_api_key}"
}

data "ibm_compute_image_template" "docker_img" {
  name = "docker-base-2018-05"
}

data "ibm_network_vlan" "private" {
  router_hostname = "${var.vlan_router_hostname_private[terraform.workspace]}.${var.datacenter}"
  number = "${var.vlans_private[terraform.workspace]}"
}

data "ibm_network_vlan" "public" {
  router_hostname = "${var.vlan_router_hostname_public[terraform.workspace]}.${var.datacenter}"
  number = "${var.vlans_public[terraform.workspace]}"
}
