require "./clan_hall/siegable"
require "../../instance_managers/siege_guard_manager"
require "../../enums/siege_teleport_who_type"

class Siege
  include Siegable
  include Packets::Outgoing
  include Loggable

  OWNER = -1
  DEFENDER = 0
  ATTACKER = 1
  DEFENDER_NOT_APPROVED = 2

  @control_towers = [] of L2ControlTowerInstance
  @flame_towers = [] of L2FlameTowerInstance
  @normal_side = true
  @siege_end_date = Calendar.new
  @scheduled_start_siege_task : TaskScheduler::DelayedTask?
  @first_owner_clan_id = -1
  @attacker_clans = Concurrent::Array(L2SiegeClan).new
  @defender_clans = Concurrent::Array(L2SiegeClan).new

  getter control_tower_count = 0
  getter siege_guard_manager
  getter defender_waiting_clans = Concurrent::Array(L2SiegeClan).new
  getter! castle
  getter? in_progress = false
  getter? registration_over = false

  def initialize(castle : Castle)
    @castle = castle
    @siege_guard_manager = SiegeGuardManager.new(castle)
    start_auto_task
  end

  def end_siege
    unless in_progress?
      return
    end

    sm = SystemMessage.siege_of_s1_has_ended
    sm.add_castle_id(castle.residence_id)
    Broadcast.to_all_online_players(sm)

    if castle.owner_id > 0
      clan = ClanTable.get_clan(castle.owner_id).not_nil!
      sm = SystemMessage.clan_s1_victorious_over_s2_s_siege
      sm.add_string(clan.name)
      sm.add_castle_id(castle.residence_id)
      Broadcast.to_all_online_players(sm)

      if clan.id == @first_owner_clan_id
        clan.increase_blood_alliance_count
      else
        castle.ticket_buy_count = 0

        clan.members.each do |m|
          pc = m.player_instance
          if pc && pc.noble?
            Hero.set_castle_taken(pc.l2id, castle.residence_id)
          end
        end
      end
    else
      sm = SystemMessage.siege_s1_draw
      sm.add_castle_id(castle.residence_id)
      Broadcast.to_all_online_players(sm)
    end

    attacker_clans.each do |attacker_clan|
      unless clan = ClanTable.get_clan(attacker_clan.clan_id)
        next
      end

      clan.clear_siege_kills
      clan.clear_siege_deaths
    end

    defender_clans.each do |defender_clan|
      unless clan = ClanTable.get_clan(defender_clan.clan_id)
        next
      end

      clan.clear_siege_kills
      clan.clear_siege_deaths
    end

    castle.update_clans_reputation
    remove_flags
    teleport_player(SiegeTeleportWhoType::NotOwner, TeleportWhereType::TOWN)
    @in_progress = false
    update_player_siege_state_flags(true)
    save_castle_siege
    clear_siege_clan
    remove_towers
    @siege_guard_manager.unspawn_siege_guard
    if castle.owner_id > 0
      @siege_guard_manager.remove_mercs
    end
    castle.spawn_door
    castle.zone.active = false
    castle.zone.update_zone_status_for_characters_inside
    castle.zone.siege_instance = nil

    OnCastleSiegeFinish.new(self).async(castle)
  end

  private def remove_defender(sc : L2SiegeClan?)
    if sc
      defender_clans.delete_first(sc)
    end
  end

  private def remove_attacker(sc : L2SiegeClan?)
    if sc
      attacker_clans.delete_first(sc)
    end
  end

  private def add_defender(sc : L2SiegeClan?, type : SiegeClanType)
    unless sc
      return
    end

    sc.type = type
    defender_clans << sc
  end

  private def add_attacker(sc : L2SiegeClan?)
    unless sc
      return
    end

    sc.type = SiegeClanType::ATTACKER
    attacker_clans << sc
  end

  def mid_victory
    unless in_progress?
      return
    end

    if castle.owner_id > 0
      @siege_guard_manager.remove_mercs
    end

    if defender_clans.empty? && attacker_clans.size == 1
      sc_new_owner = get_attacker_clan(castle.owner_id)
      remove_attacker(sc_new_owner)
      add_defender(sc_new_owner, SiegeClanType::OWNER)
      end_siege
      return
    end

    if castle.owner_id > 0
      ally_id = ClanTable.get_clan(castle.owner_id).not_nil!.ally_id
      if defender_clans.empty?
        if ally_id != 0
          in_same_ally = true
          attacker_clans.each do |sc|
            if ClanTable.get_clan(sc.clan_id).not_nil!.ally_id != ally_id
              in_same_ally = false
              break
            end
          end

          if in_same_ally
            sc_new_owner = get_attacker_clan(castle.owner_id)
            remove_attacker(sc_new_owner)
            add_defender(sc_new_owner, SiegeClanType::OWNER)
            end_siege
            return
          end
        end
      end

      sc_new_owner = get_attacker_clan(castle.owner_id)
      remove_attacker(sc_new_owner)
      add_defender(sc_new_owner, SiegeClanType::OWNER)

      ClanTable.get_clan_allies(ally_id).each do |clan|
        if sc = get_attacker_clan(clan.id)
          remove_attacker(sc)
          add_defender(sc, SiegeClanType::DEFENDER)
        end
      end

      teleport_player(SiegeTeleportWhoType::Attacker, TeleportWhereType::SIEGEFLAG)
      teleport_player(SiegeTeleportWhoType::Spectator, TeleportWhereType::TOWN)

      remove_defender_flags
      castle.remove_upgrade
      castle.spawn_door(true)
      remove_towers
      @control_tower_count = 0
      spawn_control_tower
      spawn_flame_tower
      update_player_siege_state_flags(false)

      OnCastleSiegeOwnerChange.new(self).async(castle)
    end
  end

  def start_siege
    if in_progress?
      return
    end

    @first_owner_clan_id = castle.owner_id

    if attacker_clans.empty?
      if @first_owner_clan_id <= 0
        sm = SystemMessage.siege_of_s1_has_been_canceled_due_to_lack_of_interest
      else
        sm = SystemMessage.s1_siege_was_canceled_because_no_clans_participated
        owner_clan = ClanTable.get_clan(@first_owner_clan_id).not_nil!
        owner_clan.increase_blood_alliance_count
      end

      sm.add_castle_id(castle.residence_id)
      Broadcast.to_all_online_players(sm)
      save_castle_siege
      return
    end

    @in_normal_side = true
    @in_progress = true

    load_siege_clan
    update_player_siege_state_flags(false)
    teleport_player(SiegeTeleportWhoType::NotOwner, TeleportWhereType::TOWN)
    @control_tower_count = 0
    spawn_control_tower
    spawn_flame_tower
    castle.spawn_door
    spawn_siege_guard
    MercTicketManager.delete_tickets(castle.residence_id)
    castle.zone.siege_instance = self
    castle.zone.active = true
    castle.zone.update_zone_status_for_characters_inside

    @siege_end_date = Calendar.new
    @siege_end_date.add(:MINUTE, SiegeManager.siege_length)
    ThreadPoolManager.schedule_general(->schedule_end_siege_task, 1000)

    sm = SystemMessage.siege_of_s1_has_started
    sm.add_castle_id(castle.residence_id)
    Broadcast.to_all_online_players(sm)

    OnCastleSiegeStart.new(self).async(castle)
  end

  def announce_to_player(sm, both_sides : Bool)
    defender_clans.each do |siege_clan|
      clan = ClanTable.get_clan(siege_clan.clan_id).not_nil!
      clan.each_online_player do |pc|
        pc.send_packet(sm)
      end
    end

    unless both_sides
      return
    end

    attacker_clans.each do |siege_clan|
      clan = ClanTable.get_clan(siege_clan.clan_id).not_nil!
      clan.each_online_player do |pc|
        pc.send_packet(sm)
      end
    end
  end

  def update_player_siege_state_flags(clear : Bool)
    attacker_clans.each do |siege_clan|
      clan = ClanTable.get_clan(siege_clan.clan_id).not_nil!
      clan.each_online_player do |m|
        if clear
          m.siege_state = 0
          m.siege_side = 0
          m.in_siege = false
          m.stop_fame_task
        else
          m.siege_state = 1
          m.siege_side = castle.residence_id
          if in_zone?(m)
            m.in_siege = true
            m.start_fame_task(Config.castle_zone_fame_task_frequency * 1000, Config.castle_zone_fame_aquire_points)
          end
        end

        m.send_packet(UserInfo.new(m))
        m.send_packet(ExBrExtraUserInfo.new(m))
        m.known_list.each_player do |pc|
          rc = RelationChanged.new(m, m.get_relation(pc), m.auto_attackable?(pc))
          pc.send_packet(rc)
          if s = m.summon
            rc = RelationChanged.new(s, m.get_relation(pc), m.auto_attackable?(pc))
            pc.send_packet(rc)
          end
        end
      end
    end

    defender_clans.each do |siege_clan|
      clan = ClanTable.get_clan(siege_clan.clan_id).not_nil!
      clan.each_online_player do |m|
        if clear
          m.siege_state = 0
          m.siege_side = 0
          m.in_siege = false
          m.stop_fame_task
        else
          m.siege_state = 2
          m.siege_side = castle.residence_id
          if in_zone?(m)
            m.in_siege = true
            m.start_fame_task(Config.castle_zone_fame_task_frequency * 1000, Config.castle_zone_fame_aquire_points)
          end
        end

        m.send_packet(UserInfo.new(m))
        m.send_packet(ExBrExtraUserInfo.new(m))
        m.known_list.each_player do |pc|
          rc = RelationChanged.new(m, m.get_relation(pc), m.auto_attackable?(pc))
          pc.send_packet(rc)
          if s = m.summon
            rc = RelationChanged.new(s, m.get_relation(pc), m.auto_attackable?(pc))
            pc.send_packet(rc)
          end
        end
      end
    end
  end

  def approve_siege_defender_clan(clan_id : Int32)
    if clan_id <= 0
      return
    end

    save_siege_clan(ClanTable.get_clan(clan_id).not_nil!, DEFENDER, true)
    load_siege_clan
  end

  def in_zone?(obj : L2Object) : Bool
    in_zone?(*obj.xyz)
  end

  def in_zone?(x : Int32, y : Int32, z : Int32) : Bool
    in_progress? && castle.in_zone?(x, y, z)
  end

  def attacker?(clan : L2Clan?) : Bool
    !!clan && !!get_attacker_clan(clan)
  end

  def defender?(clan : L2Clan?) : Bool
    !!clan && !!get_defender_clan(clan)
  end

  def defender_waiting?(clan : L2Clan?) : Bool
    !!clan && !!get_defender_waiting_clan(clan)
  end

  def clear_siege_clan
    sql = "DELETE FROM siege_clans WHERE castle_id=?"
    GameDB.exec(sql, castle.residence_id)

    sql = "DELETE FROM siege_clans WHERE clan_id=?"
    GameDB.exec(sql, castle.owner_id)

    attacker_clans.clear
    defender_clans.clear
    defender_waiting_clans.clear
  rescue e
    error e
  end

  def clear_siege_waiting_clan
    sql = "DELETE FROM siege_clans WHERE castle_id=? and type = 2"
    GameDB.exec(sql, castle.residence_id)

    defender_waiting_clans.clear
  rescue e
    error e
  end

  def attackers_in_zone : Array(L2PcInstance)
    players = [] of L2PcInstance

    attacker_clans.each do |siege_clan|
      clan = ClanTable.get_clan(siege_clan.clan_id).not_nil!
      clan.each_online_player do |pc|
        if pc.in_siege?
          players << pc
        end
      end
    end

    players
  end

  def players_in_zone : Array(L2PcInstance)
    castle.zone.players_inside.to_a
  end

  def owners_in_zone : Array(L2PcInstance)
    players = [] of L2PcInstance

    defender_clans.each do |siege_clan|
      clan = ClanTable.get_clan(siege_clan.clan_id).not_nil!
      clan.each_online_player do |pc|
        if clan.id != castle.owner_id
          next
        end

        if pc.in_siege?
          players << pc
        end
      end
    end

    players
  end

  def spectators_in_zone : Array(L2PcInstance)
    castle.zone.players_inside.reject(&.in_siege?).to_a
  end

  def killed_ct(ct : L2Npc)
    @control_tower_count &-= 1
    if @control_tower_count < 0
      @control_tower_count = 0
    end
  end

  def killed_flag(flag : L2Npc?)
    if flag
      attacker_clans.each &.remove_flag(flag)
    end
  end

  def list_register_clan(pc : L2PcInstance)
    pc.send_packet(SiegeInfo.new(castle))
  end

  def register_attacker(pc : L2PcInstance)
    register_attacker(pc, false)
  end

  def register_attacker(pc : L2PcInstance, force : Bool)
    unless clan = pc.clan
      return
    end

    ally_id = 0
    if castle.owner_id != 0
      ally_id = ClanTable.get_clan(castle.owner_id).not_nil!.ally_id
    end

    if ally_id != 0
      if clan.ally_id == ally_id && !force
        pc.send_packet(SystemMessageId::CANNOT_ATTACK_ALLIANCE_CASTLE)
        return
      end
    end

    if force
      if SiegeManager.registered?(clan, castle.residence_id)
        pc.send_packet(SystemMessageId::ALREADY_REQUESTED_SIEGE_BATTLE)
      else
        save_siege_clan(clan, ATTACKER, false)
      end

      return
    end

    if can_register?(pc, ATTACKER)
      save_siege_clan(clan, ATTACKER, false)
    end
  end

  def register_defender(pc : L2PcInstance)
    register_defender(pc, false)
  end

  def register_defender(pc : L2PcInstance, force : Bool)
    if castle.owner_id <= 0
      pc.send_message("You cannot register as a defender because #{castle.name} is owned by NPC.")
      return
    end

    if force
      if SiegeManager.registered?(pc.clan, castle.residence_id)
        pc.send_packet(SystemMessageId::ALREADY_REQUESTED_SIEGE_BATTLE)
      else
        save_siege_clan(pc.clan.not_nil!, DEFENDER_NOT_APPROVED, false)
      end

      return
    end

    if can_register?(pc, DEFENDER_NOT_APPROVED)
      save_siege_clan(pc.clan.not_nil!, DEFENDER_NOT_APPROVED, false)
    end
  end

  def remove_siege_clan(clan_id : Int32)
    if clan_id <= 0
      return
    end

    sql = "DELETE FROM siege_clans WHERE castle_id=? and clan_id=?"
    GameDB.exec(sql, castle.residence_id, clan_id)

    load_siege_clan
  rescue e
    error e
  end

  def remove_siege_clan(clan : L2Clan?)
    unless clan
      return
    end

    if clan.castle_id == castle.residence_id
      return
    end

    unless SiegeManager.registered?(clan, castle.residence_id)
      return
    end

    remove_siege_clan(clan.id)
  end

  def remove_siege_clan(pc : L2PcInstance)
    remove_siege_clan(pc.clan)
  end

  def start_auto_task
    correct_siege_date_time

    info { "Siege of #{castle.name}: #{castle.siege_date.time}." }

    load_siege_clan

    if task = @scheduled_start_siege_task
      task.cancel
    end

    @scheduled_start_siege_task = ThreadPoolManager.schedule_general(->schedule_start_siege_task, 1000)
  end

  def teleport_player(who : SiegeTeleportWhoType, where : TeleportWhereType)
    case who
    when .owner?
      players = owners_in_zone
    when .not_owner?
      players = players_in_zone.reject do |pc|
        pc.in_observer_mode? || (pc.clan_id > 0 && pc.clan_id == castle.owner_id)
      end
    when .attacker?
      players = attackers_in_zone
    when .spectator?
      players = spectators_in_zone
    end


    if players
      players.each do |pc|
        if pc.override_castle_conditions? || pc.jailed?
          next
        end

        pc.tele_to_location(where)
      end
    end
  end

  private def add_attacker(clan_id : Int32)
    attacker_clans << L2SiegeClan.new(clan_id, SiegeClanType::ATTACKER)
  end

  private def add_defender(clan_id : Int32)
    defender_clans << L2SiegeClan.new(clan_id, SiegeClanType::DEFENDER)
  end

  private def add_defender(clan_id : Int32, type : SiegeClanType)
    defender_clans << L2SiegeClan.new(clan_id, type)
  end

  def add_defender_waiting(clan_id : Int32)
    siege_clan = L2SiegeClan.new(clan_id, SiegeClanType::DEFENDER_PENDING)
    defender_waiting_clans << siege_clan
  end

  def can_register?(pc : L2PcInstance, type_id : Int) : Bool
    case
    when registration_over?
      sm = SystemMessage.deadline_for_siege_s1_passed
      sm.add_castle_id(castle.residence_id)
      pc.send_packet(sm)
    when in_progress?
      pc.send_packet(SystemMessageId::NOT_SIEGE_REGISTRATION_TIME2)
    when pc.clan.nil? || pc.clan.not_nil!.level < SiegeManager.siege_clan_min_level
      pc.send_packet(SystemMessageId::ONLY_CLAN_LEVEL_5_ABOVE_MAY_SIEGE)
    when pc.clan.not_nil!.id == castle.owner_id
      pc.send_packet(SystemMessageId::CLAN_THAT_OWNS_CASTLE_IS_AUTOMATICALLY_REGISTERED_DEFENDING)
    when pc.clan.not_nil!.castle_id > 0
      pc.send_packet(SystemMessageId::CLAN_THAT_OWNS_CASTLE_CANNOT_PARTICIPATE_OTHER_SIEGE)
    when SiegeManager.registered?(pc.clan, castle.residence_id)
      pc.send_packet(SystemMessageId::ALREADY_REQUESTED_SIEGE_BATTLE)
    when already_registered_for_same_day?(pc.clan.not_nil!)
      pc.send_packet(SystemMessageId::APPLICATION_DENIED_BECAUSE_ALREADY_SUBMITTED_A_REQUEST_FOR_ANOTHER_SIEGE_BATTLE)
    when type_id == ATTACKER && attacker_clans.size >= SiegeManager.attacker_max_clans
      pc.send_packet(SystemMessageId::ATTACKER_SIDE_FULL)
    when (type_id == DEFENDER || type_id == DEFENDER_NOT_APPROVED || type_id == OWNER) && defender_clans.size + defender_waiting_clans.size >= SiegeManager.defender_max_clans
      pc.send_packet(SystemMessageId::DEFENDER_SIDE_FULL)
    else
      return true
    end

    false
  end

  def already_registered_for_same_day?(clan : L2Clan) : Bool
    SiegeManager.sieges.each do |siege|
      if siege == self
        next
      end

      if siege.siege_date.day == siege_date.day
        if siege.attacker?(clan)
          return true
        end

        if siege.defender?(clan)
          return true
        end

        if siege.defender_waiting?(clan)
          return true
        end
      end
    end

    false
  end

  def correct_siege_date_time
    corrected = false

    if castle.siege_date.ms < Time.ms
      corrected = true
      set_next_siege_date
    end

    if corrected
      save_siege_date
    end
  end

  private def load_siege_clan
    attacker_clans.clear
    defender_clans.clear
    defender_waiting_clans.clear

    sql = "SELECT clan_id,type FROM siege_clans where castle_id=?"
    GameDB.each(sql, castle.residence_id) do |rs|
      case type_id = rs.get_i32(:"type")
      when DEFENDER
        add_defender(rs.get_i32(:"clan_id"))
      when ATTACKER
        add_attacker(rs.get_i32(:"clan_id"))
      when DEFENDER_NOT_APPROVED
        add_defender_waiting(rs.get_i32(:"clan_id"))
      end

    end
  rescue e
    error e
  end

  private def remove_towers
    @flame_towers.each &.delete_me
    @flame_towers.clear

    @control_towers.each &.delete_me
    @control_towers.clear
  end

  private def remove_flags
    attacker_clans.each &.remove_flags
    defender_clans.each &.remove_flags
  end

  private def remove_defender_flags
    defender_clans.each &.remove_flags
  end

  private def save_castle_siege
    set_next_siege_date

    time_registration_over_date.ms = Time.ms
    time_registration_over_date.add(1.day)
    castle.time_registration_over = false

    save_siege_date
    start_auto_task
  end

  def save_siege_date
    if task = @scheduled_start_siege_task
      task.cancel
      @scheduled_start_siege_task = ThreadPoolManager.schedule_general(->schedule_start_siege_task, 1000)
    end

    sql = "UPDATE castle SET siegeDate = ?, regTimeEnd = ?, regTimeOver = ? WHERE id = ?"
    GameDB.exec(
      sql,
      siege_date.ms,
      time_registration_over_date.ms,
      time_registration_over?.to_s,
      castle.residence_id
    )
  rescue e
    error e
  end

  private def save_siege_clan(clan : L2Clan, type_id : Int, update_registration : Bool)
    if clan.castle_id > 0
      return
    end

    case type_id
    when DEFENDER, DEFENDER_NOT_APPROVED, OWNER
      if defender_clans.size + defender_waiting_clans.size >= SiegeManager.defender_max_clans
        return
      end
    else
      if attacker_clans.size >= SiegeManager.attacker_max_clans
        return
      end
    end

    if !update_registration
      sql = "INSERT INTO siege_clans (clan_id,castle_id,type,castle_owner) values (?,?,?,0)"
      GameDB.exec(sql, clan.id, castle.residence_id, type_id)
    else
      sql = "UPDATE siege_clans SET type = ? WHERE castle_id = ? AND clan_id = ?"
      GameDB.exec(sql, type_id, castle.residence_id, clan.id)
    end

    case type_id
    when DEFENDER, OWNER
      add_defender(clan.id)
    when ATTACKER
      add_attacker(clan.id)
    when DEFENDER_NOT_APPROVED
      add_defender_waiting(clan.id)
    end

  rescue e
    error e
  end

  private def set_next_siege_date
    cal = castle.siege_date
    time = Time.ms

    if cal.ms < time
      cal.ms = time
    end

    SiegeScheduleData.schedule_dates.each do |holder|
      cal.day = holder.day
      cal.hour = holder.hour
      cal.minute = 0
      cal.second = 0
      if cal.before?(Time.now)
        cal.add(2.weeks)
      end

      if CastleManager.get_siege_dates(cal.ms) < holder.max_concurrent
        CastleManager.register_siege_date(castle.residence_id, cal.ms)
        break
      end
    end

    sm = SystemMessage.s1_announced_siege_time
    sm.add_castle_id(castle.residence_id)
    Broadcast.to_all_online_players(sm)

    @registration_over = false
  end

  private def spawn_control_tower
    SiegeManager.get_control_towers(castle.residence_id).each do |ts|
      begin
        sp = L2Spawn.new(ts.id)
        sp.location = ts.location
        @control_towers << sp.do_spawn.as(L2ControlTowerInstance)
      rescue e
        error e
      end
    end

    @control_tower_count = @control_towers.size
  end

  private def spawn_flame_tower
    SiegeManager.get_flame_towers(castle.residence_id).each do |ts|
      begin
        sp = L2Spawn.new(ts.id)
        sp.location = ts.location
        tower = sp.do_spawn.as(L2FlameTowerInstance)
        tower.upgrade_level = ts.upgrade_level
        tower.zone_list = ts.zone_list
        @flame_towers << tower
      rescue e
        error e
      end
    end
  end

  private def spawn_siege_guard
    siege_guard_manager.spawn_siege_guard

    siege_guard_manager.siege_guard_spawn.each do |sp|
      closest_ct = nil
      distance_closest = Int32::MAX
      @control_towers.each do |ct|
        dst = ct.calculate_distance(sp, true, true)
        if dst < distance_closest
          closest_ct = ct
          distance_closest = dst
        end
      end

      if closest_ct
        closest_ct.register_guard(sp)
      end
    end
  end

  def get_attacker_clan(clan : L2Clan?) : L2SiegeClan?
    get_attacker_clan(clan.id) if clan
  end

  def get_attacker_clan(clan_id : Int32) : L2SiegeClan?
    attacker_clans.find { |sc| sc.clan_id == clan_id }
  end

  def attacker_clans : Interfaces::Array(L2SiegeClan)?
    @normal_side ? @attacker_clans : @defender_clans
  end

  def attacker_respawn_delay
    SiegeManager.attacker_respawn_delay
  end

  def get_defender_clan(clan : L2Clan?) : L2SiegeClan?
    get_defender_clan(clan.id) if clan
  end

  def get_defender_clan(clan_id : Int32) : L2SiegeClan?
    defender_clans.find { |sc| sc.clan_id == clan_id }
  end

  def defender_clans : Interfaces::Array(L2SiegeClan)?
    @normal_side ? @defender_clans : @attacker_clans
  end

  def get_defender_waiting_clan(clan : L2Clan?) : L2SiegeClan?
    get_defender_waiting_clan(clan.id) if clan
  end

  def get_defender_waiting_clan(clan_id : Int32) : L2SiegeClan?
    defender_waiting_clans.find { |sc| sc.clan_id == clan_id }
  end

  def time_registration_over? : Bool
    castle.time_registration_over?
  end

  def siege_date : Calendar
    castle.siege_date
  end

  def time_registration_over_date : Calendar
    castle.time_registration_over_date
  end

  def end_time_registration(automatic : Bool)
    castle.time_registration_over = true

    unless automatic
      save_siege_date
    end
  end

  def get_flag(clan : L2Clan?) : Interfaces::Array(L2Npc)?
    unless clan
      return
    end

    if sc = get_attacker_clan(clan)
      sc.flag
    end
  end

  def give_fame? : Bool
    true
  end

  def fame_frequency : Int32
    Config.castle_zone_fame_task_frequency.to_i32
  end

  def fame_amount : Int32
    Config.castle_zone_fame_aquire_points
  end

  def update_siege
    # no_op
  end

  #

  private def schedule_end_siege_task
    unless in_progress?
      return
    end

    time = @siege_end_date.ms - Time.ms
    if time > 3_600_000
      sm = SystemMessage.s1_hours_until_siege_conclusion
      sm.add_int(2)
      announce_to_player(sm, true)
      ThreadPoolManager.schedule_general(->schedule_end_siege_task, time - 3_600_000)
    elsif time <= 3_600_000 && time > 600_000
      sm = SystemMessage.s1_minutes_until_siege_conclusion
      sm.add_int(time / 60_000)
      announce_to_player(sm, true)
      ThreadPoolManager.schedule_general(->schedule_end_siege_task, time - 600_000)
    elsif time <= 600_000 && time > 300_000
      sm = SystemMessage.s1_minutes_until_siege_conclusion
      sm.add_int(time / 60_000)
      announce_to_player(sm, true)
      ThreadPoolManager.schedule_general(->schedule_end_siege_task, time - 300_000)
    elsif time <= 300_000 && time > 10_000
      sm = SystemMessage.s1_minutes_until_siege_conclusion
      sm.add_int(time / 60_000)
      announce_to_player(sm, true)
      ThreadPoolManager.schedule_general(->schedule_end_siege_task, time - 10_000)
    elsif time <= 10_000 && time > 0
      sm = SystemMessage.castle_siege_s1_seconds_left
      sm.add_int(time / 1000)
      announce_to_player(sm, true)
      ThreadPoolManager.schedule_general(->schedule_end_siege_task, time)
    else
      castle.siege.end_siege
    end
  rescue e
    error e
  end

  private def schedule_start_siege_task
    @scheduled_start_siege_task.try &.cancel
    if in_progress?
      return
    end

    unless time_registration_over?
      time = time_registration_over_date.ms - Time.ms
      if time > 0
        @scheduled_start_siege_task = ThreadPoolManager.schedule_general(->schedule_start_siege_task, time)
        return
      end
      end_time_registration(true)
    end

    time = siege_date.ms - Time.ms
    if time > 86_400_000
      @scheduled_start_siege_task = ThreadPoolManager.schedule_general(->schedule_start_siege_task, time - 86400000)
    elsif time <= 86_400_000 && time > 13_600_000
      sm = SystemMessage.registration_term_for_s1_ended
      sm.add_castle_id(castle.residence_id)
      Broadcast.to_all_online_players(sm)
      @registration_over = true
      clear_siege_waiting_clan
      @scheduled_start_siege_task = ThreadPoolManager.schedule_general(->schedule_start_siege_task, time - 13600000)
    elsif time <= 13_600_000 && time > 600_000
      @scheduled_start_siege_task = ThreadPoolManager.schedule_general(->schedule_start_siege_task, time - 600000)
    elsif time <= 600_000 && time > 300_000
      @scheduled_start_siege_task = ThreadPoolManager.schedule_general(->schedule_start_siege_task, time - 300000)
    elsif time <= 300_000 && time > 10_000
      @scheduled_start_siege_task = ThreadPoolManager.schedule_general(->schedule_start_siege_task, time - 10000)
    elsif time <= 10_000 && time > 0
      @scheduled_start_siege_task = ThreadPoolManager.schedule_general(->schedule_start_siege_task, time)
    else
      castle.siege.start_siege
    end
  rescue e
    error e
  end

  def to_log(io : IO)
    super
    io.print('(', castle.name, ')')
  end
end
