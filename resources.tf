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

output "queue1_url" {
  value = aws_sqs_queue.example_queue1.id
}

output "queue2_url" {
  value = aws_sqs_queue.example_queue2.id
}
