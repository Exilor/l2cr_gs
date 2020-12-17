require "./listeners/abstract_event_listener"

class ListenersContainer
  include Synchronizable
  include Loggable

  @listeners : Interfaces::Map(EventType, Array(AbstractEventListener))?

  def add_listener(lst : AbstractEventListener) : AbstractEventListener
    (listeners[lst.type] ||= [] of AbstractEventListener) << lst
    lst
  end

  def remove_listener(lst : AbstractEventListener) : AbstractEventListener
    unless tmp = @listeners
      raise "ListenersContainer not initialized"
    end

    unless tmp2 = tmp[lst.type]?
      raise "ListenersContainer doesn't have event type #{lst.type}"
    end

    tmp2.delete_first(lst)
    lst
  end

  def get_listeners(type : EventType) : Indexable(AbstractEventListener)
    if tmp = @listeners
      if tmp2 = tmp[type]?
        return tmp2
      end
    end

    Slice(AbstractEventListener).empty
  end

  def remove_listener_if(type : EventType, & : AbstractEventListener -> Bool)
    get_listeners(type).safe_each do |listener|
      if yield listener
        listener.unregister_me
      end
    end
  end

  def remove_listener_if(& : AbstractEventListener -> Bool)
    unless tmp = @listeners
      return
    end

    tmp.each_value do |list|
      list.safe_each do |listener|
        if yield listener
          listener.unregister_me
        end
      end
    end
  end

  def has_listener?(type : EventType) : Bool
    !get_listeners(type).empty?
  end

  private def listeners : Interfaces::Map(EventType, Array(AbstractEventListener))
    @listeners || sync do
      @listeners ||= begin
        Concurrent::Map(EventType, Array(AbstractEventListener)).new
      end
    end
  end
end
