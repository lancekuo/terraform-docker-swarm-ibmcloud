resource "ibm_lbaas" "kibana" {
    name        = "kibana.${var.project}.${terraform.workspace}.${var.domain}"
    description = "Load balancer for Kibana"
    subnets     = ["${var.primary_subnet}"]

    protocols = [
    # {
    #     frontend_protocol     = "HTTPS"
    #     frontend_port         = 443
    #     backend_protocol      = "HTTP"
    #     backend_port          = 80
    #     load_balancing_method = "round_robin"
    #     tls_certificate_id    = 11670
    # },
    {
        frontend_protocol     = "HTTP"
        frontend_port         = 80
        backend_protocol      = "HTTP"
        backend_port          = 5601
        load_balancing_method = "round_robin"
    },
    ]

    server_instances = [
      {
        "private_ip_address" = "${ibm_compute_vm_instance.manager.0.ipv4_address_private}"
      },
      {
        "private_ip_address" = "${ibm_compute_vm_instance.manager.1.ipv4_address_private}"
      },
      {
        "private_ip_address" = "${ibm_compute_vm_instance.manager.2.ipv4_address_private}"
      },
    ]
}
resource "ibm_lbaas" "grafana" {
    name        = "grafana.${var.project}.${terraform.workspace}.${var.domain}"
    description = "Load balancer for Grafana"
    subnets     = ["${var.primary_subnet}"]

    protocols = [
    # {
    #     frontend_protocol     = "HTTPS"
    #     frontend_port         = 443
    #     backend_protocol      = "HTTP"
    #     backend_port          = 80
    #     load_balancing_method = "round_robin"
    #     tls_certificate_id    = 11670
    # },
    {
        frontend_protocol     = "HTTP"
        frontend_port         = 80
        backend_protocol      = "HTTP"
        backend_port          = 3000
        load_balancing_method = "round_robin"
    },
    ]

    server_instances = [
      {
        "private_ip_address" = "${ibm_compute_vm_instance.manager.0.ipv4_address_private}"
      },
      {
        "private_ip_address" = "${ibm_compute_vm_instance.manager.1.ipv4_address_private}"
      },
      {
        "private_ip_address" = "${ibm_compute_vm_instance.manager.2.ipv4_address_private}"
      },
    ]
}

resource "ibm_lbaas" "lbaas" {
    name        = "${var.project}.${terraform.workspace}.${var.domain}"
    description = "Load balancer for ${var.project}"
    subnets     = ["${var.primary_subnet}"]

    protocols = [
    # {
    #     frontend_protocol     = "HTTPS"
    #     frontend_port         = 443
    #     backend_protocol      = "HTTP"
    #     backend_port          = 80
    #     load_balancing_method = "round_robin"
    #     tls_certificate_id    = 11670
    # },
    {
        frontend_protocol     = "HTTP"
        frontend_port         = 80
        backend_protocol      = "HTTP"
        backend_port          = 80
        load_balancing_method = "round_robin"
    },
    ]

    server_instances = [
      {
        "private_ip_address" = "${ibm_compute_vm_instance.node.0.ipv4_address_private}"
      },
      {
        "private_ip_address" = "${ibm_compute_vm_instance.node.1.ipv4_address_private}"
      },
      {
        "private_ip_address" = "${ibm_compute_vm_instance.node.2.ipv4_address_private}"
      },
      {
        "private_ip_address" = "${ibm_compute_vm_instance.node.3.ipv4_address_private}"
      },
    ]
}

