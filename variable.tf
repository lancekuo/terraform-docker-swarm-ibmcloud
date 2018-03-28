variable "ibm_bmx_api_key" {}
variable "ibm_sl_username" {}
variable "ibm_sl_api_key" {}

variable "vm_post_install_script_uri" {}
variable "datacenter" {}
variable "domain" {}
variable "project" {}

variable "manager_count" {}
variable "node_count" {}

variable "rsa_key_nat" {
  type = "map"
}

variable "rsa_key_bastion" {
  type = "map"
}

variable "rsa_key_manager" {
  type = "map"
}

variable "rsa_key_node" {
  type = "map"
}

#stupid things start here
variable "vlans_public" {
  type = "map"
}
variable "vlans_private" {
  type = "map"
}
variable "vlan_router_hostname_public" {
  type = "map"
}
variable "vlan_router_hostname_private" {
  type = "map"
}
#stupid things start here for LBaaS
variable "vlan_subnets_private" {
  type = "map"
}
