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
    doc.find_element("list") do |n|
      n.each_element do |d|
        if d.name.casecmp?("enchantRateGroup")
          name = d["name"]
          group = EnchantItemGroup.new(name)
          d.find_element "current" do |cd|
            range = cd["enchant"]
            chance = cd["chance"].to_f
            min, max = -1, 0
            if range.includes?('-')
              split = range.split('-')
              if split.size == 2 && split.all? &.num?
                min = split[0].to_i
                max = split[1].to_i
              end
            elsif range.num?
              min = range.to_i
              max = min
            end

            if min > -1 && max > 0
              group.add_chance(RangeChanceHolder.new(min, max, chance))
            end
          end
          ITEM_GROUPS[name] = group
        elsif d.name.casecmp?("enchantScrollGroup")
          id = d["id"].to_i
          group = EnchantScrollGroup.new(id)
          d.find_element("enchantRate") do |cd|
            rate_group = EnchantRateItem.new(cd["group"])
            cd.find_element("item") do |z|
              if slot = z["slot"]?
                rate_group.add_slot(ItemTable::SLOTS[slot])
              end
              if mw = z["magicWeapon"]?
                rate_group.magic_weapon = Bool.new(mw)
              end
              if id2 = z["id"]?
                rate_group.item_id = id2.to_i
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
