struct NextAction
  def initialize(event : AI::Event, intention : AI::Intention, &callback : ->)
    @event = event
    @intention = intention
    @callback = callback
  end

  def event?(event : AI::Event) : Bool
    @event == event
  end

  def intention?(intention : AI::Intention) : Bool
    @intention == intention
  end

  def do_action
    @callback.call
  end
end
