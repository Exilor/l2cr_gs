module BypassHandler::TutorialClose
  extend self
  extend BypassHandler

  def use_bypass(command, pc, target)
    pc.send_packet(TutorialCloseHtml::STATIC_PACKET)
    false
  end

  def commands
    {"tutorial_close"}
  end
end
