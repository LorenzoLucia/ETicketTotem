import asyncio
from websockets.asyncio.server import serve

async def publish_numbers(websocket):
    n = input("Press 1 to send 'CARTA VALIDA' and 2 to send 'CARTA NON VALIDA'")
    if n == 1:
        msg = "CARTA VALIDA"
    elif n == 2:
        msg = "CARTA NON VALIDA"
    else:
        msg = "ERROR"

    await websocket.send(msg)
    print(f"Sent: {msg}")

async def main():
    async with serve(publish_numbers, "", 9001) as server:
        await server.serve_forever()  # Run forever

asyncio.run(main())