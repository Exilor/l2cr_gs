abstract class AbstractEventListener
  module Owner
  end

  getter_initializer container : ListenersContainer, type : EventType,
    owner : Owner?

  abstract def execute_event(event, return_class)

  def unregister_me
    container.remove_listener(self)
  end
end
