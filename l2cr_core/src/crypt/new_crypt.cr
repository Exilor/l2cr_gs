require "./blowfish"
require "../rnd"

struct NewCrypt
  STATIC_BLOWFISH_KEY = UInt8.slice(
    107, 96, 203, 91, 130, 206, 144, 177, 204, 43, 108, 85, 108, 108, 108, 108
  )

  def initialize(key : Indexable(UInt8) = STATIC_BLOWFISH_KEY)
    @blowfish = Blowfish.new(key)
  end

  def key=(key : Indexable(UInt8))
    @blowfish.key = key
  end

  def encrypt(data : Bytes, offset : Int32, size : Int32)
    pos = offset
    stop = offset + size
    while pos < stop
      @blowfish.encrypt_block(data, pos)
      pos += 8
    end
  end

  def decrypt(data : Bytes, offset : Int32, size : Int32)
    pos = offset
    stop = offset + size
    while pos < stop
      @blowfish.decrypt_block(data, pos)
      pos += 8
    end
  end

  def self.verify_checksum(data : Bytes, offset : Int32, size : Int32) : Bool
    if size & 3 != 0 || size <= 4
      return false
    end

    checksum = 0
    count = size - 4
    check = -1
    i = offset

    while i < count
      check = IO::ByteFormat::LittleEndian.decode(Int32, data + i)
      checksum ^= check
      i += 4
    end

    check = IO::ByteFormat::LittleEndian.decode(Int32, data + i)
    # puts "Check: #{check}, checksum: #{checksum}."
    check == checksum
  end

  def self.append_checksum(data : Bytes, offset : Int32, size : Int32)
    checksum = 0
    count = size - 4
    ecx, i = 0, offset

    while i < count
      ecx = IO::ByteFormat::LittleEndian.decode(Int32, data + i)
      checksum ^= ecx
      i += 4
    end

    IO::ByteFormat::LittleEndian.encode(checksum, data + i)
  end

  def self.xor(data : Bytes, offset : Int32, size : Int32, key : Int32)
    stop = size - 8
    pos = 4 + offset
    edx, ecx = 0, key

    while pos < stop
      edx = IO::ByteFormat::LittleEndian.decode(Int32, data + pos)
      ecx += edx
      edx ^= ecx
      IO::ByteFormat::LittleEndian.encode(edx, data + pos)
      pos += 4
    end

    IO::ByteFormat::LittleEndian.encode(ecx, data + pos)
  end
end
