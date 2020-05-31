require "./siegable"
require "../../l2_siege_clan"

abstract class ClanHallSiegeEngine < Quest
  include Siegable

  private SQL_LOAD_ATTACKERS = "SELECT attacker_id FROM clanhall_siege_attackers WHERE clanhall_id = ?"
  private SQL_SAVE_ATTACKERS = "INSERT INTO clanhall_siege_attackers VALUES (?,?)"
  private SQL_LOAD_GUARDS = "SELECT * FROM clanhall_siege_guards WHERE clanHallId = ?"

  FORTRESS_RESSISTANCE = 21
  DEVASTATED_CASTLE = 34
  BANDIT_STRONGHOLD = 35
  RAINBOW_SPRINGS = 62
  BEAST_FARM = 63
  FORTRESS_OF_DEAD = 64

  @guards = [] of L2Spawn
  @hall : SiegableHall
  @siege_task : TaskExecutor::Scheduler::DelayedTask?
  @mission_accomplished = false

  getter attackers = Concurrent::Map(Int32, L2SiegeClan).new

  def initialize(name : String, description : String, hall_id : Int32)
    super(-1, name, description)

    @hall = ClanHallSiegeManager.get_siegable_hall(hall_id).not_nil!
    @hall.siege = self
    delay = @hall.next_siege_time - Time.ms - 3_600_000
    @siege_task = ThreadPoolManager.schedule_general(->prepare_owner_task, delay)
    info { "Siege scheduled for #{siege_date.time}." }
    load_attackers
  end

  def load_attackers
    GameDB.each(SQL_LOAD_ATTACKERS, @hall.id) do |rs|
      id = rs.get_i32(:"attacker_id")
      clan = L2SiegeClan.new(id, SiegeClanType::ATTACKER)
      @attackers[id] = clan
    end
  rescue e
    error e
  end

  def save_attackers
    sql = "DELETE FROM clanhall_siege_attackers WHERE clanhall_id = ?"
    GameDB.exec(sql, @hall.id)
    if @attackers.size > 0
      @attackers.each_value do |clan|
        GameDB.exec(SQL_SAVE_ATTACKERS, @hall.id, clan.clan_id)
      end
    end
  rescue e
    error e
  end

  def load_guards
    GameDB.each(SQL_LOAD_GUARDS, @hall.id) do |rs|
      npc_id = rs.get_i32(:"npcId").to_u16!.to_i32
      sp = L2Spawn.new(npc_id)
      sp.x = rs.get_i32(:"x")
      sp.y = rs.get_i32(:"y")
      sp.z = rs.get_i32(:"z")
      sp.heading = rs.get_i32(:"heading")
      sp.respawn_delay = rs.get_i32(:"respawnDelay")
      sp.amount = 1
      @guards << sp
    end
  rescue e
    error e
  end

  def spawn_siege_guards
    @guards.each &.init
  end

  def unspawn_siege_guards
    @guards.each do |guard|
      guard.stop_respawn
      if ls = guard.last_spawn
        ls.delete_me
      end
    end
  end

  def get_flag(clan : L2Clan?) : Interfaces::Array(L2Npc)?
    if temp = get_attacker_clan(clan)
      temp.flag # nilable?
    end
  end

  def attacker?(clan : L2Clan?) : Bool
    return false unless clan
    @attackers.has_key?(clan.id)
  end

  def defender?(clan : L2Clan?) : Bool
    false
  end

  def get_attacker_clan(clan_id : Int32) : L2SiegeClan?
    @attackers[clan_id]?
  end

  def get_attacker_clan(clan : L2Clan?) : L2SiegeClan?
    if clan
      get_attacker_clan(clan.id)
    end
  end

  def attacker_clans : Interfaces::Array(L2SiegeClan)?
    @attackers.values
  end

  def attackers_in_zone : Array(L2PcInstance)
    # attackers = [] of L2PcInstance
    # @hall.siege_zone.players_inside.each do |pc|
    #   clan = pc.clan
    #   if clan && @attackers.has_key?(clan.id)
    #     attackers << pc
    #   end
    # end
    # attackers

    @hall.siege_zone.players_inside.select do |pc|
      clan = pc.clan
      clan && @attackers.has_key?(clan.id)
    end
  end

  def get_defender_clan(clan_id : Int32) : L2SiegeClan?
    # return nil
  end

  def get_defender_clan(clan : L2Clan?) : L2SiegeClan?
    # return nil
  end

  def defender_clans : Interfaces::Array(L2SiegeClan)?
    # return nil
  end

  def prepare_owner
    if @hall.owner_id > 0
      clan = L2SiegeClan.new(@hall.owner_id, SiegeClanType::ATTACKER)
      @attackers[clan.clan_id] = clan
    end

    @hall.free
    @hall.banish_foreigners
    sm = SystemMessage.registration_term_for_s1_ended
    sm.add_string(name)
    Broadcast.to_all_online_players(sm)
    @hall.update_siege_status(SiegeStatus::WAITING_BATTLE)

    @siege_task = ThreadPoolManager.schedule_general(->siege_starts_task, 3600000)
  end

  def start_siege
    if @attackers.empty? && @hall.id != 21 # Fortress of Resistance has no attackers
      on_siege_ends
      @attackers.clear
      @hall.update_next_siege
      @siege_task = ThreadPoolManager.schedule_general(->prepare_owner_task, @hall.siege_date.ms)
      @hall.update_siege_status(SiegeStatus::WAITING_BATTLE)
      sm = SystemMessage.siege_of_s1_has_been_canceled_due_to_lack_of_interest
      sm.add_string(@hall.name)
      Broadcast.to_all_online_players(sm)
      return
    end

    @hall.spawn_door
    load_guards
    spawn_siege_guards
    @hall.update_siege_zone(true)

    state = 1i8
    @attackers.each_value do |s_clan|
      unless clan = ClanTable.get_clan(s_clan.clan_id)
        next
      end

      clan.each_online_player do |pc|
        pc.siege_state = state
        pc.broadcast_user_info
        pc.in_hideout_siege = true
      end
    end

    @hall.update_siege_status(SiegeStatus::RUNNING)
    on_siege_starts
    @siege_task = ThreadPoolManager.schedule_general(->siege_ends_task, @hall.siege_length)
  end

  def end_siege
    sm = SystemMessage.siege_of_s1_has_ended
    sm.add_string(@hall.name)
    Broadcast.to_all_online_players(sm)

    winner = winner() # L2Clan
    if @mission_accomplished && winner
      @hall.owner = winner
      winner.hideout_id = @hall.id
      sm = SystemMessage.clan_s1_victorious_over_s2_s_siege
      sm.add_string(winner.name)
      sm.add_string(@hall.name)
      Broadcast.to_all_online_players(sm)
    else
      sm = SystemMessage.siege_s1_draw
      sm.add_string(@hall.name)
      Broadcast.to_all_online_players(sm)
    end

    @mission_accomplished = false

    @hall.update_siege_zone(false)
    @hall.update_next_siege
    @hall.spawn_door(false)
    @hall.banish_foreigners

    state = 0i8
    @attackers.each_value do |s_clan|
      unless clan = ClanTable.get_clan(s_clan.clan_id)
        next
      end

      clan.each_online_player do |pc|
        pc.siege_state = state
        pc.broadcast_user_info
        pc.in_hideout_siege = false
      end
    end

    @hall.siege_zone.players_inside.each &.start_pvp_flag

    @attackers.clear

    on_siege_ends

    delay = @hall.next_siege_time - Time.ms - 3_600_000
    @siege_task = ThreadPoolManager.schedule_general(->prepare_owner_task, delay)

    info { "Siege of #{@hall.name} scheduled for #{@hall.siege_date.time}." }

    @hall.update_siege_status(SiegeStatus::REGISTERING)
    unspawn_siege_guards
  end

  def update_siege
    cancel_siege_task
    delay = @hall.next_siege_time - 3_600_000
    @siege_task = ThreadPoolManager.schedule_general(->prepare_owner_task, delay)
    info { "Siege of #{@hall.name} scheduled for #{@hall.siege_date.time}." }
  end

  def cancel_siege_task
    @siege_task.try &.cancel
  end

  def siege_date : Calendar
    @hall.siege_date
  end

  def give_fame? : Bool
    Config.chs_enable_fame
  end

  def fame_amount : Int32
    Config.chs_fame_amount
  end

  def fame_frequency : Int32
    Config.chs_fame_frequency
  end

  def broadcast_npc_say(npc : L2Npc, type : Int32, npc_str : NpcString)
    say = NpcSay.new(npc.l2id, type, npc.id, npc_str)
    source_region = MapRegionManager.get_map_region_loc_id(npc)
    L2World.players.each do |pc|
      if MapRegionManager.get_map_region_loc_id(pc) == source_region
        pc.send_packet(say)
      end
    end
  end

  def get_inner_spawn_loc(pc : L2PcInstance)
    # return nil
  end

  def can_plant_flag?
    true
  end

  def door_is_auto_attackable?
    true
  end

  def on_siege_starts
    # no-op
  end

  def on_siege_ends
    # no-op
  end

  abstract def winner : L2Clan?

  def prepare_owner_task
    prepare_owner
  end

  def siege_starts_task
    start_siege
  end

  def siege_ends_task
    end_siege
  end
end
