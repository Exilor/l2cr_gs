module BypassHandler::Multisell
  extend self
  extend BypassHandler

  def use_bypass(command : String, pc : L2PcInstance, target : L2Character?) : Bool
    return false unless target.is_a?(L2Npc)

    command = command.downcase
    if command.starts_with?(commands[0])
      list_id = command.from(9).strip
      list_id = list_id.to_i
      MultisellData.separate_and_send(list_id, pc, target, false)
    elsif command.starts_with?(commands[1])
      list_id = command.from(13).strip
      list_id = list_id.to_i
      MultisellData.separate_and_send(list_id, pc, target, true)
    end

    false
  end

  def commands : Enumerable(String)
    {"multisell", "exc_multisell"}
  end
end
