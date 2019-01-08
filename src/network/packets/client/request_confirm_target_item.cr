class Packets::Incoming::RequestConfirmTargetItem < Packets::Incoming::AbstractRefinePacket
  @item_l2id = 0

  def read_impl
    @item_l2id = d
  end

  def run_impl
    return unless pc = active_char
    return unless item = pc.inventory.get_item_by_l2id(@item_l2id)

    unless valid?(pc, item)
      if item.augmented?
        pc.send_packet(SystemMessageId::ONCE_AN_ITEM_IS_AUGMENTED_IT_CANNOT_BE_AUGMENTED_AGAIN)
        return
      end

      pc.send_packet(SystemMessageId::THIS_IS_NOT_A_SUITABLE_ITEM)
      return
    end

    pc.send_packet(ExPutItemResultForVariationMake.new(@item_l2id, item.id))
  end
end
