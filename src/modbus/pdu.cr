module Modbus
  class PDUException < Exception
  end

  class PDU
    getter :data

    def initialize(@function_code : UInt8)
      @data = Bytes.new(0)
    end

    def recv(io : IO)
      function_code = io.read_byte || raise(IO::EOFError.new)
      if function_code != @function_code
        if function_code == @function_code + 0x80
          # error response
          exception_code = io.read_byte || raise(IO::EOFError.new)
          raise ModbusException.new(exception_code)
        else
          raise PDUException.new("function code mismatch")
        end
      end

      if function_code < 5
        # these PDUs are variable size
        byte_count = io.read_byte || raise(IO::EOFError.new)
        @data = Bytes.new(byte_count)
        io.read_fully(@data)
      else
        @data = Bytes.new(4)
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
