class ObjectKnownList
  include Synchronizable

  getter_initializer active_object : L2Object

  def known_objects : Concurrent::Map(Int32, L2Object)
    @known_objects || sync do
      @known_objects ||= Concurrent::Map(Int32, L2Object).new
    end
  end

  def add_known_object(object : L2Object) : Bool
    if @active_object.instance_id != -1
      if object.instance_id != @active_object.instance_id
        return false
      end
    end

    if object.is_a?(L2PcInstance) && object.appearance.ghost?
      return false
    end

    return false if knows_object?(object)

    radius = get_distance_to_watch_object(object)
    unless Util.in_short_radius?(radius, @active_object, object, true)
      return false
    end

    known_objects[object.l2id] = object

    true
  end

  def knows_object?(object : L2Object) : Bool
    return true if @active_object == object
    return false unless known_objects = @known_objects
    known_objects.has_key?(object.l2id)
  end

  def remove_all_known_objects
    @known_objects.try &.clear
  end

  def remove_known_object(object : L2Object?) : Bool
    remove_known_object(object, false)
  end

  def remove_known_object(object : L2Object?, forget : Bool) : Bool
    return false unless object
    return true if forget
    return false unless known_objects = @known_objects
    !!known_objects.delete(object.l2id)
  end

  def find_objects
    me = @active_object
    return unless world_region = me.world_region

    if me.playable?
      world_region.sorrounding_regions.each do |region|
        region.objects.each_value do |object|
          if object != me
            add_known_object(object)
            object.known_list.add_known_object(me)
          end
        end
      end
    elsif me.character?
      world_region.sorrounding_regions.each do |region|
        if region.active?
          region.playables.each_value do |object|
            if object != me
              add_known_object(object)
            end
          end
        end
      end
    end
  end

  def forget_objects(full_check : Bool)
    me = @active_object
    @known_objects.try &.each do |id, object|
      next if !full_check && !object.playable?
      if !object.visible? || !Util.in_short_radius?(get_distance_to_watch_object(object), me, object, true)
        known_objects.delete(id)
        remove_known_object(object, true)
      end
    end
  end

  def each_object(& : L2Object ->) : Nil
    @known_objects.try &.each_value { |o| yield o }
  end

  def get_distance_to_forget_object(object : L2Object) : Int32
    0
  end

  def get_distance_to_watch_object(object : L2Object) : Int32
    0
  end
end
