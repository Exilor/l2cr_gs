class EffectHandler::SetSkill < AbstractEffect
  @skill_id : Int32
  @skill_lvl : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super

    @skill_id = params.get_i32("skillId", 0)
    @skill_lvl = params.get_i32("skillLvl", 1)
  end

  def on_start(info)
    return unless info.effected.player?

    if skill = SkillData[@skill_id, @skill_lvl]?
      info.effected.acting_player.add_skill(skill, true)
      info.effected.acting_player.send_skill_list
    end
  end

  def instant?
    true
  end
end
