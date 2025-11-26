from kafka import KafkaProducer
import json

# Initialize producer
producer = KafkaProducer(
    bootstrap_servers=['localhost:9092'],  # Kafka broker address
    value_serializer=lambda v: json.dumps(v).encode('utf-8')  # serialize to JSON
)

# Send a few messages
for i in range(5):
    message = {"number": i}
    producer.send('test-topic', value=message)
    print(f"Sent: {message}")

producer.flush()  # ensure all messages are sent
producer.close()
