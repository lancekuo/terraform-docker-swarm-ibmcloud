variable "metric_mount_point" {
    default = "/opt/prometheus"
}
variable "logs_mount_point" {
    default = "/opt/elasticsearch"
}
resource "ibm_storage_file" "metrics" {
  type       = "Endurance"
  datacenter = "${var.datacenter}"
  capacity   = 50
  iops       = 4

  allowed_subnets           = ["${data.ibm_network_vlan.private.subnets.0}"]
  hourly_billing            = true

  notes = "MetricsStorage"
    lifecycle         = {
        ignore_changes  = "*"
        prevent_destroy = true
    }
}

resource "ibm_storage_file" "logs" {
  type       = "Endurance"
  datacenter = "${var.datacenter}"
  capacity   = 50
  iops       = 4

  allowed_subnets           = ["${data.ibm_network_vlan.private.subnets.0}"]
  hourly_billing            = true

  notes = "AppLogsStorage"
    lifecycle         = {
        ignore_changes  = "*"
        prevent_destroy = true
    }
}

resource "null_resource" "metrics_trigger" {
    triggers {
        file_id = "${ibm_storage_file.metrics.id}"
        manager_id = "${element(ibm_compute_vm_instance.manager.*.id,1)}"
    }

    provisioner "remote-exec" {
        inline = [
            "echo '====== Creating Mount point =====';if [ -d ${var.metric_mount_point} ];then echo \"=> The mount endpoint has existed.\";else sudo mkdir ${var.metric_mount_point};sudo chmod 777 ${var.metric_mount_point};echo \"Mount point created.\";fi",
            "echo '====== Updating fstab file =====';if ! grep -e \"${var.metric_mount_point}\" /etc/fstab 1> /dev/null;then echo \"${ibm_storage_file.metrics.mountpoint} ${var.metric_mount_point}    nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0\"| sudo tee -a /etc/fstab;else echo '=> Fstab has updated, no change in this step...'; fi ",
            "mount ${var.metric_mount_point}",
        ]
        connection {
            bastion_host        = "${ibm_compute_vm_instance.bastion.ipv4_address}"
            bastion_user        = "root"
            bastion_private_key = "${file("${path.root}${var.rsa_key_bastion["private_key_path"]}")}"

            type                = "ssh"
            user                = "root"
            host                = "${ibm_compute_vm_instance.manager.1.ipv4_address_private}"
            private_key         = "${file("${path.root}${var.rsa_key_manager["private_key_path"]}")}"
        }
    }
  }
resource "null_resource" "logs_trigger" {
    triggers {
        file_id = "${ibm_storage_file.logs.id}"
        manager_id = "${element(ibm_compute_vm_instance.manager.*.id,1)}"
    }

    provisioner "remote-exec" {
        inline = [
            "echo '====== Creating Mount point =====';if [ -d ${var.logs_mount_point} ];then echo \"=> The mount endpoint has existed.\";else sudo mkdir ${var.logs_mount_point};sudo chmod 777 ${var.logs_mount_point};echo \"Mount point created.\";fi",
            "echo '====== Updating fstab file =====';if ! grep -e \"${var.logs_mount_point}\" /etc/fstab 1> /dev/null;then echo \"${ibm_storage_file.logs.mountpoint} ${var.logs_mount_point}    nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0\"| sudo tee -a /etc/fstab;else echo '=> Fstab has updated, no change in this step...'; fi ",
            "mount ${var.logs_mount_point}",
        ]
        connection {
            bastion_host        = "${ibm_compute_vm_instance.bastion.ipv4_address}"
            bastion_user        = "root"
            bastion_private_key = "${file("${path.root}${var.rsa_key_bastion["private_key_path"]}")}"

            type                = "ssh"
            user                = "root"
            host                = "${ibm_compute_vm_instance.manager.1.ipv4_address_private}"
            private_key         = "${file("${path.root}${var.rsa_key_manager["private_key_path"]}")}"
        }
    }
  }
