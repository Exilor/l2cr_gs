class Scripts::HellboundEngine < AbstractNpcAI
  private DOOR_LIST = {
    {19250001, 5},
    {19250002, 5},
    {20250001, 9},
    {20250002, 7}
  }
  private MAX_TRUST = {
    0, 300000, 600000, 1000000, 1010000, 1400000, 1490000, 2000000, 2000001,
    2500000, 4000000, 0
  }
  private DEREK = 18465
  private ANNOUNCEMENT = "Hellbound has reached level: %lvl%"
  private UPDATE_INTERVAL = 60000 # 1 minute
  private UPDATE_EVENT = "UPDATE"

  class_getter! instance : self

  getter cached_level = -1
  getter max_trust = 0
  getter min_trust = 0

  def initialize
    super(self.class.simple_name, "hellbound")

    HellboundPointData.load
    HellboundSpawns.load
    add_kill_id(HellboundPointData.points_info.keys)

    start_quest_timer(UPDATE_EVENT, 1000, nil, nil)

    info { "Level: #{level}" }
    info { "Trust: #{trust}" }
    info { locked? ? "Status: locked" : "Status: unlocked" }
    @@instance = self
  end

  def on_adv_event(event, npc, pc)
    if event == UPDATE_EVENT
      level = level()
      if level > 0 && level == cached_level
        if trust == max_trust && level != 4
          level += 1
          self.level = level
          on_level_change(level)
        end
      else
        on_level_change(level)
      end

      start_quest_timer(UPDATE_EVENT, UPDATE_INTERVAL, nil, nil)
    end

    super
  end

  private def do_spawn
    added = deleted = 0

    HellboundSpawns.spawns.each do |sp|
      npc = sp.last_spawn
      min = HellboundSpawns.get_spawn_min_level(sp.id)
      if level < min || level > HellboundSpawns.get_spawn_max_level(sp.id)
        sp.stop_respawn
        if npc && npc.visible?
          npc.delete_me
          deleted += 1
        end
      else
        sp.start_respawn

        if npc.nil?
          sp.do_spawn
          added += 1
        else
          if npc.decayed?
            npc.decayed = false
          end

          if npc.dead?
            npc.do_revive
          end

          unless npc.visible?
            npc.visible = true
            added += 1
          end

          npc.heal!
        end
      end
    end

    if added > 0
      info { "Spawned #{added} NPCs." }
    end

    if deleted > 0
      info { "Removed #{deleted} NPCs." }
    end
  end

  def level : Int32
    GlobalVariablesManager.instance.get_i32("HBLevel", 0)
  end

  def level=(lvl : Int32)
    if lvl == level
      return
    end

    info { "Changing level from #{level} to #{lvl}." }

    GlobalVariablesManager.instance["HBLevel"] = lvl
  end

  def trust : Int32
    GlobalVariablesManager.instance.get_i32("HBTrust", 0)
  end

  def trust=(trust : Int32)
    debug { "Changing trust from #{trust()} to #{trust}." } if trust != trust()
    GlobalVariablesManager.instance["HBTrust"] = trust
  end

  def locked? : Bool
    level <= 0
  end

  def on_kill(npc, pc, is_summon)
    npc_id = npc.id
    data = HellboundPointData
    level = level()

    if data.points_info.has_key?(npc_id)
      if level >= data.get_min_hb_lvl(npc_id)
        if level <= data.get_max_hb_lvl(npc_id)
          if data.get_lowest_trust_limit(npc_id) == 0 || trust > data.get_lowest_trust_limit(npc_id)
            update_trust(data.get_points_amount(npc_id), true)
          end
        end
      end

      if npc_id == DEREK && level == 4
        self.level = 5
      end
    end

    super
  end

  def on_level_change(new_level : Int32)
    begin
      self.max_trust = MAX_TRUST[new_level]
      self.min_trust = MAX_TRUST[new_level - 1]
    rescue e
      error e
      self.max_trust = 0
      self.min_trust = 0
    end

    update_trust(0, false)

    do_spawn

    DOOR_LIST.each do |door_data|
      begin
        door = DoorData.get_door!(door_data[0])
        if door.open?
          if new_level < door_data[1]
            door.close_me
          end
        else
          if new_level >= door_data[1]
            door.open_me
          end
        end
      rescue e
        error e
      end
    end

    if @cached_level > 0
      Broadcast.to_all_online_players(ANNOUNCEMENT.sub("%lvl%", new_level.to_s))
      info { "New level: #{new_level}" }
    end

    @cached_level = new_level
  end

  private def max_trust=(trust : Int32)
    @max_trust = trust

    if @max_trust > 0 && trust() > @max_trust
      self.trust = @max_trust
    end
  end

  private def min_trust=(trust : Int32)
    @min_trust = trust

    if trust() >= @max_trust
      self.trust = @min_trust
    end
  end

  def update_trust(trust : Int32, use_rates : Bool)
    sync do
      if locked?
        return
      end

      reward = trust
      if use_rates
        if trust > 0
          reward = Config.rate_hb_trust_increase
        else
          reward = Config.rate_hb_trust_decrease
        end
        reward = (trust * reward).to_i
      end

      final_trust = Math.max(trust() + reward, @min_trust)
      if @max_trust > 0
        self.trust = Math.min(final_trust, @max_trust)
      else
        self.trust = final_trust
      end
    end
  end
end

alias HellboundEngine = Scripts::HellboundEngine
