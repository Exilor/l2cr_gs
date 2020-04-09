require "./connection"

module MMO::Client(T)
  getter! connection

  def initialize(@connection : Connection(T)?)
  end

  abstract def encrypt(buf : ByteBuffer, size : Int32) : Bool
  abstract def decrypt(buf : ByteBuffer, size : Int32) : Bool
  abstract def on_disconnection
  abstract def on_forced_disconnection
end
