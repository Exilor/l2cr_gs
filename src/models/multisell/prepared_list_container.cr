require "./list_container"
require "./prepared_entry"

class Multisell::PreparedListContainer < Multisell::ListContainer
  def initialize(template : ListContainer, inventory_only : Bool, pc : L2PcInstance?, npc : L2Npc?)
    super(template.list_id)

    @npc_l2id = 0

    @maintain_enchantment = template.maintain_enchantment?
    @apply_taxes = false
    tax_rate = 0.0

    if npc
      @npc_l2id = npc.l2id
      if template.apply_taxes? && npc.in_town? && npc.castle.owner_id > 0
        @apply_taxes = true
        tax_rate = npc.castle.tax_rate
      end
    end

    if inventory_only
      return unless pc

      if @maintain_enchantment
        items = pc.inventory.get_unique_items_by_enchant_level(false, false, false)
      else
        items = pc.inventory.get_unique_items(false, false, false)
      end

      items.each do |item|
        if !item.equipped? && (item.template.is_a?(L2Armor) || item.template.is_a?(L2Weapon))
          template.entries.each do |ent|
            ent.ingredients.each do |ing|
              if item.id == ing.item_id
                entry = PreparedEntry.new(ent, item, @apply_taxes, @maintain_enchantment, tax_rate)
                @entries << entry
                break
              end
            end
          end
        end
      end
    else
      template.entries.each do |entry|
        @entries << PreparedEntry.new(entry, nil, @apply_taxes, false, tax_rate)
      end
    end
  end

  def check_npc_l2id(npc_l2id : Int32) : Bool
    @npc_l2id == 0 || @npc_l2id == npc_l2id
  end
end
