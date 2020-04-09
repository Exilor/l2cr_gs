require "./char_known_list"

class StaticObjectKnownList < CharKnownList
  def get_distance_to_forget_object(object : L2Object) : Int32
    case object
    when L2PcInstance
      return 4000
    when L2DefenderInstance
      return 800
    else
      # [automatically added else]
    end


    0
  end

  def get_distance_to_watch_object(object : L2Object) : Int32
    case object
    when L2PcInstance
      return 2000
    when L2DefenderInstance
      return 600
    else
      # [automatically added else]
    end


    0
  end

  def active_char : L2StaticObjectInstance
    super.as(L2StaticObjectInstance)
  end
end
