class L2DynamicZone < L2ZoneType
  # def initialize(@region : L2WorldRegion, @owner : L2Character, @skill : Skill)
  #   super(-1)

  #   self.settings = ZoneManager.get_settings(name) || TaskZoneSettings.new
  #   settings.task = ThreadPolManager.schedule_general(->remove, skill.abnormal_time * 1000)
  # end

  # def settings
  #   super.as(TaskZoneSettings)
  # end

  def on_enter(char)
    if char.player?
      warn "TODO"
      char.send_message("You have entered a temporary zone!")
    end

    # if @owner
    #   @skill.apply_effects(@owner, char)
    # end
  end

  def on_exit(char)
    if char.player?
      warn "TODO"
      char.send_message("You have left a temporary zone!")
    end

    # if char == @owner
    #   remove
    #   return
    # end

    # char.stop_skill_effects(true, @skill.id)
  end

  # private def remove
  #   unless settings.task && @skill
  #     return
  #   end

  #   settings.task.try &.cancel

  #   @region.remove_zone(self)

  #   characters_inside.each do |m|
  #     m.stop_skill_effects(true, @skill.id)
  #   end

  #   @owner.stop_skill_effects(true, @skill.id)
  # end

  # def on_die_inside(char)
  #   if char == @owner
  #     remove
  #   else
  #     char.stop_skill_effects(true, @skill.id)
  #   end
  # end

  # def on_revive_inside(char)
  #   @skill.apply_effects(@owner, char)
  # end
end
