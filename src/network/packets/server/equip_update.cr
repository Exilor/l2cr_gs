class Packets::Outgoing::EquipUpdate < GameServerPacket
  initializer item : L2ItemInstance, change : Int32

  private def write_impl
    c 0x4b

    d @change
    d @item.l2id
    case @item.template.body_part
    when L2Item::SLOT_L_EAR
      d 0x01
    when L2Item::SLOT_R_EAR
      d 0x02
    when L2Item::SLOT_NECK
      d 0x03
    when L2Item::SLOT_R_FINGER
      d 0x04
    when L2Item::SLOT_L_FINGER
      d 0x05
    when L2Item::SLOT_HEAD
      d 0x06
    when L2Item::SLOT_R_HAND
      d 0x07
    when L2Item::SLOT_L_HAND
      d 0x08
    when L2Item::SLOT_GLOVES
      d 0x09
    when L2Item::SLOT_CHEST
      d 0x0a
    when L2Item::SLOT_LEGS
      d 0x0b
    when L2Item::SLOT_FEET
      d 0x0c
    when L2Item::SLOT_BACK
      d 0x0d
    when L2Item::SLOT_LR_HAND
      d 0x0e
    when L2Item::SLOT_HAIR
      d 0x0f
    when L2Item::SLOT_BELT
      d 0x10
    else
      # [automatically added else]
    end

  end
end
