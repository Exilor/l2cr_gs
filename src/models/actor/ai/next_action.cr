# class NextAction
#   @events : UInt32
#   @intentions : UInt32

#   def initialize(event : AI::Event, intention : AI::Intention, &@callback : ->)
#     @events = event.mask
#     @intentions = intention.mask
#   end

#   def add_event(event : AI::Event)
#     @events |= event.mask
#   end

#   def add_intention(intention : AI::Intention)
#     @intentions |= intention.mask
#   end

#   def remove_event(event : AI::Event)
#     @events &= ~event.mask
#   end

#   def remove_intention(intention : AI::Intention)
#     @intentions &= ~intention.mask
#   end

#   def event?(event : AI::Event) : Bool
#     @events & event.mask == event.mask
#   end

#   def intention?(intention : AI::Intention) : Bool
#     @intentions & intention.mask == intention.mask
#   end

#   def do_action
#     @callback.call
#   end
# end

# Actual code always uses exactly 1 intention and 1 event per NextAction.
struct NextAction
  def initialize(@event : AI::Event, @intention : AI::Intention, &@callback : ->)
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
