module ItemHandler::ExtractableItems
  extend self
  extend ItemHandler

  def use_item(playable, item, force)
    unless playable.player?
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    pc = playable.acting_player
    etc_item = item.template.as(L2EtcItem)
    unless exitem = etc_item.extractable_items
      warn { "No extractable items for #{exitem}." }
      return false
    end

    unless pc.destroy_item("Extract", item.l2id, 1, pc, true)
      debug "destroy_item returned false."
      return false
    end

    created = false

    exitem.each do |expi|
      if Rnd.rand(100000) <= expi.chance
        min = (expi.min * Config.rate_extractable).to_i64
        max = (expi.max * Config.rate_extractable).to_i64

        create_item_amount = max == min ? min : Rnd.rand((max - min) + 1) + min
        next if create_item_amount == 0

        if item.stackable? || create_item_amount == 1
          pc.add_item("Extract", expi.id, create_item_amount, -1, pc, true)
        else
          create_item_amount.times do
            pc.add_item("Extract", expi.id, 1, -1, pc, true)
          end
        end
        created = true
      end
    end

    unless created
      pc.send_packet(SystemMessageId::NOTHING_INSIDE_THAT)
    end

    true
  end
end
