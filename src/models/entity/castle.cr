require "./abstract_residence"
require "./siege"

class Castle < AbstractResidence
  # Castle Functions
  FUNC_TELEPORT = 1
  FUNC_RESTORE_HP = 2
  FUNC_RESTORE_MP = 3
  FUNC_RESTORE_EXP = 4
  FUNC_SUPPORT = 5

  getter doors = [] of L2DoorInstance
  getter owner_id = 0
  getter siege_date = Calendar.new
  @siege : Siege?
  property? time_registration_over : Bool = true
  @siege_time_registration_end_date : Calendar?
  getter tax_percent = 0
  getter tax_rate = 0.0
  getter treasury = 0i64
  getter? show_npc_crest = false
  @tele_zone : L2ResidenceTeleportZone?
  @former_owner : L2Clan?
  getter artefacts = Array(L2ArtefactInstance).new(1)
  @functions = {} of Int32 => CastleFunction
  getter ticket_buy_count = 0
  @zone : L2SiegeZone?

  def initialize(castle_id : Int32)
    super

    load

    init_residence_zone

    if owner_id != 0
      load_functions
      load_door_upgrade
    end
  end

  def get_function(type : Int32) : CastleFunction?
    @functions[type]?
  end

  def engrave(clan : L2Clan, target : L2Object)
    sync do
      unless @artefacts.includes?(target)
        return
      end

      self.owner = clan
      sm = SystemMessage.clan_s1_engraved_ruler
      sm.add_string(clan.name)
      siege.announce_to_player(sm, true)
    end
  end

  def add_to_treasury(amount : Int64)
    if owner_id <= 0
      return
    end

    if name.casecmp?("Schuttgart") || name.casecmp?("Goddard")
      if rune = CastleManager.get_castle("rune")
        rune_tax = (amount * rune.tax_rate).to_i64
        if rune.owner_id > 0
          rune.add_to_treasury(rune_tax)
        end
        amount -= rune_tax
      end
    end

    if !name.casecmp?("aden") && !name.casecmp?("Rune") && !name.casecmp?("Schuttgart") && !name.casecmp?("Goddard")
      if aden = CastleManager.get_castle("aden")
        aden_tax = (amount * aden.tax_rate).to_i64
        if aden.owner_id > 0
          aden.add_to_treasury(aden_tax)
        end
        amount -= aden_tax
      end
    end

    add_to_treasury_no_tax(amount)
  end

  def add_to_treasury_no_tax(amount : Int64) : Bool
    if owner_id <= 0
      return false
    end

    if amount < 0
      amount = amount.abs
      if @treasury < amount
        return false
      end
      @treasury -= amount
    else
      if @treasury + amount > Inventory.max_adena
        @treasury = Inventory.max_adena
      else
        @treasury += amount
      end
    end

    begin
      GameDB.exec(
        "UPDATE castle SET treasury = ? WHERE id = ?",
        treasury,
        residence_id
      )
    rescue e
      error e
    end

    true
  end

  def banish_foreigners
    residence_zone.banish_foreigners(owner_id)
  end

  def in_zone?(x : Int32, y : Int32, z : Int32) : Bool
    zone.inside_zone?(x, y, z)
  end

  def zone : L2SiegeZone
    unless @zone
      ZoneManager.each(L2SiegeZone) do |zone|
        if zone.siege_l2id == residence_id
          @zone = zone
          break
        end
      end
    end

    @zone.as?(L2SiegeZone) ||
    raise("Couldn't find siege zone for castle with id #{residence_id}")
  end

  def residence_zone
    super.as(L2CastleZone)
  end

  def tele_zone : L2ResidenceTeleportZone
    unless @tele_zone
      ZoneManager.each(L2ResidenceTeleportZone) do |zone|
        if zone.residence_id == residence_id
          @tele_zone = zone
          break
        end
      end
    end

    @tele_zone.as?(L2ResidenceTeleportZone) ||
    raise("Couldn't find teleport zone for castle with id #{residence_id}")
  end

  def oust_all_players
    tele_zone.oust_all_players
  end

  def get_distance(obj : L2Object) : Float64
    zone.get_distance_to_zone(obj)
  end

  def close_door(pc : L2PcInstance, door_id : Int32)
    open_close_door(pc, door_id, false)
  end

  def open_door(pc : L2PcInstance, door_id : Int32)
    open_close_door(pc, door_id, true)
  end

  def open_close_door(pc : L2PcInstance, door_id : Int32, open : Bool)
    if pc.clan_id != owner_id
      return
    end

    if door = get_door(door_id)
      open ? door.open_me : door.close_me
    end
  end

  def remove_upgrade
    remove_door_upgrade
    remove_trap_upgrade
    @functions.each_key { |fc| remove_function(fc) }
    @functions.clear
  end

  def owner=(clan : L2Clan?)
    if owner_id > 0 && (clan.nil? || clan.id != owner_id)
      if old_owner = ClanTable.get_clan(owner_id)
        unless @former_owner
          @former_owner = old_owner
          if Config.remove_castle_circlets
            CastleManager.remove_circlet(old_owner, residence_id)
          end
        end

        begin
          if old_leader = old_owner.leader.player_instance?
            if old_leader.mount_type.wyvern?
              old_leader.dismount
            end
          end
        rescue e
          error e
        end
        old_owner.castle_id = 0
        old_owner.each_online_player do |m|
          remove_residential_skills(m)
          m.send_skill_list
        end
      end
    end

    update_owner_in_db(clan)
    self.show_npc_crest = false

    if clan && clan.fort_id > 0
      FortManager.get_fort_by_owner!(clan).remove_owner(true)
    end

    if siege.in_progress?
      siege.mid_victory
    end

    TerritoryWarManager.get_territory!(residence_id).owner_clan = clan

    if clan
      clan.each_online_player do |m|
        give_residential_skills(m)
        m.send_skill_list
      end
    end
  end

  def remove_owner(clan : L2Clan?)
    if clan
      @former_owner = clan
      if Config.remove_castle_circlets
        CastleManager.remove_circlet(clan, residence_id)
      end
      clan.each_online_player do |m|
        remove_residential_skills(m)
        m.send_skill_list
      end
      clan.castle_id = 0
      clan.broadcast_to_online_members(PledgeShowInfoUpdate.new(clan))
    end

    update_owner_in_db(nil)

    if siege.in_progress?
      siege.mid_victory
    end

    @functions.each_key { |fc| remove_function(fc) }
    @functions.clear
  end

  def tax_percent=(@tax_percent : Int32)
    @tax_rate = @tax_percent / 100.0

    GameDB.exec(
      "UPDATE castle SET taxPercent = ? WHERE id = ?",
      tax_percent,
      residence_id
    )
  rescue e
    error e
  end

  def spawn_door
    spawn_door(false)
  end

  def spawn_door(is_door_weak : Bool)
    @doors.each do |door|
      if door.dead?
        door.do_revive
        door.current_hp = (is_door_weak ? door.max_hp / 2 : door.max_hp).to_f
      end

      if door.open?
        door.close_me
      end
    end
  end

  private def load
    sql1 = "SELECT * FROM castle WHERE id = ?"
    sql2 = "SELECT clan_id FROM clan_data WHERE hasCastle = ?"

    GameDB.each(sql1, residence_id) do |rs|
      self.name = rs.get_string("name")

      date = Calendar.new
      date.ms = rs.get_i64("siegeDate")
      @siege_date = date
      date = Calendar.new
      date.ms = rs.get_i64("regTimeEnd")
      @siege_time_registration_end_date = date

      @tax_percent = rs.get_i32("taxPercent")
      @treasury = rs.get_i64("treasury")

      @show_npc_crest = rs.get_bool("showNpcCrest")
      @ticket_buy_count = rs.get_i32("ticketBuyCount")
    end

    @tax_rate = @tax_percent / 100.0

    GameDB.each(sql2, residence_id) do |rs|
      @owner_id = rs.get_i32("clan_id")
    end
  rescue e
    error e
  end

  private def load_functions
    sql = "SELECT * FROM castle_functions WHERE castle_id = ?"
    GameDB.each(sql, residence_id) do |rs|
      type = rs.get_i32("type")
      lvl = rs.get_i32("lvl")
      lease = rs.get_i32("lease")
      rate = rs.get_i64("rate")
      end_time = rs.get_i64("endTime")
      fn = CastleFunction.new(self, type, lvl, lease, 0, rate, end_time, true)
      @functions[type] = fn
    end
  rescue e
    error e
  end

  def remove_function(type : Int32)
    sql = "DELETE FROM castle_functions WHERE castle_id=? AND type=?"
    GameDB.exec(sql, residence_id, type)
  rescue e
    error e
  end

  def update_functions(pc : L2PcInstance, type : Int32, lvl : Int32, lease : Int, rate : Int64, add_new : Bool) : Bool
    if lease > 0
      unless pc.destroy_item_by_item_id("Consume", Inventory::ADENA_ID, lease.to_i64, nil, true)
        return false
      end
    end

    if add_new
      @functions[type] = CastleFunction.new(self, type, lvl, lease, 0, rate, 0, false)
    else
      if lvl == 0 && lease == 0
        remove_function(type)
      else
        diff_lease = lease - @functions[type].lease
        if diff_lease > 0
          @functions.delete(type)
          @functions[type] = CastleFunction.new(self, type, lvl, lease, 0, rate, -1, false)
        else
          fn = @functions[type]
          fn.lease = lease
          fn.lvl = lvl
          fn.db_save
        end
      end
    end

    true
  rescue e
    error e
    false
  end

  def activate_instance
    load_door
  end

  private def load_door
    DoorData.doors.each do |door|
      if door.castle? && door.castle.residence_id == residence_id
        @doors << door
      end
    end
  end

  private def load_door_upgrade
    sql = "SELECT * FROM castle_doorupgrade WHERE castleId=?"
    GameDB.each(sql, residence_id) do |rs|
      door_id = rs.get_i32("doorId")
      ratio = rs.get_i32("ratio")
      set_door_upgrade(door_id, ratio, false)
    end
  rescue e
    error e
  end

  private def remove_door_upgrade
    @doors.each do |door|
      door.stat.upgrade_hp_ratio = 1
      door.max_hp!
    end

    sql = "DELETE FROM castle_doorupgrade WHERE castleId=?"
    GameDB.exec(sql, residence_id)
  rescue e
    error e
  end

  def set_door_upgrade(door_id : Int32, ratio : Int32, save : Bool)
    if doors.empty?
      door = DoorData.get_door(door_id)
    else
      get_door(door_id)
    end

    unless door
      raise "#set_door_upgrade: couldn't find door"
    end

    door.stat.upgrade_hp_ratio = ratio
    door.max_hp!

    if save
      begin
        sql = "REPLACE INTO castle_doorupgrade (doorId, ratio, castleId) values (?,?,?)"
        GameDB.exec(
          sql,
          door_id,
          ratio,
          residence_id
        )
      rescue e
        error e
      end
    end
  end

  private def update_owner_in_db(clan : L2Clan?)
    if clan
      @owner_id = clan.id
    else
      @owner_id = 0
      CastleManorManager.reset_manor_data(residence_id)
    end

    sql = "UPDATE clan_data SET hasCastle = 0 WHERE hasCastle = ?"
    GameDB.exec(sql, residence_id)

    sql = "UPDATE clan_data SET hasCastle = ? WHERE clan_id = ?"
    GameDB.exec(sql, residence_id, owner_id)

    if clan
      clan.castle_id = residence_id
      clan.broadcast_to_online_members(PledgeShowInfoUpdate.new(clan))
      clan.broadcast_to_online_members(Music::SIEGE_VICTORY.packet)
    end
  rescue e
    error e
  end

  def get_door(door_id : Int32) : L2DoorInstance?
    if door_id <= 0
      return
    end

    doors.find { |door| door.id == door_id }
  end

  def owner? : L2Clan?
    if @owner_id != 0
      ClanTable.get_clan(@owner_id)
    end
  end

  def owner : L2Clan
    unless owner = owner?
      raise "This castle (#{self}) has no owner"
    end

    owner
  end

  def siege
    @siege ||= Siege.new(self)
  end

  def time_registration_over_date
    @siege_time_registration_end_date ||= Calendar.new
  end

  def show_npc_crest=(show : Bool)
    if @show_npc_crest != show
      @show_npc_crest = show
      update_show_npc_crest
    end
  end

  def update_clans_reputation
    former_owner = @former_owner

    if former_owner
      if former_owner != ClanTable.get_clan!(owner_id)
        max_reward = Math.max(0, former_owner.reputation_score)
        former_owner.take_reputation_score(Config.lose_castle_points, true)
        if owner = ClanTable.get_clan(owner_id)
          owner.add_reputation_score(Math.min(Config.take_castle_points, max_reward), true)
        end
      else
        former_owner.add_reputation_score(Config.castle_defended_points, true)
      end
    else
      if owner = ClanTable.get_clan(owner_id)
        owner.add_reputation_score(Config.take_castle_points, true)
      end
    end
  end

  def update_show_npc_crest
    sql = "UPDATE castle SET showNpcCrest = ? WHERE id = ?"
    GameDB.exec(sql, show_npc_crest?.to_s, residence_id)
  rescue e
    error e
  end

  def give_residential_skills(pc : L2PcInstance)
    territory = TerritoryWarManager.get_territory(residence_id)
    if territory && territory.owned_ward_ids.includes?(residence_id + 80)
      territory.owned_ward_ids.each do |ward_id|
        SkillTreesData.get_available_residential_skills(ward_id).each do |s|
          if sk = SkillData[s.skill_id, s.skill_level]?
            pc.add_skill(sk, false)
          else
            warn "No skill for Territory Ward id: #{ward_id}, skill id: #{s.skill_id}, level: #{s.skill_level}."
          end
        end
      end
    end

    super
  end

  def remove_residential_skills(pc : L2PcInstance)
    territory = TerritoryWarManager.get_territory(residence_id)
    if territory
      territory.owned_ward_ids.each do |ward_id|
        SkillTreesData.get_available_residential_skills(ward_id).each do |s|
          if sk = SkillData[s.skill_id, s.skill_level]?
            pc.remove_skill(sk, true)
          else
            warn "No skill for Territory Ward id: #{ward_id}, skill id: #{s.skill_id}, level: #{s.skill_level}."
          end
        end
      end
    end

    super
  end

  def register_artefact(artefact : L2ArtefactInstance)
    @artefacts << artefact
  end

  def ticket_buy_count=(count : Int32)
    @ticket_buy_count = count

    sql = "UPDATE castle SET ticketBuyCount = ? WHERE id = ?"
    GameDB.exec(sql, count, residence_id)
  rescue e
    error e
  end

  def get_trap_upgrade_level(tower_index : Int32) : Int32
    if sp = SiegeManager.get_flame_towers(residence_id)[tower_index]?
      return sp.upgrade_level
    end

    0
  end

  def set_trap_upgrade(tower_index : Int32, level : Int32, save : Bool)
    if save
      begin
        sql = "REPLACE INTO castle_trapupgrade (castleId, towerIndex, level) values (?,?,?)"
        GameDB.exec(sql, residence_id, tower_index, level)
      rescue e
        error e
      end
    end

    if sp = SiegeManager.get_flame_towers(residence_id)[tower_index]?
      sp.upgrade_level = level
    end
  end

  def remove_trap_upgrade
    SiegeManager.get_flame_towers(residence_id).each &.upgrade_level = 0

    sql = "DELETE FROM castle_trapupgrade WHERE castleId=?"
    GameDB.exec(sql, residence_id)
  rescue e
    error e
  end

  private def init_residence_zone
    # ZoneManager.get_all_zones(L2CastleZone).each do |zone|
    #   if zone.residence_id == residence_id
    #     self.residence_zone = zone
    #   end
    # end

    ZoneManager.each(L2CastleZone) do |zone|
      if zone.residence_id == residence_id
        self.residence_zone = zone
      end
    end
  end

  class CastleFunction
    include Loggable

    getter type, rate
    property lvl : Int32

    def initialize(@castle : Castle, @type : Int32, @lvl : Int32, @fee : Int32, @temp_fee : Int32, @rate : Int64, @end_date : Int64, cwh : Bool)
      initialize_task(cwh)
    end

    def lease
      @fee
    end

    def lease=(@fee : Int32)
    end

    def end_time
      @end_date
    end

    def end_time=(@end_date : Int64)
    end

    private def initialize_task(cwh : Bool)
      if @castle.owner_id <= 0
        return
      end

      time = Time.ms
      task = ->{ function_task(cwh) }

      if @end_date > time
        ThreadPoolManager.schedule_general(task, @end_date - time)
      else
        ThreadPoolManager.schedule_general(task, 0)
      end
    end

    private def function_task(cwh : Bool)
      if @castle.owner_id <= 0
        return
      end

      clan = ClanTable.get_clan!(@castle.owner_id)
      ware = clan.warehouse

      if ware.adena >= @fee || !cwh
        fee = @fee
        if end_time == -1
          fee = @temp_fee
        end
        self.end_time = Time.ms + rate
        if cwh
          ware.destroy_item_by_item_id("CS_function_fee", Inventory::ADENA_ID, fee.to_i64, nil, nil)
        end
        ThreadPoolManager.schedule_general(->{ function_task(true) }, rate)
      else
        @castle.remove_function(type)
      end
    rescue e
      error e
    end

    def db_save
      sql = "REPLACE INTO castle_functions (castle_id, type, lvl, lease, rate, endTime) VALUES (?,?,?,?,?,?)"
      GameDB.exec(
        sql,
        @castle.residence_id,
        type,
        lvl,
        lease,
        rate,
        end_time
      )
    rescue e
      error e
    end
  end
end
