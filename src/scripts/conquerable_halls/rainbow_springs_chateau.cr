class Scripts::RainbowSpringsChateau < ClanHallSiegeEngine
  module TeleportBack
    def self.call
      ARENA_ZONES.each do |arena_id|
        chars = ZoneManager.get_zone_by_id(arena_id).not_nil!.characters_inside
        chars.each do |chr|
          chr.tele_to_location(TeleportWhereType::TOWN)
        end
      end
    end
  end

  private RAINBOW_SPRINGS = 62

  private WAR_DECREES = 8034
  private RAINBOW_NECTAR = 8030
  private RAINBOW_MWATER = 8031
  private RAINBOW_WATER = 8032
  private RAINBOW_SULFUR = 8033

  private MESSENGER = 35604
  private CARETAKER = 35603
  private CHEST = 35593

  private GOURDS = {
    35588,
    35589,
    35590,
    35591
  }

  private YETIS = {
    35596,
    35597,
    35598,
    35599
  }

  private ARENAS = {
    Location.new(151562, -127080, -2214), # Arena 1
    Location.new(153141, -125335, -2214), # Arena 2
    Location.new(153892, -127530, -2214), # Arena 3
    Location.new(155657, -125752, -2214)  # Arena 4
  }

  private ARENA_ZONES = {
    112081,
    112082,
    112083,
    112084
  }

  private TEXT_PASSAGES = {
    "Fight for Rainbow Springs!",
    "Are you a match for the Yetti?",
    "Did somebody order a knuckle sandwich?"
  }

  private DEBUFFS = [] of Skill

  private WAR_DECREES_COUNT = {} of Int32 => Int64
  private ACCEPTED_CLANS = [] of L2Clan
  private USED_TEXT_PASSAGES = {} of String => Array(L2Clan)
  private PENDING_ITEM_TO_GET = {} of L2Clan => Int32

  @rainbow : SiegableHall?
  @next_siege : TaskExecutor::Scheduler::DelayedTask?
  @siege_end : TaskExecutor::Scheduler::DelayedTask?
  @registration_ends : String?
  @gourds = {} of Int32 => L2Spawn

  getter winner : L2Clan?

  def initialize
    super(self.class.simple_name, "conquerablehalls", RAINBOW_SPRINGS)

    add_first_talk_id(MESSENGER)
    add_talk_id(MESSENGER)
    add_first_talk_id(CARETAKER)
    add_talk_id(CARETAKER)
    add_first_talk_id(YETIS)
    add_talk_id(YETIS)

    load_attackers


    if @rainbow = ClanHallSiegeManager.get_siegable_hall(RAINBOW_SPRINGS)
      delay = @rainbow.not_nil!.next_siege_time
      if delay > -1
        set_registration_end_string(delay - 3600000)
        @next_siege = ThreadPoolManager.schedule_general(->set_final_attackers_task, delay)
      else
        warn "No date set for RainBow Springs Chateau Clan hall siege."
      end
    end
  end

  private def set_final_attackers_task
    @rainbow ||= ClanHallSiegeManager.get_siegable_hall(RAINBOW_SPRINGS)

    spot_left = 4
    if @rainbow.not_nil!.owner_id > 0
      if owner = ClanTable.get_clan(@rainbow.not_nil!.owner_id)
        @rainbow.not_nil!.free
        owner.hideout_id = 0
        ACCEPTED_CLANS << owner
        spot_left -= 1
      end

      spot_left.times do |i|
        counter = 0i64
        clan = nil
        WAR_DECREES_COUNT.each_key do |clan_id|
          acting_clan = ClanTable.get_clan(clan_id)
          if acting_clan.nil? || acting_clan.dissolving_expiry_time > 0
            WAR_DECREES_COUNT.delete(clan_id)
            next
          end

          count = WAR_DECREES_COUNT[clan_id]
          if count > counter
            counter = count
            clan = acting_clan
          end
        end
        if clan && ACCEPTED_CLANS.size < 4
          ACCEPTED_CLANS << clan
          if leader = clan.leader.player_instance
            leader.send_message("Your clan has been accepted to join the RainBow Srpings Chateau siege!")
          end
        end
      end
      if ACCEPTED_CLANS.size >= 2
        @next_siege = ThreadPoolManager.schedule_general(->siege_starts_task, 3600000)
        @rainbow.not_nil!.update_siege_status(SiegeStatus::WAITING_BATTLE)
      else
        Broadcast.to_all_online_players("Rainbow Springs Chateau siege aborted due lack of population")
      end
    end
  end

  private def start_siege_task
    @rainbow ||= ClanHallSiegeManager.get_siegable_hall(RAINBOW_SPRINGS)

    # XXX @rainbow.not_nil!.siegeStarts

    spawn_gourds
    @siege_end = ThreadPoolManager.schedule_general(siege_end_task(nil), @rainbow.not_nil!.siege_length - 120000)
  end

  private def siege_end_task(winner)
    -> do
      @rainbow ||= ClanHallSiegeManager.get_siegable_hall(RAINBOW_SPRINGS)

      unspawn_gourds

      if w = winner
        @rainbow.not_nil!.owner = w
      end

      # XXX @rainbow.not_nil!.siegeEnds

      ThreadPoolManager.schedule_general(->set_final_attackers_task, @rainbow.not_nil!.next_siege_time)
      set_registration_end_string((@rainbow.not_nil!.next_siege_time + Time.ms) - 3600000)
      # Teleport out of the arenas is made 2 mins after game ends
      ThreadPoolManager.schedule_general(TeleportBack, 120000)
    end
  end

  def on_first_talk(npc, pc)
    html = ""
    npc_id = npc.id
    if npc_id == MESSENGER
      if @rainbow.not_nil!.owner_id > 0
        main = "messenger_yetti001.htm"
      else
        main = "messenger_yetti001a.htm"
      end
      html = HtmCache.get_htm(pc, "data/scripts/conquerablehalls/RainbowSpringsChateau/" + main).not_nil!
      html = html.sub("%time%", @registration_ends.to_s)
      if @rainbow.not_nil!.owner_id > 0
        html = html.sub("%owner%", ClanTable.get_clan(@rainbow.not_nil!.owner_id).not_nil!.name)
      end
    elsif npc_id == CARETAKER
      if @rainbow.not_nil!.in_siege?
        html = "game_manager003.htm"
      else
        html = "game_manager001.htm"
      end
    elsif YETIS.includes?(npc_id)
      # L2J TODO: Review.
      if @rainbow.not_nil!.in_siege?
        if !pc.clan_leader?
          html = "no_clan_leader.htm"
        else
          clan = pc.clan
          if index = ACCEPTED_CLANS.index(clan)
            if npc_id == YETIS[index]
              html = "yeti_main.htm"
            end
          end
        end
      end
    end
    pc.last_quest_npc_l2id = npc.l2id

    html
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!
    pc = pc.not_nil!

    html = event
    clan = pc.clan
    case npc.id
    when MESSENGER
      case event
      when "register"
        if clan.nil? || !pc.clan_leader?
          html = "messenger_yetti010.htm"
        elsif clan.castle_id > 0 || clan.fort_id > 0 || clan.hideout_id > 0
          html = "messenger_yetti012.htm"
        elsif !@rainbow.not_nil!.registering?
          html = "messenger_yetti014.htm"
        elsif WAR_DECREES_COUNT.has_key?(clan.id)
          html = "messenger_yetti013.htm"
        elsif clan.level < 3 || clan.size < 5
          html = "messenger_yetti011.htm"
        else
          war_decrees = pc.inventory.get_item_by_item_id(WAR_DECREES)
          if war_decrees.nil?
            html = "messenger_yetti008.htm"
          else
            count = war_decrees.count
            WAR_DECREES_COUNT[clan.id] = count
            pc.destroy_item("Rainbow Springs Registration", war_decrees, npc, true)
            add_attacker(clan.id, count)
            html = "messenger_yetti009.htm"
          end
        end
      when "cancel"
        if clan.nil? || !pc.clan_leader?
          html = "messenger_yetti010.htm"
        elsif !WAR_DECREES_COUNT.has_key?(clan.id)
          html = "messenger_yetti016.htm"
        elsif !@rainbow.not_nil!.registering?
          html = "messenger_yetti017.htm"
        else
          remove_attacker(clan.id)
          html = "messenger_yetti018.htm"
        end
      when "unregister"
        if @rainbow.not_nil!.registering?
          if WAR_DECREES_COUNT.has_key?(clan.not_nil!.id)
            pc.add_item("Rainbow Spring unregister", WAR_DECREES, WAR_DECREES_COUNT[clan.not_nil!.id] // 2, npc, true)
            WAR_DECREES_COUNT.delete(clan.not_nil!.id)
            html = "messenger_yetti019.htm"
          else
            html = "messenger_yetti020.htm"
          end
        elsif @rainbow.not_nil!.waiting_battle?
          ACCEPTED_CLANS.delete(clan.not_nil!)
          html = "messenger_yetti020.htm"
        end
      else
        # [automatically added else]
      end

    when CARETAKER
      if event == "portToArena"
        party = pc.party
        if clan.nil?
          html = "game_manager009.htm"
        elsif !pc.clan_leader?
          html = "game_manager004.htm"
        elsif party.nil?
          html = "game_manager005.htm"
        elsif party.leader != pc
          html = "game_manager006.htm"
        else
          clan_id = pc.clan_id
          non_clan_member_in_party = party.members.any? do |m|
            m.clan_id != clan_id
          end

          if non_clan_member_in_party
            html = "game_manager007.htm"
          elsif party.size < 5
            html = "game_manager008.htm"
          elsif clan.castle_id > 0 || clan.fort_id > 0 || clan.hideout_id > 0
            html = "game_manager010.htm"
          elsif clan.level < Config.chs_clan_minlevel
            html = "game_manager011.htm"
          # elsif  # Something about the rules.
          # {
          # html = "game_manager012.htm"
          # }
          # elsif  # Already registered.
          # {
          # html = "game_manager013.htm"
          # }
          elsif !ACCEPTED_CLANS.includes?(clan)
            html = "game_manager014.htm"
          # elsif  # Not have enough cards to register.
          # {
          # html = "game_manager015.htm"
          # }
          else
            port_to_arena(pc, ACCEPTED_CLANS.index(clan))
          end
        end
      end
    else
      # [automatically added else]
    end


    if event.starts_with?("enterText")
      clan = clan.not_nil!
      # Shouldn't happen
      unless ACCEPTED_CLANS.includes?(clan)
        return
      end

      split = event.split("_ ")
      if split.size < 2
        return
      end

      passage = split[1]

      unless valid_passage?(passage)
        return
      end

      if list = USED_TEXT_PASSAGES[passage]?
        if list.includes?(clan)
          html = "yeti_passage_used.htm"
        else
          list << clan
          # PENDING_ITEM_TO_GET.sync do
            if left = PENDING_ITEM_TO_GET[clan]?
              PENDING_ITEM_TO_GET[clan] = left + 1
            else
              PENDING_ITEM_TO_GET[clan] = 1
            end
          # end
          html = "yeti_item_exchange.htm"
        end
      end
    end
    # TODO(Zoey76): Rewrite this to prevent exploits...
    # elsif event.starts_with?("getItem"))
    # {
    # if !PENDING_ITEM_TO_GET.has_key?(clan))
    # {
    # html = "yeti_cannot_exchange.htm"
    # }
    #
    # int left = PENDING_ITEM_TO_GET.get(clan)
    # if left > 0)
    # {
    # int itemId = Integer(event.split("_")[1])
    # pc.addItem("Rainbow Spring Chateau Siege", itemId, 1, npc, true)
    # --left
    # PENDING_ITEM_TO_GET.put(clan, left)
    # html = "yeti_main.htm"
    # }
    # else
    # {
    # html = "yeti_cannot_exchange.htm"
    # }
    # }

    html
  end

  def on_kill(npc, killer, is_summon)
    unless @rainbow.not_nil!.in_siege?
      return
    end

    unless clan = killer.clan
      return
    end
    unless index = ACCEPTED_CLANS.index(clan)
      return
    end

    npc_id = npc.id


    if npc_id == CHEST
      shout_random_text(npc)
    elsif npc_id == GOURDS[index]
      sync do
        @siege_end.try &.cancel
        ThreadPoolManager.execute_general(siege_end_task(clan))
      end
    end

    nil
  end

  def on_item_use(item, player)
    unless @rainbow.not_nil!.in_siege?
      return
    end

    target = player.target

    unless target.is_a?(L2Npc)
      return
    end

    yeti = target.id
    unless yeti_target?(yeti)
      return
    end

    clan = player.clan
    if clan.nil? || !ACCEPTED_CLANS.include?(clan)
      return
    end

    # Nectar must spawn the enraged yeti. Dunno if it makes any other thing
    # Also, the items must execute
    # - Reduce gourd hpb ( reduce_gourd_hp(int, L2PcInstance) )
    # - Cast debuffs on enemy clans ( cast_debuffs_on_enemies(int) )
    # - Change arena gourds ( move_gourds )
    # - Increase gourd hp ( increase_gourd_hp(int) )

    item_id = item.id
    if item_id == RAINBOW_NECTAR
      # Spawn enraged (where?)
      reduce_gourd_hp(ACCEPTED_CLANS.index(clan), player)
    elsif item_id == RAINBOW_MWATER
      increase_gourd_hp(ACCEPTED_CLANS.index(clan))
    elsif item_id == RAINBOW_WATER
      move_gourds
    elsif item_id == RAINBOW_SULFUR
      cast_debuffs_on_enemies(ACCEPTED_CLANS.index(clan))
    end

    nil
  end

  private def port_to_arena(leader, arena)
    arena = arena.not_nil!
    unless arena.between?(0, 3)
      warn { "Wrong arena id passed: #{arena}." }
      return
    end

    leader.party.not_nil!.members.each do |pc|
      pc.stop_all_effects
      if smn = pc.summon
        smn.unsummon(pc)
      end
      pc.tele_to_location(ARENAS[arena])
    end
  end

  private def spawn_gourds
    ACCEPTED_CLANS.size.times do |i|
      if @gourds[i]?.nil?
        begin
          sp = @gourds[i] = L2Spawn.new(@gourds[i])
          sp.x = ARENAS[i].x + 150
          sp.y = ARENAS[i].y + 150
          sp.z = ARENAS[i].z
          sp.heading = 1
          sp.amount = 1
        rescue e
          warn { "Unable to spawn guard for clan index #{i}" }
        end
      end
      SpawnTable.add_new_spawn(@gourds[i], false)
      @gourds[i].init
    end
  end

  private def unspawn_gourds
    ACCEPTED_CLANS.size.times do |i|
      @gourds[i].last_spawn.try &.delete_me
      SpawnTable.delete_spawn(@gourds[i], false)
    end
  end

  private def move_gourds
    ACCEPTED_CLANS.size.times do |i|
      old_spawn = @gourds[(idx - 1) - i]
      cur_spawn = @gourds[i]

      @gourds[(idx - 1) - i] = cur_spawn

      cur_spawn.last_spawn.try &.tele_to_location(old_spawn.location)
    end
  end

  private def reduce_gourd_hp(index, player)
    gourd = @gourds[index]
    gourd.last_spawn.try &.reduce_current_hp(1000, player, nil)
  end

  private def increase_gourd_hp(index)
    gourd = @gourds[index]
    gourd_npc = gourd.last_spawn.not_nil!
    gourd_npc.current_hp += 1000
  end

  private def cast_debuffs_on_enemies(arena)
    ARENA_ZONES.each do |id|
      if id == arena
        next
      end

      chars = ZoneManager.get_zone_by_id(id).not_nil!.characters_inside
      chars.each do |chr|
        DEBUFFS.each do |sk|
          sk.apply_effects(chr, chr)
        end
      end
    end
  end

  private def shout_random_text(npc)
    length = TEXT_PASSAGES.size

    if USED_TEXT_PASSAGES.size >= length
      return
    end

    message = TEXT_PASSAGES.sample

    if USED_TEXT_PASSAGES.has_key?(message)
      shout_random_text(npc)
    else
      USED_TEXT_PASSAGES[message] = [] of L2Clan
      shout = Say2::NPC_SHOUT
      l2id = npc.l2id
      say = NpcSay.new(l2id, shout, npc.id, message)
      npc.broadcast_packet(say)
    end
  end

  private def valid_passage?(text)
    TEXT_PASSAGES.any? &.casecmp?(text)
  end

  private def yeti_target?(npc_id)
    YETIS.includes?(npc_id)
  end

  private def remove_attacker(clan_id)
    sql = "DELETE FROM rainbowsprings_attacker_list WHERE clanId = ?"
    GameDB.exec(sql, clan_id)
  rescue e
    error e
  end

  private def add_attacker(clan_id, count)
    sql = "INSERT INTO rainbowsprings_attacker_list VALUES (?,?)"
    GameDB.exec(sql, clan_id, count)
  rescue e
    error e
  end

  def load_attackers
    GameDB.each("SELECT * FROM rainbowsprings_attacker_list") do |rs|
      WAR_DECREES_COUNT[rs.get_i32("clan_id")] = rs.get_i64("decrees_count")
    end
  rescue e
    error e
  end

  private def set_registration_end_string(time)
    c = Calendar.new
    c.ms = time
    year = c.year
    month = c.month + 1
    day = c.day
    hour = c.hour
    mins = c.minute

    tmp = mins < 10 ? ":0" : ":"
    @registration_ends = "#{year}-#{month}-#{day} #{hour}#{tmp}#{mins}"
  end

  def launch_siege
    @next_siege.cancel
    ThreadPoolManager.execute_general(->siege_starts_task)
  end

  def end_siege
    @siege_end.try &.cancel
    ThreadPoolManager.execute_general(siege_end_task(nil))
  end

  def update_admin_date(date)
    @rainbow ||= ClanHallSiegeManager.get_siegable_hall(RAINBOW_SPRINGS)
    @rainbow.not_nil!.next_siege_time = date
    @next_siege.try &.cancel
    date -= 3600000
    set_registration_end_string(date)
    @next_siege = ThreadPoolManager.schedule_general(->set_final_attackers_task, @rainbow.not_nil!.next_siege_time)
  end
end
