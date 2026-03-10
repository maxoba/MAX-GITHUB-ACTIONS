provider "aws" {
 region = var.region
}

/*resource "aws_vpc" "test" {
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "action-test-vpc"
    env = "prod"
  }
}
*/
terraform {
  backend "s3" {
  bucket = "mybucketmaxoba"
  key = "github-action/terraform.tfstate"
  region = "us-west-2"
}
}
 variable "region"{
  type = string
  default = "us-west-2"
 }