require "./l2_character_ai"

class L2VehicleAI < L2CharacterAI
  private def on_intention_attack(target : L2Character?)
  end

  private def on_intention_cast(skill : Skill, target : L2Object?)
  end

  private def on_intention_follow(target : L2Character)
  end

  private def on_intention_pick_up(object : L2Object)
  end

  private def on_intention_interact(object : L2Object)
  end

  private def on_event_attacked(attacker : L2Character?)
  end

  private def on_event_aggression(target : L2Character?, aggro : Int64)
  end

  private def on_event_stunned(attacker : L2Character?)
  end

  private def on_event_sleeping(attacker : L2Character?)
  end

  private def on_event_rooted(attacker : L2Character?)
  end

  private def on_event_forget_object(object : L2Object?)
  end

  private def on_event_cancel
  end

  private def on_event_dead
  end

  private def on_event_fake_death
  end

  private def on_event_finish_casting
  end

  private def client_action_failed
  end

  def move_to_pawn(pawn : L2Object, offset : Int32)
  end

  private def client_stopped_moving
  end
end
