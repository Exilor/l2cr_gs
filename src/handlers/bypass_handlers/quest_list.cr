module BypassHandler::QuestList
  extend self
  extend BypassHandler

  def use_bypass(command, pc, target)
    return false unless target.is_a?(L2AdventurerInstance)
    pc.send_packet(ExShowQuestInfo::STATIC_PACKET)
    true
  end

  def commands
    {"questlist"}
  end
end
