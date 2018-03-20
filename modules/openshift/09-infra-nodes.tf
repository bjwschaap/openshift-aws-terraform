// This file contains the definition of the Openshift infestructure nodes
resource "aws_instance" "infra_nodes" {
  count                = 3
  ami                  = "${data.aws_ami.CentOS7.id}"
  instance_type        = "${var.node_instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.node_instance_profile.id}"
  subnet_id            = "${element(aws_subnet.private-subnets.*.id, count.index)}"
  key_name             = "${aws_key_pair.keypair.key_name}"
  user_data            = "${file("${path.module}/files/node_user_data.yml")}"
  security_groups      = [
    "${aws_security_group.node_sg.id}",
    "${aws_security_group.infra_sg.id}"
  ]
  ebs_block_device     = {
    device_name           = "/dev/sda1"
    delete_on_termination = true
    volume_size           = "50"
    volume_type           = "gp2"
  }
  // Disk for Docker images and volumes
  ebs_block_device     = {
    device_name           = "/dev/xvdb"
    delete_on_termination = true
    volume_size           = "25"
    volume_type           = "gp2"
  }
  // Disk for Openshift volumes
  ebs_block_device     = {
    device_name           = "/dev/xvdc"
    delete_on_termination = true
    volume_size           = "50"
    volume_type           = "gp2"
  }
  depends_on           = [
    "aws_iam_instance_profile.node_instance_profile",
    "aws_subnet.private-subnets"
  ]

  tags {
    Name              = "ose-infra-node0${count.index + 1}.${data.aws_route53_zone.selected.name}"
    Project           = "openshift"
    openshift-role    = "infra"
    KubernetesCluster = "${var.stackname}"
  }
}