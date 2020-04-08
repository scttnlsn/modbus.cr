module Modbus
  class Buffer < IO
    def initialize(buffer : IO::Memory = IO::Memory.new)
      @buffer = buffer || IO::Memory.new
      @buffer.rewind
    end

    def read(bytes)
      @buffer.read(bytes)
    end

    def write(bytes) : Nil
      @buffer.write(bytes)
    end

    def to_slice
      @buffer.to_slice
    end

    def bits
      bits = BitArray.new(@buffer.size * 8)
      i = 0

      @buffer.to_slice.each do |byte|
        (0...8).each do |shift|
          bit = ((byte >> shift) & 0x1)
          bits[i] = (bit == 0x1)
          i += 1
        end
      end

      bits
    end

    def crc16
      crc = 0xFFFF_u16

      @buffer.to_slice.each do |byte|
        crc ^= byte

        (0...8).each do |shift|
          if (crc & 0x0001) != 0
            crc >>= 1
            crc ^= 0xA001
          else
            crc >>= 1
          end
        end
      end

      crc
    end

    def write_crc
      result = IO::Memory.new
      result.write_bytes(crc16, IO::ByteFormat::LittleEndian)
      write(result.to_slice)
    end
  end
end
