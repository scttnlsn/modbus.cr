module Modbus
  class PDUException < Exception
  end

  class PDU
    getter :data

    def initialize(function_code : UInt8)
      @function_code = function_code
      @data = Bytes.new(0)
    end

    def recv(io : IO)
      function_code = io.read_byte || raise(IO::EOFError.new)
      if function_code != @function_code
        raise PDUException.new("function code mismatch")
      end

      if function_code >= 5
        @data = Bytes.new(4)
        io.read_fully(@data)
      else
        byte_count = io.read_byte || raise(IO::EOFError.new)

        @data = Bytes.new(byte_count)
        io.read_fully(@data)
      end
    end

    def bytes
      bytes = IO::Memory.new
      bytes.write_byte(@function_code)

      if @function_code < 5
        bytes.write_byte(data.size.to_u8)
      end

      bytes.write(data)
      bytes.to_slice
    end
  end
end
