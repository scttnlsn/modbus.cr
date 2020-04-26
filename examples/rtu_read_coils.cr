require "../src/modbus"

serial_port = File.open("/dev/ttyUSB0", "r+")
client = Modbus::RTUClient.open(serial_port)

# read 4 coils starting at address 1
coils : BitArray = client.read_coils(1, 4)
puts coils
