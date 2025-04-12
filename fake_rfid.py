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
    async with websockets.serve(lambda ws: publish_numbers(ws), "localhost", 9001):
        await asyncio.Future()  # Run forever

asyncio.run(main())