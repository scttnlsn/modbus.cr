module Modbus
  class RTUClient < Client
    include RTU

    getter :unit_address

    def self.open(fd : IO::FileDescriptor, unit_address : UInt8 = 1)
      fd.sync = true
      fd.read_buffering = false
      fd.blocking = true
      fd.raw!

      new(fd, unit_address)
    end

    def initialize(io, @unit_address : UInt8 = 1)
      super(io)
    end
  end
end
