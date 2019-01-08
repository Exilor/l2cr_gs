class Packets::Incoming::RequestConfirmCancelItem < GameClientPacket
  @l2id = 0

  def read_impl
    @l2id = d
  end

  def run_impl
    return unless pc = active_char
    return unless item = pc.inventory.get_item_by_l2id(@l2id)

    if item.owner_id != pc.l2id
      Util.punish(pc, "tried to destroy augment on an item he doesn't own.")
      return
    end

    unless item.augmented?
      pc.send_packet(SystemMessageId::AUGMENTATION_REMOVAL_CAN_ONLY_BE_DONE_ON_AN_AUGMENTED_ITEM)
      return
    end

    if item.pvp? && !Config.alt_allow_augment_pvp_items
      pc.send_packet(SystemMessageId::THIS_IS_NOT_A_SUITABLE_ITEM)
      return
    end

    price = 0
    case item.template.crystal_type
    when CrystalType::C
      if item.crystal_count < 1720
        price = 95_000
      elsif item.crystal_count < 2452
        price = 150_000
      else
        price = 210_000
      end
    when CrystalType::B
      if item.crystal_count < 1746
        price = 240_000
      else
        price = 270_000
      end
    when CrystalType::A
      if item.crystal_count < 2160
        price = 330_000
      elsif item.crystal_count < 2824
        price = 390_000
      else
        price = 420_000
      end
    when CrystalType::S
      price = 480_000
    when CrystalType::S80, CrystalType::S84
      price = 920_000
    else
      return
    end

    pc.send_packet(ExPutItemResultForVariationCancel.new(item, price))
  end
end
