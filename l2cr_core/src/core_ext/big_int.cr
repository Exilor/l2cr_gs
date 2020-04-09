require "big"

lib LibGMP
  # fun sizeinbase = __gmpz_sizeinbase(op : MPZ*, base : Int32) : Int32
  fun export = __gmpz_export(rop : Void*, countp : Int32*, order : Int32, size : Int32, endian : Int32, nails : Int32, op : MPZ*) : UInt8*
  fun import = __gmpz_import(rop : MPZ*, count : Int32, order : Int32, size : Int32, endian : Int32, nails : Int32, op : Void*)
end

struct BigInt
  def size #: Int32
    LibGMP.sizeinbase(self, 256)
  end

  def bytes(format = IO::ByteFormat::SystemEndian) : Bytes
    e = format == IO::ByteFormat::BigEndian ? 1 : -1
    Bytes.new(size).tap { |s| LibGMP.export(s, nil, e, 1, 1, 0, self) }
  end

  def self.new(bytes, format = IO::ByteFormat::SystemEndian) : self
    e = format == IO::ByteFormat::BigEndian ? 1 : -1
    new { |mpz| LibGMP.import(mpz, bytes.size, e, 1, 1, 0, bytes) }
  end
end
