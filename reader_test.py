import RPi.GPIO as GPIO
from mfrc522 import SimpleMFRC522
from time import sleep

GPIO.cleanup()

reader = SimpleMFRC522()

def read_rfid():
	print("Place your RFID tag or card near the reader...")
	id, text = reader.read()
	print(f"RFID Tag ID: {id}")
	print(f"Stored Text: {text}")

def write_rfid(text):
	id, text_written = reader.write(text)
	print(f"ID: {id}")
	print(f"Text Written: {text_written}")

def main():
	read_rfid()
	write_rfid('CARTA VALIDA')
	sleep(5)

	read_rfid()
	write_rfid('CARTA NON VALIDA')
	sleep(5)

	while True:
		read_rfid()

	GPIO.cleanup()

if __name__ == '__main__':
	main()
