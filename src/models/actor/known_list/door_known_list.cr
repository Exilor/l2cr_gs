require "./char_known_list"

class DoorKnownList < CharKnownList
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
      3500
    else
      0
    end
  end

  def active_char : L2DoorInstance
    super.as(L2DoorInstance)
  end
end
