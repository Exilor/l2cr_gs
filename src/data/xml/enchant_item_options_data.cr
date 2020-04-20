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

    find_element(doc, "list") do |list|
      find_element(list, "item") do |d|
        item_id = parse_int(d, "id")
        DATA[item_id] ||= {} of Int32 => EnchantOptions
        find_element(d, "options") do |cd|
          level = parse_int(cd, "level")
          op = EnchantOptions.new(level)
          DATA[item_id][op.level] = op
          3.times do |i|
            att = parse_string(cd, "option#{i + 1}", nil)
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
