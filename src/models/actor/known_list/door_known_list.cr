require "./char_known_list"

class DoorKnownList < CharKnownList
  def get_distance_to_forget_object(object : L2Object) : Int32
    if object.is_a?(L2DefenderInstance)
      return 800
    elsif object.player?
      return 4000
    end

    0
  end

  def get_distance_to_watch_object(object : L2Object) : Int32
    if object.is_a?(L2DefenderInstance)
      return 600
    elsif object.player?
      return 3500
    end

    0
  end

  def active_char : L2DoorInstance
    super.as(L2DoorInstance)
  end
end
