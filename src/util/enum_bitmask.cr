class EnumBitmask(T)
  property bitmask : Int32

  def initialize
    @bitmask = 0
  end

  def initialize(@bitmask : Int32)
  end

  def initialize(set : Bool)
    @bitmask = set ? T.mask.to_i32 : 0
  end

  def set_all
    @bitmask = T.mask.to_i32
  end

  def clear
    @bitmask = 0
  end

  def set(*enum_members : T)
    @bitmask = enum_members.inject(0) { |mask, m| mask | m.mask }
  end

  def <<(member : T)
    @bitmask |= member.mask
    self
  end

  def add(*enum_members : T)
    @bitmask |= enum_members.inject(0) { |mask, m| mask | m.mask }
  end

  def remove(*enum_members : T)
    @bitmask &= ~enum_members.inject(0) { |mask, m| mask | m.mask }
    enum_members.each { |m| @bitmask &= ~m.mask }
  end

  def has?(*enum_members : T) : Bool
    enum_members.none? { |m| @bitmask & m.mask == 0 }
  end

  def clone : self
    EnumBitmask(T).new(@bitmask)
  end
end
