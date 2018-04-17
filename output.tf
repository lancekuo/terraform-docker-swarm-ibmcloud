output "Bastion" {
  value = "${ibm_compute_vm_instance.bastion.ipv4_address}"
}

output "Manager" {
  value = "${ibm_compute_vm_instance.manager.*.ipv4_address_private}"
}
output "test" {
  value = "${ibm_lbaas.project_lb.vip}"
}
