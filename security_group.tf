resource "ibm_security_group" "nat_pub" {
  name        = "${var.project}.${terraform.workspace}-nat-public"
  description = "Allow ssh and ICMP to the nat machine in public network"
}

resource "ibm_security_group_rule" "nat_pub_i_ICMP" {
  direction         = "ingress"
  protocol          = "icmp"
  security_group_id = "${ibm_security_group.nat_pub.id}"
}

resource "ibm_security_group_rule" "nat_pub_i_ssh" {
  direction         = "ingress"
  port_range_min    = 22
  port_range_max    = 22
  protocol          = "tcp"
  remote_group_id   = "${ibm_security_group.bastion_pvt.id}"
  security_group_id = "${ibm_security_group.nat_pub.id}"
}

resource "ibm_security_group_rule" "nat_pub_e_TCP" {
  direction         = "egress"
  port_range_min    = 1
  port_range_max    = 65535
  protocol          = "tcp"
  remote_ip         = "0.0.0.0/0"
  security_group_id = "${ibm_security_group.nat_pub.id}"
}

# resource "ibm_network_interface_sg_attachment" "nat_pub" {
#     security_group_id    = "${ibm_security_group.nat_pub.id}"
#     network_interface_id = "${ibm_compute_vm_instance.nat.public_interface_id}"
# }

###
resource "ibm_security_group" "nat_pvt" {
  name        = "${var.project}.${terraform.workspace}-nat-private"
  description = "Allow TCP and ICMP procotol in and out to the private network of NAT machine"
}

resource "ibm_security_group_rule" "nat_pvt_i_ICMP" {
  direction         = "ingress"
  protocol          = "icmp"
  security_group_id = "${ibm_security_group.nat_pvt.id}"
}

resource "ibm_security_group_rule" "nat_pvt_i_TCP" {
  direction         = "ingress"
  port_range_min    = 1
  port_range_max    = 65535
  protocol          = "tcp"
  remote_ip         = "0.0.0.0/0"
  security_group_id = "${ibm_security_group.nat_pvt.id}"
}

resource "ibm_security_group_rule" "nat_pvt_e_ICMP" {
  direction         = "egress"
  protocol          = "icmp"
  security_group_id = "${ibm_security_group.nat_pvt.id}"
}

resource "ibm_security_group_rule" "nat_pvt_e_TCP" {
  direction         = "egress"
  port_range_min    = 1
  port_range_max    = 65535
  protocol          = "tcp"
  remote_ip         = "0.0.0.0/0"
  security_group_id = "${ibm_security_group.nat_pvt.id}"
}

# resource "ibm_network_interface_sg_attachment" "nat_pvt" {
#     security_group_id    = "${ibm_security_group.nat_pvt.id}"
#     network_interface_id = "${ibm_compute_vm_instance.nat.private_interface_id}"
# }

resource "ibm_security_group" "bastion_pub" {
  name        = "${var.project}.${terraform.workspace}-bastion-public"
  description = "Allow ssh and ICMP to the bastion machine in public network"
}

resource "ibm_security_group_rule" "bastion_pub_i_ICMP" {
  direction         = "ingress"
  protocol          = "icmp"
  security_group_id = "${ibm_security_group.bastion_pub.id}"
}

resource "ibm_security_group_rule" "bastion_pub_i_ssh" {
  direction      = "ingress"
  port_range_min = 22
  port_range_max = 22
  protocol       = "tcp"

  # remote_ip         = "99.230.139.175/32"
  remote_ip         = "0.0.0.0/0"
  security_group_id = "${ibm_security_group.bastion_pub.id}"
}

resource "ibm_security_group_rule" "bastion_pub_e_TCP" {
  direction         = "egress"
  port_range_min    = 1
  port_range_max    = 65535
  protocol          = "tcp"
  remote_ip         = "0.0.0.0/0"
  security_group_id = "${ibm_security_group.bastion_pub.id}"
}

# resource "ibm_network_interface_sg_attachment" "bastion_pub" {
#     security_group_id    = "${ibm_security_group.bastion_pub.id}"
#     network_interface_id = "${ibm_compute_vm_instance.bastion.public_interface_id}"
# }

###
resource "ibm_security_group" "bastion_pvt" {
  name        = "${var.project}.${terraform.workspace}-bastion-private"
  description = "Allow TCP and ICMP procotol in and out to the private network of Bastion machine"
}

