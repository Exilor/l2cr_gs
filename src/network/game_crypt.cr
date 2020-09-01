class GameCrypt
  private KEYS = Slice.new(20) do
    key = Slice.new(16) { Rnd.u8 }
    IO::ByteFormat::LittleEndian.encode(10894608412357896136, key + 8)
    key
  end

  @enabled = false
  @key  = GC.malloc_atomic(32).as(UInt8*)

  def key=(key : Bytes)
    @key.copy_from(key.to_unsafe, key.size)
    (@key + 16).copy_from(key.to_unsafe, key.size)
  end

  def encrypt(raw : UInt8*, offset : Int32, size : Int32)
    unless @enabled
      @enabled = true
      return
    end

    out_key = @key + 16

    temp = 0
    size.times do |i|
      temp2 = raw[offset &+ i]
      temp = temp2 ^ out_key[i & 15] ^ temp
      raw[offset &+ i] = temp
    end

    out_key.as(Int32*)[2] &+= size
  end

  def decrypt(raw : UInt8*, offset : Int32, size : Int32)
    return unless @enabled

    temp = 0
    size.times do |i|
      temp2 = raw[offset &+ i]
      raw[offset &+ i] = temp2 ^ @key[i & 15] ^ temp
      temp = temp2
    end

    @key.as(Int32*)[2] &+= size
  end

  def self.sample : Bytes
    KEYS.sample(random: Rnd)
  end
end
