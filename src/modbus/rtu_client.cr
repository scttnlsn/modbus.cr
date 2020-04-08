require "bit_array"

module Modbus
  class RTUClient < Client
    include RTU

    getter :unit_address

    def initialize(unit_address : UInt8, io)
      super(io)
      @unit_address = unit_address
    end
  end
end
