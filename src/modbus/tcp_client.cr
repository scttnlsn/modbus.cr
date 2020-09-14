module Modbus
  class TCPClient < Client
    include TCP

    getter :unit_address

    def initialize(io, @unit_address : UInt8 = 1)
      super(io)
    end
  end
end
