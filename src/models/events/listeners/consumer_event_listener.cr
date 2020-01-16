require "./abstract_event_listener"

class ConsumerEventListener < AbstractEventListener
  @callback : BaseEvent ->

  def initialize(container : ListenersContainer, event_type : EventType, owner, callback : BaseEvent ->)
    @callback = callback.unsafe_as(Proc(BaseEvent, Nil))
    super(container, event_type, owner)
  end

  def initialize(container : ListenersContainer, event_type : EventType, owner, &callback : BaseEvent ->)
    initialize(container, event_type, owner, callback)
  end

  def execute_event(event, etc)
    @callback.call(event)
    nil
  end
end
