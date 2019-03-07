require "../models/tower_spawn"

module SiegeManager
  extend self
  extend Loggable

  private CONTROL_TOWERS = {} of Int32 => Array(TowerSpawn)
  private FLAME_TOWERS = {} of Int32 => Array(TowerSpawn)

  class_getter attacker_max_clans = 500
  class_getter attacker_respawn_delay = 0
  class_getter defender_max_clans = 500
  class_getter flag_max_count = 1
  class_getter siege_clan_min_level = 5
  class_getter siege_length = 120
  class_getter blood_alliance_reward = 0

  def load
    cfg = StatsSet.new
    cfg.parse(Dir.current + Config::SIEGE_CONFIGURATION_FILE)

    @@attacker_max_clans = cfg.get_i32("AttackerMaxClans", 500)
    @@attacker_respawn_delay = cfg.get_i32("AttackerRespawn", 0)
    @@defender_max_clans = cfg.get_i32("DefenderMaxClans", 500)
    @@flag_max_count = cfg.get_i32("MaxFlags", 1)
    @@siege_clan_min_level = cfg.get_i32("SiegeClanMinLevel", 5)
    @@siege_length = cfg.get_i32("SiegeLength", 120)
    @@blood_alliance_reward = cfg.get_i32("BloodAllianceReward", 1)

    CastleManager.castles.each do |castle|
      control_towers = [] of TowerSpawn

      1.upto(0xff - 1) do |i|
        key_name = "#{castle.name}ControlTower#{i}"
        unless cfg.has_key?(key_name)
          break
        end

        st = cfg.get_string(key_name, "").split(',')
        begin
          x = st.shift.to_i
          y = st.shift.to_i
          z = st.shift.to_i
          npc_id = st.shift.to_i
          control_towers << TowerSpawn.new(npc_id, Location.new(x, y, z))
        rescue e
          error e
        end
      end

      flame_towers = [] of TowerSpawn

      1.upto(0xff - 1) do |i|
        key_name = "#{castle.name}FlameTower#{i}"
        unless cfg.has_key?(key_name)
          break
        end

        st = cfg.get_string(key_name, "").split(',')
        begin
          x = st.shift.to_i
          y = st.shift.to_i
          z = st.shift.to_i
          npc_id = st.shift.to_i
          zone_list = [] of Int32
          while temp = st.shift?
            zone_list << temp.to_i
          end
          flame_towers << TowerSpawn.new(npc_id, Location.new(x, y, z))
        rescue e
          error e
        end
      end

      CONTROL_TOWERS[castle.residence_id] = control_towers
      FLAME_TOWERS[castle.residence_id] = flame_towers
      temp = cfg.get_i32(castle.name + "MaxMercenaries", MercTicketManager::MERCS_MAX_PER_CASTLE[castle.residence_id - 1])
      MercTicketManager::MERCS_MAX_PER_CASTLE[castle.residence_id - 1] = temp

      if castle.owner_id != 0
        load_trap_upgrade(castle.residence_id)
      end
    end

    sieges # Force Siege initialization.
  end

  def add_siege_skills(pc : L2PcInstance)
    SkillData.get_siege_skills(pc.noble?, pc.clan.castle_id > 0).each do |sk|
      pc.add_skill(sk, false)
    end
  end

  def registered?(clan : L2Clan?, castle_id : Int32) : Bool
    unless clan
      return false
    end

    if clan.castle_id > 0
      return true
    end

    register = false

    begin
      sql = "SELECT clan_id FROM siege_clans where clan_id=? and castle_id=?"
      GameDB.each(sql, clan.id, castle_id) do |rs|
        register = true
        break
      end
    rescue e
      error e
    end

    register
  end

  def remove_siege_skills(pc : L2PcInstance)
    SkillData.get_siege_skills(pc.noble?, pc.clan.castle_id > 0).each do |sk|
      pc.remove_skill(sk)
    end
  end

  def get_control_towers(castle_id : Int32) : Enumerable(TowerSpawn)
    CONTROL_TOWERS[castle_id]
  end

  def get_flame_towers(castle_id : Int32) : Enumerable(TowerSpawn)
    FLAME_TOWERS[castle_id]
  end

  def get_siege(loc : Locatable) : Siege?
    get_siege(*loc.xyz)
  end

  def get_siege(x : Int32, y : Int32, z : Int32) : Siege?
    CastleManager.castles.each do |castle|
      if castle.siege.in_zone?(x, y, z)
        return castle.siege
      end
    end

    nil
  end

  def sieges : Array(Siege)
    ret = Array(Siege).new(CastleManager.castles.size)
    CastleManager.castles.each do |castle|
      ret << castle.siege
    end
    ret
    # CastleManager.castles.map &.siege # compiler can't infer block body
  end

  private def load_trap_upgrade(castle_id : Int32)
    sql = "SELECT * FROM castle_trapupgrade WHERE castleId=?"
    GameDB.each(sql, castle_id) do |rs|
      idx = rs.get_i32("towerIndex")
      lvl = rs.get_i32("level")
      FLAME_TOWERS[castle_id][idx].upgrade_level = lvl
    end
  rescue e
    error e
  end
end
