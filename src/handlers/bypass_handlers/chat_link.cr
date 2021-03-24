module BypassHandler::ChatLink
  extend self
  extend BypassHandler

  def use_bypass(command : String, pc : L2PcInstance, target : L2Character?) : Bool
    return false unless npc = target.as?(L2Npc)

    val = command[5]?.try &.to_i || 0

    if val == 0 && npc.has_listener?(EventType::ON_NPC_FIRST_TALK)
      OnNpcFirstTalk.new(npc, pc).async(npc)
    else
      npc.show_chat_window(pc, val)
    end

    false
  end

  def commands : Enumerable(String)
    {"Chat"}
  end
end
