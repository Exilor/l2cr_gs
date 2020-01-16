class Scripts::NornilsGarden < AbstractInstance
  private class NornilsWorld < InstanceWorld
    property first_npc : L2Npc?
    property spawned_1 : Bool = false
    property spawned_2 : Bool = false
    property spawned_3 : Bool = false
    property spawned_4 : Bool = false
  end

  # NPCs
  private GARDEN_GUARD = 32330
  private FINAL_GATES = {
    32260,
    32261,
    32262
  }
  # Skills

  # Locations
  private SPAWN_PPL = Location.new(-111184, 74540, -12430)
  private EXIT_PPL = Location.new(-74058, 52040, -3680)
  # Misc
  private TEMPLATE_ID = 11
  private DURATION_TIME = 70
  private EMPTY_DESTROY_TIME = 5
  private INSTANCE_LVL_MIN = 18
  private INSTANCE_LVL_MAX = 22
  private AUTO_GATES = {
    {
    # Warriors gate
      20110,
      16200001
    },
    {
    # Midway gate
      20111,
      16200004
    },
    {
    # Gate
      20112,
      16200013
    }
  }
  private HERB_JAR = 18478
  private GATEKEEPERS = {
    {18352, 9703,        0}, # Kamael Guard
    {18353, 9704,        0}, # Guardian of Records
    {18354, 9705,        0}, # Guardian of Observation
    {18355, 9706,        0}, # Spicula's Guard
    {18356, 9707, 16200024}, # Harkilgamed's Gatekeeper
    {18357, 9708, 16200025}, # Rodenpicula's Gatekeeper
    {18358, 9713,        0}, # Guardian of Secrets
    {18359, 9709, 16200023}, # Arviterre's Guardian
    {18360, 9710,        0}, # Katenar's Gatekeeper
    {18361, 9711,        0}, # Guardian of Prediction
    {25528, 9712,        0}  # Tiberias
  }
  private HP_HERBS_DROPLIST = {
    # itemId, count, chance
    {8602, 1, 10},
    {8601, 2, 40},
    {8600, 3, 70}
  }
  private GROUP_1 = {
    {18363, -109899, 74431, -12528, 16488},
    {18483, -109701, 74501, -12528, 24576},
    {18483, -109892, 74886, -12528,     0},
    {18363, -109703, 74879, -12528, 49336}
  }
  private GROUP_2 = {
    {18363, -110393, 78276, -12848, 49152},
    {18363, -110561, 78276, -12848, 49152},
    {18362, -110414, 78495, -12905, 48112},
    {18362, -110545, 78489, -12903, 48939},
    {18483, -110474, 78601, -12915, 49488},
    {18362, -110474, 78884, -12915, 49338},
    {18483, -110389, 79131, -12915, 48539},
    {18483, -110551, 79134, -12915, 49151}
  }
  private GROUP_3 = {
    {18483, -107798, 80721, -12912, 0},
    {18483, -107798, 80546, -12912, 0},
    {18347, -108033, 80644, -12912, 0},
    {18363, -108520, 80647, -12912, 0},
    {18483, -108740, 80752, -12912, 0},
    {18363, -109016, 80642, -12912, 0},
    {18483, -108740, 80546, -12912, 0}
  }
  private GROUP_4 = {
    {18362, -110082, 83998, -12928, 0},
    {18362, -110082, 84210, -12928, 0},
    {18363, -109963, 84102, -12896, 0},
    {18347, -109322, 84102, -12880, 0},
    {18362, -109131, 84097, -12880, 0},
    {18483, -108932, 84101, -12880, 0},
    {18483, -109313, 84488, -12880, 0},
    {18362, -109122, 84490, -12880, 0},
    {18347, -108939, 84489, -12880, 0}
  }
  private MP_HERBS_DROPLIST = {
    # itemId, count, chance
    {8605, 1, 10},
    {8604, 2, 40},
    {8603, 3, 70}
  }

  @skill1 : Skill?
  @skill2 : Skill?
  @skill3 : Skill?
  @skill4 : Skill?

  def initialize
    super(self.class.simple_name)

    add_start_npc(GARDEN_GUARD)
    add_first_talk_id(GARDEN_GUARD)
    add_talk_id(GARDEN_GUARD)
    GATEKEEPERS.each do |i|
      add_kill_id(i[0])
    end
    AUTO_GATES.each do |i|
      add_enter_zone_id(i[0])
    end
    add_talk_id(FINAL_GATES)
    add_attack_id(HERB_JAR)
    add_attack_id(18362) # first garden guard

    @skill1 = SkillData[4322, 1]?
    @skill2 = SkillData[4327, 1]?
    @skill3 = SkillData[4329, 1]?
    @skill4 = SkillData[4324, 1]?
  end

  private def drop_herb(mob, player, drop)
    chance = Rnd.rand(100)
    drop.each do |element|
      if chance < element[2]
        mob.drop_item(player, element[0], element[1].to_i64)
      end
    end
  end

  private def give_buffs(ch)
    if skill = @skill1
      skill.apply_effects(ch, ch)
    end
    if skill = @skill2
      skill.apply_effects(ch, ch)
    end
    if skill = @skill3
      skill.apply_effects(ch, ch)
    end
    if skill = @skill4
      skill.apply_effects(ch, ch)
    end
  end

  def teleport_player(player, loc, instance_id)
    give_buffs(player)
    if summon = player.summon
      give_buffs(summon)
    end

    super
  end

  private def exit_instance(player)
    inst = InstanceManager.get_world(player.instance_id)
    if inst.is_a?(NornilsWorld)
      world = inst
      world.remove_allowed(player.l2id)
      teleport_player(player, EXIT_PPL, 0)
    end
  end

  private def enter_instance(npc, player)
    world = InstanceManager.get_player_world(player)
    if world
      if !world.is_a?(NornilsWorld) || world.template_id != TEMPLATE_ID
        player.send_packet(SystemMessageId::YOU_HAVE_ENTERED_ANOTHER_INSTANT_ZONE_THEREFORE_YOU_CANNOT_ENTER_CORRESPONDING_DUNGEON)
        return
      end
      # check for level difference again on reenter
      if player.level > INSTANCE_LVL_MAX || player.level < INSTANCE_LVL_MIN
        sm = SystemMessage.c1_s_level_requirement_is_not_sufficient_and_cannot_be_entered
        sm.add_pc_name(player)
        player.send_packet(sm)
        return
      end
      # check what instance still exist
      inst = InstanceManager.get_instance(world.instance_id)
      if inst
        teleport_player(player, SPAWN_PPL, world.instance_id)
      end
      return
    end
    # Creating new instance
    result = chech_conditions(npc, player)
    unless result.casecmp?("ok")
      return result
    end

    instance_id = InstanceManager.create_dynamic_instance("NornilsGarden.xml")
    inst = InstanceManager.get_instance(instance_id).not_nil!

    inst.name = InstanceManager.get_instance_id_name(TEMPLATE_ID)
    inst.exit_loc = Location.new(player)
    inst.allow_summon = false
    inst.duration = DURATION_TIME * 60000
    inst.empty_destroy_time = EMPTY_DESTROY_TIME.to_i64 * 60000
    world = NornilsWorld.new
    world.instance_id = instance_id
    world.template_id = TEMPLATE_ID
    InstanceManager.add_world(world)
    # _log.info("Nornils Garden: started, Instance: " + instance_id + " created by player: " + player.name)

    prepare_instance(world)

    # and finally teleport party into instance
    if party = player.party
      party.members.each do |party_member|
        world.add_allowed(party_member.l2id)
        teleport_player(party_member, SPAWN_PPL, instance_id)
      end
    end
  end

  private def prepare_instance(world)
    world.first_npc = add_spawn(18362, -109702, 74696, -12528, 49568, false, 0, false, world.instance_id)

    door = get_door(16200010, world.instance_id)
    if door
      door.targetable = false
      door.mesh_index = 2
    end
  end

  private def spawn1(npc)
    inst = InstanceManager.get_world(npc.instance_id)
    if inst.is_a?(NornilsWorld)
      world = inst
      if npc == world.first_npc && !world.spawned_1
        world.spawned_1 = true

        GROUP_1.each do |mob|
          add_spawn(mob[0], mob[1], mob[2], mob[3], mob[4], false, 0, false, world.instance_id)
        end
      end
    end
  end

  private def spawn2(npc)
    inst = InstanceManager.get_world(npc.instance_id)
    if inst.is_a?(NornilsWorld)
      world = inst
      if !world.spawned_2
        world.spawned_2 = true

        GROUP_2.each do |mob|
          add_spawn(mob[0], mob[1], mob[2], mob[3], mob[4], false, 0, false, world.instance_id)
        end
      end
    end
  end

  private def spawn3(cha)
    inst = InstanceManager.get_world(cha.instance_id)
    if inst.is_a?(NornilsWorld)
      world = inst
      if !world.spawned_3
        world.spawned_3 = true

        GROUP_3.each do |mob|
          add_spawn(mob[0], mob[1], mob[2], mob[3], mob[4], false, 0, false, world.instance_id)
        end
      end
    end
  end

  private def spawn4(cha)
    inst = InstanceManager.get_world(cha.instance_id)
    if inst.is_a?(NornilsWorld)
      world = inst
      unless world.spawned_4
        world.spawned_4 = true

        GROUP_4.each do |mob|
          add_spawn(mob[0], mob[1], mob[2], mob[3], mob[4], false, 0, false, world.instance_id)
        end
      end
    end
  end

  def open_door(st, player, door_id)
    st.unset("correct")
    tmpworld = InstanceManager.get_world(player.instance_id)
    if tmpworld.is_a?(NornilsWorld)
      open_door(door_id, tmpworld.instance_id)
    end
  end

  private def chech_conditions(npc, player) : String
    # custom
    if player.gm?
      debug "Skipping conditions check because #{player.name} is a GM (custom)."
      return "ok"
    end


    # player must be in party
    unless party = player.party
      player.send_packet(SystemMessageId::NOT_IN_PARTY_CANT_ENTER)
      return "32330-05.html"
    end
    # ...and be party leader
    if party.leader != player
      player.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_ENTER)
      return "32330-08.html"
    end
    kamael = false

    # for each party member
    party.members.each do |party_member|
      # player level must be in range
      if party_member.level > INSTANCE_LVL_MAX
        sm = SystemMessage.c1_s_level_requirement_is_not_sufficient_and_cannot_be_entered
        sm.add_pc_name(party_member)
        player.send_packet(sm)
        return "32330-06.html"
      end
      if party_member.level < INSTANCE_LVL_MIN
        sm = SystemMessage.c1_s_level_requirement_is_not_sufficient_and_cannot_be_entered
        sm.add_pc_name(party_member)
        player.send_packet(sm)
        return "32330-07.html"
      end
      if party_member.class_id.level != 0
        sm = SystemMessage.c1_s_level_requirement_is_not_sufficient_and_cannot_be_entered
        sm.add_pc_name(party_member)
        player.send_packet(sm)
        return "32330-06.html"
      end
      # player must be near party leader
      unless party_member.inside_radius?(player, 500, true, true)
        sm = SystemMessage.c1_is_in_a_location_which_cannot_be_entered_therefore_it_cannot_be_processed
        sm.add_pc_name(party_member)
        player.send_packet(sm)
        return "32330-08.html"
      end
      if party_member.race.to_i == 5
        checkst = party_member.get_quest_state(Q00179_IntoTheLargeCavern.simple_name)
        if checkst && checkst.state.started?
          kamael = true
        else
          sm = SystemMessage.c1_s_quest_requirement_is_not_sufficient_and_cannot_be_entered
          sm.add_pc_name(party_member)
          player.send_packet(sm)
          return "32330-08.html"
        end
      end
    end

    unless kamael
      return "32330-08.html"
    end

    "ok"
  end

  def on_enter_zone(character, zone)
    if character.is_a?(L2PcInstance) && character.alive?
      if !character.teleporting? && character.online?
        world = InstanceManager.get_world(character.instance_id)
        if world.is_a?(NornilsWorld)
          AUTO_GATES.each do |auto|
            if zone.id == auto[0]
              open_door(auto[1], world.instance_id)
            end
            if zone.id == 20111
              spawn3(character)
            elsif zone.id == 20112
              spawn4(character)
            end
          end
        end
      end
    end

    super
  end

  def on_adv_event(event, npc, player)
    player = player.not_nil!
    npc = npc.not_nil!
    html = event
    st = get_quest_state(player, false)
    return get_no_quest_msg(player) unless st

    if npc.id == GARDEN_GUARD && event.casecmp?("enter_instance")
      html = enter_instance(npc, player)
    elsif npc.id == 32258 && event.casecmp?("exit")
      begin
        exit_instance(player)
      rescue e
        error e
      end
    elsif FINAL_GATES.includes?(npc.id)
      if event.match?(/\A3226[012]-02.html\z/i)
        st.unset("correct")
      elsif event.num?
        correct = st.get_int("correct") + 1
        st.set("correct", correct.to_s)
        html = "#{npc.id}-0#{correct + 2}.html"
      elsif event.casecmp?("check")
        correct = st.get_int("correct")
        if npc.id == 32260 && correct == 3
          open_door(st, player, 16200014)
        elsif npc.id == 32261 && correct == 3
          open_door(st, player, 16200015)
        elsif npc.id == 32262 && correct == 4
          open_door(st, player, 16200016)
        else
          return "#{npc.id}-00.html"
        end
      end
    end

    html
  end

  def on_talk(npc, player)
    if FINAL_GATES.includes?(npc.id)
      cst = player.get_quest_state(Scripts::Q00179_IntoTheLargeCavern.simple_name)
      if cst && cst.state.started?
        return "#{npc.id}-01.html"
      end

      get_no_quest_msg(player)
    end
  end

  def on_first_talk(npc, player)
    get_quest_state(player, true)
    "#{npc.id}.html"
  end

  def on_attack(npc, attacker, damage, is_summon)
    if npc.id == HERB_JAR && npc.alive?
      drop_herb(npc, attacker, HP_HERBS_DROPLIST)
      drop_herb(npc, attacker, MP_HERBS_DROPLIST)
      npc.do_die(attacker)
    elsif npc.id == 18362 && npc.instance_id > 0
      spawn1(npc)
    end

    nil
  end

  def on_kill(npc, player, is_summon)
    st = get_quest_state(player, false)
    if st.nil?
      return
    end

    GATEKEEPERS.each do |gk|
      if npc.id == gk[0]
        # Drop key
        npc.drop_item(player, gk[1], 1)

        # Check if gatekeeper should open bridge, and open it
        if gk[2] > 0
          tmpworld = InstanceManager.get_world(player.instance_id)
          if tmpworld.is_a?(NornilsWorld)
            open_door(gk[2], tmpworld.instance_id)
          end
        end
      end
      if npc.id == 18355
        spawn2(npc)
      end
    end

    super
  end

  def on_enter_instance(player, world, first_entrance)
    # do nothing
  end
end
