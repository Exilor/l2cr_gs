require "../../models/items/enchant/enchant_scroll"
require "../../models/items/enchant/enchant_support_item"
require "../../models/items/enchant/enchant_item_group"

module EnchantItemData
  extend self
  extend XMLReader

  private SCROLLS  = {} of Int32 => EnchantScroll
  private SUPPORTS = {} of Int32 => EnchantSupportItem

  def load
    SCROLLS.clear
    SUPPORTS.clear

    parse_datapack_file("enchantItemData.xml")

    info { "Loaded #{SCROLLS.size} enchant scrolls." }
    info { "Loaded #{SUPPORTS.size} support items." }
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |n|
      n.each_element do |d|
        if d.name.casecmp?("enchant")
          set = StatsSet.new(d.attributes)
          item = EnchantScroll.new(set)
          d.find_element("item") do |cd|
            item.add_item(cd["id"].to_i)
          end
          SCROLLS[item.id] = item
        elsif d.name.casecmp?("support")
          set = StatsSet.new(d.attributes)
          item = EnchantSupportItem.new(set)
          SUPPORTS[item.id] = item
        end
      end
    end
  end

  def get_enchant_scroll(scroll : L2ItemInstance) : EnchantScroll?
    SCROLLS[scroll.id]?
  end

  def get_support_item(item : L2ItemInstance) : EnchantSupportItem?
    SUPPORTS[item.id]?
  end
end
