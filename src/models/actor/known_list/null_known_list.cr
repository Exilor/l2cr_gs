require "./object_known_list"

class NullKnownList < ObjectKnownList
  def add_known_object(object : L2Object) : Bool
    false
  end

  def get_distance_to_forget_object(object : L2Object) : Int32
    0
  end

  def get_distance_to_watch_object(object : L2Object) : Int32
    0
  end

  def remove_all_known_objects
    # no-op
  end

  def remove_known_object(object : L2Object, forget : Bool) : Bool
    false
  end

  def known_objects : Hash(Int32, L2Object)
    raise "#known_objects not supported for NullKnownList"
  end

  def active_object : L2Object
    raise "#active_object not supported for NullKnownList"
  end

  INSTANCE = allocate
end
