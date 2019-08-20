require "./char_known_list"

class VehicleKnownList < CharKnownList
  def get_distance_to_forget_object(object : L2Object) : Int32
    unless object.player?
      return 0
    end

    object.known_list.get_distance_to_forget_object(active_object)
  end

  def get_distance_to_watch_object(object : L2Object) : Int32
    unless object.player?
      return 0
    end

    object.known_list.get_distance_to_watch_object(active_object)
  end
end
