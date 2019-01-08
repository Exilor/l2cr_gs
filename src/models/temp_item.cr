class TempItem
  getter item_id : Int32
  getter item_name : String
  getter reference_price : Int32
  property quantity : Int32

  def initialize(item : L2ItemInstance, @quantity : Int32)
    @item_id = item.id
    @item_name = item.template.name
    @reference_price = item.reference_price
  end
end
