require "../known_list/guard_known_list"

class L2GuardInstance < L2Attackable
  def instance_type
    InstanceType::L2GuardInstance
  end

  def init_known_list
    @known_list = GuardKnownList.new(self)
  end

  def get_html_path(npc_id, val)
    pom = val == 0 ? npc_id : "#{npc_id}-#{val}"
    "data/html/guard/#{pom}.htm"
  end

  def on_action(pc, interact = true)
    return unless can_target?(pc)

    if l2id != pc.target_id
      pc.target = self
    elsif interact
      if in_aggro_list?(pc)
        if Config.debug
          debug "#{pc.name} attacked guard #{l2id}."
        end
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
