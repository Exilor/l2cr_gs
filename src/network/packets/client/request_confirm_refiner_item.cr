class Packets::Incoming::RequestConfirmRefinerItem < Packets::Incoming::AbstractRefinePacket
  @target_id = 0
  @refiner_id = 0

  private def read_impl
    @target_id = d
    @refiner_id = d
  end

  private def run_impl
    return unless pc = active_char
    return unless target_item = pc.inventory.get_item_by_l2id(@target_id)
    return unless refiner_item = pc.inventory.get_item_by_l2id(@refiner_id)

    unless valid?(pc, target_item, refiner_item)
      pc.send_packet(SystemMessageId::THIS_IS_NOT_A_SUITABLE_ITEM)
      return
    end

    refiner_item_id = refiner_item.template.id
    grade = target_item.template.item_grade
    ls = get_life_stone(refiner_item_id)
    gemstone_id = get_gemstone_id(grade)
    gemstone_count = get_gemstone_count(grade, ls.grade)

    packet = ExPutIntensiveResultForVariationMake.new(@refiner_id, refiner_item_id, gemstone_id, gemstone_count)
    pc.send_packet(packet)
  end
end
