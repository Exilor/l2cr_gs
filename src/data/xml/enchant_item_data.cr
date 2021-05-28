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

  private def parse_document(doc : XML::Node, file : File)
    find_element(doc, "list") do |n|
      each_element(n) do |d, d_name|
        if d_name.casecmp?("enchant")
          set = get_attributes(d)
          item = EnchantScroll.new(set)
          find_element(d, "item") do |cd|
            item.add_item(parse_int(cd, "id"))
          end
          SCROLLS[item.id] = item
        elsif d_name.casecmp?("support")
          set = get_attributes(d)
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
