require "./abstract_event_return"

class ChatFilterReturn < AbstractEventReturn
  getter filtered_text

  def initialize(filtered_text : String, override : Bool, abort : Bool)
    super(override, abort)
    @filtered_text = filtered_text
  end
end
