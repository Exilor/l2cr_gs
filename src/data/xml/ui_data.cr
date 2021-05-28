require "../../models/action_key"

module UIData
  extend self
  extend XMLReader

  private KEYS = {} of Int32 => Array(ActionKey)
  private CATEGORIES = {} of Int32 => Array(Int32)

  def load
    KEYS.clear
    CATEGORIES.clear
    parse_datapack_file("ui/ui_en.xml")
    info { "Loaded #{KEYS.size} keys and #{CATEGORIES.size} categories." }
  end

  def categories : Hash(Int32, Array(Int32))
    CATEGORIES
  end

  def keys : Hash(Int32, Array(ActionKey))
    KEYS
  end

  private def parse_document(doc : XML::Node, file : File)
    find_element(doc, "list") do |n|
      find_element(n, "category") do |d|
        parse_category(d)
      end
    end
  end

  private def parse_category(n)
    cat = parse_int(n, "id")
    each_element(n) do |d, d_name|
      case d_name.casecmp
      when "commands"
        parse_commands(cat, d)
      when "keys"
        parse_keys(cat, d)
      end
    end
  end

  private def parse_commands(cat, d)
    find_element(d, "cmd") do |c|
      add_category(CATEGORIES, cat, get_content(c).to_i)
    end
  end

  private def parse_keys(cat, d)
    find_element(d, "key") do |c|
      akey = ActionKey.new(cat)

      each_attribute(c) do |att, val|
        val = val.to_i

        case att
        when "cmd"
          akey.command_id = val
        when "key"
          akey.key_id = val
        when "toggleKey1"
          akey.toggle_key1 = val
        when "toggleKey2"
          akey.toggle_key2 = val
        when "showType"
          akey.show_status = val
        end
      end

      add_key(KEYS, cat, akey)
    end
  end

  def add_category(map, cat, cmd)
    (map[cat] ||= [] of Int32) << cmd
  end

  def add_key(map, cat, akey)
    (map[cat] ||= [] of ActionKey) << akey
  end
end
