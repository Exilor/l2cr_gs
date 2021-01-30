require "../models/fort_siege_spawn"
require "../models/combat_flag"

module FortSiegeManager
  extend self
  extend Loggable

  private COMMANDER_SPAWN_LIST = Concurrent::Map(Int32, Array(FortSiegeSpawn)).new
  private FLAG_LIST = Concurrent::Map(Int32, Array(CombatFlag)).new
  private SIEGES = [] of FortSiege

  class_getter attacker_max_clans = 500
  class_getter flag_max_count = 1
  class_getter siege_clan_min_level = 4
  class_getter siege_length = 60
  class_getter countdown_length = 10
  class_getter suspicious_merchant_respawn_delay = 180
  class_getter? can_register_just_territory = true

  def load
    path = Dir.current + Config::FORTSIEGE_CONFIGURATION_FILE
    cfg = PropertiesReader.new
    cfg.parse(path)

    @@can_register_just_territory = cfg.get_bool("JustToTerritory", true)
    @@attacker_max_clans = cfg.get_i32("AttackerMaxClans", 500)
    @@flag_max_count = cfg.get_i32("MaxFlags", 1)
    @@siege_clan_min_level = cfg.get_i32("SiegeClanMinLevel", 4)
    @@siege_length = cfg.get_i32("SiegeLength", 60)
    @@countdown_length = cfg.get_i32("CountDownLength", 10)
    @@suspicious_merchant_respawn_delay = cfg.get_i32("SuspiciousMerchantRespawnDelay", 180)

    COMMANDER_SPAWN_LIST.clear
    FLAG_LIST.clear

    FortManager.forts.each do |fort|
      commander_spawns = [] of FortSiegeSpawn
      flag_spawns = [] of CombatFlag

      (1...5).each do |i|
        key = "#{fort.name.delete(' ')}Commander#{i}"
        params = cfg.get_string(key, "")
        if params.empty?
          break
        end

        st = params.strip.split(',')

        begin
          x = st.shift.to_i
          y = st.shift.to_i
          z = st.shift.to_i
          heading = st.shift.to_i
          npc_id = st.shift.to_i

          sp = FortSiegeSpawn.new(fort.residence_id, x, y, z, heading, npc_id, i)
          commander_spawns << sp
        rescue e
          error e
        end
      end

      COMMANDER_SPAWN_LIST[fort.residence_id] = commander_spawns

      (1...4).each do |i|
        key = "#{fort.name.delete(' ')}Flag#{i}"
        params = cfg.get_string(key, "")
        if params.empty?
          break
        end

        st = params.strip.split(',')

        begin
          x = st.shift.to_i
          y = st.shift.to_i
          z = st.shift.to_i
          flag_id = st.shift.to_i

          sp = CombatFlag.new(fort.residence_id, x, y, z, 0, flag_id)
          flag_spawns << sp
        rescue e
          error e
        end
      end

      FLAG_LIST[fort.residence_id] = flag_spawns
    end
  end

  def add_siege_skills(pc : L2PcInstance)
    pc.add_skill(CommonSkill::SEAL_OF_RULER.skill, false)
    pc.add_skill(CommonSkill::BUILD_HEADQUARTERS.skill, false)
  end

  def remove_siege_skills(pc : L2PcInstance)
    pc.remove_skill(CommonSkill::SEAL_OF_RULER.skill)
    pc.remove_skill(CommonSkill::BUILD_HEADQUARTERS.skill)
  end

  def registered?(clan : L2Clan?, fort_id : Int32) : Bool
    unless clan
      return false
    end

    register = false

    begin
      sql = "SELECT clan_id FROM fortsiege_clans where clan_id=? and fort_id=?"
      GameDB.each(sql, clan.id, fort_id) do
        register = true
        break
      end
    rescue e
      error e
    end

    register
  end

  def get_commander_spawn_list(fort_id : Int32) : Array(FortSiegeSpawn)?
    COMMANDER_SPAWN_LIST[fort_id]?
  end

  def get_flag_list(fort_id : Int32) : Array(CombatFlag)?
    FLAG_LIST[fort_id]?
  end

  def get_siege(obj : L2Object) : FortSiege?
    get_siege(*obj.xyz)
  end

  def get_siege(x : Int32, y : Int32, z : Int32) : FortSiege?
    FortManager.forts.each do |fort|
      if fort.siege.in_zone?(x, y, z)
        return fort.siege
      end
    end

    nil
  end

  def sieges : Array(FortSiege)
    SIEGES
  end

  def add_siege(siege : FortSiege)
    SIEGES << siege
  end

  def combat?(item_id : Int32) : Bool
    item_id == 9819
  end

  def activate_combat_flag(pc : L2PcInstance, item : L2ItemInstance) : Bool
    unless can_pickup?(pc)
      return false
    end

    fort = FortManager.get_fort(pc).not_nil!
    list = FLAG_LIST[fort.residence_id]
    list.each do |cf|
      if cf.combat_flag_instance == item
        cf.activate(pc, item)
      end
    end

    true
  end

  def can_pickup?(pc : L2PcInstance) : Bool
    sm = Packets::Outgoing::SystemMessage.the_fortress_battle_of_s1_has_finished
    sm.add_item_name(9819)

    if pc.combat_flag_equipped?
      pc.send_packet(sm)
      return false
    end

    fort = FortManager.get_fort(pc)

    if fort.nil? || fort.residence_id <= 0
      pc.send_packet(sm)
      return false
    elsif !fort.siege.in_progress?
      pc.send_packet(sm)
      return false
    elsif fort.siege.get_attacker_clan(pc.clan).nil?
      pc.send_packet(sm)
      return false
    end

    true
  end

  def drop_combat_flag(pc : L2PcInstance, fort_id : Int32)
    fort = FortManager.get_fort_by_id(fort_id).not_nil!
    list = FLAG_LIST[fort.residence_id]
    list.each do |cf|
      if cf.player_l2id == pc.l2id
        cf.drop_it
        if fort.siege.in_progress?
          cf.spawn_me
        end
      end
    end
  end
end
