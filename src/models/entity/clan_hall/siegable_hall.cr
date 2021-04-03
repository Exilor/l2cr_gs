require "../clan_hall"
require "../siege_clan_type"
require "./clan_hall_siege_engine"
require "./siege_status"

class SiegableHall < ClanHall
  private SQL_SAVE = "UPDATE siegable_clanhall SET ownerId=?, nextSiege=? WHERE clanHallId=?"
  private SCHEDULE_CONFIG = Int32.slice(7, 0, 0, 12, 0)

  @status = SiegeStatus::REGISTERING
  @next_siege = Calendar.new

  getter siege_length = 0i64
  getter! siege : ClanHallSiegeEngine
  property! siege_zone : L2SiegeZone

  def initialize(set : StatsSet)
    super

    @siege_length = set.get_i64("siegeLenght")
    raw = set.get_string("scheduleConfig").split(';')
    if raw.size == 5
      5.times do |i|
        str = raw[i]
        begin
          SCHEDULE_CONFIG[i] = str.to_i
        rescue e
          error e
        end
      end
    else
      warn "Wrong scheduleConfig value in table."
    end

    next_siege = set.get_i64("nextSiege")
    if next_siege - Time.ms < 0
      update_next_siege
    else
      @next_siege.ms = next_siege
    end

    if owner_id != 0
      @free = false
      load_functions
    end
  end

  def spawn_door
    spawn_door(false)
  end

  def spawn_door(weak : Bool)
    doors.each do |door|
      if door.dead?
        door.do_revive
        if weak
          door.current_hp = door.max_hp.fdiv(2)
        else
          door.max_hp!
        end
      end

      if door.open?
        door.close_me
      end
    end
  end

  def update_db
    GameDB.exec(SQL_SAVE, owner_id, next_siege_time, id)
  rescue e
    error e
  end

  def siege=(siegable : ClanHallSiegeEngine)
    @siege = siegable
    @siege_zone.not_nil!.siege_instance = siegable # nilable?
  end

  def siege_date : Calendar
    @next_siege
  end

  def next_siege_time : Int64
    @next_siege.ms
  end

  def next_siege_date=(ms : Int64)
    @next_siege.ms = ms
  end

  def next_siege_date=(next_siege : Calendar)
    @next_siege = next_siege
  end

  def update_next_siege
    c = Calendar.new
    c.add(SCHEDULE_CONFIG[0].days)
    c.add(SCHEDULE_CONFIG[1].months)
    c.add(SCHEDULE_CONFIG[2].years)
    c.hour = SCHEDULE_CONFIG[3]
    c.minute = SCHEDULE_CONFIG[4]
    c.second = 0
    self.next_siege_date = c
    update_db
  end

  def add_attacker(clan : L2Clan)
    if siege = siege?
      siege.attackers[clan.id] = L2SiegeClan.new(clan.id, SiegeClanType::ATTACKER)
    end
  end

  def remove_attacker(clan : L2Clan)
    if siege = siege?
      siege.attackers.delete(clan.id)
    end
  end

  def registered?(clan : L2Clan) : Bool
    return false unless siege = siege?
    siege.attacker?(clan)
  end

  def siege_status : SiegeStatus
    @status
  end

  def registering? : Bool
    @status.registering?
  end

  def in_siege? : Bool
    @status.running?
  end

  def waiting_battle? : Bool
    @status.waiting_battle?
  end

  def update_siege_status(status : SiegeStatus)
    @status = status
  end

  def update_siege_zone(active : Bool)
    siege_zone.active = active
  end

  def show_siege_info(pc : L2PcInstance)
    pc.send_packet(SiegeInfo.new(self))
  end

  def siegable_hall? : Bool
    true
  end

  def zone? : L2SiegableHallZone?
    super.as(L2SiegableHallZone?)
  end

  def zone : L2SiegableHallZone
    super.as(L2SiegableHallZone)
  end
end
