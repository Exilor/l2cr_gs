require "./char_known_list"

class DecoyKnownList < CharKnownList
  def get_distance_to_forget_object(object : L2Object) : Int32
    if object == active_char.owner || object == active_char.target
      return 6000
    end

    3000
  end

  def get_distance_to_watch_object(object : L2Object) : Int32
    1500
  end

  def active_char : L2Decoy
    super.as(L2Decoy)
  end
end
