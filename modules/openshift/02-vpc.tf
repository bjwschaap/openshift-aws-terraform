// This file defines all VPC specific settings like subnets, gateways and
// routing tables.

//  Define the VPC.
resource "aws_vpc" "openshift" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name    = "${var.vpc_name}"
    Project = "openshift"
  }
}

// Create the DHCP options
resource "aws_vpc_dhcp_options" "openshift" {
  domain_name         = "ec2.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name = "${var.vpc_name}-dopt"
    Project = "openshift"
  }
}

// Associate the DHCP options with the VPC
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.openshift.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.openshift.id}"
}

//  Create an Internet Gateway for the public subnets in the VPC.
resource "aws_internet_gateway" "openshift" {
  vpc_id = "${aws_vpc.openshift.id}"

  tags {
    Name    = "${var.vpc_name}-igw"
    Project = "openshift"
  }
}

//  Create the public subnets.
resource "aws_subnet" "public-subnets" {
  count                   = 3
  vpc_id                  = "${aws_vpc.openshift.id}"
  cidr_block              = "${element(var.public_subnet_cidr_list, count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.openshift"]

  tags {
    Name              = "ose-public_subnet-${count.index + 1}"
    Project           = "openshift"
    KubernetesCluster = "${var.stackname}"
  }
}

//  Create a route table allowing all subnets to access to the IGW.
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.openshift.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.openshift.id}"
  }

  tags {
    Name    = "${var.vpc_name}-public-rt"
    Project = "openshift"
  }
}

//  Now associate the route table with the public subnets - giving
//  all public subnet instances access to the internet.
resource "aws_route_table_association" "public-subnets" {
  count          = 3
  subnet_id      = "${element(aws_subnet.public-subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
  depends_on     = ["aws_subnet.public-subnets"]
}

// Create an Elastic IP and let the NAT gateway use it
// to allow the private subnets to go to the internet
resource "aws_eip" "openshift_nat" {
  vpc    = true

  tags {
    Name    = "${var.vpc_name}-nat-eip"
    Project = "openshift"
  }
}

// Create a NAT gateway for the private subnets in the VPC. Just use the
// first public subnet to bind to.
resource "aws_nat_gateway" "openshift" {
  subnet_id     = "${aws_subnet.public-subnets.0.id}"
  allocation_id = "${aws_eip.openshift_nat.id}"

  tags {
    Name    = "${var.vpc_name}-ngw"
    Project = "openshift"
  }
}

//  Create the private subnets.
resource "aws_subnet" "private-subnets" {
  count                   = 3
  vpc_id                  = "${aws_vpc.openshift.id}"
  cidr_block              = "${element(var.private_subnet_cidr_list, count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  depends_on              = ["aws_nat_gateway.openshift"]

  tags {
    Name              = "ose-private_subnet-${count.index + 1}"
    Project           = "openshift"
    KubernetesCluster = "${var.stackname}"
  }
}

// The private routing table, directing traffic through the NAT gateway
resource "aws_route_table" "private" {
  vpc_id     = "${aws_vpc.openshift.id}"
  depends_on = ["aws_nat_gateway.openshift"]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.openshift.id}"
  }

  tags {
    Name    = "${var.vpc_name}-private-rt"
    Project = "openshift"
  }
}

//  Now associate the private route table with the private subnets - giving
//  all private subnet instances access to the NAT gateway.
resource "aws_route_table_association" "private-subnets" {
  count          = 3
  subnet_id      = "${element(aws_subnet.private-subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
  depends_on     = ["aws_subnet.private-subnets"]
}
