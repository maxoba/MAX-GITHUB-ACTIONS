# s3
resource "aws_s3_bucket" "lagos" {
  bucket = "maxoba-${random_pet.bucket_name.id}-${random_integer.bucket_int.result}"

  tags = {
    Name        = "Lagos"
    Environment = "Dev"
  }
}

resource "random_pet" "bucket_name" {
  prefix = "max"
  length = 2
}

resource "random_integer" "bucket_int" {
  max = 500
  min = 1
}

resource "aws_sqs_queue" "queue" {
  name   = "s3-notification-queue"
  policy = data.aws_iam_policy_document.queue.json
}

