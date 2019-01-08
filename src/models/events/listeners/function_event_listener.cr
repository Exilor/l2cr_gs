require "./abstract_event_listener"

class FunctionEventListener < AbstractEventListener
  def initialize(container : ListenersContainer, event_type : EventType, owner, &@callback : BaseEvent -> AbstractEventReturn?)
    super(container, event_type, owner)
  end

  # def execute_event(event, return_class : (R.class)?) : R? forall R
  #   @callback.call(event).as?(R) if return_class
  # end

  def execute_event(event, return_class)
    @callback.call(event)
  end
end
