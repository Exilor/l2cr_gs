class L2BossZone < L2ZoneType
  @oust_loc = Slice(Int32).new(3)

  getter time_invade = 0

  class Settings < AbstractZoneSettings
    getter player_allowed_reentry_times = Concurrent::Map(Int32, Int64).new
    getter players_allowed = Concurrent::Array(Int32).new
    getter raid_list = Concurrent::Array(L2Character).new

    def clear
      @player_allowed_reentry_times.clear
      @players_allowed.clear
      @raid_list.clear
    end
  end

  def initialize(id : Int32)
    super(id)

    self.settings = ZoneManager.get_settings(name) || Settings.new
    GrandBossManager.add_zone(self)
  end

  def set_parameter(name : String, value : String)
    case name
    when "InvadeTime"
      @time_invade = value.to_i
    when "oustX"
      @oust_loc[0] = value.to_i
    when "oustY"
      @oust_loc[1] = value.to_i
    when "oustZ"
      @oust_loc[2] = value.to_i
    else
      super
    end
  end

  def settings
    super.as(Settings)
  end

  def on_enter(char)
    unless enabled?
      return
    end

    if pc = char.as?(L2PcInstance)
      if pc.override_zone_conditions?
        return
      end

      if idx = settings.players_allowed.index(pc.l2id)
        if exp_time = settings.player_allowed_reentry_times[pc.l2id]?
          settings.player_allowed_reentry_times.delete(pc.l2id)
          if exp_time > Time.ms
            return
          end
        else
          server_start_time = GameServer.start_time.ms
          if server_start_time > Time.ms - @time_invade
            return
          end
        end
        settings.players_allowed.delete_at(idx)
      end

      if @oust_loc.none? { |coord| coord == 0 }
        pc.tele_to_location(@oust_loc[0], @oust_loc[1], @oust_loc[2])
      else
        pc.tele_to_location(TeleportWhereType::TOWN)
      end
    elsif char.is_a?(L2Summon)
      if pc = char.acting_player
        if settings.players_allowed.includes?(pc.l2id) || pc.override_zone_conditions?
          return
        end

        if @oust_loc.none? { |coord| coord == 0 }
          pc.tele_to_location(@oust_loc[0], @oust_loc[1], @oust_loc[2])
        else
          pc.tele_to_location(TeleportWhereType::TOWN)
        end
      end

      char.unsummon(pc)
    end
  end

  def on_exit(char)
    unless enabled?
      return
    end

    if pc = char.as?(L2PcInstance)
      if pc.override_zone_conditions?
        return
      end

      if !pc.online? && settings.players_allowed.includes?(pc.l2id)
        settings.player_allowed_reentry_times[pc.l2id] = Time.ms + @time_invade
      else
        if idx = settings.players_allowed.index(pc.l2id)
          settings.players_allowed.delete_at(idx)
        end
        settings.player_allowed_reentry_times.delete(pc.l2id)
      end
    elsif char.playable?
      unless characters_inside.none?
        settings.raid_list.clear
        count = 0
        characters_inside.each do |obj|
          if obj.playable?
            count &+= 1
          elsif obj.attackable? && obj.raid?
            settings.raid_list << obj
          end
        end

        if count == 0 && !settings.raid_list.empty?
          settings.raid_list.each do |raid|
            unless raid = raid.as?(L2Attackable)
              next
            end

            if raid.spawn?.nil? || raid.dead?
              next
            end

            unless raid.inside_radius?(raid.spawn, 150, false, false)
              raid.return_home
            end
          end
        end
      end
    end

    if char.is_a?(L2Attackable) && char.raid? && char.alive?
      char.return_home
    end
  end

  def self.enabled=(flag : Bool)
    if enabled? != flag
      oust_all_players
    end

    super
  end

  def allowed_players=(players : Enumerable(Int32))
    if players
      settings.players_allowed.replace(players)
    end
  end

  def allowed_players
    settings.players_allowed
  end

  def player_allowed?(pc : L2PcInstance) : Bool
    if pc.override_zone_conditions?
      true
    elsif settings.players_allowed.includes?(pc.l2id)
      true
    else
      if !@oust_loc.includes?(0)
        pc.tele_to_location(@oust_loc[0], @oust_loc[1], @oust_loc[2])
      else
        pc.tele_to_location(TeleportWhereType::TOWN)
      end

      false
    end
  end

  def move_players_to(loc : Location)
    return if @character_list.empty?

    characters_inside.each do |pc|
      if pc.is_a?(L2PcInstance) && pc.online?
        pc.tele_to_location(loc)
      end
    end
  end

  def oust_all_players
    return if @character_list.empty?

    characters_inside.each do |pc|
      if pc.is_a?(L2PcInstance) && pc.online?
        if !@oust_loc.includes?(0)
          pc.tele_to_location(@oust_loc[0], @oust_loc[1], @oust_loc[2])
        else
          pc.tele_to_location(TeleportWhereType::TOWN)
        end
      end
    end

    settings.players_allowed.clear
    settings.player_allowed_reentry_times.clear
  end

  def allow_player_entry(pc : L2PcInstance, duration_in_sec : Int32)
    unless pc.override_zone_conditions?
      unless settings.players_allowed.includes?(pc.l2id)
        settings.players_allowed << pc.l2id
      end

      time = Time.s_to_ms(duration_in_sec)
      settings.player_allowed_reentry_times[pc.l2id] = Time.ms + time
    end
  end

  def remove_player(pc : L2PcInstance)
    unless pc.override_zone_conditions?
      settings.players_allowed.delete_first(pc.l2id)
      settings.player_allowed_reentry_times.delete(pc.l2id)
    end
  end

  def update_known_list(npc : L2Npc)
    return if @character_list.empty?

    known_players = npc.known_list.known_players

    characters_inside.each do |pc|
      if pc.player? && pc.online?
        known_players[pc.l2id] = pc
      end
    end
  end
end
