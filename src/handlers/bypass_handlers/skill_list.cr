module BypassHandler::SkillList
  extend self
  extend BypassHandler

  def use_bypass(command, pc, target) : Bool
    return false unless target.is_a?(L2NpcInstance)

    # TODO: support for Config.alt_game_skill_learn
    L2NpcInstance.show_skill_list(pc, target, pc.class_id)

    true
  end

  def commands
    {"SkillList"}
  end
end
