module BypassHandler::QuestList
  extend self
  extend BypassHandler

  def use_bypass(command : String, pc : L2PcInstance, target : L2Character?) : Bool
    return false unless target.is_a?(L2AdventurerInstance)
    pc.send_packet(ExShowQuestInfo::STATIC_PACKET)
    true
  end

  def commands : Enumerable(String)
    {"questlist"}
  end
end
