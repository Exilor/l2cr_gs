require "./abstract_event_listener"

class DummyEventListener < AbstractEventListener
  def execute_event(event, etc)
    # no-op
  end
end
