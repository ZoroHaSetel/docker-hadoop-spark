from kafka import KafkaConsumer
consumer = KafkaConsumer('test-topic')
for msg in consumer:
    print ('incomming ------- ->', msg)