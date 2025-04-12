import RPi.GPIO as GPIO
from mfrc522 import SimpleMFRC522
import time

reader = SimpleMFRC522()

try:
    print("Place your RFID tag or card near the reader...")
    id, text = reader.read()
    print(f"RFID Tag ID: {id}")
    print(f"Stored Text: {text}")
    publish_data(topic, id)

except KeyboardInterrupt:
    print("Exiting...")
finally:
    GPIO.cleanup()
    time.sleep(1)
    client.disconnect()

import asyncio
import websockets

async def publish_numbers(websocket):
    number = 1234567890  # Starting number
    input("Press Enter to start sending numbers...")
    
    await websocket.send(str(number))
    print(f"Sent: {number}")

        # number += 1
        # await asyncio.sleep(1)

async def main():
    async with websockets.serve(lambda ws: publish_numbers(ws), "localhost", 8765):
        await asyncio.Future()  # Run forever

asyncio.run(main())

