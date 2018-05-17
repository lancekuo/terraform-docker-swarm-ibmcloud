output "Bastion" {
  value = "${ibm_compute_vm_instance.bastion.ipv4_address}"
}

output "Manager" {
  value = "${ibm_compute_vm_instance.manager.*.ipv4_address_private}"
}
output "vlan_SUBNETS" {
  value = "${data.ibm_network_vlan.private.subnets.0.subnet}"
}
output "Project_VIP" {
  value = "${ibm_lbaas.project.vip}"
}
