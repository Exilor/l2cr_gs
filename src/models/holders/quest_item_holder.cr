require "./item_holder"

class QuestItemHolder < ItemHolder
  getter chance

  def initialize(id : Int32, chance : Int32)
    initialize(id, chance, 1)
  end

  def initialize(id : Int32, @chance : Int32, count : Int64)
    super(id, count)
  end
end
