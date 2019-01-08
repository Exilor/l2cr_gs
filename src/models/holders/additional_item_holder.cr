require "./item_holder"

class AdditionalItemHolder < ItemHolder
  getter? allowed_to_use

  def initialize(id : Int32, @allowed_to_use : Bool)
    super(id, 0)
  end
end
