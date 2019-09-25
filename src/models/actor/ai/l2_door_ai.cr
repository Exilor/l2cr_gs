require "./l2_character_ai"

class L2DoorAI < L2CharacterAI
  def on_intention_idle
  end

  def on_intention_active
  end

  def on_intention_rest
  end

  def on_intention_attack(target)
  end

  def on_intention_cast(skill, target)
  end

  def on_intention_move_to(destination)
  end

  def on_intention_follow(target)
  end

  def on_intention_pick_up(item)
  end

  def on_intention_interact(object)
  end

  def on_event_think
  end

  def on_event_attacked(attacker : L2Character)
    task = OnEventAttackedDoorTask.new(@actor.as(L2DoorInstance), attacker)
    ThreadPoolManager.execute_general(task)
  end

  def on_event_aggression(target, aggro)
  end

  def on_event_stunned(attacker)
  end

  def on_event_sleeping(attacker)
  end

  def on_event_rooted(attacker)
  end

  def on_event_ready_to_act
  end

  def on_event_user_cmd(arg0, arg1)
  end

  def on_event_arrived
  end

  def on_event_arrived_revalidate
  end

  def on_event_arrived_blocked(location)
  end

  def on_event_forget_object(object)
  end

  def on_event_cancel
  end

  def on_event_dead
  end

  struct OnEventAttackedDoorTask
    initializer door : L2DoorInstance, attacker : L2Character

    def call
      @door.known_defenders do |guard|
        if @door.inside_radius?(guard, guard.template.clan_help_range, false, true)
          if (@attacker.z - guard.z).abs < 200
            guard.notify_event(AGGRESSION, @attacker, 15)
          end
        end
      end
    end
  end
end
