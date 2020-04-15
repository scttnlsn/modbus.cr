module Modbus
  class ClientException < Exception
  end

  class Client
    getter :io

    def initialize(io : IO)
      @io = io
    end

    def read_coils(addr : UInt16, num_coils : UInt16) : BitArray
      function_code = 1_u8

      pdu = IO::Memory.new
      pdu.write_byte(function_code)
      pdu.write_bytes(addr - 1, IO::ByteFormat::BigEndian)
      pdu.write_bytes(num_coils, IO::ByteFormat::BigEndian)

      send_message(pdu.to_slice)

      buffer = recv_message(function_code)
      buffer.bits()[0...num_coils.to_i32]
    end

    def read_input_registers(addr : UInt16, num_registers : UInt16) : Array(UInt16)
      function_code = 4_u8

      pdu = IO::Memory.new
      pdu.write_byte(function_code)
      pdu.write_bytes(addr - 1, IO::ByteFormat::BigEndian)
      pdu.write_bytes(num_registers, IO::ByteFormat::BigEndian)

      send_message(pdu.to_slice)

      buffer = recv_message(function_code)
      buffer.words()[0...num_registers.to_i32]
    end

    private def send_pdu(bytes)
      io.write(bytes)
    end

    private def recv_pdu(expected_function_code)
      function_code = io.read_byte || raise(IO::EOFError.new)
      if function_code != expected_function_code
        raise ClientException.new("function code mismatch")
      end

      byte_count = io.read_byte || raise(IO::EOFError.new)

      bytes = Bytes.new(byte_count)
      io.read_fully(bytes)

      bytes
    end
  end
end
