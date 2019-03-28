class Quests::Q00511_AwlUnderFoot < Quest
  private class FAUWorld < InstanceWorld
  end

  private class FortDungeon
    property reenter_time : Int64 = 0i64
    getter_initializer instance_id: Int32
  end

  private class SpawnRaid
    include Runnable
    include Loggable

    initializer owner: Q00511_AwlUnderFoot, world: FAUWorld

    def run
      if @world.status == 0
        spawn_id = RAIDS1.sample
      elsif @world.status == 1
        spawn_id = RAIDS2.sample
      else
        spawn_id = RAIDS3.sample
      end
      raid = @owner.add_spawn(spawn_id, 53319, 245814, -6576, 0, false, 0, false, @world.instance_id)
      if raid.is_a?(L2RaidBossInstance)
        raid.give_raid_curse = false
      end
    rescue e
      error "Fortress AwlUnderFoot Raid Spawn error:"
      error e
    end
  end

  private REENTERTIME = 14400000
  private RAID_SPAWN_DELAY = 120000
  private FORT_DUNGEONS = {} of Int32 => FortDungeon
  # QUEST ITEMS
  private DL_MARK = 9797
  # REWARDS
  private KNIGHT_EPALUETTE = 9912
  # MONSTER TO KILL -- Only last 3 Raids (lvl ordered) give DL_MARK
  private RAIDS1 = {
    25572,
    25575,
    25578
  }
  private RAIDS2 = {
    25579,
    25582,
    25585,
    25588
  }
  private RAIDS3 = {
    25589,
    25592,
    25593
  }
  # Skill
  private RAID_CURSE = SkillHolder.new(5456)

  def initialize
    super(511, self.class.simple_name, "instances")

    FORT_DUNGEONS[35666] = FortDungeon.new(22)
    FORT_DUNGEONS[35698] = FortDungeon.new(23)
    FORT_DUNGEONS[35735] = FortDungeon.new(24)
    FORT_DUNGEONS[35767] = FortDungeon.new(25)
    FORT_DUNGEONS[35804] = FortDungeon.new(26)
    FORT_DUNGEONS[35835] = FortDungeon.new(27)
    FORT_DUNGEONS[35867] = FortDungeon.new(28)
    FORT_DUNGEONS[35904] = FortDungeon.new(29)
    FORT_DUNGEONS[35936] = FortDungeon.new(30)
    FORT_DUNGEONS[35974] = FortDungeon.new(31)
    FORT_DUNGEONS[36011] = FortDungeon.new(32)
    FORT_DUNGEONS[36043] = FortDungeon.new(33)
    FORT_DUNGEONS[36081] = FortDungeon.new(34)
    FORT_DUNGEONS[36118] = FortDungeon.new(35)
    FORT_DUNGEONS[36149] = FortDungeon.new(36)
    FORT_DUNGEONS[36181] = FortDungeon.new(37)
    FORT_DUNGEONS[36219] = FortDungeon.new(38)
    FORT_DUNGEONS[36257] = FortDungeon.new(39)
    FORT_DUNGEONS[36294] = FortDungeon.new(40)
    FORT_DUNGEONS[36326] = FortDungeon.new(41)
    FORT_DUNGEONS[36364] = FortDungeon.new(42)

    FORT_DUNGEONS.each_key do |i|
      add_start_npc(i)
      add_talk_id(i)
    end

    add_kill_id(RAIDS1)
    add_kill_id(RAIDS2)
    add_kill_id(RAIDS3)

    25572.upto(25595) do |i|
      add_attack_id(i)
    end
  end


  private def check_conditions(player)
    unless party = player.party?
      return "FortressWarden-03.htm"
    end
    if party.leader != player
      return get_htm(player, "FortressWarden-04.htm").sub("%leader%", party.leader.name)
    end
    party.members.each do |m|
      st = get_quest_state(m, false)
      if st.nil? || st.get_int("cond") < 1
        return get_htm(player, "FortressWarden-05.htm").sub("%player%", m.name)
      end
      unless Util.in_range?(1000, player, m, true)
        return get_htm(player, "FortressWarden-06.htm").sub("%player%", m.name)
      end
    end

    nil
  end

  private def check_fort_condition(player, npc, is_enter)
    fort = npc.fort
    dungeon = FORT_DUNGEONS[npc.id]?
    if player.nil? || fort.nil? || dungeon.nil?
      return "FortressWarden-01.htm"
    end
    clan = player.clan?
    if clan.nil? || clan.fort_id != fort.residence_id
      return "FortressWarden-01.htm"
    elsif fort.fort_state == 0
      return "FortressWarden-02a.htm"
    elsif fort.fort_state == 2
      return "FortressWarden-02b.htm"
    elsif is_enter && dungeon.reenter_time > Time.ms
      return "FortressWarden-07.htm"
  end

    unless party = player.party?
      return "FortressWarden-03.htm"
    end
    party.members.each do |m|
      if m.clan?.nil? || m.clan.fort_id == 0 || m.clan.fort_id != fort.residence_id
        html = get_htm(player, "FortressWarden-05.htm")
        return html.sub("%player%", m.name)
      end
    end

    nil
  end

  private def enter_instance(player, template, coords, dungeon, ret)
    # check for existing instances for this player
    world = InstanceManager.get_player_world(player)
    # existing instance
    if world
      unless world.is_a?(FAUWorld)
        player.send_packet(SystemMessageId::YOU_HAVE_ENTERED_ANOTHER_INSTANT_ZONE_THEREFORE_YOU_CANNOT_ENTER_CORRESPONDING_DUNGEON)
        return ""
      end
      teleport_player(player, coords, world.instance_id)
      return ""
    end
    # New instance
    if ret
      return ret
    end

    if ret = check_conditions(player)
      return ret
    end
    party = player.party?
    instance_id = InstanceManager.create_dynamic_instance(template)
    ins = InstanceManager.get_instance!(instance_id)
    ins.exit_loc = Location.new(player)
    world = FAUWorld.new
    world.instance_id = instance_id
    world.template_id = dungeon.instance_id
    world.status = 0
    dungeon.reenter_time = Time.ms + REENTERTIME
    InstanceManager.add_world(world)
    info { "Fortress AwlUnderFoot started #{template} Instance: #{instance_id} created by player: #{player.name}." }
    ThreadPoolManager.schedule_general(SpawnRaid.new(self, world.as(FAUWorld)), RAID_SPAWN_DELAY)

    # teleport players
    if party.nil?
      teleport_player(player, coords, instance_id)
      world.add_allowed(player.l2id)
    else
      party.members.each do |m|
        teleport_player(m, coords, instance_id)
        world.add_allowed(m.l2id)
        get_quest_state(m, true)
      end
    end

    get_htm(player, "FortressWarden-08.htm").sub("%clan%", player.clan.name)
  end

  def on_adv_event(event, npc, player)
    player = player.not_nil!
    npc = npc.not_nil!

    html = event
    if event.casecmp?("enter")
      tele = {53322, 246380, -6580}
      return enter_instance(player, "fortdungeon.xml", tele, FORT_DUNGEONS[npc.id], check_fort_condition(player, npc, true))
    end
    st = get_quest_state!(player)

    if event.casecmp?("FortressWarden-10.htm")
      if st.cond?(0)
        st.start_quest
      end
    elsif event.casecmp?("FortressWarden-15.htm")
      st.exit_quest(true, true)
    end

    html
  end

  def on_attack(npc, player, damage, is_summon)
    attacker = is_summon ? player.summon! : player
    if attacker.level - npc.level >= 9
      if attacker.buff_count > 0 || attacker.dance_count > 0
        npc.target = attacker
        npc.do_simultaneous_cast(RAID_CURSE)
      elsif party = player.party?
        party.members.each do |m|
          if m.buff_count > 0 || m.dance_count > 0
            npc.target = m
            npc.do_simultaneous_cast(RAID_CURSE)
          end
        end
      end
    end

    super
  end

  def on_kill(npc, player, is_summon)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(FAUWorld)
      if RAIDS3.includes?(npc.id)
        if party = player.party?
          party.members.each do |pl|
            reward_player(pl)
          end
        else
          reward_player(player)
        end

        instance_obj = InstanceManager.get_instance!(world.instance_id)
        instance_obj.duration = 360000
        instance_obj.remove_npcs
      else
        world.inc_status
        ThreadPoolManager.schedule_general(SpawnRaid.new(self, world), RAID_SPAWN_DELAY)
      end
    end

    nil
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)
    if ret = check_fort_condition(player, npc, false)
      return ret
    end

    npc_id = npc.id
    cond = 0
    if st.state == State::CREATED
      st.set("cond", "0")
    else
      cond = st.get_int("cond")
    end
    if FORT_DUNGEONS.has_key?(npc_id) && cond == 0
      if player.level >= 60
        html = "FortressWarden-09.htm"
      else
        html = "FortressWarden-00.htm"
        st.exit_quest(true)
      end
    elsif FORT_DUNGEONS.has_key?(npc_id) && cond > 0 && st.state == State::STARTED
      count = st.get_quest_items_count(DL_MARK)
      if cond == 1 && count > 0
        html = "FortressWarden-14.htm"
        st.take_items(DL_MARK, -1)
        st.reward_items(KNIGHT_EPALUETTE, count)
      elsif cond == 1 && count == 0
        html = "FortressWarden-10.htm"
      end
    end

    html || get_no_quest_msg(player)
  end

  private def reward_player(player)
    st = get_quest_state!(player, false)
    if st.cond?(1)
      st.give_items(DL_MARK, 140)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end
  end

  private def teleport_player(player, coords, instance_id)
    player.instance_id = instance_id
    player.tele_to_location(coords[0], coords[1], coords[2])
  end
end
