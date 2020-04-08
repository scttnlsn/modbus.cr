# modbus

Modbus client library for Crystal

Modbus protocol summary:
https://www.fernhillsoftware.com/help/drivers/modbus/modbus-protocol.html

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     modbus:
       github: scttnlsn/modbus.cr
   ```

2. Run `shards install`

## Example

```crystal
require "modbus"

serial_port = File.open("/dev/ttyUSB0")
rtu_client = Modbus::RTUClient.new(serial_port)

coils = rtu_client.read_coils(20, 10) # read 10 coils starting at coil 20
coils[0] # coil 20 => true/false
```
