resource "ibm_compute_ssh_key" "manager" {
  label      = "manager.${var.project}.${terraform.workspace}.${var.domain}"
  notes      = "${var.project}.${terraform.workspace}.${var.domain}"
  public_key = "${file("${path.root}${var.rsa_key_manager["public_key_path"]}")}"
}

resource "ibm_compute_vm_instance" "manager" {
  count                      = "${var.manager_count}"
  hostname                   = "manager-${count.index}"
  domain                     = "${var.project}.${terraform.workspace}.${var.domain}"
  ssh_key_ids                = ["${ibm_compute_ssh_key.manager.id}"]
  image_id                   = "${data.ibm_compute_image_template.docker_img.id}"
  datacenter                 = "${var.datacenter}"
  local_disk                 = false
  network_speed              = 100
  cores                      = 2
  memory                     = 16384
  post_install_script_uri    = "${var.vm_post_install_script_uri}"
  private_network_only       = true
  private_vlan_id            = "${data.ibm_network_vlan.private.id}"
  private_security_group_ids = ["${ibm_security_group.manager_pvt.id}", "${ibm_security_group.docker-gossip.id}", "${ibm_security_group.manager_services.id}"]

  connection {
    bastion_host        = "${ibm_compute_vm_instance.bastion.ipv4_address}"
    bastion_user        = "root"
    bastion_private_key = "${file("${path.root}${var.rsa_key_bastion["private_key_path"]}")}"

    type        = "ssh"
    user        = "root"
    host        = "${self.ipv4_address_private}"
    private_key = "${file("${path.root}${var.rsa_key_manager["private_key_path"]}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "role-setup ${ibm_compute_vm_instance.nat.ipv4_address_private}",
      " if [ ${count.index} -eq 0 ]; then sudo docker swarm init;git clone https://github.com/lancekuo/dfproxy.git; else sudo docker swarm join ${ibm_compute_vm_instance.manager.0.ipv4_address_private}:2377 --token $(docker -H ${ibm_compute_vm_instance.manager.0.ipv4_address_private} swarm join-token -q manager); fi",
      " if [ ${count.index} -eq 1 ]; then git clone https://github.com/lancekuo/prometheus.git;mkdir /opt/prometheus;mkdir /opt/elasticsearch; fi",
      " if [ ${count.index} -eq 2 ]; then git clone https://github.com/lancekuo/elk.git; fi",
      "mkdir /opt/kafka-log; mkdir /opt/orderer; mkdir /opt/peer; mkdir /opt/app-postgres",
      "TMP='__HOST____PATH__    nfs4    rw,noatime'; for i in '/fabric/kafka /opt/kafka-log' '/fabric/orderer /opt/orderer' '/fabric/peer /opt/peer' '/data/postgresql /opt/app-postgres'; do echo $$TMP|sed -e 's@__HOST__@${ibm_storage_file.data.mountpoint}@g'| sed -e \"s@__PATH__@$$i@g\">>/etc/fstab; mount $$i;done",
      "echo ${self.hostname}",
      "echo \"export APP_STORAGE_HOST=${ibm_storage_file.data.hostname};export APP_VOLUME=${ibm_storage_file.data.volumename}/data01;export METRIC_STORAGE_HOST=${ibm_storage_file.metrics.hostname};export METRIC_VOLUME=${ibm_storage_file.metrics.volumename}/data01;export LOG_STORAGE_HOST=${ibm_storage_file.logs.hostname};export LOG_VOLUME=${ibm_storage_file.logs.volumename}/data01;export CERTS_STORAGE_HOST=${ibm_storage_file.certs.hostname};export CERTS_VOLUME=${ibm_storage_file.certs.volumename}/data01\" > /etc/profile.d/storage_path_env.sh ",
    ]
  }

  tags = ["${terraform.workspace}", "manager", "swarm"]
}
