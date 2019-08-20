require "../../models/options/enchant_options"

module EnchantItemOptionsData
  extend self
  extend XMLReader

  private DATA = {} of Int32 => Hash(Int32, EnchantOptions)

  def load
    DATA.clear
    parse_datapack_file("enchantItemOptions.xml")
  end

  private def parse_document(doc, file)
    counter = 0

    doc.find_element("list") do |list|
      list.find_element("item") do |d|
        item_id = d["id"].to_i
        DATA[item_id] ||= {} of Int32 => EnchantOptions
        d.find_element("options") do |cd|
          level = cd["level"].to_i
          op = EnchantOptions.new(level)
          DATA[item_id][op.level] = op
          3.times do |i|
            att = cd["option#{i + 1}"]?
            if att && att.num?
              op[i] = att.to_i
            end
          end

          counter += 1
        end
      end
    end

    info { "Loaded #{DATA.size} items and #{counter} options." }
  end

  def get_options(item_id : Int32, enchant_level : Int32) : EnchantOptions?
    return unless temp = DATA[item_id]?
    temp[enchant_level]?
  end

  def get_options(item : L2ItemInstance?) : EnchantOptions?
    get_options(item.id, item.enchant_level) if item
  end
end
