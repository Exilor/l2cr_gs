require "./product"

class L2BuyList
  @products = {} of Int32 => Product
  @allowed_npcs : Set(Int32)?

  getter_initializer list_id: Int32

  delegate size, to: @products

  def products : Enumerable(Product)
    @products.values_slice
  end

  def get_product_by_item_id(item_id : Int32) : Product?
    @products[item_id]?
  end

  def add_product(product : Product)
    @products[product.item_id] = product
  end

  def add_allowed_npc(id : Int32)
    (@allowed_npcs ||= Set(Int32).new) << id
  end

  def npc_allowed?(id : Int32) : Bool
    return false unless allowed = @allowed_npcs
    allowed.includes?(id)
  end
end
