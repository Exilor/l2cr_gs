require "./abstract_document"
require "../../../models/items/l2_armor"
require "../../../models/items/l2_weapon"
require "../../../models/items/l2_etc_item"

class ItemDocument < AbstractDocument
  private class Item
    property id = 0
    property set = StatsSet.new
    property current_level = 0
    property! item : L2Item?
    property name : String?
    property type : String?
  end

  private getter! current_item : Item

  getter(item_list) { [] of L2Item }

  private def parse_document(doc, file)
    doc.each_element do |n|
      if n.name.casecmp?("list")
        n.each_element do |d|
          if d.name.casecmp?("item")
            parse_item(d)

            if item = @current_item.try &.item?
              item_list << item
            end
          end
        end
      end
    end
  end

  private def parse_item(n)
    item_id = n["id"].to_i
    class_name = n["type"]
    item_name = n["name"]

    @current_item = Item.new
    current_item.id = item_id
    current_item.name = item_name
    current_item.type = class_name
    current_item.set["item_id"] = item_id
    current_item.set["name"] = item_name

    n.each_element do |n|
      case n.name.casecmp
      when "table"
        if current_item.item?
          raise "Item created but table node found"
        end
        parse_table(n)
      when "set"
        if current_item.item?
          raise "Item crated but set node found"
        end
        parse_set(n, current_item.set, 1)
      when "for"
        make_item
        parse_template(n, current_item.item)
      when "cond"
        make_item

        condition = parse_condition(n.first_element_child, current_item.item)

        msg = n["msg"]?
        msg_id = n["msgId"]?

        if condition && msg
          condition.message = msg
        elsif condition && msg_id
          condition.message_id = get_value(msg_id).to_i
          add_name = n["addName"]?
          if add_name && get_value(msg_id).to_i > 0
            condition.add_name
          end
        end

        if condition
          current_item.item.attach(condition)
        end
      end
    end

    make_item
  end

  private def get_table_value(name : String) : String
    @tables[name][current_item.current_level]
  end

  private def get_table_value(name : String, idx : Int) : String
    @tables[name][idx - 1]
  end

  private def make_item
    return if current_item.item?
    type =
    case current_item.type
    when "Armor"
      L2Armor
    when "Weapon"
      L2Weapon
    when "EtcItem"
      L2EtcItem
    end

    if type
      current_item.item = type.new(current_item.set)
    end
  end
end
