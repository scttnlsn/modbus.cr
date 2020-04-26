require "../spec_helper"

describe Modbus::PDU do
  describe "#recv" do
    it "should send and receive messages" do
      response = Bytes[0x81, 0x01]

      io = DuplexIO.new(IO::Memory.new(response))
      pdu = Modbus::PDU.new(1)

      expect_raises(Modbus::ModbusException, "Illegal Function") do
        pdu.recv(io)
      end
    end
  end
end
