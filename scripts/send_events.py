import json
import time
import uuid
import random
import boto3


QUEUE_URL = "https://sqs.eu-central-1.amazonaws.com/767415906579/serverless-event-pipeline-ingestion-queue-dev"
REGION = "eu-central-1"

# Initialize SQS client
sqs = boto3.client('sqs', region_name=REGION)

CATEGORIES = ['Electronics', 'Home & Kitchen', 'Books', 'Sports', 'Fashion']
CITIES = ['Berlin', 'Istanbul', 'London', 'Amsterdam', 'New York']

def generate_sample_order():
    return {
        "order_id": f"ORD-{uuid.uuid4().hex[:8].upper()}",
        "customer_id": f"CUST-{random.randint(1000, 9999)}",
        "category": random.choice(CATEGORIES),
        "city": random.choice(CITIES),
        "item_count": random.randint(1, 5),
        "total_amount": round(random.uniform(15.0, 750.0), 2),
        "status": "COMPLETED"
    }

def main():
    print(f"Target SQS Queue: {QUEUE_URL}\n")
    print("🚀 Sending 10 sample order events to the pipeline...")

    for i in range(1, 11):
        order_event = generate_sample_order()
        response = sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(order_event)
        )
        print(f"[{i}/10] Sent Order {order_event['order_id']} | SQS MessageId: {response['MessageId']}")
        time.sleep(0.3)

    print("\n✅ All events sent successfully!")

if __name__ == "__main__":
    main()