module ItemHandler::CharmOfCourage
  extend self
  extend ItemHandler

  def use_item(playable, item, force)
    return false unless playable.player?

    pc = playable.acting_player
    level = pc.level
    item_level = item.template.item_grade.to_i

    level =
    case
    when level < 20 then 0
    when level < 40 then 1
    when level < 52 then 2
    when level < 61 then 3
    when level < 76 then 4
    else 5
    end

    if item_level < level
      sm = SystemMessage.s1_cannot_be_used
      sm.add_item_name(item.id)
      pc.send_packet(sm)
      return false
    end

    if pc.destroy_item_without_trace("Consume", item.l2id, 1, nil, false)
      pc.charm_of_courage = true
      pc.send_packet(EtcStatusUpdate.new(pc))
      true
    else
      false
    end
  end
end
