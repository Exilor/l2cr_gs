require "./char_known_list"

class StaticObjectKnownList < CharKnownList
  def get_distance_to_forget_object(object : L2Object) : Int32
    case object
    when L2DefenderInstance
      800
    when L2PcInstance
      4000
    else
      0
    end
  end

  def get_distance_to_watch_object(object : L2Object) : Int32
    case object
    when L2DefenderInstance
      600
    when L2PcInstance
      2000
    else
      0
    end
  end

  def active_char
    super.as(L2StaticObjectInstance)
  end
end
