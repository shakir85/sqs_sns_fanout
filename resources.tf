provider "aws" {
  region = "us-east-1"
}

resource "aws_sns_topic" "example_topic" {
  name = "example-topic"
}

resource "aws_sqs_queue" "example_queue1" {
  name = "example-queue1"
}

resource "aws_sqs_queue" "example_queue2" {
  name = "example-queue2"
}

resource "aws_sns_topic_subscription" "queue1_subscription" {
  topic_arn = aws_sns_topic.example_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.example_queue1.arn
}

resource "aws_sns_topic_subscription" "queue2_subscription" {
  topic_arn = aws_sns_topic.example_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.example_queue2.arn
}

resource "aws_iam_policy" "sqs_sns_policy" {
  name = "sqs-sns-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "SQS:ReceiveMessage",
          "SQS:DeleteMessage",
          "SQS:GetQueueAttributes",
        ],
        Effect = "Allow",
        Resource = aws_sqs_queue.example_queue1.arn,
      },
      {
        Action = "sns:Publish",
        Effect = "Allow",
        Resource = aws_sns_topic.example_topic.arn,
      },
    ],
  })
}

resource "aws_iam_role" "sqs_sns_role" {
  name = "sqs-sns-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "sqs.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "sqs_sns_attachment" {
  policy_arn = aws_iam_policy.sqs_sns_policy.arn
  role       = aws_iam_role.sqs_sns_role.name
}

output "queue1_url" {
  value = aws_sqs_queue.example_queue1.id
}

output "queue2_url" {
  value = aws_sqs_queue.example_queue2.id
}
