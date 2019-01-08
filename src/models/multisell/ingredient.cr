require "./item_info"

class Multisell::Ingredient
  getter template : L2Item?
  property item_id : Int32
  property item_count : Int64
  property item_info : Multisell::ItemInfo?
  property? tax_ingredient : Bool
  property? maintain_ingredient : Bool

  def initialize(set : StatsSet)
    initialize(
      set.get_i32("id"),
      set.get_i64("count"),
      set.get_bool("isTaxIngredient", false),
      set.get_bool("maintainIngredient", false)
    )
  end

  def initialize(@item_id : Int32, @item_count : Int64, @tax_ingredient : Bool, @maintain_ingredient : Bool)
    if @item_id > 0
      @template = ItemTable[@item_id]?
    end
  end

  def clone : self
    Ingredient.new(@item_id, @item_count, @tax_ingredient, @maintain_ingredient)
  end

  def stackable? : Bool
    return false unless template = @template
    template.stackable?
  end

  def armor_or_weapon? : Bool
    return false unless template = @template
    template.is_a?(L2Armor) || template.is_a?(L2Weapon)
  end

  def weight : Int32
    @template.try &.weight || 0
  end

  def enchant_level : Int32
    @item_info.try &.enchant_level || 0
  end

  def inspect(io : IO)
    io << "Ingredient(#{ItemTable[@item_id] || @item_id} x#{@item_count})"
  end

  def to_s(io : IO)
    inspect(io)
  end
end
