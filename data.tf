# VLANs are not able to provision on the fly, it is dead cloud. Sake.
provider "ibm" {
    bluemix_api_key    = "${var.ibm_bmx_api_key}"
    softlayer_username = "${var.ibm_sl_username}"
    softlayer_api_key  = "${var.ibm_sl_api_key}"
}

data "ibm_compute_image_template" "docker_img" {
    name = "docker-base"
}

data "ibm_network_vlan" "private" {
    name = "Private-swarm"
}

data "ibm_network_vlan" "public" {
    name = "Public-swarm"
}
