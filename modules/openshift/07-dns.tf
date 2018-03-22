// This file contains all DNS (Route53) resources

data "aws_route53_zone" "selected" {
  name         = "${var.public_hosted_zone}."
}

// Record pointing to the external ELB for the Openshift Masters
resource "aws_route53_record" "openshift-master" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "openshift-master.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.master_ext_elb.dns_name}"
    zone_id                = "${aws_elb.master_ext_elb.zone_id}"
    evaluate_target_health = true
  }
}

// Record pointing to the internal ELB for the Openshift Masters
resource "aws_route53_record" "internal-openshift-master" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "internal-openshift-master.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.master_int_elb.dns_name}"
    zone_id                = "${aws_elb.master_int_elb.zone_id}"
    evaluate_target_health = true
  }
}

// Record  for the application wildcard domain, pointing to the ELB for the Openshift Infra nodes
resource "aws_route53_record" "app_wildcard" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "*.${var.app_dns_prefix}.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.infra_elb.dns_name}"
    zone_id                = "${aws_elb.infra_elb.zone_id}"
    evaluate_target_health = true
  }
}

// Records for master nodes
resource "aws_route53_record" "master_nodes" {
  count   = 3
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "ose-master0${count.index + 1}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = 300
  records = ["${element(aws_instance.master_nodes.*.private_ip, count.index)}"]
}

// Records for Infra nodes
resource "aws_route53_record" "infra_nodes" {
  count   = 3
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "ose-infra-node0${count.index + 1}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = 300
  records = ["${element(aws_instance.infra_nodes.*.private_ip, count.index)}"]
}

// Records for the app/worker nodes
resource "aws_route53_record" "app_nodes" {
  count   = 3
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "ose-app-node0${count.index + 1}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = 300
  records = ["${element(aws_instance.infra_nodes.*.private_ip, count.index)}"]
}

// Record for the Bastion host
resource "aws_route53_record" "bastion_node" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "bastion.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = 300
  records = ["${aws_eip.bastion.public_ip}"]
}
