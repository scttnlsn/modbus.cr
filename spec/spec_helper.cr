require "spec"
require "../src/modbus"

class DuplexIO < IO
  def initialize(rx : IO)
    @rx = rx
    @rx.rewind
    @tx = IO::Memory.new
  end

  def read(bytes : Bytes)
    @rx.read(bytes)
  end

  def write(bytes : Bytes) : Nil
    @tx.write(bytes)
  end

  def tx
    @tx.rewind
    @tx
  end
end
