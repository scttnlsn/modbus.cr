module Modbus
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

    def write_single_coil(addr : UInt16, value : Bool) : Bool
      function_code = 5_u8

      pdu = IO::Memory.new
      pdu.write_byte(function_code)
      pdu.write_bytes(addr - 1, IO::ByteFormat::BigEndian)

      if value
        # on
        pdu.write_byte(0xFF)
        pdu.write_byte(0x00)
      else
        # off
        pdu.write_byte(0x00)
        pdu.write_byte(0x00)
      end

      send_message(pdu.to_slice)

      buffer = recv_message(function_code)
      addr, val = buffer.words()
      val == 0xFF00
    end

    def write_single_register(addr : UInt16, value : UInt16) : UInt16
      function_code = 6_u8

      pdu = IO::Memory.new
      pdu.write_byte(function_code)
      pdu.write_bytes(addr - 1, IO::ByteFormat::BigEndian)
      pdu.write_bytes(value, IO::ByteFormat::BigEndian)

      send_message(pdu.to_slice)

      buffer = recv_message(function_code)
      addr, val = buffer.words()
      val
    end

    def write_multiple_registers(addr : UInt16, values : Array(UInt16)) : Array(UInt16)
      function_code = 16_u8

      pdu = IO::Memory.new
      pdu.write_byte(function_code)
      pdu.write_bytes(addr - 1, IO::ByteFormat::BigEndian)
      pdu.write_bytes(values.size.to_u16, IO::ByteFormat::BigEndian)
      pdu.write_byte(values.size.to_u8 * 2)

      values.each do |value|
        pdu.write_bytes(value.to_u16, IO::ByteFormat::BigEndian)
      end

      send_message(pdu.to_slice)

      buffer = recv_message(function_code)
      addr, count = buffer.words()
      [addr + 1, count]
    end

    private def read_bits(function_code : UInt8, addr : UInt16, num_bits : UInt16) : BitArray
      pdu = IO::Memory.new
      pdu.write_byte(function_code)
      pdu.write_bytes(addr - 1, IO::ByteFormat::BigEndian)
      pdu.write_bytes(num_bits, IO::ByteFormat::BigEndian)

      send_message(pdu.to_slice)

      buffer = recv_message(function_code)
      buffer.bits()[0...num_bits.to_i32]
    end

    private def read_bytes(function_code : UInt8, addr : UInt16, num_bytes : UInt16) : Array(UInt16)
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

    private def recv_pdu(function_code)
      pdu = PDU.new(function_code)
      pdu.recv(io)
      pdu
    end
  end
end
