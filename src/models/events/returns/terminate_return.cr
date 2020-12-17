require "./abstract_event_return"

class TerminateReturn < AbstractEventReturn
  getter terminate

  def initialize(terminate : Bool, override : Bool, abort : Bool)
    super(override, abort)
    @terminate = terminate
  end
end
