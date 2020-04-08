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
    doc.find_element("list") do |n|
      n.each_element do |d|
        case d.name
        when "shortcuts"
          parse_shortcuts(d)
        when "macros"
          parse_macros(d)
        else
          # automatically added
        end

      end
    end
  end

  private def parse_shortcuts(d)
    class_id_node = d["classId"]?
    list = [] of Shortcut
    d.find_element("page") do |c|
      page_id = c["pageId"].to_i
      c.find_element("slot") do |b|
        list << create_shortcut(page_id, b)
      end
    end

    if class_id_node
      temp = ClassId[class_id_node.to_i]
      INITIAL_SHORTCUT_DATA[temp] = list
    else
      INITIAL_GLOBAL_SHORTCUT_LIST.concat(list)
    end
  end

  private def parse_macros(d)
    d.find_element("macro") do |c|
      next unless c["enabled"]?.nil? || Bool.new(c["enabled"])
      macro_id = c["macroId"].to_i
      icon = c["icon"].to_i
      name = c["name"]
      description = c["description"]
      acronym = c["acronym"]
      commands = [] of MacroCMD
      entry = 0

      c.find_element("command") do |b|
        type = MacroType.parse(b["type"])
        d1 = d2 = 0
        cmd = b.text
        case type
        when .skill? # MacroType::SKILL
          d1 = b["skillId"].to_i
          d2 = b["skillLvl"].to_i
        when .action? # MacroType::ACTION
          d1 = b["actionId"].to_i
        when .text? # MacroType::TEXT
          # nothing to do
        when .shortcut? # MacroType::SHORTCUT
          d1 = b["page"].to_i
          d2 = b["slot"].to_i
        when .item? # MacroType::ITEM
          d1 = b["itemId"].to_i
        when .delay? # MacroType::DELAY
          d1 = b["delay"].to_i
        else
          # automatically added
        end

        commands << MacroCMD.new(entry, type, d1, d2, cmd)
        entry += 1
      end

      mcr = Macro.new(macro_id, icon, name, description, acronym, commands)
      MACRO_PRESETS[macro_id] = mcr
    end
  end

  private def create_shortcut(page, b)
    slot = b["slotId"].to_i
    type = ShortcutType.parse(b["shortcutType"])
    id = b["shortcutId"].to_i
    level = b["shortcutLevel"]?.try &.to_i || 0
    char_type = b["characterType"]?.try &.to_i || 0
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
        # automatically added
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
        # automatically added
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