module Modbus
  class TCPException < Exception
  end

  module TCP
    @txn_id : UInt16 = 0_u16

    abstract def unit_address

    protected def send_message(pdu)
      buffer = Buffer.new
      buffer.write_word(next_txn_id)
      buffer.write_word(0)
      buffer.write_word(pdu.size.to_u16 + 1) # +1 to account for unit_address
      buffer.write_byte(unit_address)
      buffer.write(pdu)

      io.write(buffer.to_slice)
      io.flush
    end

    protected def recv_message(function_code : UInt8)
      txn_id = io.read_bytes(UInt16, IO::ByteFormat::BigEndian)
      protocol = io.read_bytes(UInt16, IO::ByteFormat::BigEndian)
      size = io.read_bytes(UInt16, IO::ByteFormat::BigEndian)

      if io.read_byte != unit_address
        raise TCPException.new("unit address mismatch")
      end

      pdu = recv_pdu(function_code)

      buffer = Buffer.new
      buffer.write(pdu.data)
      buffer
    end

    private def next_txn_id
      if @txn_id == UInt16::MAX
        @txn_id = 0
      else
        @txn_id += 1
      end
    end
  end
end