resource "ibm_security_group_rule" "bastion_pvt_i_ICMP" {
  direction         = "ingress"
  protocol          = "icmp"
  security_group_id = "${ibm_security_group.bastion_pvt.id}"
}

resource "ibm_security_group_rule" "bastion_pvt_i_TCP" {
  direction         = "ingress"
  port_range_min    = 1
  port_range_max    = 65535
  protocol          = "tcp"
  remote_ip         = "0.0.0.0/0"
  security_group_id = "${ibm_security_group.bastion_pvt.id}"
}

resource "ibm_security_group_rule" "bastion_pvt_e_ICMP" {
  direction         = "egress"
  protocol          = "icmp"
  security_group_id = "${ibm_security_group.bastion_pvt.id}"
}

resource "ibm_security_group_rule" "bastion_pvt_e_TCP" {
  direction         = "egress"
  port_range_min    = 1
  port_range_max    = 65535
  protocol          = "tcp"
  remote_ip         = "0.0.0.0/0"
  security_group_id = "${ibm_security_group.bastion_pvt.id}"
}

# resource "ibm_network_interface_sg_attachment" "bastion_pvt" {
#     security_group_id    = "${ibm_security_group.bastion_pvt.id}"
#     network_interface_id = "${ibm_compute_vm_instance.bastion.private_interface_id}"
# }

####
resource "ibm_security_group" "manager_pvt" {
  name        = "${var.project}.${terraform.workspace}-manager"
  description = "Open ssh, ICMP, and docker api port to access swarm manager internally"
}

resource "ibm_security_group_rule" "manager_pvt_i_ICMP" {
  direction         = "ingress"
  protocol          = "icmp"
  security_group_id = "${ibm_security_group.manager_pvt.id}"
}

resource "ibm_security_group_rule" "manager_pvt_ssh" {
  direction         = "ingress"
  port_range_min    = 22
  port_range_max    = 22
  protocol          = "tcp"
  remote_group_id   = "${ibm_security_group.bastion_pvt.id}"
  security_group_id = "${ibm_security_group.manager_pvt.id}"
}

resource "ibm_security_group_rule" "manager_pvt_docker_api" {
  direction         = "ingress"
  port_range_min    = 2375
  port_range_max    = 2376
  protocol          = "tcp"
  remote_group_id   = "${ibm_security_group.bastion_pvt.id}"
  security_group_id = "${ibm_security_group.manager_pvt.id}"
}

resource "ibm_security_group_rule" "manager_pvt_e_ICMP" {
  direction         = "egress"
  protocol          = "icmp"
  security_group_id = "${ibm_security_group.manager_pvt.id}"
}

resource "ibm_security_group_rule" "manager_pvt_e_TCP" {
  direction         = "egress"
  port_range_min    = 1
  port_range_max    = 65535
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.manager_pvt.id}"
}

resource "ibm_security_group_rule" "manager_pvt_e_UDP" {
  direction         = "egress"
  port_range_min    = 1
  port_range_max    = 65535
  protocol          = "udp"
  security_group_id = "${ibm_security_group.manager_pvt.id}"
}

# resource "ibm_network_interface_sg_attachment" "prv_swarm_manager" {
#     count                = "${var.manager_count}"
#     security_group_id    = "${ibm_security_group.manager_pvt.id}"
#     network_interface_id = "${element(ibm_compute_vm_instance.manager.*.private_interface_id, count.index)}"
# }
resource "ibm_security_group" "manager_services" {
  name        = "${var.project}.${terraform.workspace}-services"
  description = "Open port for managers in order to access internal apps."
}
resource "ibm_security_group_rule" "manager_services_kibana" {
  direction         = "ingress"
  port_range_min    = 5601
  port_range_max    = 5601
  protocol          = "tcp"
  remote_ip         = "0.0.0.0/0"
  security_group_id = "${ibm_security_group.manager_services.id}"
}
resource "ibm_security_group_rule" "manager_services_grafana" {
  direction         = "ingress"
  port_range_min    = 3000
  port_range_max    = 3000
  protocol          = "tcp"
  remote_ip         = "0.0.0.0/0"
  security_group_id = "${ibm_security_group.manager_services.id}"
}

