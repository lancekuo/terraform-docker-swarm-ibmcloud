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

resource "ibm_compute_ssh_key" "nat" {
  label      = "${var.rsa_key_nat["key_name"]}.${terraform.workspace}"
  public_key = "${file("${path.root}${var.rsa_key_nat["public_key_path"]}")}"
}

resource "ibm_compute_ssh_key" "bastion" {
  label      = "${var.rsa_key_bastion["key_name"]}.${terraform.workspace}"
  public_key = "${file("${path.root}${var.rsa_key_bastion["public_key_path"]}")}"
}

resource "ibm_compute_vm_instance" "bastion" {
  hostname                   = "bastion"
  domain                     = "${terraform.workspace}.${var.domain}"
  ssh_key_ids                = ["${ibm_compute_ssh_key.bastion.id}"]
  image_id                   = "${data.ibm_compute_image_template.docker_img.id}"
  datacenter                 = "${var.datacenter}"
  local_disk                 = false
  network_speed              = 100
  cores                      = 2
  memory                     = 2048
  post_install_script_uri    = "${var.vm_post_install_script_uri}"
  public_vlan_id             = "${data.ibm_network_vlan.public.id}"
  private_vlan_id            = "${data.ibm_network_vlan.private.id}"
  private_security_group_ids = ["${ibm_security_group.bastion_pvt.id}"]
  public_security_group_ids  = ["${ibm_security_group.bastion_pub.id}"]
}

resource "ibm_compute_vm_instance" "nat" {
  hostname                   = "nat"
  domain                     = "${terraform.workspace}.${var.domain}"
  ssh_key_ids                = ["${ibm_compute_ssh_key.nat.id}"]
  image_id                   = "${data.ibm_compute_image_template.docker_img.id}"
  datacenter                 = "${var.datacenter}"
  local_disk                 = false
  network_speed              = 1000
  cores                      = 1
  memory                     = 2048
  post_install_script_uri    = "${var.vm_post_install_script_uri}"
  public_vlan_id             = "${data.ibm_network_vlan.public.id}"
  private_vlan_id            = "${data.ibm_network_vlan.private.id}"
  private_security_group_ids = ["${ibm_security_group.nat_pvt.id}"]
  public_security_group_ids  = ["${ibm_security_group.nat_pub.id}"]

  connection {
    bastion_host        = "${ibm_compute_vm_instance.bastion.ipv4_address}"
    bastion_user        = "root"
    bastion_private_key = "${file("${path.root}${var.rsa_key_bastion["private_key_path"]}")}"

    type        = "ssh"
    user        = "root"
    host        = "${self.ipv4_address_private}"
    private_key = "${file("${path.root}${var.rsa_key_nat["private_key_path"]}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "role-setup",
    ]
  }
}
