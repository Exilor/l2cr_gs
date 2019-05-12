class Scripts::PailakaDevilsLegacy < AbstractInstance
  private class DIWorld < InstanceWorld
    getter followers_list = [] of L2Attackable
    property! lematan_npc : L2Attackable?
  end

  # NPCs
  private LEMATAN = 18633 # Lematan
  private SURVIVOR = 32498 # Devil's Isle Survivor
  private FOLLOWERS = 18634 # Lematan's Follower
  private POWDER_KEG = 18622 # Powder Keg
  private TREASURE_BOX = 32495 # Treasure Chest
  private ADVENTURER2 = 32511 # Dwarf Adventurer
  # Items
  private ANTIDOTE_POTION = 13048 # Pailaka Antidote
  private DIVINE_POTION = 13049 # Divine Soul
  private PAILAKA_KEY = 13150 # Pailaka All-Purpose Key
  private SHIELD = 13032 # Pailaka Instant Shield
  private DEFENCE_POTION = 13059 # Long-Range Defense Increasing Potion
  private HEALING_POTION = 13033 # Quick Healing Potion
  # Skills
  private ENERGY = SkillHolder.new(5712) # Energy Ditch
  private BOOM = SkillHolder.new(5714) # Boom Up
  private AV_TELEPORT = SkillHolder.new(4671) # AV - Teleport
  # Locations
  private TELEPORT = Location.new(76427, -219045, -3780)
  private LEMATAN_SPAWN = Location.new(88108, -209252, -3744, 6425)
  private LEMATAN_PORT_POINT = Location.new(86116, -209117, -3774)
  private LEMATAN_PORT = Location.new(85000, -208699, -3336)
  private ADVENTURER_LOC = Location.new(84983, -208736, -3336, 49915)
  private FOLLOWERS_LOC = {
    Location.new(85067, -208943, -3336, 20106),
    Location.new(84904, -208944, -3336, 10904),
    Location.new(85062, -208538, -3336, 44884),
    Location.new(84897, -208542, -3336, 52973),
    Location.new(84808, -208633, -3339, 65039),
    Location.new(84808, -208856, -3339,     0),
    Location.new(85144, -208855, -3341, 33380),
    Location.new(85139, -208630, -3339, 31777),
  }
  # Misc
  private TEMPLATE_ID = 44
  private ZONE = 20109

  def initialize
    super(self.class.simple_name)

    add_talk_id(SURVIVOR)
    add_attack_id(POWDER_KEG, TREASURE_BOX, LEMATAN)
    add_kill_id(LEMATAN)
    add_spawn_id(FOLLOWERS)
    add_enter_zone_id(ZONE)
    add_move_finished_id(LEMATAN)
  end

  def on_adv_event(event, npc, player)
    npc = npc.not_nil!

    world = InstanceManager.get_world(npc.instance_id)

    if event == "enter"
      player = player.not_nil!
      qs = player.get_quest_state(Scripts::Q00129_PailakaDevilsLegacy.simple_name).not_nil!
      enter_instance(player, DIWorld.new, "PailakaDevilsLegacy.xml", TEMPLATE_ID)
      if qs.cond?(1)
        qs.set_cond(2, true)
        htmltext = "32498-01.htm"
      else
        htmltext = "32498-02.htm"
      end
    elsif world.is_a?(DIWorld)
      case event
      when "FOLLOWER_CAST"
        if world.lematan_npc? && world.lematan_npc.alive?
          world.followers_list.each do |follower|
            follower.target = world.lematan_npc
            follower.do_cast(ENERGY)
          end
          start_quest_timer("FOLLOWER_CAST", 15000, world.lematan_npc?, nil)
        end
      when "LEMATAN_TELEPORT"
        npc.as(L2Attackable).clear_aggro_list
        npc.disable_core_ai(false)
        npc.tele_to_location(LEMATAN_PORT)
        npc.variables["ON_SHIP"] = 1
        npc.spawn.location = LEMATAN_PORT
        FOLLOWERS_LOC.each do |loc|
          follower = add_spawn(FOLLOWERS, loc, false, 0, false, world.instance_id).as(L2Attackable)
          follower.disable_core_ai(true)
          follower.immobilized = true
          world.followers_list << follower
        end
        start_quest_timer("FOLLOWER_CAST", 4000, world.lematan_npc?, nil)
      when "TELEPORT"
        player = player.not_nil!
        player.tele_to_location(TELEPORT)
      when "DELETE"
        npc.delete_me
      end
    end

    htmltext
  end

  def on_attack(npc, attacker, damage, is_summon)
    world = InstanceManager.get_world(npc.instance_id)

    if world.is_a?(DIWorld)
      case npc.id
      when POWDER_KEG
        if damage > 0 && npc.script_value?(0)
          npc.known_list.each_character(600) do |monster|
            if monster.is_a?(L2Attackable) && monster.monster?
              monster.add_damage_hate(npc, 0, 999)
              monster.set_intention(AI::ATTACK, npc)
              monster.reduce_current_hp(500.0 + rand(0..200), npc, BOOM.skill)
            end
          end
          npc.do_cast(BOOM)
          npc.script_value = 1
          start_quest_timer("DELETE", 2000, npc, nil)
        end
      when LEMATAN
        if npc.script_value?(0) && npc.current_hp < npc.max_hp * 0.5
          npc.disable_core_ai(true)
          npc.script_value = 1
          npc.running = true
          npc.set_intention(AI::MOVE_TO, LEMATAN_PORT_POINT)
        end
      when TREASURE_BOX
        if npc.script_value?(0)
          case rand(7)
          when 0, 1
            npc.drop_item(attacker, ANTIDOTE_POTION, rand(1i64..10i64))
          when 2
            npc.drop_item(attacker, DIVINE_POTION, rand(1i64..5i64))
          when 3
            npc.drop_item(attacker, PAILAKA_KEY, rand(1i64..2i64))
          when 4
            npc.drop_item(attacker, DEFENCE_POTION, rand(1i64..7i64))
          when 5
            npc.drop_item(attacker, SHIELD, rand(1i64..10i64))
          when 6
            npc.drop_item(attacker, HEALING_POTION, rand(1i64..10i64))
          end

          npc.script_value = 1
          start_quest_timer("DELETE", 3000, npc, attacker)
        end
      end
    end

    super
  end

  def on_kill(npc, player, is_summon)
    world = InstanceManager.get_world(npc.instance_id)

    if world.is_a?(DIWorld)
      world.followers_list.each do |follower|
        follower.delete_me
      end
      world.followers_list.clear
      add_spawn(ADVENTURER2, ADVENTURER_LOC, false, 0, false, npc.instance_id)
    end

    super
  end

  def on_enter_zone(char, zone)
    if char.is_a?(L2PcInstance) && char.alive? && !char.teleporting? && char.online?
      world = InstanceManager.get_world(char.instance_id)
      if world && world.template_id == TEMPLATE_ID
        start_quest_timer("TELEPORT", 1000, world.as(DIWorld).lematan_npc?, char)
      end
    end

    super
  end

  def on_move_finished(npc)
    if npc.location == LEMATAN_PORT_POINT
      npc.do_cast(AV_TELEPORT)
      start_quest_timer("LEMATAN_TELEPORT", 2000, npc, nil)
    end
  end

  def on_enter_instance(player, world, first_entrance)
    if first_entrance
      world.add_allowed(player.l2id)
      world.as(DIWorld).lematan_npc = add_spawn(LEMATAN, LEMATAN_SPAWN, false, 0, false, world.instance_id).as(L2Attackable)
    end
    teleport_player(player, TELEPORT, world.instance_id)
  end
end
