module Modbus
  EXCEPTIONS = {
    1 => "Illegal Function",
    2 => "Illegal Data Address",
    3 => "Illegal Data Value",
    4 => "Slave Device Failure",
    5 => "Acknowledge",
    6 => "Slave Device Busy",
    7 => "Negative Acknowledge",
    8 => "Memory Parity Error",
    10 => "Gateway Path Unavailable",
    11 => "Gateway Target Device Failed to Respond",
  }

  class ModbusException < Exception
    getter :pdu

    def initialize(exception_code)
      msg = EXCEPTIONS[exception_code] || "Unknown Error"
      super(msg)
    end
  end
end
