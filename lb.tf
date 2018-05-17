resource "ibm_lbaas" "kibana" {
    name        = "kibana.${var.project}.${terraform.workspace}.${var.domain}"
    description = "${var.project}.${terraform.workspace}.${var.domain} Kibana Portal"
    subnets     = ["${var.vlan_subnets_private[terraform.workspace]}"]

    protocols = [
    {
        frontend_protocol     = "TCP"
        frontend_port         = 80
        backend_protocol      = "TCP"
        backend_port          = 5601
        load_balancing_method = "round_robin"
    },
    ]
}
resource "ibm_lbaas_server_instance_attachment" "kibana" {
    count              = "${var.manager_count}"
    private_ip_address = "${element(ibm_compute_vm_instance.manager.*.ipv4_address_private, count.index)}"
    weight             = 50
    lbaas_id           = "${ibm_lbaas.kibana.id}"
}

resource "ibm_lbaas" "grafana" {
    name        = "grafana.${var.project}.${terraform.workspace}.${var.domain}"
    description = "${var.project}.${terraform.workspace}.${var.domain} Grafana Portal"
    subnets     = ["${var.vlan_subnets_private[terraform.workspace]}"]

    protocols = [
    {
        frontend_protocol     = "TCP"
        frontend_port         = 80
        backend_protocol      = "TCP"
        backend_port          = 3000
        load_balancing_method = "round_robin"
    },
    ]
}
resource "ibm_lbaas_server_instance_attachment" "grafana" {
    count              = "${var.manager_count}"
    private_ip_address = "${element(ibm_compute_vm_instance.manager.*.ipv4_address_private, count.index)}"
    weight             = 50
    lbaas_id           = "${ibm_lbaas.grafana.id}"
}

resource "ibm_lbaas" "project" {
    name        = "${var.project}.${terraform.workspace}.${var.domain}"
    description = "${var.project}.${terraform.workspace}.${var.domain} Application"
    subnets     = ["${var.vlan_subnets_private[terraform.workspace]}"]

    protocols = [
    {
        frontend_protocol     = "TCP"
        frontend_port         = 80
        backend_protocol      = "TCP"
        backend_port          = 80
        load_balancing_method = "round_robin"
    },
    {
        frontend_protocol     = "TCP"
        frontend_port         = 443
        backend_protocol      = "TCP"
        backend_port          = 443
        load_balancing_method = "round_robin"
    },
    ]
}
resource "ibm_lbaas_server_instance_attachment" "project" {
    count              = "${var.node_count}"
    private_ip_address = "${element(ibm_compute_vm_instance.node.*.ipv4_address_private, count.index)}"
    weight             = 50
    lbaas_id           = "${ibm_lbaas.project.id}"
}
