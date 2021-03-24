module BypassHandler::TutorialClose
  extend self
  extend BypassHandler

  def use_bypass(command : String, pc : L2PcInstance, target : L2Character?) : Bool
    pc.send_packet(TutorialCloseHtml::STATIC_PACKET)
    false
  end

  def commands : Enumerable(String)
    {"tutorial_close"}
  end
end
