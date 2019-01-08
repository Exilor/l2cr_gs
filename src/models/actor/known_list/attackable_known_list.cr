require "./npc_known_list"

class AttackableKnownList < NpcKnownList
  def remove_known_object(object : L2Object, forget : Bool) : Bool
    return false unless super

    if object.character?
      active_char.aggro_list.delete(object)
    end

    if active_char.ai? && known_players.empty? && !active_char.walker?
      active_char.intention = AI::IDLE
    end

    true
  end

  def get_distance_to_forget_object(object : L2Object) : Int32
    (get_distance_to_watch_object(object) * 1.5).to_i
  end

  def get_distance_to_watch_object(object : L2Object) : Int32
    return 0 unless object.character?

    if object.playable?
      return object.known_list.get_distance_to_watch_object(active_char)
    end

    att = active_char
    Math.max(300, Math.max(att.aggro_range, att.template.clan_help_range))
  end

  def active_char
    super.as(L2Attackable)
  end
end
