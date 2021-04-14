module ItemHandler::Harvester
  extend self
  extend ItemHandler

  def use_item(playable : L2Playable, item : L2ItemInstance, force_use : Bool) : Bool
    return false unless Config.allow_manor

    unless playable.player?
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    pc = playable.acting_player
    target = pc.target

    unless target.is_a?(L2MonsterInstance) && target.dead?
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      pc.action_failed
      return false
    end

    item.template.skills.each { |sk| pc.use_magic(sk.skill, false, false) }

    true
  end
end
