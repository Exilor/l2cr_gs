# class GameCrypt
#   private FORMAT = IO::ByteFormat::LittleEndian

#   private KEYS = Slice.new(20) do
#     key = Slice.new(16) { Rnd.u8 }
#     FORMAT.encode(10894608412357896136, key + 8)
#     key
#   end

#   @enabled = false
#   @in_key  = Bytes.new(16, 0u8)
#   @out_key = Bytes.new(16, 0u8)

#   def key=(key : Bytes)
#     @in_key.copy_from(key)
#     @out_key.copy_from(key)
#   end

#   def encrypt(raw : Bytes, offset : Int32, size : Int32)
#     return @enabled = true unless @enabled

#     temp = 0
#     size.times do |i|
#       temp2 = raw[offset + i]
#       temp = temp2 ^ @out_key[i & 15] ^ temp
#       raw[offset + i] = temp
#     end

#     old = FORMAT.decode(Int32, @out_key + 8)
#     FORMAT.encode(old + size, @out_key + 8)
#   end

#   def decrypt(raw : Bytes, offset : Int32, size : Int32)
#     return unless @enabled

#     temp = 0
#     size.times do |i|
#       temp2 = raw[offset + i]
#       raw[offset + i] = temp2 ^ @in_key[i & 15] ^ temp
#       temp = temp2
#     end

#     old = FORMAT.decode(Int32, @in_key + 8)
#     FORMAT.encode(old + size, @in_key + 8)
#   end

#   def self.sample : Bytes
#     KEYS.sample
#   end
# end


# class GameCrypt
#   private KEYS = Slice.new(20) do
#     key = Slice.new(16) { Rnd.u8 }
#     IO::ByteFormat::LittleEndian.encode(10894608412357896136, key + 8)
#     key
#   end

#   @enabled = false
#   @in_key  = GC.malloc_atomic(32u32).as(UInt8*)
#   @out_key : UInt8*

#   def initialize
#     @out_key = @in_key + 16
#   end

#   def key=(key : Bytes)
#     @in_key.copy_from(key.to_unsafe, key.size)
#     @out_key.copy_from(key.to_unsafe, key.size)
#   end

#   def encrypt(raw : Bytes, offset : Int32, size : Int32)
#     return @enabled = true unless @enabled

#     temp = 0
#     size.times do |i|
#       temp2 = raw[offset + i]
#       temp = temp2 ^ @out_key[i & 15] ^ temp
#       raw[offset + i] = temp
#     end

#     @out_key.as(Int32*)[2] += size
#   end

#   def decrypt(raw : Bytes, offset : Int32, size : Int32)
#     return unless @enabled

#     temp = 0
#     size.times do |i|
#       temp2 = raw[offset + i]
#       raw[offset + i] = temp2 ^ @in_key[i & 15] ^ temp
#       temp = temp2
#     end

#     @in_key.as(Int32*)[2] += size
#   end

#   def self.sample : Bytes
#     KEYS.sample(random: Rnd)
#   end
# end



class GameCrypt
  private KEYS = Slice.new(20) do
    key = Slice.new(16) { Rnd.u8 }
    IO::ByteFormat::LittleEndian.encode(10894608412357896136, key + 8)
    key
  end

  @enabled = false
  @in_key  = GC.malloc_atomic(32u32).as(UInt8*)
  @out_key : UInt8*

  def initialize
    @out_key = @in_key + 16
  end

  def key=(key : Bytes)
    @in_key.copy_from(key.to_unsafe, key.size)
    @out_key.copy_from(key.to_unsafe, key.size)
  end

  def encrypt(raw : Bytes, offset : Int32, size : Int32)
    return @enabled = true unless @enabled

    if size >= raw.size + offset
      raise IndexError.new
    end

    ptr = raw.to_unsafe

    temp = 0
    size.times do |i|
      temp2 = ptr[offset + i]
      temp = temp2 ^ @out_key[i & 15] ^ temp
      ptr[offset + i] = temp
    end

    @out_key.as(Int32*)[2] += size
  end

  def decrypt(raw : Bytes, offset : Int32, size : Int32)
    return unless @enabled

    if size >= raw.size + offset
      raise IndexError.new
    end

    ptr = raw.to_unsafe

    temp = 0
    size.times do |i|
      temp2 = ptr[offset + i]
      ptr[offset + i] = temp2 ^ @in_key[i & 15] ^ temp
      temp = temp2
    end

    @in_key.as(Int32*)[2] += size
  end

  def self.sample : Bytes
    KEYS.sample(random: Rnd)
  end
end
