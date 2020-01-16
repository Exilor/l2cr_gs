require "../known_list/guard_known_list"

class L2GuardInstance < L2Attackable
  def instance_type : InstanceType
    InstanceType::L2GuardInstance
  end

  private def init_known_list
    @known_list = GuardKnownList.new(self)
  end

  def get_html_path(npc_id, val)
    if val == 0
      "data/html/guard/#{npc_id}.htm"
    else
      "data/html/guard/#{npc_id}-#{val}.htm"
    end
  end

  def on_action(pc : L2PcInstance, interact : Bool)
    return unless can_target?(pc)

    if l2id != pc.target_id
      pc.target = self
    elsif interact
      if in_aggro_list?(pc)
        pc.set_intention(AI::ATTACK, self)
      else
        if can_interact?(pc)
          broadcast_packet(SocialAction.new(l2id, Rnd.rand(8)))
          pc.last_folk_npc = self
          if has_listener?(EventType::ON_NPC_QUEST_START)
            pc.last_quest_npc_l2id = l2id
          end
          if has_listener?(EventType::ON_NPC_FIRST_TALK)
            OnNpcFirstTalk.new(self, pc).async(self)
          else
            show_chat_window(pc, 0)
          end
        else
          pc.set_intention(AI::INTERACT, self)
        end
      end
    end

    pc.action_failed
  end

  def on_spawn
    self.no_rnd_walk = true
    super

    if region = L2World.get_region(x, y)
      unless region.active?
        ai.stop_ai_task
      end
    end
  end
end
