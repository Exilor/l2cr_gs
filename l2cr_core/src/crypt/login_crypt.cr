require "./new_crypt"

class LoginCrypt
  def initialize(key)
    @crypt = NewCrypt.new(key)
    @static_crypt = NewCrypt.new
  end

  def decrypt(data : Bytes, offset : Int32, size : Int32) : Bool
    unless size % 8 == 0
      raise "LoginCrypt#decrypt: size must be a multiple of 8 but is #{size}."
    end

    if offset + size > data.size
      raise "LoginCrypt#decrypt: data is too short for given size and offset (offset: #{offset}, size: #{size}, data.size: #{data.size})."
    end

    @crypt.decrypt(data, offset, size)
    NewCrypt.verify_checksum(data, offset, size)
  end

  def encrypt(data : Bytes, offset : Int32, size : Int32) : Int32
    size += 4

    if static_crypt = @static_crypt
      size += 4
      size += 8 - (size % 8)

      if offset + size > data.size
        raise "Packet too long: offset(#{offset}) + size(#{size}) > data.size(#{data.size})."
      end

      NewCrypt.xor(data, offset, size)
      static_crypt.encrypt(data, offset, size)
      @static_crypt = nil
    else
      size += 8 - (size % 8)

      if offset + size > data.size
        raise "Packet too long: offset(#{offset}) + size(#{size}) > data.size(#{data.size})."
      end

      NewCrypt.append_checksum(data, offset, size)
      @crypt.encrypt(data, offset, size)
    end

    size
  end
end
