require "../../models/items/enchant/enchant_item_group"
require "../../models/items/enchant/enchant_scroll_group"
require "../../models/items/enchant/enchant_rate_item"

module EnchantItemGroupsData
  extend self
  extend XMLReader

  private ITEM_GROUPS = {} of String => EnchantItemGroup
  private SCROLL_GROUPS = {} of Int32 => EnchantScrollGroup

  def load
    ITEM_GROUPS.clear
    SCROLL_GROUPS.clear
    parse_datapack_file("enchantItemGroups.xml")
    info { "Loaded #{ITEM_GROUPS.size} item group templates." }
    info { "Loaded #{SCROLL_GROUPS.size} scroll group templates." }
  end

  def get_item_group(item : L2Item, scroll_group : Int) : EnchantItemGroup?
    return unless group = SCROLL_GROUPS[scroll_group]?
    return unless rate_group = group.get_rate_group(item)
    ITEM_GROUPS[rate_group.name]?
  end

  def get_item_group(id : String) : EnchantItemGroup?
    ITEM_GROUPS[id]?
  end

  def get_scroll_group(id : Int32) : EnchantScrollGroup?
    SCROLL_GROUPS[id]?
  end

  private def parse_document(doc, file)
    find_element(doc, "list") do |n|
      each_element(n) do |d, d_name|
        if d_name.casecmp?("enchantRateGroup")
          name = parse_string(d, "name")
          group = EnchantItemGroup.new(name)
          find_element(d, "current") do |cd|
            range = parse_string(cd, "enchant")
            chance = parse_double(cd, "chance")
            min, max = -1, 0
            if range.includes?('-')
              split = range.split('-')
              if split.size == 2 && split.all? &.number?
                min = split[0].to_i
                max = split[1].to_i
              end
            elsif range.number?
              min = range.to_i
              max = min
            end

            if min > -1 && max > 0
              group.add_chance(RangeChanceHolder.new(min, max, chance))
            end
          end
          ITEM_GROUPS[name] = group
        elsif d_name.casecmp?("enchantScrollGroup")
          id = parse_int(d, "id")
          group = EnchantScrollGroup.new(id)
          find_element(d, "enchantRate") do |cd|
            rate_group = EnchantRateItem.new(parse_string(cd, "group"))
            find_element(cd, "item") do |z|
              if slot = parse_string(z, "slot", nil)
                rate_group.add_slot(ItemTable::SLOTS[slot])
              end
              if mw = parse_string(z, "magicWeapon", nil)
                rate_group.magic_weapon = Bool.new(mw)
              end
              if id2 = parse_int(z, "id", nil)
                rate_group.item_id = id2
              end
            end
            group.add_rate_group(rate_group)
          end
          SCROLL_GROUPS[id] = group
        end
      end
    end
  end
end
