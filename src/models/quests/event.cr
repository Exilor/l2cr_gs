require "./quest"

abstract class Event < Quest
  def initialize(name : String, description : String)
    super(-1, name, description)
  end

  abstract def event_start(event_maker : L2PcInstance) : Bool
  abstract def event_stop : Bool
  abstract def event_bypass(pc : L2PcInstance, bypass : String) : Bool
end
