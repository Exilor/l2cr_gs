require "./abstract_event_return"

struct ChatFilterReturn < AbstractEventReturn
  getter filtered_text

  def initialize(@filtered_text : String, override : Bool, abort : Bool)
    super(override, abort)
  end
end
