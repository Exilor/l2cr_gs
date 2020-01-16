class L2DamageZone < L2ZoneType
  @hp_damage_per_second = 200
  @mp_damage_per_second = 0
  @start_task = 10
  @reuse_task = 5000
  @castle_id = 0
  @castle : Castle?

  def initialize(id)
    super(id)

    self.target_type = InstanceType::L2Playable
    self.settings = ZoneManager.get_settings(name) || TaskZoneSettings.new
  end

  def settings
    super.as(TaskZoneSettings)
  end

  def castle : Castle?
    if @castle_id > 0 && @castle.nil?
      @castle = CastleManager.get_castle_by_id(@castle_id).not_nil!
    end
    @castle
  end

  def set_parameter(name, value)
    case name.casecmp
    when "dmgHPSec"
      @hp_damage_per_second = value.to_i
    when "dmgMPSec"
      @mp_damage_per_second = value.to_i
    when "castleId"
      @castle_id = value.to_i
    when "initialDelay"
      @start_task = value.to_i
    when "reuse"
      @reuse_task = value.to_i
    else
      super
    end
  end

  def on_enter(char)
    if settings.task.nil? && (@hp_damage_per_second != 0 || @mp_damage_per_second != 0)
      pc = char.acting_player
      if castle = @castle
        unless castle.siege.in_progress? && pc && pc.siege_state != 2
          return
        end
      end

      sync do
        settings.task ||= ThreadPoolManager.schedule_general_at_fixed_rate(->apply_damage, @start_task, @reuse_task)
      end
    end
  end

  def on_exit(char)
    if @character_list.empty? && settings.task
      settings.clear
    end
  end

  private def apply_damage
    return unless enabled?
    siege = false

    if castle = castle()
      siege = castle.siege.in_progress?
      unless siege
        settings.clear
        return
      end
    end

    characters_inside.each do |char|
      if char.alive?
        if siege
          pc = char.acting_player
          if pc && pc.in_siege? && pc.siege_state == 2
            next
          end
        end

        multiplier = 1.0 + (char.calc_stat(Stats::DAMAGE_ZONE_VULN, 0) / 100)

        if @hp_damage_per_second != 0
          char.reduce_current_hp(@hp_damage_per_second * multiplier, nil, nil)
        end

        if @mp_damage_per_second != 0
          char.reduce_current_mp(@mp_damage_per_second * multiplier)
        end
      end
    end
  end
end
