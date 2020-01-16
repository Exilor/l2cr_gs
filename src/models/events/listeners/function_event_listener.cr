require "./abstract_event_listener"

class FunctionEventListener < AbstractEventListener
  @callback : BaseEvent -> AbstractEventReturn?

  def initialize(container : ListenersContainer, event_type : EventType, owner, callback : BaseEvent -> AbstractEventReturn?)
    @callback = callback.unsafe_as(Proc(BaseEvent, AbstractEventReturn?))
    super(container, event_type, owner)
  end

  def execute_event(event, return_class)
    @callback.call(event)
  end
end
