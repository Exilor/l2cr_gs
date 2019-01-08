class Packets::Incoming::RequestConfirmGemStone < Packets::Incoming::AbstractRefinePacket
  @target_item_obj_id = 0
  @refiner_item_obj_id = 0
  @gemstone_item_obj_id = 0
  @gemstone_count = 0i64

  def read_impl
    @target_item_obj_id = d
    @refiner_item_obj_id = d
    @gemstone_item_obj_id = d
    @gemstone_count = q
  end

  def run_impl
    return unless pc = active_char
    return unless target_item = pc.inventory.get_item_by_l2id(@target_item_obj_id)
    return unless refiner_item = pc.inventory.get_item_by_l2id(@refiner_item_obj_id)
    return unless gemstone_item = pc.inventory.get_item_by_l2id(@gemstone_item_obj_id)

    unless valid?(pc, target_item, refiner_item, gemstone_item)
      pc.send_packet(SystemMessageId::THIS_IS_NOT_A_SUITABLE_ITEM)
      return
    end

    return unless ls = get_life_stone(refiner_item.id)

    if @gemstone_count != get_gemstone_count(target_item.template.item_grade, ls.grade)
      pc.send_packet(SystemMessageId::GEMSTONE_QUANTITY_IS_INCORRECT)
      return
    end

    packet = ExPutCommissionResultForVariationMake.new(@gemstone_item_obj_id, @gemstone_count, gemstone_item.id)
    pc.send_packet(packet)
  end
end
