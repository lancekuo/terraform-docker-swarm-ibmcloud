resource "ibm_compute_ssh_key" "node" {
  label      = "node.${var.project}.${terraform.workspace}"
  public_key = "${file("${path.root}${var.rsa_key_node["public_key_path"]}")}"
}

resource "ibm_compute_vm_instance" "node" {
  count                      = "${var.node_count}"
  hostname                   = "node-${count.index}"
  domain                     = "${terraform.workspace}.${var.project}.${var.domain}"
  ssh_key_ids                = ["${ibm_compute_ssh_key.node.id}"]
  image_id                   = "${data.ibm_compute_image_template.docker_img.id}"
  datacenter                 = "${var.datacenter}"
  local_disk                 = false
  network_speed              = 100
  cores                      = 2
  memory                     = 16384
  post_install_script_uri    = "${var.vm_post_install_script_uri}"
  private_network_only       = true
  private_vlan_id            = "${data.ibm_network_vlan.private.id}"
  private_security_group_ids = ["${ibm_security_group.node_pvt.id}", "${ibm_security_group.docker-gossip.id}"]

  connection {
    bastion_host        = "${ibm_compute_vm_instance.bastion.ipv4_address}"
    bastion_user        = "root"
    bastion_private_key = "${file("${path.root}${var.rsa_key_bastion["private_key_path"]}")}"

    type        = "ssh"
    user        = "root"
    host        = "${self.ipv4_address_private}"
    private_key = "${file("${path.root}${var.rsa_key_node["private_key_path"]}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "role-setup ${ibm_compute_vm_instance.nat.ipv4_address_private}",
      "sudo docker swarm join ${ibm_compute_vm_instance.manager.0.ipv4_address_private}:2377 --token $(docker -H ${ibm_compute_vm_instance.manager.0.ipv4_address_private} swarm join-token -q worker)",
    ]
  }

  tags = ["${terraform.workspace}", "node", "swarm"]
}
