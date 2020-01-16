require "../known_list/race_manager_known_list"

class L2RaceManagerInstance < L2Npc
  private LANES = 8
  private WINDOW_START = 0
  private SECOND = 1000
  private MINUTE = SECOND * 60
  private ACCEPTING_BETS = 0
  private WAITING = 1
  private STARTING_RACE = 2
  private RACE_END = 3
  private CODES = {
    {-1, 0},
    {0, 15322},
    {13765, -1}
  }
  private COST = {100, 500, 1000, 5000, 10000, 20000, 50000, 100000}

  @@not_initialized = true
  @@state = RACE_END
  @@minutes = 5
  @@managers = [] of self

  protected class_property race_number : Int32 = 4
  protected class_property packet : MonRaceInfo?

  def initialize(template : L2NpcTemplate)
    super

    if @@not_initialized
      @@not_initialized = false

      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_TICKETS_AVAILABLE_FOR_S1_RACE), 0, 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_TICKETS_NOW_AVAILABLE_FOR_S1_RACE), 30 * SECOND, 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_TICKETS_AVAILABLE_FOR_S1_RACE), MINUTE, 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_TICKETS_NOW_AVAILABLE_FOR_S1_RACE), MINUTE + (30 * SECOND), 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_TICKETS_STOP_IN_S1_MINUTES), 2 * MINUTE, 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_TICKETS_STOP_IN_S1_MINUTES), 3 * MINUTE, 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_TICKETS_STOP_IN_S1_MINUTES), 4 * MINUTE, 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_TICKETS_STOP_IN_S1_MINUTES), 5 * MINUTE, 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_TICKETS_STOP_IN_S1_MINUTES), 6 * MINUTE, 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_S1_TICKET_SALES_CLOSED), 7 * MINUTE, 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_S2_BEGINS_IN_S1_MINUTES), 7 * MINUTE, 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_S2_BEGINS_IN_S1_MINUTES), 8 * MINUTE, 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_S1_BEGINS_IN_30_SECONDS), (8 * MINUTE) + (30 * SECOND), 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_S1_COUNTDOWN_IN_FIVE_SECONDS), (8 * MINUTE) + (50 * SECOND), 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_BEGINS_IN_S1_SECONDS), (8 * MINUTE) + (55 * SECOND), 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_BEGINS_IN_S1_SECONDS), (8 * MINUTE) + (56 * SECOND), 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_BEGINS_IN_S1_SECONDS), (8 * MINUTE) + (57 * SECOND), 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_BEGINS_IN_S1_SECONDS), (8 * MINUTE) + (58 * SECOND), 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_BEGINS_IN_S1_SECONDS), (8 * MINUTE) + (59 * SECOND), 10 * MINUTE)
      ThreadPoolManager.schedule_general_at_fixed_rate(Announcement.new(self, SystemMessageId::MONSRACE_RACE_START), 9 * MINUTE, 10 * MINUTE)
    end

    @@managers << self
  end

  def instance_type : InstanceType
    InstanceType::L2RaceManagerInstance
  end

  private def init_known_list
    @known_list = RaceManagerKnownList.new(self)
  end

  def known_list : RaceManagerKnownList
    super.as(RaceManagerKnownList)
  end

  def make_announcement(type : SystemMessageId)
    sm = SystemMessage[type]

    case sm.id
    when 816, # MONSRACE_TICKETS_AVAILABLE_FOR_S1_RACE
         817  # MONSRACE_TICKETS_NOW_AVAILABLE_FOR_S1_RACE
      if @@state != ACCEPTING_BETS
        @@state = ACCEPTING_BETS
        start_race
      end
      sm.add_int(@@race_number)
    when 818, # MONSRACE_TICKETS_STOP_IN_S1_MINUTES
         820, # MONSRACE_S2_BEGINS_IN_S1_MINUTES
         823  # MONSRACE_BEGINS_IN_S1_SECONDS
      sm.add_int(@@minutes)
      if sm.id == 820
        sm.add_int(@@race_number)
      end
      @@minutes -= 1
    when 819 # MONSRACE_S1_TICKET_SALES_CLOSED
      sm.add_int(@@race_number)
      @@state = WAITING
      @@minutes = 2
    when 821, # MONSRACE_S1_BEGINS_IN_30_SECONDS
         822, # MONSRACE_S1_COUNTDOWN_IN_FIVE_SECONDS
         825  # MONSRACE_S1_RACE_END
      sm.add_int(@@race_number)
      @@minutes = 5
    when 826 # MONSRACE_FIRST_PLACE_S1_SECOND_S2
      @@state = RACE_END
      sm.add_int(MonsterRace.first_place)
      sm.add_int(MonsterRace.second_place)
    end

    broadcast(sm)

    if sm.system_message_id == SystemMessageId::MONSRACE_RACE_START
      @@state = STARTING_RACE
      start_race
      @@minutes = 5
    end
  end

  def broadcast(gsp : GameServerPacket)
    @@managers.each do |manager|
      if manager.alive?
        Broadcast.to_known_players(manager, gsp)
      end
    end
  end

  def send_monster_info
    broadcast(@@packet.not_nil!)
  end

  def start_race
    if @@state == STARTING_RACE
      broadcast(Music::S_RACE.packet)
      broadcast(Sound::ITEMSOUND2_RACE_START.packet)
      @@packet = MonRaceInfo.new(CODES[1][0], CODES[1][1], MonsterRace.monsters, MonsterRace.speeds)
      send_monster_info
      ThreadPoolManager.schedule_general(RunRace.new(self), 5000)
    else
      MonsterRace.new_race
      MonsterRace.new_speeds
      @@packet = MonRaceInfo.new(CODES[0][0], CODES[0][1], MonsterRace.monsters, MonsterRace.speeds)
      send_monster_info
    end
  end

  def on_bypass_feedback(pc : L2PcInstance, cmd : String)
    if cmd.starts_with?("BuyTicket") && @@state != ACCEPTING_BETS
      pc.send_packet(SystemMessageId::MONSRACE_TICKETS_NOT_AVAILABLE)
      cmd = "Chat 0"
    end

    if cmd.starts_with?("ShowOdds") && @@state == ACCEPTING_BETS
      pc.send_packet(SystemMessageId::MONSRACE_NO_PAYOUT_INFO)
      cmd = "Chat 0"
    end

    if cmd.starts_with?("BuyTicket")
      val = cmd.from(10).to_i
      if val == 0
        pc.set_race(0, 0)
        pc.set_race(1, 0)
      end

      if (val == 10 && pc.get_race(0) == 0) || (val == 20 && pc.get_race(0) == 0 && pc.get_race(1) == 0)
        val = 0
      end

      show_buy_ticket(pc, val)
    elsif cmd == "ShowOdds"
      show_odds(pc)
    elsif cmd == "ShowInfo"
      show_monster_info(pc)
    elsif cmd == "calculateWin"
      # commented out in L2J
    elsif cmd == "viewHistory"
      # commented out in L2J
    else
      super
    end
  end

  def show_odds(pc : L2PcInstance)
    if @@state == ACCEPTING_BETS
      return
    end

    npc_id = template.id

    html = NpcHtmlMessage.new(l2id)
    filename = get_html_path(npc_id, 5)
    html.set_file(pc, filename)
    8.times do |i|
      search = "Mob#{i + 1}"
      html[search] = MonsterRace.monsters[i].template.name
    end
    html["1race"] = @@race_number
    html["%objectId%"] = l2id
    pc.send_packet(html)
    pc.action_failed
  end

  def show_monster_info(pc : L2PcInstance)
    npc_id = template.id

    html = NpcHtmlMessage.new(l2id)
    filename = get_html_path(npc_id, 5)
    html.set_file(pc, filename)
    8.times do |i|
      search = "Mob#{i + 1}"
      html[search] = MonsterRace.monsters[i].template.name
    end
    html["%objectId%"] = l2id
    pc.send_packet(html)
    pc.action_failed
  end

  def show_buy_ticket(pc : L2PcInstance, val : Int32)
    unless @@state == ACCEPTING_BETS
      debug "#show_buy_ticket: not accepting bets."
      return
    end
    debug "#show_buy_ticket (val: #{val}."

    npc_id = template.id
    html = NpcHtmlMessage.new(l2id)

    if val < 10
      filename = get_html_path(npc_id, 2)
      html.set_file(pc, filename)
      8.times do |i|
        html["Mob#{i + 1}"] = MonsterRace.monsters[i].template.name
      end
      if val == 0
        html["No1"] = ""
      else
        html["No1"] = val
        pc.set_race(0, val)
      end
    elsif val < 20
      if pc.get_race(0) == 0
        return
      end

      filename = get_html_path(npc_id, 3)
      html.set_file(pc, filename)
      html["0place"] = pc.get_race(0)
      html["Mob1"] = MonsterRace.monsters[pc.get_race(0) - 1].template.name
      if val == 10
        html["0adena"] = ""
      else
        html["0adena"] = COST[val - 11]
        pc.set_race(1, val - 10)
      end
    elsif val == 20
      if pc.get_race(0) == 0 || pc.get_race(1) == 0
        return
      end

      filename = get_html_path(npc_id, 4)
      html.set_file(pc, filename)
      html["0place"] = pc.get_race(0)
      html["Mob1"] = MonsterRace.monsters[pc.get_race(0) - 1].template.name
      html["0adena"] = COST[pc.get_race(1) - 1]
      html["0tax"] = 0
      html["0total"] = COST[pc.get_race(1) - 1]
    else
      if pc.get_race(0) == 0 || pc.get_race(1) == 0
        return
      end

      ticket = pc.get_race(0)
      price_id = pc.get_race(1)
      sm = SystemMessage.acquired_s1_s2
      sm.add_int(@@race_number)
      sm.add_item_name(4443)
      pc.send_packet(sm)

      item = L2ItemInstance.new(IdFactory.next, 4443)
      item.count = 1
      item.enchant_level = @@race_number
      item.custom_type_1 = ticket
      item.custom_type_2 = COST[price_id - 1] // 100
      pc.inventory.add_item("Race", item, pc, self)
      iu = InventoryUpdate.new
      iu.add_item(item)
      adena = pc.inventory.get_item_by_item_id(Inventory::ADENA_ID).not_nil!
      iu.add_modified_item(adena)
      pc.send_packet(iu)
      return
    end

    html["1race"] = @@race_number
    html["objectId"] = l2id
    pc.send_packet(html)
    pc.action_failed
  end

  private struct Announcement
    initializer announcer : L2RaceManagerInstance, sm_id : SystemMessageId

    def call
      @announcer.make_announcement(@sm_id)
    end
  end

  private struct Race
    initializer info : Array(Info)

    def get_lane_info(lane : Int)
      @info[lane]
    end
  end

  private record Info, id : Int32, place : Int32, odds : Int32, payout : Int32

  private struct RunRace
    initializer manager : L2RaceManagerInstance

    def call
      L2RaceManagerInstance.packet = Packets::Outgoing::MonRaceInfo.new(
        CODES[2][0], CODES[2][1], MonsterRace.monsters, MonsterRace.speeds
      )
      @manager.send_monster_info
      ThreadPoolManager.schedule_general(RunEnd.new(@manager), 30000)
    end
  end

  private struct RunEnd
    initializer manager : L2RaceManagerInstance

    def call
      @manager.make_announcement(SystemMessageId::MONSRACE_FIRST_PLACE_S1_SECOND_S2)
      @manager.make_announcement(SystemMessageId::MONSRACE_S1_RACE_END)
      L2RaceManagerInstance.race_number += 1

      8.times do |i|
        dl = Packets::Outgoing::DeleteObject.new(MonsterRace.monsters[i])
        @manager.broadcast(dl)
      end
    end
  end
end
