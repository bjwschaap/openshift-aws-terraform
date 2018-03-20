//  Generates the inventory file needed by Ansible to perform the openshift
// installation.
data "template_file" "inventory" {
  template = "${file("${path.module}/files/inventory.template.cfg")}"

  vars {
    access_key      = "${aws_iam_access_key.openshift-aws-user.id}"
    secret_key      = "${aws_iam_access_key.openshift-aws-user.secret}"
    public_hostname = "${aws_route53_record.openshift-master.name}"
    hosted_zone     = "${var.public_hosted_zone}"
    app_node_count  = "${var.app_node_count}"
  }
}

//  Create the inventory.
resource "local_file" "inventory" {
  content     = "${data.template_file.inventory.rendered}"
  filename = "${path.cwd}/inventory.cfg"
}
