require "./entry"

class Multisell::PreparedEntry < Multisell::Entry
  @stackable = true

  getter tax_amount = 0i64

  def initialize(template, item, apply_taxes, maintain_enchantment, tax_rate)
    @tax_amount = 0i64
    @entry_id = template.entry_id * 100_000

    if maintain_enchantment && item
      @entry_id += item.enchant_level
    end

    adena_amount = 0i64
    info = nil

    template.ingredients.each do |ing|
      if ing.item_id == Inventory::ADENA_ID
        if ing.tax_ingredient?
          if apply_taxes
            @tax_amount = (ing.item_count * tax_rate).round.to_i64
          end
        else
          adena_amount += ing.item_count
        end
      elsif maintain_enchantment && item && ing.armor_or_weapon?
        info = Multisell::ItemInfo.new(item)
        new_ingredient = ing.clone
        new_ingredient.item_info = info
        @ingredients << new_ingredient
      else
        new_ingredient = ing.clone
        @ingredients << new_ingredient
      end
    end

    adena_amount += @tax_amount

    if adena_amount > 0
      ing = Ingredient.new(Inventory::ADENA_ID, adena_amount, false, false)
      @ingredients << ing
    end

    template.products.each do |ing|
      unless ing.stackable?
        @stackable = false
      end

      new_product = ing.clone

      if maintain_enchantment && ing.armor_or_weapon?
        new_product.item_info = info
      elsif ing.armor_or_weapon? && ing.template.not_nil!.default_enchant_level > 0
        info = Multisell::ItemInfo.new(ing.template.not_nil!.default_enchant_level)
        new_product.item_info = info
      end

      @products << new_product
    end
  end
end
