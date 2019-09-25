module ActionHandler::L2NpcAction
  extend self
  extend ActionHandler

  def action(pc : L2PcInstance, target : L2Object, interact : Bool) : Bool
    return false unless npc = target.as?(L2Npc)

    pc.last_folk_npc = npc

    if npc != pc.target
      pc.target = npc

      if npc.auto_attackable?(pc)
        npc.ai # wake up ai
      end
    elsif interact
      if npc.auto_attackable?(pc) && !npc.looks_dead?
        if GeoData.can_see_target?(pc, npc)
          pc.set_intention(AI::ATTACK, npc)
        else
          dst = GeoData.move_check(pc, npc)
          pc.set_intention(AI::MOVE_TO, dst)
        end
      elsif !npc.auto_attackable?(pc)
        unless GeoData.can_see_target?(pc, npc)
          dst = GeoData.move_check(pc, npc)
          pc.set_intention(AI::MOVE_TO, dst)
          return true
        end

        if !npc.can_interact?(pc)
          pc.set_intention(AI::INTERACT, npc)
        else
          pc.send_packet(MoveToPawn.new(pc, npc, 100))
          if npc.has_random_animation?
            npc.on_random_animation(rand(8))
          end

          if npc.event_mob?
            L2Event.show_event_html(pc, npc.l2id.to_s)
          else
            if npc.has_listener?(EventType::ON_NPC_QUEST_START)
              pc.last_quest_npc_l2id = npc.l2id
            end

            if npc.has_listener?(EventType::ON_NPC_FIRST_TALK)
              OnNpcFirstTalk.new(npc, pc).async(npc)
            else
              npc.show_chat_window(pc)
            end
          end

          if Config.player_movement_block_time > 0 && !pc.gm?
            pc.update_not_move_until
          end
        end
      end
    end

    true
  end

  def instance_type : InstanceType
    InstanceType::L2Npc
  end
end
