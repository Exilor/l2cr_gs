module ItemHandler::EventItem
  extend self
  extend ItemHandler

  def use_item(playable, item, force)
    unless pc = playable.as?(L2PcInstance)
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    case item_id = item.id
    when 13787
      use_block_checker_item(pc, item)
    when 13788
      use_block_checker_item(pc, item)
    else
      warn { "Item with id #{item_id} is not handled." }
      false
    end
  end

  private def use_block_checker_item(pc : L2PcInstance, item : L2ItemInstance) : Bool
    arena = pc.block_checker_arena
    if arena == -1
      sm = SystemMessage.s1_cannot_be_used
      sm.add_item_name(item)
      pc.send_packet(sm)
      return false
    end

    unless sk = item.etc_item!.skills.not_nil!.first.skill?
      warn { "Skill for item #{item} not found." }
      return false
    end

    unless pc.destroy_item("Consume", item, 1, pc, true)
      return false
    end

    block = pc.target.as(L2BlockInstance)
    if holder = HandysBlockCheckerManager.get_holder(arena)
      team = holder.get_player_team(pc)
      block.known_list.get_known_players_in_radius(sk.effect_range) do |pc2|
        enemy_team = holder.get_player_team(pc2)
        if enemy_team != -1 && enemy_team != team
          sk.apply_effects(pc, pc2)
        end
      end

      return true
    end

    warn { "Player #{pc.name} [#{pc.l2id}] is in an unknown block checker arena." }

    false
  end
end
