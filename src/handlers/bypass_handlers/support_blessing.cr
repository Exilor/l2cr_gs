module BypassHandler::SupportBlessing
  extend self
  extend BypassHandler

  def use_bypass(command : String, pc : L2PcInstance, target : L2Character?) : Bool
    return false unless target.is_a?(L2Npc)

    if pc.level > 39 || pc.class_id.level >= 2
      target.show_chat_window(pc, "data/html/default/SupportBlessingHighLevel.htm")
      return true
    end
    target.target = pc
    target.do_cast(CommonSkill::BLESSING_OF_PROTECTION.skill)
    false
  end

  def commands : Enumerable(String)
    {"GiveBlessing"}
  end
end
