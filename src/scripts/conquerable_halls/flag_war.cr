require "../../models/entity/clan_hall/clan_hall_siege_engine"

abstract class FlagWar < ClanHallSiegeEngine
  private SQL_LOAD_ATTACKERS = "SELECT * FROM siegable_hall_flagwar_attackers WHERE hall_id = ?"
  private SQL_SAVE_ATTACKER = "INSERT INTO siegable_hall_flagwar_attackers_members VALUES (?,?,?)"
  private SQL_LOAD_MEMEBERS = "SELECT object_id FROM siegable_hall_flagwar_attackers_members WHERE clan_id = ?"
  private SQL_SAVE_CLAN = "INSERT INTO siegable_hall_flagwar_attackers VALUES(?,?,?,?)"
  private SQL_SAVE_NPC = "UPDATE siegable_hall_flagwar_attackers SET npc = ? WHERE clan_id = ?"
  private SQL_CLEAR_CLAN = "DELETE FROM siegable_hall_flagwar_attackers WHERE hall_id = ?"
  private SQL_CLEAR_CLAN_ATTACKERS = "DELETE FROM siegable_hall_flagwar_attackers_members WHERE hall_id = ?"

  @royal_flag = 0
  @flag_red = 0
  @flag_yellow = 0
  @flag_green = 0
  @flag_blue = 0
  @flag_purple = 0

  @ally_1 = 0
  @ally_2 = 0
  @ally_3 = 0
  @ally_4 = 0
  @ally_5 = 0

  @teleport_1 = 0

  @messenger = 0

  @outter_doors_to_open = Slice(Int32).new(2, 0)
  @inner_doors_to_open = Slice(Int32).new(2, 0)
  @flag_coords = [] of Location

  @tele_zones = {} of Int32 => L2ResidenceHallTeleportZone

  @quest_reward = 0

  @center : Location?

  @data = {} of Int32 => ClanData
  @first_phase = false

  getter winner : L2Clan?

  def initialize(name, hall_id)
    super(name, "conquerablehalls/flagwar", hall_id)

    add_start_npc(@messenger)
    add_first_talk_id(@messenger)
    add_talk_id(@messenger)

    6.times do |i|
      add_first_talk_id(@teleport_1 + i)
    end

    add_kill_id(@ally_1)
    add_kill_id(@ally_2)
    add_kill_id(@ally_3)
    add_kill_id(@ally_4)
    add_kill_id(@ally_5)

    add_spawn_id(@ally_1)
    add_spawn_id(@ally_2)
    add_spawn_id(@ally_3)
    add_spawn_id(@ally_4)
    add_spawn_id(@ally_5)

    # If siege ends w/ more than 1 flag alive, winner is old owner
    @winner = ClanTable.get_clan(@hall.owner_id)
  end

  def on_first_talk(npc, pc)
    if npc.id == @messenger
      if !attacker?(pc.clan)
        clan = ClanTable.get_clan(@hall.owner_id)
        content = get_htm(pc, "messenger_initial.htm")
        content = content.gsub("%clanName%", clan ? clan.name : "no owner")
        content = content.gsub("%objectId%", npc.l2id.to_s)
        html = content
      else
        html = "messenger_initial.htm"
      end
    else
      index = npc.id - @teleport_1
      if index == 0 && @first_phase
        html = "teleporter_notyet.htm"
      else
        @tele_zones[index].check_teleport_task
        html = "teleporter.htm"
      end
    end

    html
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!
    pc = pc.not_nil!
    html = event

    sync do
      clan = pc.clan

      if event.starts_with?("register_clan") # Register the clan for the siege
        if !@hall.registering?
          if @hall.in_siege?
            html = "messenger_registrationpassed.htm"
          else
            send_registration_page_date(pc)
            return
          end
        elsif clan.nil? || !pc.clan_leader?
          html = "messenger_notclannotleader.htm"
        elsif attackers.size >= 5
          html = "messenger_attackersqueuefull.htm"
        elsif attacker?(clan)
          html = "messenger_clanalreadyregistered.htm"
        elsif @hall.owner_id == clan.id
          html = "messenger_curownermessage.htm"
        else
          arg = event.split
          if arg.size >= 2
            # Register passing the quest
            if arg[1] == "wQuest"
              if pc.destroy_item_by_item_id(@hall.name + " Siege", @quest_reward, 1, npc, false) # Quest passed
                register_clan(clan)
                html = get_flag_html(@data[clan.id].flag)
              else
                html = "messenger_noquest.htm"
              end
            # Register paying the fee
            elsif arg[1] == "wFee" && can_pay_registration?
              if pc.reduce_adena(name + " Siege", 200000, npc, false) # Fee payed
                register_clan(clan)
                html = get_flag_html(@data[clan.id].flag)
              else
                html = "messenger_nomoney.htm"
              end
            end
          end
        end
      # Select the flag to defend
      elsif event.starts_with?("select_clan_npc")
        if !pc.clan_leader?
          html = "messenger_onlyleaderselectally.htm"
        elsif !@data.has_key?(clan.not_nil!.id)
          html = "messenger_clannotregistered.htm"
        else
          clan = clan.not_nil!
          var = event.split
          if var.size >= 2
            id = 0
            begin
              id = var[1].to_i
            rescue e
              warn { "select_clan_npc->Wrong mahum warrior id #{var[1]}." }
            end
            if id > 0 && (html = get_ally_html(id))
              @data[clan.id].npc = id
              save_npc(id, clan.id)
            end
          else
            warn { "Not enough parameters to save clan npc for clan #{clan.name}." }
          end
        end
      # View (and change ? ) the current selected mahum warrior
      elsif event.starts_with?("view_clan_npc")
        if clan.nil?
          html = "messenger_clannotregistered.htm"
        elsif (cd = @data[clan.id]?).nil?
          html = "messenger_notclannotleader.htm"
        elsif cd.npc == 0
          html = "messenger_leaderdidnotchooseyet.htm"
        else
          html = get_ally_html(cd.npc)
        end
      # Register a clan member for the fight
      elsif event == "register_member"
        if clan.nil?
          html = "messenger_clannotregistered.htm"
        elsif !@hall.registering?
          html = "messenger_registrationpassed.htm"
        elsif !@data.has_key?(clan.id)
          html = "messenger_notclannotleader.htm"
        elsif @data[clan.id].players.size >= 18
          html = "messenger_clanqueuefull.htm"
        else
          data = @data[clan.id]
          data.players << pc.l2id
          save_member(clan.id, pc.l2id)
          if data.npc == 0
            html = "messenger_leaderdidnotchooseyet.htm"
          else
            html = "messenger_clanregistered.htm"
          end
        end
      # Show cur attacker list
      elsif event == "view_attacker_list"
        if @hall.registering?
          send_registration_page_date(pc)
        else
          html = get_htm(pc, "messenger_registeredclans.htm")
          i = 0
          @data.each do |key, value|
            unless attacker = ClanTable.get_clan(key)
              next
            end
            html = html.gsub("%clan#{i}%", clan.not_nil!.name)
            html = html.gsub("%clanMem#{i}%", value.players.size.to_s)
            i &+= 1
          end
          if @data.size < 5
            @data.size.upto(4) do |c|
              html = html.gsub("%clan#{c}%", "Empty pos. ")
              html = html.gsub("%clanMem#{c}%", "Empty pos. ")
            end
          end
        end
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    sync do
      if @hall.in_siege?
        npc_id = npc.id
        @data.each_key do |key|
          if @data[key].npc == npc_id
            remove_participant(key, true)
          end
        end

        sync do
          # TODO: Zoey76: previous bad implementation.
          # Converting map.keys to List and map.values to List doesn't ensure that
          # first element in the key's List correspond to the first element in the values' List
          # That's the reason that values aren't copied to a List, instead using @data.get(clan_ids[0])
          clan_ids = @data.keys
          if @first_phase
            # Siege ends if just 1 flag is alive
            # Hall was free before battle or owner didn't set the ally npc
            if (clan_ids.size == 1 && @hall.owner_id <= 0) || @data[clan_ids[0]].npc == 0
              @mission_accomplished = true
              # @winner = ClanTable.get_clan(@data.keys[0])
              # remove_participant(@data.keys[0], false)
              cancel_siege_task
              end_siege
            elsif @data.size == 2 && @hall.owner_id > 0 # Hall has defender (owner)
              cancel_siege_task # No time limit now
              @first_phase = false
              @hall.siege_zone.active = false
              @inner_doors_to_open.each do |door_id|
                @hall.open_close_door(door_id, true)
              end

              @data.each_value do |data|
                do_unspawns(data)
              end

              ThreadPoolManager.schedule_general(-> {
                @inner_doors_to_open.each do |door_id|
                  @hall.open_close_door(door_id, false)
                end

                @data.each do |key, value|
                  do_spawns(key, value)
                end

                @hall.siege_zone.active = true
              }, 300_000)
            end
          else
            @mission_accomplished = true
            @winner = ClanTable.get_clan(clan_ids[0])
            remove_participant(clan_ids[0], false)
            end_siege
          end
        end
      end
    end

    nil
  end

  def on_spawn(npc)
    npc.set_intention(AI::MOVE_TO, @center)
    nil
  end

  def prepare_owner
    if @hall.owner_id > 0
      register_clan(ClanTable.get_clan(@hall.owner_id).not_nil!)
    end

    @hall.banish_foreigners
    sm = SystemMessage.registration_term_for_s1_ended
    sm.add_string(name)
    Broadcast.to_all_online_players(sm)
    @hall.update_siege_status(SiegeStatus::WAITING_BATTLE)

    @siege_task = ThreadPoolManager.schedule_general(->siege_starts_task, 3600000)
  end

  def start_siege
    if attackers.size < 2
      on_siege_ends
      attackers.clear
      @hall.update_next_siege
      sm = SystemMessage.siege_of_s1_has_been_canceled_due_to_lack_of_interest
      sm.add_string(@hall.name)
      Broadcast.to_all_online_players(sm)
      return
    end

    # Open doors for challengers
    @outter_doors_to_open.each do |door|
      @hall.open_close_door(door, true)
    end

    # Teleport owner inside
    if @hall.owner_id > 0
      owner = ClanTable.get_clan(@hall.owner_id).not_nil!
      loc = @hall.zone.spawns[0] # Owner restart point
      owner.members.each do |pc|
        player = pc.player_instance
        if player && player.online?
          player.tele_to_location(loc, false)
        end
      end
    end

    # Schedule open doors closement, banish non siege participants and<br>
    # siege start in 2 minutes
    ThreadPoolManager.schedule_general(-> {
      @outter_doors_to_open.each do |door|
        @hall.open_close_door(door, false)
      end

      @hall.zone.banish_non_siege_participants

      start_siege
    }, 300000)
  end

  def on_siege_starts
    @data.each do |key, value|
      # Spawns challengers flags and npcs
      begin
        data = value
        do_spawns(key, data)
        fill_player_list(data)
      rescue e
        end_siege
        warn "Problems in siege initialization."
      end
    end
  end

  def end_siege
    if @hall.owner_id > 0
      clan = ClanTable.get_clan(@hall.owner_id).not_nil!
      clan.hideout_id = 0
      @hall.free
    end

    super
  end

  def on_siege_ends
    unless @data.empty?
      @data.each_key do |clan_id|
        if @hall.owner_id == clan_id
          remove_participant(clan_id, false)
        else
          remove_participant(clan_id, true)
        end
      end
    end

    clear_tables
  end

  def get_inner_spawn_loc(player)
    if player.clan_id == @hall.owner_id
      loc = @hall.zone.spawns[0]
    else
      if cd = @data[player.clan_id]?
        index = cd.flag - @flag_red
        if index.between?(0, 4)
          loc = @hall.zone.challenger_spawns[index]
        else
          raise IndexError.new
        end
      end
    end

    loc
  end

  def can_plant_flag?
    false
  end

  def door_is_auto_attackable?
    false
  end

  def do_spawns(clan_id, data)
    index = 0
    if @first_phase
      index = data.flag - @flag_red
    else
      index = clan_id == @hall.owner_id ? 5 : 6
    end

    loc = @flag_coords[index]

    data.flag_instance = L2Spawn.new(data.flag)
    data.flag_instance.not_nil!.location = loc
    data.flag_instance.not_nil!.respawn_delay = 10_000
    data.flag_instance.not_nil!.amount = 1
    data.flag_instance.not_nil!.init

    data.warrior = L2Spawn.new(data.npc)
    data.warrior.not_nil!.location = loc
    data.warrior.not_nil!.respawn_delay = 10_000
    data.warrior.not_nil!.amount = 1
    data.warrior.not_nil!.init
    data.warrior.not_nil!.last_spawn.not_nil!.ai.as(L2SpecialSiegeGuardAI).ally.concat(data.players)
  rescue e
    warn "Could not make clan spawns."
  end

  private def fill_player_list(data)
    data.players.each do |l2id|
      if plr = L2World.get_player(l2id)
        data.players_instance << plr
      end
    end
  end

  private def register_clan(clan)
    clan_id = clan.id

    sc = L2SiegeClan.new(clan_id, SiegeClanType::ATTACKER)
    attackers[clan_id] = sc

    data = ClanData.new
    data.flag = @royal_flag + @data.size
    data.players << clan.leader_id
    @data[clan_id] = data

    save_clan(clan_id, data.flag)
    save_member(clan_id, clan.leader_id)
  end

  private def do_unspawns(data)
    if flag = data.flag_instance
      flag.stop_respawn
      flag.last_spawn.try &.delete_me
    end

    if warrior = data.warrior
      warrior.stop_respawn
      warrior.last_spawn.try &.delete_me
    end
  end

  private def remove_participant(clan_id, teleport)
    if dat = @data.delete(clan_id)
      # Destroy clan flag
      if flag = dat.flag_instance
        flag.stop_respawn
        flag.last_spawn.try &.delete_me
      end

      if warrior = dat.warrior
        # Destroy clan warrior
        warrior.stop_respawn
        warrior.last_spawn.try &.delete_me
      end

      dat.players.clear

      if teleport
        # Teleport players outside
        dat.players_instance.each do |pc|
          pc.tele_to_location(TeleportWhereType::TOWN)
        end
      end

      dat.players_instance.clear
    end
  end

  def can_pay_registration?
    true
  end

  private def send_registration_page_date(pc)
    msg = NpcHtmlMessage.new
    msg.html = get_htm(pc, "siege_date.htm")
    msg["%nextSiege%"] = @hall.siege_date.time
    pc.send_packet(msg)
  end

  abstract def get_flag_html(flag : Int32) : String?
  abstract def get_ally_html(ally : Int32) : String?

  def load_attackers
    GameDB.each(SQL_LOAD_ATTACKERS, @hall.id) do |rs|
      clan_id = rs.get_i32(:"clan_id")

      unless ClanTable.get_clan(clan_id)
        warn { "Loaded an unexistent clan as attacker (clan id #{clan_id})." }
        next
      end

      data = ClanData.new
      data.flag = rs.get_i32(:"flag")
      data.npc = rs.get_i32(:"npc")

      @data[clan_id] = data
      load_attacker_members(clan_id)
    end
  rescue e
    error "Could not load attackers."
    error e
  end

  private def load_attacker_members(clan_id)
    unless list_instance = @data[clan_id].players
      warn { "Tried to load unregistered clan with id #{clan_id}." }
      return
    end

    begin
      GameDB.each(SQL_LOAD_MEMEBERS, clan_id) do |rs|
        list_instance << rs.get_i32(:"object_id")
      end
    rescue e
      error e
    end
  end

  private def save_clan(clan_id, flag)
    GameDB.exec(SQL_SAVE_CLAN, @hall.id, flag, 0, clan_id)
  rescue e
    error e
  end

  private def save_npc(npc, clan_id)
    GameDB.exec(SQL_SAVE_NPC, npc, clan_id)
  rescue e
    error e
  end

  private def save_member(clan_id, l2id)
    GameDB.exec(SQL_SAVE_ATTACKER, @hall.id, clan_id, l2id)
  rescue e
    error e
  end

  private def clear_tables
    GameDB.transaction do |tr|
      tr.exec(SQL_CLEAR_CLAN, @hall.id)
      tr.exec(SQL_CLEAR_CLAN_ATTACKERS, @hall.id)
    end
  rescue e
    error e
  end

  private class ClanData
    getter players_instance = Array(L2PcInstance).new(18)
    getter players = Array(Int32).new(18)
    property flag = 0
    property npc = 0
    property warrior : L2Spawn?
    property flag_instance : L2Spawn?
  end
end
