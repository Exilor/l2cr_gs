class Options
  include Loggable

  @funcs = [] of FuncTemplate
  @activation_skills = [] of OptionsSkillHolder

  property active_skill : SkillHolder?
  property passive_skill : SkillHolder?

  getter_initializer id: Int32

  def has_funcs? : Bool
    !@funcs.empty?
  end

  def get_stat_funcs(item : L2ItemInstance?, pc : L2Character)
    return Slice(AbstractFunction).empty if @funcs.empty?

    funcs = [] of AbstractFunction
    @funcs.each do |temp|
      if function = temp.get_func(pc, pc, item, self)
        funcs << function
      end
    end
    funcs
  end

  def add_func(template : FuncTemplate)
    @funcs << template
  end

  def has_active_skill? : Bool
    !!@active_skill
  end

  def has_passive_skill? : Bool
    !!@passive_skill
  end

  def has_activation_skills? : Bool
    !@activation_skills.empty?
  end

  def has_activation_skills?(type : OptionsSkillType) : Bool
    @activation_skills.any? { |sh| sh.skill_type == type }
  end

  def get_activation_skills(type : OptionsSkillType)
    @activation_skills.select { |sh| sh.skill_type == type }
  end

  def add_activation_skill(holder : OptionsSkillHolder)
    @activation_skills << holder
  end

  def apply(pc : L2PcInstance)
    if has_funcs?
      pc.add_stat_funcs(get_stat_funcs(nil, pc))
    end

    if skill = @active_skill.try &.skill
      add_skill(pc, skill)
    end

    if skill = @passive_skill.try &.skill
      add_skill(pc, skill)
    end

    if has_activation_skills?
      @activation_skills.each do |holder|
        pc.add_trigger_skill(holder)
      end
    end

    pc.send_skill_list
  end

  def remove(pc : L2PcInstance)
    if has_funcs?
      pc.remove_stats_owner(self)
    end

    if skill = @active_skill.try &.skill
      pc.remove_skill(skill, false, false)
    end

    if skill = @passive_skill.try &.skill
      pc.remove_skill(skill, false, true)
    end

    if has_activation_skills?
      @activation_skills.each do |holder|
        pc.remove_trigger_skill(holder)
      end
    end

    pc.send_skill_list
  end

  private def add_skill(pc : L2PcInstance, skill : Skill)
    update_time_stamp = false
    pc.add_skill(skill, false)

    if skill.active?
      time = pc.get_skill_remaining_reuse_time(skill.hash)
      if time > 0
        pc.add_time_stamp(skill, time)
        pc.disable_skill(skill, time)
      end
    end

    if update_time_stamp
      pc.send_packet(Packets::Outgoing::SkillCoolTime.new(pc))
    end
  end
end
