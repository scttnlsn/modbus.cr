module Modbus
  class ClientException < Exception
  end

  class Client
    getter :io

    def initialize(io : IO)
      @io = io
    end

    def read_coils(addr : UInt16, num_coils : UInt16) : BitArray
      read_bits(1, addr, num_coils)
    end

    def read_discrete_inputs(addr : UInt16, num_inputs : UInt16) : BitArray
      read_bits(2, addr, num_inputs)
    end

    def read_holding_registers(addr : UInt16, num_registers : UInt16) : Array(UInt16)
      read_bytes(3, addr, num_registers)
    end

    def read_input_registers(addr : UInt16, num_registers : UInt16) : Array(UInt16)
      read_bytes(4, addr, num_registers)
    end

    def read_bits(function_code : UInt8, addr : UInt16, num_bits : UInt16) : BitArray
      pdu = IO::Memory.new
      pdu.write_byte(function_code)
      pdu.write_bytes(addr - 1, IO::ByteFormat::BigEndian)
      pdu.write_bytes(num_bits, IO::ByteFormat::BigEndian)

      send_message(pdu.to_slice)

      buffer = recv_message(function_code)
      buffer.bits()[0...num_bits.to_i32]
    end

    def read_bytes(function_code : UInt8, addr : UInt16, num_bytes : UInt16) : Array(UInt16)
      pdu = IO::Memory.new
      pdu.write_byte(function_code)
      pdu.write_bytes(addr - 1, IO::ByteFormat::BigEndian)
      pdu.write_bytes(num_bytes, IO::ByteFormat::BigEndian)

      send_message(pdu.to_slice)

      buffer = recv_message(function_code)
      buffer.words()[0...num_bytes.to_i32]
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
