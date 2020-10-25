require "../../enums/crystal_type"

module EnchantItemHPBonusData
  extend self
  extend XMLReader

  private FULL_ARMOR_MODIFIER = 1.5f32 # L2J wants to move this to config
  # private ARMOR_HP_BONUSES = Hash(CrystalType, Array(Int32)).new
  private ARMOR_HP_BONUSES = EnumMap(CrystalType, Array(Int32)).new

  def load
    ARMOR_HP_BONUSES.clear
    parse_datapack_file("stats/enchantHPBonus.xml")
    info { "Loaded #{ARMOR_HP_BONUSES.size} enchant HP bonuses." }
  end

  private def parse_document(doc, file)
    find_element(doc, "list") do |n|
      find_element(n, "enchantHP") do |d|
        bonuses = [] of Int32
        find_element(d, "bonus") { |e| bonuses << get_content(e).to_i }
        grade = parse_enum(d, "grade", CrystalType)
        ARMOR_HP_BONUSES[grade] = bonuses
      end
    end

    unless ARMOR_HP_BONUSES.empty?
      ItemTable.all_armors_id.each do |item_id|
        item = ItemTable[item_id]
        unless item.crystal_type.none?
          case item.body_part
          when L2Item::SLOT_CHEST, L2Item::SLOT_FEET, L2Item::SLOT_GLOVES,
               L2Item::SLOT_HEAD, L2Item::SLOT_LEGS, L2Item::SLOT_BACK,
               L2Item::SLOT_FULL_ARMOR, L2Item::SLOT_UNDERWEAR,
               L2Item::SLOT_L_HAND, L2Item::SLOT_BELT

            ft = FuncTemplate.new(nil, nil, StatFunction::ENCHANTHP.name, -1, Stats::MAX_HP, 0)
            item.attach(ft)
          end

        end
      end
    end
  end

  def get_hp_bonus(item : L2ItemInstance) : Int32
    return 0 if item.oly_enchant_level <= 0

    values = ARMOR_HP_BONUSES[item.template.item_grade_s_plus]?

    if !values || values.empty?
      return 0
    end

    bonus = values[Math.min(item.oly_enchant_level, values.size) &- 1]

    if item.template.body_part == L2Item::SLOT_FULL_ARMOR
      return (bonus * FULL_ARMOR_MODIFIER).to_i
    end

    bonus
  end
end