####
resource "ibm_security_group" "node_pvt" {
  name        = "${var.project}.${terraform.workspace}-node"
  description = "Open ssh, ICMP to access swarm node"
}

resource "ibm_security_group_rule" "node_pvt_i_ICMP" {
  direction         = "ingress"
  protocol          = "icmp"
  security_group_id = "${ibm_security_group.node_pvt.id}"
}

resource "ibm_security_group_rule" "node_pvt_ssh" {
  direction         = "ingress"
  port_range_min    = 22
  port_range_max    = 22
  protocol          = "tcp"
  remote_group_id   = "${ibm_security_group.bastion_pvt.id}"
  security_group_id = "${ibm_security_group.node_pvt.id}"
}

resource "ibm_security_group_rule" "node_pvt_docker_api" {
  direction         = "ingress"
  port_range_min    = 2375
  port_range_max    = 2377
  protocol          = "tcp"
  remote_group_id   = "${ibm_security_group.bastion_pvt.id}"
  security_group_id = "${ibm_security_group.node_pvt.id}"
}

resource "ibm_security_group_rule" "node_pvt_e_ICMP" {
  direction         = "egress"
  protocol          = "icmp"
  security_group_id = "${ibm_security_group.node_pvt.id}"
}

resource "ibm_security_group_rule" "node_pvt_e_TCP" {
  direction         = "egress"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.node_pvt.id}"
}
resource "ibm_security_group_rule" "node_pvt_e_UDP" {
  direction         = "egress"
  protocol          = "udp"
  security_group_id = "${ibm_security_group.node_pvt.id}"
}

####
resource "ibm_security_group" "docker-gossip" {
  name        = "${var.project}.${terraform.workspace}-docker-gossip"
  description = "Docker gossip channel"
}

resource "ibm_security_group_rule" "docker_gossip_0_tcp" {
  direction         = "ingress"
  port_range_min    = 2375
  port_range_max    = 2377
  protocol          = "tcp"
  remote_group_id   = "${ibm_security_group.docker-gossip.id}"
  security_group_id = "${ibm_security_group.docker-gossip.id}"
}

resource "ibm_security_group_rule" "docker_gossip_1_tcp" {
  direction         = "ingress"
  port_range_min    = 4789
  port_range_max    = 4790
  protocol          = "tcp"
  remote_group_id   = "${ibm_security_group.docker-gossip.id}"
  security_group_id = "${ibm_security_group.docker-gossip.id}"
}

resource "ibm_security_group_rule" "docker_gossip_1_udp" {
  direction         = "ingress"
  port_range_min    = 4789
  port_range_max    = 4790
  protocol          = "udp"
  remote_group_id   = "${ibm_security_group.docker-gossip.id}"
  security_group_id = "${ibm_security_group.docker-gossip.id}"
}

resource "ibm_security_group_rule" "docker_gossip_2_tcp" {
  direction         = "ingress"
  port_range_min    = 7946
  port_range_max    = 7946
  protocol          = "tcp"
  remote_group_id   = "${ibm_security_group.docker-gossip.id}"
  security_group_id = "${ibm_security_group.docker-gossip.id}"
}

resource "ibm_security_group_rule" "docker_gossip_2_udp" {
  direction         = "ingress"
  port_range_min    = 7946
  port_range_max    = 7946
  protocol          = "udp"
  remote_group_id   = "${ibm_security_group.docker-gossip.id}"
  security_group_id = "${ibm_security_group.docker-gossip.id}"
}

# resource "ibm_network_interface_sg_attachment" "node_pvt" {
#     count                = "${var.node_count}"
#     security_group_id    = "${ibm_security_group.node_pvt.id}"
#     network_interface_id = "${element(ibm_compute_vm_instance.node.*.private_interface_id, count.index)}"
# }

#### Those security groups below are for Fabric Network and it should be moved to the terraform script for Fabric one.
resource "ibm_security_group" "fabric_network" {
  name        = "${var.project}.${terraform.workspace}-fabric-network"
  description = "Security group for Hyperledger Fabric network"
}

resource "ibm_security_group_rule" "zookeeper_tcp" {
  direction         = "ingress"
  port_range_min    = 2181
  port_range_max    = 3888
  protocol          = "tcp"
  remote_group_id   = "${ibm_security_group.fabric_network.id}"
  security_group_id = "${ibm_security_group.fabric_network.id}"
}
