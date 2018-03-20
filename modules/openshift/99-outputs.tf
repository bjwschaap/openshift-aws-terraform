output "bastion-public_dns" {
  value = "${aws_instance.bastion_node.public_dns}"
}
output "bastion-public_ip" {
  value = "${aws_instance.bastion_node.public_ip}"
}
output "bastion-private_dns" {
  value = "${aws_instance.bastion_node.private_dns}"
}
output "bastion-private_ip" {
  value = "${aws_instance.bastion_node.private_ip}"
}
