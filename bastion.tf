#resource "ibm_network_vlan" "test_vlan" {
#   name = "test_vlan"
#   datacenter = "tor01"
#   type = "PUBLIC"
#   subnet_size = 8
#   router_hostname = "fcr01a.tor01"
#   tags = [
#     "collectd",
#     "mesos-master"
#   ]
#}

resource "ibm_compute_ssh_key" "bastion" {
    label      = "bastion.${terraform.workspace}"
    public_key = "${var.ssh_public_key}"
}

resource "ibm_compute_vm_instance" "bastion" {
    hostname                = "bastion.${terraform.workspace}"
    domain                  = "${var.domain}"
    ssh_key_ids             = ["${ibm_compute_ssh_key.bastion.id}"]
    image_id                = "${data.ibm_compute_image_template.docker_img.id}"
    datacenter              = "${var.datacenter}"
    network_speed           = 10
    cores                   = 2
    memory                  = 2048
    post_install_script_uri = "${var.vm_post_install_script_uri}"
    public_vlan_id          = "${data.ibm_network_vlan.public.id}"
    private_vlan_id         = "${data.ibm_network_vlan.private.id}"
}
