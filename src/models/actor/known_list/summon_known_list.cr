require "./playable_known_list"

class SummonKnownList < PlayableKnownList
  def get_distance_to_forget_object(object : L2Object) : Int32
    if object == active_char.owner || object == active_char.target
      return 6000
    end

    3000
  end

  def get_distance_to_watch_object(object : L2Object) : Int32
    1500
  end

  def active_char
    super.as(L2Summon)
  end
end
