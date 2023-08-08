import boto3
import time

# Initialize AWS clients
sns_client = boto3.client('sns')
sqs_client = boto3.client('sqs')

# Replace with SNS topic ARN and SQS queue URLs (see TF outputs)
sns_topic_arn = 'sns-topic-arn'
sqs_queue_url1 = 'sqs-queue-url1'
sqs_queue_url2 = 'sqs-queue-url2'

# Subscribe SQS queues to the SNS topic
def subscribe_sqs_to_sns(sns_topic_arn, sqs_queue_url):
    response = sns_client.subscribe(
        TopicArn=sns_topic_arn,
        Protocol='sqs',
        Endpoint=sqs_queue_url
    )
    print("Subscribed SQS queue to SNS:", response['SubscriptionArn'])

# Process messages from SQS queues
def process_queue(queue_url):
    while True:
        response = sqs_client.receive_message(
            QueueUrl=queue_url,
            MaxNumberOfMessages=1
        )

        if 'Messages' in response:
            for message in response['Messages']:
                print("Received message from SQS:", message['Body'])

                # Delete the message to remove it from the queue
                sqs_client.delete_message(
                    QueueUrl=queue_url,
                    ReceiptHandle=message['ReceiptHandle']
                )
        else:
            print("No messages in the queue. Waiting...")
            time.sleep(5)  # Wait for 5 seconds before polling again

# Subscribe the SQS queues to the SNS topic
subscribe_sqs_to_sns(sns_topic_arn, sqs_queue_url1)
subscribe_sqs_to_sns(sns_topic_arn, sqs_queue_url2)

# Process messages from the SQS queues
process_queue(sqs_queue_url1)
