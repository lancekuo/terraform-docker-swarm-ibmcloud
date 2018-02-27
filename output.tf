output "Bastion" {
    value = "${ibm_compute_vm_instance.bastion.ipv4_address}"
}
