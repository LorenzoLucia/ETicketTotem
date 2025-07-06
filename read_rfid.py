import RPi.GPIO as GPIO
from mfrc522 import SimpleMFRC522
import asyncio
from websockets.asyncio.server import serve

GPIO.cleanup()

reader = SimpleMFRC522()
print('reading...')

async def publish_numbers(websocket):
    print("Incoming connection...")
    rfid_read = False
    try:
        while not rfid_read:
            print("Reading RFID...")
            id, text = reader.read()
            print(f"RFID Tag ID: {id}")
            print(f"Stored Text: {text}")
            rfid_read = True
        await websocket.send(str(text))
    except Exception as e:
        print(e)


async def main():
    async with serve(publish_numbers, "", 9001) as server:
        await server.serve_forever()  # Run forever

if __name__ == "__main__":
    asyncio.run(main())

