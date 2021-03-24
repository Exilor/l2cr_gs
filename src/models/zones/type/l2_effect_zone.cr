class L2EffectZone < L2ZoneType
  @skills = Concurrent::Map(Int32, Int32).new
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

  def set_parameter(name : String, value : String)
    case name
    when "chance"
      @chance = value.to_i
    when "initialDelay"
      @initial_delay = value.to_i
    when "reuse"
      @reuse = value.to_i
    when "bypassSkillConditions"
      @bypass_conditions = value.to_b
    when "maxDynamicSkillCount"
      # @skills already initialized
    when "skillIdLvl"
      value.split(';') do |skill|
        split = skill.split('-')
        if split.size != 2
          # raise "Invalid config property '#{split}'"
        else
          id = split[0].to_i
          lvl = split[1].to_i
          @skills[id] = lvl
        end
      end
    when "showDangerIcon"
      @show_danger_icon = value.to_b
    else
      super
    end
  end

  def settings : TaskZoneSettings
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

  def add_skill(skill_id : Int32, skill_lvl : Int32)
    if skill_lvl < 1
      remove_skill(skill_id)
      return
    end

    @skills[skill_id] = skill_lvl
  end

  def remove_skill(skill_id : Int32)
    @skills.delete(skill_id)
  end

  def clear_skills
    @skills.clear
  end

  def get_skill_level(skill_id : Int32) : Int32
    @skills.fetch(skill_id, 0)
  end

  private def apply_skill
    return unless enabled?

    each_character_inside do |char|
      next unless char.alive?
      next unless Rnd.rand(100) < @chance
      @skills.each do |id, lvl|
        if skill = SkillData[id, lvl]?
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
