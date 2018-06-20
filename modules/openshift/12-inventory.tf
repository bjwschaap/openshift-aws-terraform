//  Generates the inventory file needed by Ansible to perform the openshift
// installation.
data "template_file" "inventory" {
  template = "${file("${path.module}/files/inventory.template.cfg")}"

  vars {
    access_key           = "${aws_iam_access_key.openshift-aws-user.id}"
    secret_key           = "${aws_iam_access_key.openshift-aws-user.secret}"
    public_hostname      = "${aws_route53_record.openshift-master.name}"
    internal_hostname    = "${aws_route53_record.internal-openshift-master.name}"
    hosted_zone          = "${var.public_hosted_zone}"
    app_node_count       = "${var.app_node_count}"
    app_dns_prefix       = "${var.app_dns_prefix}"
    vpc_cidr             = "${var.vpc_cidr}"
    github_client_id     = "${var.github_client_id}"
    github_client_secret = "${var.github_client_secret}"
    github_organization  = "${var.github_organization}"
    registry_s3_bucket   = "${var.registry_s3_bucket_name}"
  }
}

//  Create the inventory.
resource "local_file" "inventory" {
  content     = "${data.template_file.inventory.rendered}"
  filename = "${path.cwd}/inventory.cfg"

  lifecycle {
    prevent_destroy = true
  }
}
