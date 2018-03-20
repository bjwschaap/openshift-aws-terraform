// This file contains the resource definitions for the master nodes
resource "aws_instance" "master_nodes" {
  count                = 3
  ami                  = "${data.aws_ami.CentOS7.id}"
  instance_type        = "${var.master_instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.master_instance_profile.id}"
  subnet_id            = "${element(aws_subnet.public-subnets.*.id, count.index)}"
  key_name             = "${aws_key_pair.keypair.key_name}"
  user_data            = "${file("${path.module}/files/master_user_data.yml")}"
  security_groups      = [
    "${aws_security_group.node_sg.id}",
    "${aws_security_group.master_sg.id}",
    "${aws_security_group.etcd_sg.id}"
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
  // Disk for ETCD
  ebs_block_device     = {
    device_name           = "/dev/xvdc"
    delete_on_termination = true
    volume_size           = "25"
    volume_type           = "gp2"
  }
  // Disk for Logging
  ebs_block_device     = {
    device_name           = "/dev/xvdd"
    delete_on_termination = true
    volume_size           = "5"
    volume_type           = "gp2"
  }
  depends_on           = [
    "aws_iam_instance_profile.master_instance_profile",
    "aws_subnet.public-subnets"
  ]

  tags {
    Name              = "ose-master0${count.index + 1}.${data.aws_route53_zone.selected.name}"
    Project           = "openshift"
    openshift-role    = "master"
    KubernetesCluster = "${var.stackname}"
  }
}
