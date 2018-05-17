resource "ibm_storage_file" "metrics" {
  type            = "Endurance"
  datacenter      = "${var.datacenter}"
  capacity        = 50
  iops            = 4

  allowed_subnets = ["${data.ibm_network_vlan.private.subnets.0.subnet}"]
  hourly_billing  = true

  notes = "${var.project}.${terraform.workspace} - MetricsStorage"
    lifecycle         = {
        ignore_changes  = "*"
        prevent_destroy = true
    }
}

resource "ibm_storage_file" "logs" {
  type            = "Endurance"
  datacenter      = "${var.datacenter}"
  capacity        = 50
  iops            = 4

  allowed_subnets = ["${data.ibm_network_vlan.private.subnets.0.subnet}"]
  hourly_billing  = true

  notes = "${var.project}.${terraform.workspace} - AppLogsStorage"
    lifecycle         = {
        ignore_changes  = "*"
        prevent_destroy = true
    }
}

resource "ibm_storage_file" "certs" {
  type            = "Endurance"
  datacenter      = "${var.datacenter}"
  capacity        = 20
  iops            = 4

  allowed_subnets = ["${data.ibm_network_vlan.private.subnets.0.subnet}"]
  hourly_billing  = true

  notes = "${var.project}.${terraform.workspace} - Certs"
    lifecycle         = {
        ignore_changes  = "*"
        prevent_destroy = true
    }
}

resource "ibm_storage_file" "data" {
  type            = "Performance"
  datacenter      = "${var.datacenter}"
  capacity        = 80
  iops            = 200

  allowed_subnets = ["${data.ibm_network_vlan.private.subnets.0.subnet}"]
  hourly_billing  = true

  notes = "${var.project}.${terraform.workspace} - Application Storage"
    lifecycle         = {
        ignore_changes  = "*"
        prevent_destroy = true
    }
}
resource "null_resource" "storage_trigger" {
    triggers {
        metric_id  = "${ibm_storage_file.metrics.id}"
        logs_id    = "${ibm_storage_file.logs.id}"
        data_id    = "${ibm_storage_file.data.id}"
        certs_id   = "${ibm_storage_file.certs.id}"
        bastion_id = "${ibm_compute_vm_instance.bastion.id}"
    }

    provisioner "remote-exec" {
        inline = [
            "mount ${ibm_storage_file.metrics.mountpoint} /mnt",
            "echo '====== Metric Storage =====';sudo chmod 777 /mnt; fi umount /mnt",
            "mount ${ibm_storage_file.logs.mountpoint} /mnt",
            "echo '====== Logs Storage =====';sudo chmod 777 /mnt;fi umount /mnt",
            "mount ${ibm_storage_file.data.mountpoint} /mnt",
            "echo '====== Data Storage =====';if [ -d /mnt/app ];then echo \"=> The directory has existed.\";else sudo mkdir /mnt/app;sudo chmod 777 /mnt/app;echo \"app directory created.\";fi",
            "echo '====== PSQL Storage =====';if [ -d /mnt/data/postgresql ];then echo \"=> The directory has existed.\";else sudo mkdir -p /mnt/data/postgresql;sudo chmod 777 /mnt/data/postgresql;echo \"PSQL directory created.\";fi",
            "echo '====== Fabric Kafka Storage(TMP) =====';if [ -d /mnt/fabric/kafka ];then echo \"=> The directory has existed.\";else sudo mkdir -p /mnt/fabric/kafka;sudo chmod 777 /mnt/fabric/kafka;echo \"Kafka directory created.\";fi",
            "echo '====== Fabric Orderer Storage(TMP) =====';if [ -d /mnt/fabric/orderer ];then echo \"=> The directory has existed.\";else sudo mkdir -p /mnt/fabric/orderer;sudo chmod 777 /mnt/fabric/orderer;echo \"Orderer directory created.\";fi",
            "echo '====== Fabric Kafka Storage(TMP) =====';if [ -d /mnt/fabric/peer ];then echo \"=> The directory has existed.\";else sudo mkdir -p /mnt/fabric/peer;sudo chmod 777 /mnt/fabric/peer;echo \"Peer directory created.\";fi",
            "umount /mnt"
        ]
        connection {
            type        = "ssh"
            user        = "root"
            host        = "${ibm_compute_vm_instance.bastion.ipv4_address}"
            private_key = "${file("${path.root}${var.rsa_key_bastion["private_key_path"]}")}"
        }
    }
}
