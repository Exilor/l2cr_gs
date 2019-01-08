module EnchantItemHPBonusData
  extend self
  extend XMLReader

  private FULL_ARMOR_MODIFIER = 1.5f32 # L2J wants to move this to config
  private ARMOR_HP_BONUSES = Hash(CrystalType, Array(Int32)).new

  def load
    ARMOR_HP_BONUSES.clear
    parse_datapack_file("stats/enchantHPBonus.xml")
    info "Loaded #{ARMOR_HP_BONUSES.size} enchant HP bonuses."
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |n|
      n.find_element("enchantHP") do |d|
        bonuses = [] of Int32
        d.find_element("bonus") { |e| bonuses << e.content.to_i }
        grade = CrystalType.parse(d["grade"])
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

    bonus = values[Math.min(item.oly_enchant_level, values.size) - 1]

    if item.template.body_part == L2Item::SLOT_FULL_ARMOR
      (bonus * FULL_ARMOR_MODIFIER).to_i
    else
      bonus
    end
  end
end
