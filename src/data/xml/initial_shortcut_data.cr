module InitialShortcutData
  extend self
  extend XMLReader

  private INITIAL_SHORTCUT_DATA = EnumMap(ClassId, Array(Shortcut)).new
  private INITIAL_GLOBAL_SHORTCUT_LIST = [] of Shortcut
  private MACRO_PRESETS = {} of Int32 => Macro

  def load
    INITIAL_SHORTCUT_DATA.clear
    INITIAL_GLOBAL_SHORTCUT_LIST.clear

    parse_datapack_file("stats/initialShortcuts.xml")

    info { "Loaded #{INITIAL_GLOBAL_SHORTCUT_LIST.size} global initial shortcuts." }
    info { "Loaded #{INITIAL_SHORTCUT_DATA.size} initial shortcuts" }
    info { "Loaded #{MACRO_PRESETS.size} macro presets." }
  end

  private def parse_document(doc, file)
    find_element(doc, "list") do |n|
      each_element(n) do |d, d_name|
        case d_name
        when "shortcuts"
          parse_shortcuts(d)
        when "macros"
          parse_macros(d)
        else
          # [automatically added else]
        end
      end
    end
  end

  private def parse_shortcuts(d)
    list = [] of Shortcut
    find_element(d, "page") do |c|
      page_id = parse_int(c, "pageId")
      find_element(c, "slot") do |b|
        list << create_shortcut(page_id, b)
      end
    end

    if class_id = parse_int(d, "classId", nil)
      temp = ClassId[class_id]
      INITIAL_SHORTCUT_DATA[temp] = list
    else
      INITIAL_GLOBAL_SHORTCUT_LIST.concat(list)
    end
  end

  private def parse_macros(d)
    find_element(d, "macro") do |c|
      next if parse_bool(c, "enabled", nil) == false
      macro_id = parse_int(c, "macroId")
      icon = parse_int(c, "icon")
      name = parse_string(c, "name")
      description = parse_string(c, "description")
      acronym = parse_string(c, "acronym")
      commands = [] of MacroCMD
      entry = 0

      find_element(c, "command") do |b|
        type = parse_enum(b, "type", MacroType)
        d1 = d2 = 0
        cmd = get_content(b)
        case type
         when MacroType::SKILL
          d1 = parse_int(b, "skillId")
          d2 = parse_int(b, "skillLvl")
        when MacroType::ACTION
          d1 = parse_int(b, "actionId")
        when MacroType::TEXT
          # nothing to do
        when MacroType::SHORTCUT
          d1 = parse_int(b, "page")
          d2 = parse_int(b, "slot")
        when MacroType::ITEM
          d1 = parse_int(b, "itemId")
        when MacroType::DELAY
          d1 = parse_int(b, "delay")
        else
          # [automatically added else]
        end

        commands << MacroCMD.new(entry, type, d1, d2, cmd)
        entry &+= 1
      end

      mcr = Macro.new(macro_id, icon, name, description, acronym, commands)
      MACRO_PRESETS[macro_id] = mcr
    end
  end

  private def create_shortcut(page, b)
    slot = parse_int(b, "slotId")
    type = parse_enum(b, "shortcutType", ShortcutType)
    id = parse_int(b, "shortcutId")
    level = parse_int(b, "shortcutLevel", 0)
    char_type = parse_int(b, "characterType", 0)
    Shortcut.new(slot, page, type, id, level, char_type)
  end

  def get_shortcut_list(id : Int32) : Array(Shortcut)?
    class_id = ClassId.fetch(id) { raise "No ClassId with id #{id}" }
    get_shortcut_list(class_id)
  end

  def get_shortcut_list(class_id : ClassId) : Array(Shortcut)?
    INITIAL_SHORTCUT_DATA[class_id]?
  end

  def global_macro_list : Array(Shortcut)
    INITIAL_GLOBAL_SHORTCUT_LIST
  end

  def register_all_shortcuts(pc : L2PcInstance)
    INITIAL_GLOBAL_SHORTCUT_LIST.each do |sc1|
      shortcut_id = sc1.id
      case sc1.type
      when ShortcutType::ITEM
        next unless item = pc.inventory.get_item_by_item_id(shortcut_id)
        shortcut_id = item.l2id
      when ShortcutType::SKILL
        next unless pc.skills.has_key?(shortcut_id)
      when ShortcutType::MACRO
        next unless mcr = MACRO_PRESETS[shortcut_id]
        pc.register_macro(mcr)
      else
        # [automatically added else]
      end

      sc2 = Shortcut.new(sc1.slot, sc1.page, sc1.type, shortcut_id, sc1.level, sc1.character_type)
      pc.send_packet(Packets::Outgoing::ShortcutRegister.new(sc2))
      pc.register_shortcut(sc2)
    end

    INITIAL_SHORTCUT_DATA[pc.class_id]?.try &.each do |sc1|
      shortcut_id = sc1.id
      case sc1.type
      when ShortcutType::ITEM
        next unless item = pc.inventory.get_item_by_item_id(shortcut_id)
        shortcut_id = item.l2id
      when ShortcutType::SKILL
        next unless pc.skills.has_key?(shortcut_id)
      when ShortcutType::MACRO
        next unless mcr = MACRO_PRESETS[shortcut_id]?
        pc.register_macro(mcr)
      else
        # [automatically added else]
      end

      sc2 = Shortcut.new(sc1.slot, sc1.page, sc1.type, shortcut_id, sc1.level, sc1.character_type)
      pc.send_packet(Packets::Outgoing::ShortcutRegister.new(sc2))
      pc.register_shortcut(sc2)
    end

    # custom
    MACRO_PRESETS.each_value do |mcr|
      pc.register_macro(mcr)
    end
    #
  end
end
