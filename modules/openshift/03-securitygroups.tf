// This file contains all securitygroups for incoming/outgoing network traffic.

// Bastion host rules
resource "aws_security_group" "bastion_sg" {
  name        = "ose-bastion-sg"
  description = "Network traffic rules for the Bastion host"
  vpc_id      = "${aws_vpc.openshift.id}"

  ingress {
    description = "Allow SSH from internet to Bastion host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "ose-bastion-sg"
    Project = "openshift"
  }
}

// ETCD rules
resource "aws_security_group" "etcd_sg" {
  name        = "ose-etcd-sg"
  description = "Network traffic rules for the ETCD hosts"
  vpc_id      = "${aws_vpc.openshift.id}"

  ingress {
    description     = "Allow etcd traffic between etcd nodes"
    from_port       = 2379
    to_port         = 2380
    protocol        = "tcp"
    security_groups = ["${aws_security_group.etcd_sg.id}"]
  }

  ingress {
    description     = "Allow etcd traffic from master nodes"
    from_port       = 2379
    to_port         = 2379
    protocol        = "tcp"
    security_groups = ["${aws_security_group.master_sg.id}"]
  }

  tags {
    Name    = "ose-etcd-sg"
    Project = "openshift"
  }
}

// Infra nodes loadbalancer rules
resource "aws_security_group" "infra_elb_sg" {
  name        = "ose-router-sg"
  description = "Network traffic rules for the infra nodes ELB"
  vpc_id      = "${aws_vpc.openshift.id}"

  ingress {
    description = "Allow HTTP from internet to infra nodes"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from internet to infra nodes"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "ose-router-sg"
    Project = "openshift"
  }
}

// Master external loadbalancer rules
resource "aws_security_group" "master_ext_elb_sg" {
  name        = "ose-elb-master-sg"
  description = "Master external Loadbalancer"
  vpc_id      = "${aws_vpc.openshift.id}"

  ingress {
    description = "Allow external access to the Openshift Web Console"
    from_port   = "${var.master_api_port}"
    to_port     = "${var.master_api_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow access to the Openshift Web Console"
    from_port   = "${var.master_api_port}"
    to_port     = "${var.master_api_port}"
    protocol    = "tcp"
    security_groups = ["${aws_security_group.master_sg.id}"]
  }

  tags {
    Name    = "ose-elb-master-sg"
    Project = "openshift"
  }
}

// Master internal loadbalancer rules
resource "aws_security_group" "master_int_elb_sg" {
  name        = "ose-int-elb-master-sg"
  description = "Master internal Loadbalancer"
  vpc_id      = "${aws_vpc.openshift.id}"

  egress {
    description = "Allow API access to the master nodes"
    from_port   = "${var.master_api_port}"
    to_port     = "${var.master_api_port}"
    protocol    = "tcp"
    security_groups = ["${aws_security_group.master_sg.id}"]
  }

  egress {
    description = "Allow API access to the worker nodes"
    from_port   = "${var.master_api_port}"
    to_port     = "${var.master_api_port}"
    protocol    = "tcp"
    security_groups = ["${aws_security_group.node_sg.id}"]
  }

  tags {
    Name    = "ose-int-elb-master-sg"
    Project = "openshift"
  }
}

// Infra nodes rules
resource "aws_security_group" "infra_sg" {
  name        = "ose-infra-node-sg"
  description = "Infra nodes security group"
  vpc_id      = "${aws_vpc.openshift.id}"

  ingress {
    description     = "Allow HTTP traffic to infra nodes"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.infra_elb_sg.id}"]
  }

  ingress {
    description     = "Allow HTTPS traffic to infra nodes"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.infra_elb_sg.id}"]
  }

  egress {
    description     = "Allow HTTP traffic to infra nodes"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.infra_elb_sg.id}"]
  }

  egress {
    description     = "Allow Elasticsearch API traffic to infra nodes"
    from_port       = 9200
    to_port         = 9200
    protocol        = "tcp"
    security_groups = ["${aws_security_group.infra_elb_sg.id}"]
  }

  egress {
    description     = "Allow Elasticsearch Cluster traffic to infra nodes"
    from_port       = 9300
    to_port         = 9300
    protocol        = "tcp"
    security_groups = ["${aws_security_group.infra_elb_sg.id}"]
  }

  egress {
    description     = "Allow HTTPS traffic to infra nodes"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.infra_elb_sg.id}"]
  }

  tags {
    Name    = "ose-infra-node-sg"
    Project = "openshift"
  }
}

