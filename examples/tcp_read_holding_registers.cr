require "socket"
require "../src/modbus"

socket = TCPSocket.new("CLASSIC.lan", 502)
client = Modbus::TCPClient.new(socket)

# read 1 register starting at address 4115
registers = client.read_holding_registers(4115, 1)
puts registers[0]
