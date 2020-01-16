require "./abstract_event_listener"

class AnnotationEventListener < AbstractEventListener
  def initialize(container : ListenersContainer, event_type : EventType, @callback : BaseEvent ->, owner, priority : Int32)
    super(container, event_type, owner)
  end

  # def execute_event(event, return_class : (R.class)?) : R? forall R # < AbstractEventReturn
  #   ret = @callback.call(event)
  #   ret.as?(R) if return_class
  # end

  def execute_event(event, return_class)
    @callback.call(event)
  end
end
