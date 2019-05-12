class Multisell::Entry
  @entry_id = 0

  getter products = [] of Ingredient
  getter ingredients = [] of Ingredient
  getter? stackable = true

  property_initializer entry_id: Int32

  def add_product(prod : Ingredient)
    @products << prod
    unless prod.stackable?
      @stackable = false
    end
  end

  def add_ingredient(ing : Ingredient)
    @ingredients << ing
  end

  def tax_amount : Int64
    0i64
  end
end
