require "../spec_helper"

describe Modbus::TCPClient do
  describe "#read_coils" do
    it "should send and receive messages" do
      request = Bytes[0x00, 0x01, 0x00, 0x00, 0x00, 0x06, 0x02, 0x01, 0x00, 0x20, 0x00, 0x0C]
      response = Bytes[0x00, 0x01, 0x00, 0x00, 0x00, 0x05, 0x02, 0x01, 0x02, 0x80, 0x02]

      io = DuplexIO.new(IO::Memory.new(response))
      client = Modbus::TCPClient.new(io, 2)
      coils = client.read_coils(33, 12)

      io.tx.to_slice.should eq request

      bits = BitArray.new(12)
      bits[7] = true
      bits[9] = true
      coils.should eq bits
    end
  end

  describe "#read_discrete_inputs" do
    it "should send and receive messages" do
      request = Bytes[0x00, 0x01, 0x00, 0x00, 0x00, 0x06, 0x01, 0x02, 0x01, 0xF4, 0x00, 0x10]
      response = Bytes[0x00, 0x01, 0x00, 0x00, 0x00, 0x05, 0x01, 0x02, 0x02, 0x05, 0x00]

      io = DuplexIO.new(IO::Memory.new(response))
      client = Modbus::TCPClient.new(io, 1)
      coils = client.read_discrete_inputs(501, 16)

      io.tx.to_slice.should eq request

      bits = BitArray.new(16)
      bits[0] = true
      bits[2] = true
      coils.should eq bits
    end
  end

  describe "#read_holding_registers" do
    it "should send and receive messages" do
      request = Bytes[0x00, 0x01, 0x00, 0x00, 0x00, 0x06, 0x01, 0x03, 0x02, 0x58, 0x00, 0x02]
      response = Bytes[0x00, 0x01, 0x00, 0x00, 0x00, 0x07, 0x01, 0x03, 0x04, 0x03, 0xE8, 0x13, 0x88]

      io = DuplexIO.new(IO::Memory.new(response))
      client = Modbus::TCPClient.new(io)
      registers = client.read_holding_registers(601, 2)

      io.tx.to_slice.should eq request
      registers.should eq [1000, 5000]
    end
  end

  describe "#read_input_registers" do
    it "should send and receive messages" do
      request = Bytes[0x00, 0x01, 0x00, 0x00, 0x00, 0x06, 0x01, 0x04, 0x00, 0xC8, 0x00, 0x02]
      response = Bytes[0x00, 0x01, 0x00, 0x00, 0x00, 0x07, 0x01, 0x04, 0x04, 0x27, 0x10, 0xC3, 0x50]

      io = DuplexIO.new(IO::Memory.new(response))
      client = Modbus::TCPClient.new(io)
      registers = client.read_input_registers(201, 2)

      io.tx.to_slice.should eq request
      registers.should eq [10000, 50000]
    end
  end

  describe "#write_single_coil" do
    it "should send and receive messages" do
      request = Bytes[0x00, 0x01, 0x00, 0x00, 0x00, 0x06, 0x01, 0x05, 0x00, 0x64, 0xFF, 0x00]
      response = Bytes[0x00, 0x01, 0x00, 0x00, 0x00, 0x06, 0x01, 0x05, 0x00, 0x64, 0xFF, 0x00]

      io = DuplexIO.new(IO::Memory.new(response))
      client = Modbus::TCPClient.new(io)
      value = client.write_single_coil(101, true)

      io.tx.to_slice.should eq request
      value.should eq true
    end
  end

  describe "#write_single_register" do
    it "should send and receive messages" do
      request = Bytes[0x00, 0x01, 0x00, 0x00, 0x00, 0x06, 0x01, 0x06, 0x00, 0x64, 0x3A, 0x98]
      response = Bytes[0x00, 0x01, 0x00, 0x00, 0x00, 0x06, 0x01, 0x06, 0x00, 0x64, 0x3A, 0x98]

      io = DuplexIO.new(IO::Memory.new(response))
      client = Modbus::TCPClient.new(io)
      value = client.write_single_register(101, 15000)

      io.tx.to_slice.should eq request
      value.should eq 15000
    end
  end

  describe "#write_multiple_registers" do
    it "should send and receive messages" do
      request = Bytes[0x00, 0x01, 0x00, 0x00, 0x00, 0x0B, 0x1C, 0x10, 0x00, 0x64, 0x00, 0x02, 0x04, 0x03, 0xE8, 0x07, 0xD8]
      response = Bytes[0x00, 0x01, 0x00, 0x00, 0x00, 0x06, 0x1C, 0x10, 0x00, 0x64, 0x00, 0x02]

      io = DuplexIO.new(IO::Memory.new(response))
      client = Modbus::TCPClient.new(io, 28)
      value = client.write_multiple_registers(101, [1000_u16, 2008_u16])

      io.tx.to_slice.should eq request
      value.should eq [101, 2]
    end
  end
end
