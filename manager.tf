resource "ibm_compute_ssh_key" "manager" {
    label      = "manager.${terraform.workspace}"
    public_key = "${file("${path.root}${var.rsa_key_manager["public_key_path"]}")}"
}

resource "ibm_compute_vm_instance" "manager" {
    count                   = "${var.manager_count}"
    hostname                = "manager-${count.index}"
    domain                  = "${terraform.workspace}.${var.domain}"
    ssh_key_ids             = ["${ibm_compute_ssh_key.manager.id}"]
    image_id                = "${data.ibm_compute_image_template.docker_img.id}"
    datacenter              = "${var.datacenter}"
    local_disk              = false
    network_speed           = 10
    cores                   = 2
    memory                  = 2048
    post_install_script_uri = "${var.vm_post_install_script_uri}"
    private_network_only    = true
    private_vlan_id         = "${data.ibm_network_vlan.private.id}"

    connection {
        bastion_host        = "${ibm_compute_vm_instance.bastion.ipv4_address}"
        bastion_user        = "root"
        bastion_private_key = "${file("${path.root}${var.rsa_key_bastion["private_key_path"]}")}"

        type                = "ssh"
        user                = "root"
        host                = "${self.ipv4_address_private}"
        private_key         = "${file("${path.root}${var.rsa_key_manager["private_key_path"]}")}"
    }

    provisioner "remote-exec" {
        inline = [
            " if [ ${count.index} -eq 0 ]; then sudo docker swarm init; else sudo docker swarm join ${ibm_compute_vm_instance.manager.0.ipv4_address_private}:2377 --token $(docker -H ${ibm_compute_vm_instance.manager.0.ipv4_address_private} swarm join-token -q manager); fi",
            "role-setup ${ibm_compute_vm_instance.nat.ipv4_address_private}",
            " if [ ${count.index} -eq 1 ]; then git clone https://github.com/lancekuo/prometheus.git; fi",
            " if [ ${count.index} -eq 2 ]; then git clone https://github.com/lancekuo/elk.git; fi",
            "echo ${self.hostname}"
        ]
    }

    provisioner "remote-exec" {
        when = "destroy"

        inline = [
            "sudo docker node update --availability drain ${self.hostname}",
            "sudo docker node demote ${self.hostname}",
            "sudo docker swarm leave --force",
        ]
        on_failure = "continue"
    }

    provisioner "remote-exec" {
        when = "destroy"

        inline = [
            "sudo docker node rm --force ${self.hostname}"
        ]
        on_failure = "continue"
        connection {
            bastion_host        = "${ibm_compute_vm_instance.bastion.ipv4_address}"
            bastion_user        = "root"
            bastion_private_key = "${file("${path.root}${var.rsa_key_bastion["private_key_path"]}")}"

            type                = "ssh"
            user                = "root"
            host                = "${ibm_compute_vm_instance.manager.0.ipv4_address_private}"
            private_key         = "${file("${path.root}${var.rsa_key_manager["private_key_path"]}")}"
        }
    }
    tags = ["${terraform.workspace}", "manager", "swarm"]
}
