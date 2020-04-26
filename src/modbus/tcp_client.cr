module Modbus
  class TCPClient < Client
    include TCP

    getter :unit_address

    def initialize(io, unit_address : UInt8 = 1)
      super(io)

      @unit_address = unit_address
    end
  end
end
