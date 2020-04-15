module Modbus
  class RTUException < Exception
  end

  module RTU
    abstract def unit_address

    protected def send_message(pdu)
      buffer = Buffer.new
      buffer.write_byte(unit_address)
      buffer.write(pdu)
      buffer.write_crc

      io.write(buffer.to_slice)
      io.flush
    end

    protected def recv_message(function_code : UInt8)
      if io.read_byte != unit_address
        raise RTUException.new("unit address mismatch")
      end

      bytes = recv_pdu(function_code)

      message = IO::Memory.new
      message.write_byte(unit_address)
      message.write_byte(function_code)
      message.write_byte(bytes.size.to_u8)
      message.write(bytes)

      crc = recv_crc
      if crc != calc_crc(message)
        raise RTUException.new("CRC mismatch")
      end

      buffer = Buffer.new
      buffer.write(bytes)
      buffer
    end

    protected def recv_crc
      bytes = Bytes.new(2)
      io.read_fully(bytes)
      bytes
    end

    private def calc_crc(message)
      crc = Buffer.new(message).crc16

      val = IO::Memory.new
      val.write_bytes(crc, IO::ByteFormat::LittleEndian)
      val.rewind
      val.to_slice
    end
  end
end
