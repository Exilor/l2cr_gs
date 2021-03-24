module BypassHandler::ReleaseAttribute
  extend self
  extend BypassHandler

  def use_bypass(command : String, pc : L2PcInstance, target : L2Character?) : Bool
    return false unless target.is_a?(L2Npc)
    packet = ExShowBaseAttributeCancelWindow.new(pc)
    pc.send_packet(packet)
    false
  end

  def commands : Enumerable(String)
    {"ReleaseAttribute"}
  end
end
