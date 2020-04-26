require "../src/modbus"

serial_port = File.open("/dev/ttyUSB0", "r+")
client = Modbus::RTUClient.open(serial_port)

# read 4 input registers starting at address 1
registers = client.read_input_registers(1, 4)
puts registers
