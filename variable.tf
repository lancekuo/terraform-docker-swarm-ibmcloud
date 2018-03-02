variable "ibm_bmx_api_key"            {}
variable "ibm_sl_username"            {}
variable "ibm_sl_api_key"             {}

variable "vm_post_install_script_uri" {}
variable "datacenter"                 {}
variable "domain"                     {}
variable "project"                    {}

variable "manager_count"              {}
variable "rsa_key_bastion"            {type="map"}
variable "rsa_key_manager"            {type="map"}

