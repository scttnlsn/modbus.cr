require "../src/modbus"

serial_port = File.open("/dev/ttyUSB0", "r+")
rtu_client = Modbus::RTUClient.open(serial_port)

# read 4 input registers starting at address 1
registers = rtu_client.read_input_registers(1, 4)
puts registers
