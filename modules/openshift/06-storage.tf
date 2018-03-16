// This file contains all S3 storage resources

resource "aws_s3_bucket" "registry_s3_bucket" {
  bucket = "${var.registry_s3_bucket_name}"
  acl    = "private"

  tags {
    Name        = "${var.registry_s3_bucket_name}"
    Project     = "openshift"
  }
}
