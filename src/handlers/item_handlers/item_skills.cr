require "./item_skills_template"

module ItemHandler::ItemSkills
  extend self
  extend ItemHandler

  def use_item(playable, item, force) : Bool
    if playable.acting_player.try &.in_olympiad_mode?
      playable.send_packet(SystemMessageId::THIS_ITEM_IS_NOT_AVAILABLE_FOR_THE_OLYMPIAD_EVENT)
      return false
    end

    ItemHandler::ItemSkillsTemplate.use_item(playable, item, force)
  end
end
