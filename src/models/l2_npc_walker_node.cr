require "./location"

class L2NpcWalkerNode < Location
  @chat_string : String

  getter delay, npc_string
  getter? run_to_location

  def initialize(x : Int32, y : Int32, z : Int32, @delay : Int32, @run_to_location : Bool, @npc_string : NpcString?, chat_string : String?)
    super(x, y, z)
    @chat_string = chat_string || ""
  end

  def chat_text : String
    if @npc_string
      raise "@npc_string and @chat_string must not be both set"
    end
    @chat_string
  end
end
