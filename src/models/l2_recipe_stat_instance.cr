struct L2RecipeStatInstance
  getter type, value

  def initialize(type, @value : Int32)
    @type = StatType.parse(type)
  end
end
