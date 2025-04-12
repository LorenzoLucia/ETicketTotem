import paho.mqtt.client as mqtt

topic = "/mqtt"  # Topic to subscribe to
broker = "localhost"  # Replace with your MQTT broker address
port = 8083  # Replace with your MQTT broker port

def listen_for_messages():
        def on_message(client, userdata, msg):
            print(f"Message received on topic {msg.topic}: {msg.payload.decode()}")

        listener_client = mqtt.Client(client_id="listener_client", transport="websockets")
        listener_client.on_message = on_message

        try:
            listener_client.connect(broker, port, 60)
            listener_client.subscribe(topic)
            listener_client.loop_forever()
        except Exception as e:
            print(f"Listener Error: {e}")

listen_for_messages()