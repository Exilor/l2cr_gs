abstract class Packets::Incoming::AbstractRefinePacket < GameClientPacket
  GRADE_NONE = 0
  GRADE_MID = 1
  GRADE_HIGH = 2
  GRADE_TOP = 3
  GRADE_ACC = 4 # Accessory LS

  private GEMSTONE_D = 2130
  private GEMSTONE_C = 2131
  private GEMSTONE_B = 2132

  private struct LifeStone
    private LEVELS = {46, 49, 52, 55, 58, 61, 64, 67, 70, 76, 80, 82, 84, 85}

    getter_initializer grade : Int32, level : Int32

    def player_level : Int32
      LEVELS[@level]
    end
  end

  # should be private but it's used in custom code in UseItem
  LIFE_STONES = {
    # itemId, (LS grade, LS level)
    8723 => LifeStone.new(GRADE_NONE, 0),
    8724 => LifeStone.new(GRADE_NONE, 1),
    8725 => LifeStone.new(GRADE_NONE, 2),
    8726 => LifeStone.new(GRADE_NONE, 3),
    8727 => LifeStone.new(GRADE_NONE, 4),
    8728 => LifeStone.new(GRADE_NONE, 5),
    8729 => LifeStone.new(GRADE_NONE, 6),
    8730 => LifeStone.new(GRADE_NONE, 7),
    8731 => LifeStone.new(GRADE_NONE, 8),
    8732 => LifeStone.new(GRADE_NONE, 9),

    8733 => LifeStone.new(GRADE_MID, 0),
    8734 => LifeStone.new(GRADE_MID, 1),
    8735 => LifeStone.new(GRADE_MID, 2),
    8736 => LifeStone.new(GRADE_MID, 3),
    8737 => LifeStone.new(GRADE_MID, 4),
    8738 => LifeStone.new(GRADE_MID, 5),
    8739 => LifeStone.new(GRADE_MID, 6),
    8740 => LifeStone.new(GRADE_MID, 7),
    8741 => LifeStone.new(GRADE_MID, 8),
    8742 => LifeStone.new(GRADE_MID, 9),

    8743 => LifeStone.new(GRADE_HIGH, 0),
    8744 => LifeStone.new(GRADE_HIGH, 1),
    8745 => LifeStone.new(GRADE_HIGH, 2),
    8746 => LifeStone.new(GRADE_HIGH, 3),
    8747 => LifeStone.new(GRADE_HIGH, 4),
    8748 => LifeStone.new(GRADE_HIGH, 5),
    8749 => LifeStone.new(GRADE_HIGH, 6),
    8750 => LifeStone.new(GRADE_HIGH, 7),
    8751 => LifeStone.new(GRADE_HIGH, 8),
    8752 => LifeStone.new(GRADE_HIGH, 9),

    8753 => LifeStone.new(GRADE_TOP, 0),
    8754 => LifeStone.new(GRADE_TOP, 1),
    8755 => LifeStone.new(GRADE_TOP, 2),
    8756 => LifeStone.new(GRADE_TOP, 3),
    8757 => LifeStone.new(GRADE_TOP, 4),
    8758 => LifeStone.new(GRADE_TOP, 5),
    8759 => LifeStone.new(GRADE_TOP, 6),
    8760 => LifeStone.new(GRADE_TOP, 7),
    8761 => LifeStone.new(GRADE_TOP, 8),
    8762 => LifeStone.new(GRADE_TOP, 9),

    9573 => LifeStone.new(GRADE_NONE, 10),
    9574 => LifeStone.new(GRADE_MID, 10),
    9575 => LifeStone.new(GRADE_HIGH, 10),
    9576 => LifeStone.new(GRADE_TOP, 10),

    10483 => LifeStone.new(GRADE_NONE, 11),
    10484 => LifeStone.new(GRADE_MID, 11),
    10485 => LifeStone.new(GRADE_HIGH, 11),
    10486 => LifeStone.new(GRADE_TOP, 11),

    12754 => LifeStone.new(GRADE_ACC, 0),
    12755 => LifeStone.new(GRADE_ACC, 1),
    12756 => LifeStone.new(GRADE_ACC, 2),
    12757 => LifeStone.new(GRADE_ACC, 3),
    12758 => LifeStone.new(GRADE_ACC, 4),
    12759 => LifeStone.new(GRADE_ACC, 5),
    12760 => LifeStone.new(GRADE_ACC, 6),
    12761 => LifeStone.new(GRADE_ACC, 7),
    12762 => LifeStone.new(GRADE_ACC, 8),
    12763 => LifeStone.new(GRADE_ACC, 9),

    12821 => LifeStone.new(GRADE_ACC, 10),
    12822 => LifeStone.new(GRADE_ACC, 11),

    12840 => LifeStone.new(GRADE_ACC, 0),
    12841 => LifeStone.new(GRADE_ACC, 1),
    12842 => LifeStone.new(GRADE_ACC, 2),
    12843 => LifeStone.new(GRADE_ACC, 3),
    12844 => LifeStone.new(GRADE_ACC, 4),
    12845 => LifeStone.new(GRADE_ACC, 5),
    12846 => LifeStone.new(GRADE_ACC, 6),
    12847 => LifeStone.new(GRADE_ACC, 7),
    12848 => LifeStone.new(GRADE_ACC, 8),
    12849 => LifeStone.new(GRADE_ACC, 9),
    12850 => LifeStone.new(GRADE_ACC, 10),
    12851 => LifeStone.new(GRADE_ACC, 11),

    14008 => LifeStone.new(GRADE_ACC, 12),

    14166 => LifeStone.new(GRADE_NONE, 12),
    14167 => LifeStone.new(GRADE_MID, 12),
    14168 => LifeStone.new(GRADE_HIGH, 12),
    14169 => LifeStone.new(GRADE_TOP, 12),

    16160 => LifeStone.new(GRADE_NONE, 13),
    16161 => LifeStone.new(GRADE_MID, 13),
    16162 => LifeStone.new(GRADE_HIGH, 13),
    16163 => LifeStone.new(GRADE_TOP, 13),
    16177 => LifeStone.new(GRADE_ACC, 13),

    16164 => LifeStone.new(GRADE_NONE, 13),
    16165 => LifeStone.new(GRADE_MID, 13),
    16166 => LifeStone.new(GRADE_HIGH, 13),
    16167 => LifeStone.new(GRADE_TOP, 13),
    16178 => LifeStone.new(GRADE_ACC, 13)
  }

  private def get_life_stone(item_id : Int32) : LifeStone
    LIFE_STONES[item_id]
  end

  private def valid?(pc : L2PcInstance, item : L2ItemInstance? = nil, refiner_item : L2ItemInstance? = nil, gem_stones : L2ItemInstance? = nil) : Bool
    case
    when gem_stones
      return false unless valid?(pc, item, refiner_item)
      item = item.not_nil!
      refiner_item = refiner_item.not_nil!
      return false unless gem_stones.owner_id == pc.l2id
      return false unless gem_stones.item_location.inventory?
      grade = item.template.item_grade
      return false unless get_gemstone_id(grade) == gem_stones.id
      ls = LIFE_STONES[refiner_item.id]
      return false if get_gemstone_count(grade, ls.grade) > gem_stones.count
      true
    when refiner_item
      return false unless valid?(pc, item)
      return false unless refiner_item.owner_id == pc.l2id
      return false unless refiner_item.item_location.inventory?
      return false unless ls = LIFE_STONES[refiner_item.id]?
      item = item.not_nil!
      return false if item.template.is_a?(L2Weapon) && ls.grade == GRADE_ACC
      return false if item.template.is_a?(L2Armor) && ls.grade != GRADE_ACC
      return false if pc.level < ls.player_level
      true
    when item
      return false unless valid?(pc)
      return false unless item.owner_id == pc.l2id
      return false if item.augmented?
      return false if item.hero_item?
      return false if item.shadow_item?
      return false if item.common_item?
      return false if item.etc_item?
      return false if item.time_limited_item?
      return false if item.pvp? && !Config.alt_allow_augment_pvp_items
      return false if item.template.crystal_type < CrystalType::C

      case item.item_location
      when ItemLocation::INVENTORY, ItemLocation::PAPERDOLL
      else return false
      end

      if item.template.is_a?(L2Weapon)
        case item.template.item_type
        when WeaponType::NONE, WeaponType::FISHINGROD
          return false
        end
      elsif item.template.is_a?(L2Armor)
        case item.template.body_part
        when L2Item::SLOT_LR_FINGER, L2Item::SLOT_LR_EAR, L2Item::SLOT_NECK
        else return false
        end
      else
        return false # will never happen
      end

      return false if Config.augmentation_blacklist.includes?(item.id)

      true
    else
      unless pc.private_store_type.none?
        pc.send_packet(SystemMessageId::YOU_CANNOT_AUGMENT_ITEMS_WHILE_A_PRIVATE_STORE_OR_PRIVATE_WORKSHOP_IS_IN_OPERATION)
        return false
      end

      if pc.active_trade_list
        pc.send_packet(SystemMessageId::YOU_CANNOT_AUGMENT_ITEMS_WHILE_TRADING)
        return false
      end

      if pc.dead?
        pc.send_packet(SystemMessageId::YOU_CANNOT_AUGMENT_ITEMS_WHILE_DEAD)
        return false
      end

      if pc.paralyzed?
        pc.send_packet(SystemMessageId::YOU_CANNOT_AUGMENT_ITEMS_WHILE_PARALYZED)
        return false
      end

      if pc.fishing?
        pc.send_packet(SystemMessageId::YOU_CANNOT_AUGMENT_ITEMS_WHILE_FISHING)
        return false
      end

      if pc.sitting?
        pc.send_packet(SystemMessageId::YOU_CANNOT_AUGMENT_ITEMS_WHILE_SITTING_DOWN)
        return false
      end

      return false if pc.cursed_weapon_equipped?
      return false if pc.enchanting?
      return false if pc.processing_transaction?

      true
    end
  end

  private def get_gemstone_id(type : CrystalType) : Int32
    case type
    when .c?, .b?
      GEMSTONE_D
    when .a?, .s?
      GEMSTONE_C
    when .s80?, .s84?
      GEMSTONE_B
    else 0
    end
  end

  private def get_gemstone_count(type : CrystalType, ls_grade : Int32) : Int32
    case ls_grade
    when GRADE_ACC
      case type
      when .c?
        200
      when .b?
        300
      when .a?
        200
      when .s?
        250
      when .s80?
        360
      when .s84?
        480
      else
        0
      end
    else
      case type
      when .c?
        20
      when .b?
        30
      when .a?
        20
      when .s?
        25
      when .s80?, .s84?
        36
      else
        0
      end
    end
  end
end
