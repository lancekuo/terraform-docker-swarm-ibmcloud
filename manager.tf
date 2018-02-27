resource "ibm_compute_ssh_key" "manager" {
    label      = "manager.${terraform.workspace}"
    public_key = "${var.ssh_public_key}"
}

resource "ibm_compute_vm_instance" "manager" {
    count                   = "${var.manager_count}"
    hostname                = "manager-${count.index}.${terraform.workspace}"
    domain                  = "${var.domain}"
    ssh_key_ids             = ["${ibm_compute_ssh_key.manager.id}"]
    image_id                = "${data.ibm_compute_image_template.docker_img.id}"
    datacenter              = "${var.datacenter}"
    network_speed           = 10
    cores                   = 2
    memory                  = 2048
    post_install_script_uri = "${var.vm_post_install_script_uri}"
    private_network_only    = true
    private_vlan_id         = "${data.ibm_network_vlan.private.id}"
    tags                    = ["${terraform.workspace}", "manager"]
}
