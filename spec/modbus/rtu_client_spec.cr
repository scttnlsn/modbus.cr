require "../spec_helper"

describe Modbus::RTUClient do
  describe "#read_coils" do
    it "should send and receive messages" do
      response = Bytes[0x02, 0x01, 0x02, 0x80, 0x02, 0x1D, 0xFD]
      io = DuplexIO.new(IO::Memory.new(response))

      rtu_client = Modbus::RTUClient.new(2, io)
      coils = rtu_client.read_coils(33, 12)

      bits = BitArray.new(12)
      bits[7] = true
      bits[9] = true
      coils.should eq bits

      io.tx.to_slice.should eq Bytes[0x02, 0x01, 0x00, 0x20, 0x00, 0x0C, 0x3D, 0xF6]
    end
  end
end
