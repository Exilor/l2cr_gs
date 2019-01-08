require "./abstract_event_listener"

class ConsumerEventListener < AbstractEventListener
  def initialize(container : ListenersContainer, event_type : EventType, owner, &@callback : BaseEvent ->)
    super(container, event_type, owner)
  end

  def execute_event(event, etc)
    @callback.call(event)
    nil
  end
end
