require "./l2_character_ai"

class L2VehicleAI < L2CharacterAI
  private def on_intention_attack(arg)
  end

  private def on_intention_cast(skill : Skill, target : L2Object?)
  end

  private def on_intention_follow(arg)
  end

  private def on_intention_pick_up(arg)
  end

  private def on_intention_interact(arg)
  end

  private def on_event_attacked(arg)
  end

  private def on_event_aggression(arg1, arg2)
  end

  private def on_event_stunned(arg)
  end

  private def on_event_sleeping(arg)
  end

  private def on_event_rooted(arg)
  end

  private def on_event_forget_object(arg)
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

  def move_to_pawn(arg1, arg2)
  end

  private def client_stopped_moving
  end
end
