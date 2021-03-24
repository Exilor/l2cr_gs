module BypassHandler::Augment
  extend self
  extend BypassHandler

  def use_bypass(command : String, pc : L2PcInstance, target : L2Character?) : Bool
    return false unless target.is_a?(L2Npc)

    case command[8].to_i
    when 1
      pc.send_packet(ExShowVariationMakeWindow::STATIC_PACKET)
      true
    when 2
      pc.send_packet(ExShowVariationCancelWindow::STATIC_PACKET)
      true
    else
      debug { "Wrong bypass subcommand '#{command[8]}'." }
      false
    end
  end

  def commands : Enumerable(String)
    {"Augment"}
  end
end
