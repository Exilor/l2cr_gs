class GameCrypt
  private KEYS = Slice.new(20) do
    key = Slice.new(16) { Rnd.u8 }
    IO::ByteFormat::LittleEndian.encode(10894608412357896136, key + 8)
    key
  end

  @enabled = false
  @in_key  = GC.malloc_atomic(32).as(UInt8*)
  @out_key : UInt8*

  def initialize
    @out_key = @in_key + 16
  end

  def key=(key : Bytes)
    @in_key.copy_from(key.to_unsafe, key.size)
    @out_key.copy_from(key.to_unsafe, key.size)
  end

  def encrypt(raw : UInt8*, offset : Int32, size : Int32)
    unless @enabled
      @enabled = true
      return
    end

    temp = 0
    size.times do |i|
      temp2 = raw[offset &+ i]
      temp = temp2 ^ @out_key[i & 15] ^ temp
      raw[offset &+ i] = temp
    end

    @out_key.as(Int32*)[2] &+= size
  end

  def decrypt(raw : UInt8*, offset : Int32, size : Int32)
    return unless @enabled

    temp = 0
    size.times do |i|
      temp2 = raw[offset &+ i]
      raw[offset &+ i] = temp2 ^ @in_key[i & 15] ^ temp
      temp = temp2
    end

    @in_key.as(Int32*)[2] &+= size
  end

  def self.sample : Bytes
    KEYS.sample(random: Rnd)
  end
end
