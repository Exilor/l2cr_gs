require "./npc_known_list"

class TrapKnownList < NpcKnownList
  def get_distance_to_forget_object(object : L2Object) : Int32
    if object == active_char.acting_player || object == active_char.target
      return 6000
    end

    3000
  end

  def get_distance_to_watch_object(object : L2Object) : Int32
    1500
  end

  def active_char
    super.as(L2TrapInstance)
  end
end
