# This module for genernate the ssh config file on the fly.
module "script" {
  source = "github.com/lancekuo/tf-tools"

  project     = "${var.project}"
  region      = ""
  bucket_name = ""
  filename    = "terraform.tfstate"
  s3-region   = ""
  node_list   = "${join(",",ibm_compute_vm_instance.manager.*.id)}"

  enable_s3_backend = false
  isIBM             = true
}
