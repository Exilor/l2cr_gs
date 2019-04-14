require "../models/entity/clan_hall/siegable_hall"

module ClanHallSiegeManager
  extend self
  extend Loggable
  include Packets::Outgoing

  private SQL_LOAD_HALLS = "SELECT * FROM siegable_clanhall"
  private SIEGABLE_HALLS = {} of Int32 => SiegableHall

  def load
    SIEGABLE_HALLS.clear

    GameDB.each(SQL_LOAD_HALLS) do |rs|
      set = StatsSet.new
      id = rs.get_i32("clanHallId")
      set["id"] = id
      set["name"] = rs.get_string("name")
      set["ownerId"] = rs.get_i32("ownerId")
      set["desc"] = rs.get_string("desc")
      set["location"] = rs.get_string("location")
      set["nextSiege"] = rs.get_i64("nextSiege")
      set["siegeLenght"] = rs.get_i64("siegeLenght")
      set["scheduleConfig"] = rs.get_string("schedule_config")
      hall = SiegableHall.new(set)
      SIEGABLE_HALLS[id] = hall
      ClanHallManager.add_clan_hall(hall)
    end
  rescue e
    error e
  end

  def conquerable_halls
    SIEGABLE_HALLS
  end

  def get_siegable_hall(id : Int32) : SiegableHall?
    conquerable_halls[id]?
  end

  def get_siegable_hall!(id : Int32) : SiegableHall
    unless hall = get_siegable_hall(id)
      raise "No siegable hall with id #{id} found"
    end

    hall
  end

  def get_nearby_clan_hall(char : L2Character) : SiegableHall?
    get_nearby_clan_hall(char.x, char.y, 10000)
  end

  def get_nearby_clan_hall(x : Int32, y : Int32, max_dist : Int32) : SiegableHall?
    SIEGABLE_HALLS.find_value do |ch|
      ch.zone.get_distance_to_zone(x, y) < max_dist
    end
  end

  def get_nearby_clan_hall!(*args) : SiegableHall
    unless hall = get_nearby_clan_hall(*args)
      raise "No clan hall found with args #{args}"
    end

    hall
  end

  def get_siege(char : L2Character) : ClanHallSiegeEngine?
    if hall = get_nearby_clan_hall(char)
      hall.siege?
    end
  end

  def register_clan(clan : L2Clan, hall : SiegableHall, pc : L2PcInstance)
    if clan.level < Config.chs_clan_minlevel
      pc.send_message("Only clans of level #{Config.chs_clan_minlevel} or higher may register for a castle siege")
    elsif hall.waiting_battle?
      sm = SystemMessage.deadline_for_siege_s1_passed
      sm.add_string(hall.name)
      pc.send_packet(sm)
    elsif hall.in_siege?
      pc.send_packet(SystemMessageId::NOT_SIEGE_REGISTRATION_TIME2)
    elsif hall.owner_id == clan.id
      pc.send_packet(SystemMessageId::CLAN_THAT_OWNS_CASTLE_IS_AUTOMATICALLY_REGISTERED_DEFENDING)
    elsif clan.castle_id != 0 || clan.hideout_id != 0
      pc.send_packet(SystemMessageId::CLAN_THAT_OWNS_CASTLE_CANNOT_PARTICIPATE_OTHER_SIEGE)
    elsif hall.siege.attacker?(clan)
      pc.send_packet(SystemMessageId::ALREADY_REQUESTED_SIEGE_BATTLE)
    elsif clan_participating?(clan)
      pc.send_packet(SystemMessageId::APPLICATION_DENIED_BECAUSE_ALREADY_SUBMITTED_A_REQUEST_FOR_ANOTHER_SIEGE_BATTLE)
    elsif hall.siege.attackers.size >= Config.chs_max_attackers
      pc.send_packet(SystemMessageId::ATTACKER_SIDE_FULL)
    else
      hall.add_attacker(clan)
    end
  end

  def unregister_clan(clan : L2Clan, hall : SiegableHall)
    if hall.registering?
      hall.remove_attacker(clan)
    end
  end

  def clan_participating?(clan : L2Clan) : Bool
    conquerable_halls.local_each_value.any? do |hall|
      hall.siege? && hall.siege.attacker?(clan)
    end
  end

  def on_server_shutdown
    conquerable_halls.each_value do |hall|
      if hall.id == 62 || hall.siege?.nil?
        next
      end

      hall.siege.save_attackers
    end
  end
end
