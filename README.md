# modbus.cr

Modbus client library for Crystal

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     modbus:
       github: scttnlsn/modbus.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "modbus"
```

## Documentation

[API (master)](https://scttnlsn.github.io/modbus.cr/)

## Example

```bash
stty -F /dev/ttyUSB0 cs8 19200 ignbrk -brkint -icrnl -imaxbel -opost -onlcr -isig -icanon -iexten -echo -echoe -echok -echoctl -echoke noflsh -ixon -crtscts -hupcl
```

```crystal
require "modbus"

serial_port = File.open("/dev/ttyUSB0", "r+")
rtu_client = Modbus::RTUClient.open(serial_port)

# read 4 coils starting at address 1
coils : BitArray = rtu_client.read_coils(1, 4)
puts coils

require "socket"

socket = TCPSocket.new("example.modbus.host", 502)
tcp_client = Modbus::TCPClient.new(socket)

# read 1 register starting at address 123
registers = tcp_client.read_holding_registers(123, 1)
puts registers[0]
```

## Testing

To run the tests:

```
crystal spec
```

## Resources

Modbus protocol info:

* https://www.fernhillsoftware.com/help/drivers/modbus/modbus-protocol.html
* https://minimalmodbus.readthedocs.io/en/stable/modbusdetails.html
