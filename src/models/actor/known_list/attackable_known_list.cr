require "./npc_known_list"

class AttackableKnownList < NpcKnownList
  def remove_known_object(object : L2Object, forget : Bool) : Bool
    return false unless super

    me = active_char

    if object.character?
      me.aggro_list.delete(object)
    end

    if me.ai? && known_players.empty? && !me.walker?
      me.intention = AI::IDLE
    end

    true
  end

  def get_distance_to_forget_object(object : L2Object) : Int32
    (get_distance_to_watch_object(object) * 1.5).to_i
  end

  def get_distance_to_watch_object(object : L2Object) : Int32
    return 0 unless object.character?

    me = active_char

    if object.playable?
      return object.known_list.get_distance_to_watch_object(me)
    end

    Math.max(300, Math.max(me.aggro_range, me.template.clan_help_range))
  end

  def active_char : L2Attackable
    super.as(L2Attackable)
  end
end
