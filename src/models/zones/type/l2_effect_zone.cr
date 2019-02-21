class L2EffectZone < L2ZoneType
  @skills = Hash(Int32, Int32).new
  @initial_delay = 0
  @reuse = 30_000
  @bypass_conditions = false
  @show_danger_icon = true
  getter chance = 100

  def initialize(id)
    super(id)

    self.target_type = InstanceType::L2Playable
    self.settings = ZoneManager.get_settings(name) || TaskZoneSettings.new
  end

  def set_parameter(name, value)
    case name
    when "chance"
      @chance = value.to_i
    when "initialDelay"
      @initial_delay = value.to_i
    when "reuse"
      @reuse = value.to_i
    when "bypassSkillConditions"
      @bypass_conditions = Bool.new(value)
    when "maxDynamicSkillCount"
      # @skills = {} of Int32 => Int32
    when "skillIdLvl"
      # skills = {} of Int32 => Int32
      value.split(';').each do |skill|
        split = skill.split('-')
        if split.size != 2
          # warn "Invalid config property (#{split.inspect})."
        else
          id = split[0].to_i
          lvl = split[1].to_i
          @skills[id] = lvl
        end
      end
      # @skills = skills
    when "showDangerIcon"
      @show_danger_icon = Bool.new(value)
    else
      super
    end
  end

  def settings
    super.as(TaskZoneSettings)
  end

  def on_enter(char)
    unless @skills.empty?
      unless settings.task
        sync do
          settings.task ||= ThreadPoolManager.schedule_general_at_fixed_rate(
            ->apply_skill, @initial_delay, @reuse
          )
        end
      end
    end

    if char.is_a?(L2PcInstance)
      char.inside_altered_zone = true
      if @show_danger_icon
        char.inside_danger_area_zone = true
        char.send_packet(EtcStatusUpdate.new(char))
      end
    end
  end

  def on_exit(char)
    if char.is_a?(L2PcInstance)
      char.inside_altered_zone = false
      if @show_danger_icon
        char.inside_danger_area_zone = false
        unless char.inside_danger_area_zone?
          char.send_packet(EtcStatusUpdate.new(char.acting_player))
        end
      end
    end

    if @character_list.empty? && settings.task
      settings.clear
    end
  end

  private def get_skill(skill_id : Int, skill_lvl : Int) : Skill?
    SkillData[skill_id, skill_lvl]?
  end

  def add_skill(skill_id : Int, skill_lvl : Int)
    if skill_lvl < 1
      remove_skill(skill_id)
      return
    end

    # unless @skills
    #   sync { @skills ||= {} of Int32 => Int32 }
    # end

    @skills[skill_id] = skill_lvl
  end

  def remove_skill(skill_id : Int)
    @skills.delete(skill_id)
  end

  def clear_skills
    @skills.clear
  end

  def get_skill_level(skill_id : Int) : Int32
    @skills.fetch(skill_id, 0)
  end

  private def apply_skill
    return unless enabled?

    characters_inside.each do |char|
      next unless char.alive?
      next unless Rnd.rand(100) < @chance
      @skills.each do |id, lvl|
        if skill = get_skill(id, lvl)
          if @bypass_conditions || skill.check_condition(char, char, false)
            unless char.affected_by_skill?(id)
              skill.apply_effects(char, char)
            end
          end
        end
      end
    end
  end
end
