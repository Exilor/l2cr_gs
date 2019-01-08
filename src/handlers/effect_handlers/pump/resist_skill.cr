class EffectHandler::ResistSkill < AbstractEffect
  @skills = []  of SkillHolder

  def initialize(attach_cond, apply_cond, set, params)
    super

    i = 1
    while true
      skill_id = params.get_i32("skillId#{i}", 0)
      break if skill_id == 0
      skill_lvl = params.get_i32("skillLevel#{i}", 0)

      @skills << SkillHolder.new(skill_id, skill_lvl)
      i += 1
    end

    if @skills.empty?
      raise "ResistSkill with no parameters"
    end
  end

  def effect_type
    L2EffectType::BUFF
  end

  def on_start(info)
    effected = info.effected
    @skills.each do |holder|
      effected.add_invul_against(holder)
      effected.send_debug_message("Applying invul against #{holder.skill}")
    end
  end

  def on_exit(info)
    effected = info.effected
    @skills.each do |holder|
      effected.remove_invul_against(holder)
      effected.send_debug_message("Removing invul against #{holder.skill}")
    end
  end
end
