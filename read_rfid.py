import RPi.GPIO as GPIO
from mfrc522 import SimpleMFRC522
import asyncio
import websockets

GPIO.cleanup()

reader = SimpleMFRC522()

async def publish_numbers(websocket):

    try:
        print("Place your RFID tag or card near the reader...")
        id, text = reader.read()
        print(f"RFID Tag ID: {type(id)}")
        print(f"Stored Text: {text}")
    except KeyboardInterrupt:
        print("Exiting...")
    finally:
        GPIO.cleanup()

    await websocket.send(str(id))
    print(f"Sent on socket: {id}")


async def main():
    async with websockets.serve(lambda ws: publish_numbers(ws), "localhost", 9001):
        await asyncio.Future()  # Run forever

asyncio.run(main())

