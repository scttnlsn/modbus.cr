require "bit_array"

module Modbus
  class RTUClient < Client
    include RTU

    getter :unit_address

    def initialize(io, unit_address : UInt8 = 1)
      super(io)
      @unit_address = unit_address
    end
  end
end
