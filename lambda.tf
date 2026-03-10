 #IAM role for Lambda execution
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Package the Lambda function code
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/src/lambda.py"
  output_path = "${path.module}/src/lambda.py.zip"
}

# Lambda function
resource "aws_lambda_function" "test_lambda" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "lagos_lambda_function"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "lambda.lambda_handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime     = "python3.9"
  timeout     = 30
  memory_size = 1024
}

# SQS Queue
resource "aws_sqs_queue" "cc_queue" {
  name                      = "cc-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
}

# IAM Policy Document
data "aws_iam_policy_document" "cc_doc" {
  statement {
    sid    = "AllowLambdaCreateLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowLambdaToReadMessage"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [aws_sqs_queue.cc_queue.arn]
  }
}

# IAM Policy
resource "aws_iam_policy" "cc_policy" {
  name        = "lambda_sqs_policy"
  description = "IAM policy for sqs lambda"

  policy = data.aws_iam_policy_document.cc_doc.json
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "cc_sqs_lambda" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.cc_policy.arn
}

# Lambda Event Source Mapping (connects SQS to Lambda)
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.cc_queue.arn
  function_name    = aws_lambda_function.test_lambda.arn
  batch_size       = 10

  scaling_config {
    maximum_concurrency = 100
  }
}