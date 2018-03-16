// Default region where to create our cluster
variable "region" {
  description = "The region where the cluster must be created"
  default = "eu-west-1"
}

// The name we should use for our cluster, and base our resource names on
variable "stackname" {
  description = "The name to use for the created cluster"
  default = "openshift"
}

//  The public key to use for SSH access.
variable "public_key_path" {
  default = "~/.ssh/ose-key.pub"
}
