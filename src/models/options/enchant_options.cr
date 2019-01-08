struct EnchantOptions
  getter level, options

  def initialize(@level : Int32)
    @options = Slice(Int32).new(3)
  end

  def []=(index : Int32, option : Int32)
    # if @options.size > index
      @options[index] = option
    # end
  end
end
