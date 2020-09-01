struct L2RecipeStatInstance
  getter type, value

  def initialize(type : String, value : Int32)
    @type = StatType.parse(type)
    @value = value
  end
end
