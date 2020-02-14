struct EnchantOptions
  getter options = Slice(Int32).new(3)

  getter_initializer level : Int32

  def []=(index : Int32, option : Int32)
    @options[index] = option
  end
end