// Application/Worker nodes rules
resource "aws_security_group" "node_sg" {
  name        = "ose-node-sg"
  description = "Application/Worker nodes security group"
  vpc_id      = "${aws_vpc.openshift.id}"

  ingress {
    description     = "Allow traffic from master to kubelet on the node"
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = ["${aws_security_group.master_sg.id}"]
  }

  ingress {
    description     = "Allow Gluster traffic between the nodes"
    from_port       = 24007
    to_port         = 24007
    protocol        = "tcp"
    security_groups = ["${aws_security_group.node_sg.id}"]
  }

  ingress {
    description     = "Allow Gluster management traffic between the nodes"
    from_port       = 24008
    to_port         = 24008
    protocol        = "tcp"
    security_groups = ["${aws_security_group.node_sg.id}"]
  }

  ingress {
    description     = "Allow Gluster SSH traffic between the nodes"
    from_port       = 2222
    to_port         = 2222
    protocol        = "tcp"
    security_groups = ["${aws_security_group.node_sg.id}"]
  }

  ingress {
    description     = "Allow Gluster NFS traffic between the nodes"
    from_port       = 49152
    to_port         = 49664
    protocol        = "tcp"
    security_groups = ["${aws_security_group.node_sg.id}"]
  }

  ingress {
    description     = "Allow Kubelet traffic between the nodes"
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = ["${aws_security_group.node_sg.id}"]
  }

  ingress {
    description     = "Allow VXLAN between the nodes"
    from_port       = 4789
    to_port         = 4789
    protocol        = "udp"
    security_groups = ["${aws_security_group.node_sg.id}"]
  }

  ingress {
    description     = "Allow SSH to the nodes from Bastion host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion_sg.id}"]
  }

  tags {
    Name    = "ose-node-sg"
    Project = "openshift"
  }
}

// Master nodes rules
resource "aws_security_group" "master_sg" {
  name        = "ose-master-sg"
  description = "Master nodes security group"
  vpc_id      = "${aws_vpc.openshift.id}"

  ingress {
    description     = "Allow Openshift API / Web Console traffic from internal ELB to master nodes"
    from_port       = "${var.master_api_port}"
    to_port         = "${var.master_api_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.master_int_elb_sg.id}"]
  }

  ingress {
    description     = "Allow Openshift API / Web Console traffic from external ELB to master nodes"
    from_port       = "${var.master_api_port}"
    to_port         = "${var.master_api_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.master_ext_elb_sg.id}"]
  }

  ingress {
    description     = "Allow DNS TCP traffic from nodes to masters"
    from_port       = 8053
    to_port         = 8053
    protocol        = "tcp"
    security_groups = ["${aws_security_group.node_sg.id}"]
  }

  ingress {
    description     = "Allow DNS UDP traffic from nodes to masters"
    from_port       = 8053
    to_port         = 8053
    protocol        = "udp"
    security_groups = ["${aws_security_group.node_sg.id}"]
  }

  ingress {
    description     = "Allow Openshift API traffic from nodes to master nodes"
    from_port       = "${var.master_api_port}"
    to_port         = "${var.master_api_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.node_sg.id}"]
  }

  ingress {
    description     = "Allow logging TCP traffic from nodes to master nodes"
    from_port       = 24224
    to_port         = 24224
    protocol        = "tcp"
    security_groups = ["${aws_security_group.node_sg.id}"]
  }

  ingress {
    description     = "Allow logging UDP traffic from nodes to master nodes"
    from_port       = 24224
    to_port         = 24224
    protocol        = "udp"
    security_groups = ["${aws_security_group.node_sg.id}"]
  }

  ingress {
    description     = "Allow Openshift API traffic between the master nodes"
    from_port       = "${var.master_api_port}"
    to_port         = "${var.master_api_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.master_sg.id}"]
  }

  tags {
    Name    = "ose-master-sg"
    Project = "openshift"
  }
}
