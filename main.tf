provider "aws" {
 region = "us-west-2"
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
