class Scripts::DisciplesNecropolisPast < AbstractInstance
  private class DNPWorld < InstanceWorld
    getter anakim_group = [] of L2Npc
    getter lilith_group = [] of L2Npc
    property kill_count : Int32 = 0
  end

  # NPCs
  private SEAL_DEVICE = 27384
  private PROMISE_OF_MAMMON = 32585
  private SHUNAIMAN = 32586
  private LEON = 32587
  private DISCIPLES_GATEKEEPER = 32657
  private LILITH = 32715
  private LILITHS_STEWARD = 32716
  private LILITHS_ELITE = 32717
  private ANAKIM = 32718
  private ANAKIMS_GUARDIAN = 32719
  private ANAKIMS_GUARD = 32720
  private ANAKIMS_EXECUTOR = 32721
  private LILIM_BUTCHER = 27371
  private LILIM_MAGUS = 27372
  private LILIM_KNIGHT_ERRANT = 27373
  private SHILENS_EVIL_THOUGHTS1 = 27374
  private SHILENS_EVIL_THOUGHTS2 = 27375
  private LILIM_KNIGHT = 27376
  private LILIM_SLAYER = 27377
  private LILIM_GREAT_MAGUS = 27378
  private LILIM_GUARD_KNIGHT = 27379
  # Items
  private SACRED_SWORD_OF_EINHASAD = 15310
  private SEAL_OF_BINDING = 13846
  # Skills
  private SEAL_ISOLATION = SkillHolder.new(5980, 3)
  private SKILLS = {
    32715 => SkillHolder.new(6187), # Presentation - Lilith Battle
    32716 => SkillHolder.new(6188), # Presentation - Lilith's Steward Battle1
    32717 => SkillHolder.new(6190), # Presentation - Lilith's Bodyguards Battle1
    32718 => SkillHolder.new(6191), # Presentation - Anakim Battle
    32719 => SkillHolder.new(6192), # Presentation - Anakim's Guardian Battle1
    32720 => SkillHolder.new(6194), # Presentation - Anakim's Guard Battle
    32721 => SkillHolder.new(6195)  # Presentation - Anakim's Executor Battle
  }
  # Locations
  private ENTER = Location.new(-89554, 216078, -7488, 0, 0)
  private EXIT = Location.new(171895, -17501, -4903, 0, 0)
  # NpcStringId
  private LILITH_SHOUT = {
    NpcString::HOW_DARE_YOU_TRY_TO_CONTEND_AGAINST_ME_IN_STRENGTH_RIDICULOUS,
    NpcString::ANAKIM_IN_THE_NAME_OF_GREAT_SHILIEN_I_WILL_CUT_YOUR_THROAT,
    NpcString::YOU_CANNOT_BE_THE_MATCH_OF_LILITH_I_LL_TEACH_YOU_A_LESSON
  }
  # Misc
  private TEMPLATE_ID = 112
  private DOOR_1 = 17240102
  private DOOR_2 = 17240104
  private DOOR_3 = 17240106
  private DOOR_4 = 17240108
  private DOOR_5 = 17240110
  private DISCIPLES_NECROPOLIS_DOOR = 17240111
  private LILITH_SPAWN = {
    LILITH => Location.new(-83175, 217021, -7504, 49151),
    LILITHS_STEWARD => Location.new(-83327, 216938, -7492, 50768),
    LILITHS_ELITE => Location.new(-83003, 216909, -7492, 4827)
  }
  private ANAKIM_SPAWN = {
    ANAKIM => Location.new(-83179, 216479, -7504, 16384),
    ANAKIMS_GUARDIAN => Location.new(-83321, 216507, -7492, 16166),
    ANAKIMS_GUARD => Location.new(-83086, 216519, -7495, 15910),
    ANAKIMS_EXECUTOR => Location.new(-83031, 216604, -7492, 17071)
  }

  def initialize
    super(self.class.simple_name)

    add_attack_id(SEAL_DEVICE)
    add_first_talk_id(SHUNAIMAN, LEON, DISCIPLES_GATEKEEPER)
    add_kill_id(
      LILIM_BUTCHER, LILIM_MAGUS, LILIM_KNIGHT_ERRANT, LILIM_KNIGHT,
      SHILENS_EVIL_THOUGHTS1, SHILENS_EVIL_THOUGHTS2, LILIM_SLAYER,
      LILIM_GREAT_MAGUS, LILIM_GUARD_KNIGHT
    )
    add_aggro_range_enter_id(
      LILIM_BUTCHER, LILIM_MAGUS, LILIM_KNIGHT_ERRANT, LILIM_KNIGHT,
      SHILENS_EVIL_THOUGHTS1, SHILENS_EVIL_THOUGHTS2, LILIM_SLAYER,
      LILIM_GREAT_MAGUS, LILIM_GUARD_KNIGHT
    )
    add_spawn_id(SEAL_DEVICE)
    add_start_npc(PROMISE_OF_MAMMON)
    add_talk_id(PROMISE_OF_MAMMON, SHUNAIMAN, LEON, DISCIPLES_GATEKEEPER)
  end

  private def spawn_npc(world)
    LILITH_SPAWN.each do |key, value|
      npc = add_spawn(key, value, false, 0, false, world.instance_id)
      world.lilith_group << npc
    end
    ANAKIM_SPAWN.each do |key, value|
      npc = add_spawn(key, value, false, 0, false, world.instance_id)
      world.anakim_group << npc
    end
  end

  private def check_doors(npc, world)
    sync do
      world.kill_count += 1
      case world.kill_count
      when 4
        open_door(DOOR_1, world.instance_id)
      when 10
        open_door(DOOR_2, world.instance_id)
      when 18
        open_door(DOOR_3, world.instance_id)
      when 28
        open_door(DOOR_4, world.instance_id)
      when 40
        open_door(DOOR_5, world.instance_id)
      else
        # automatically added
      end

    end
  end

  def on_enter_instance(pc, world, first_entrance)
    if first_entrance
      spawn_npc(world.as(DNPWorld))
      world.add_allowed(pc.l2id)
    end

    teleport_player(pc, ENTER, world.instance_id)
  end

  private def make_cast(npc, targets)
    npc.target = targets.sample(random: Rnd)
    if skill = SKILLS[npc.id]?
      npc.do_cast(skill)
    end
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!

    world = InstanceManager.get_player_world(pc)
    if world.is_a?(DNPWorld)
      case event
      when "FINISH"
        if get_quest_items_count(pc, SEAL_OF_BINDING) >= 4
          pc.show_quest_movie(13)
          start_quest_timer("TELEPORT", 27000, nil, pc)
        end
      when "TELEPORT"
        teleport_player(pc, ENTER, world.instance_id)
      when "FIGHT"
        world.anakim_group.each do |caster|
          unless caster.casting_now?
            make_cast(caster, world.lilith_group)
          end
          if caster.id == ANAKIM
            if caster.script_value?(0)
              caster.broadcast_packet(NpcSay.new(caster.l2id, Say2::NPC_SHOUT, caster.id, NpcString::FOR_THE_ETERNITY_OF_EINHASAD))
              if Util.in_range?(2000, caster, pc, true)
                pc.send_packet(NpcSay.new(caster.l2id, Say2::TELL, caster.id, NpcString::MY_POWERS_WEAKENING_HURRY_AND_TURN_ON_THE_SEALING_DEVICE))
              end
              caster.script_value = 1
            elsif Rnd.rand(100) < 10
              case Rnd.rand(3)
              when 0
                caster.broadcast_packet(NpcSay.new(caster.l2id, Say2::NPC_SHOUT, caster.id, NpcString::DEAR_SHILLIENS_OFFSPRINGS_YOU_ARE_NOT_CAPABLE_OF_CONFRONTING_US))
                if Util.in_range?(2000, caster, pc, true)
                  pc.send_packet(NpcSay.new(caster.l2id, Say2::TELL, caster.id, NpcString::ALL_4_SEALING_DEVICES_MUST_BE_TURNED_ON))
                end
              when 1
                caster.broadcast_packet(NpcSay.new(caster.l2id, Say2::NPC_SHOUT, caster.id, NpcString::ILL_SHOW_YOU_THE_REAL_POWER_OF_EINHASAD))
                if Util.in_range?(2000, caster, pc, true)
                  pc.send_packet(NpcSay.new(caster.l2id, Say2::TELL, caster.id, NpcString::LILITHS_ATTACK_IS_GETTING_STRONGER_GO_AHEAD_AND_TURN_IT_ON))
                end
              when 2
                caster.broadcast_packet(NpcSay.new(caster.l2id, Say2::NPC_SHOUT, caster.id, NpcString::DEAR_MILITARY_FORCE_OF_LIGHT_GO_DESTROY_THE_OFFSPRINGS_OF_SHILLIEN))
                if Util.in_range?(2000, caster, pc, true)
                  pc.send_packet(NpcSay.new(caster.l2id, Say2::TELL, caster.id, NpcString::DEAR_S1_GIVE_ME_MORE_STRENGTH).add_string_parameter(pc.name))
                end
              else
                # automatically added
              end

            end
          end
        end
        world.lilith_group.each do |caster|
          unless caster.casting_now?
            make_cast(caster, world.anakim_group)
          end
          if caster.id == LILITH
            if caster.script_value?(0)
              caster.broadcast_packet(NpcSay.new(caster.l2id, Say2::NPC_SHOUT, caster.id, NpcString::YOU_SUCH_A_FOOL_THE_VICTORY_OVER_THIS_WAR_BELONGS_TO_SHILIEN))
              caster.script_value = 1
            elsif Rnd.rand(100) < 10
              caster.broadcast_packet(NpcSay.new(caster.l2id, Say2::NPC_SHOUT, caster.id, LILITH_SHOUT.sample))
            end
          end

          start_quest_timer("FIGHT", 1000, nil, pc)
          break
        end
      else
        # automatically added
      end

    end

    super
  end

  def on_aggro_range_enter(npc, player, is_summon)
    case npc.id
    when LILIM_BUTCHER, LILIM_GUARD_KNIGHT
      if npc.script_value?(0)
        npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::THIS_PLACE_ONCE_BELONGED_TO_LORD_SHILEN))
        npc.script_value = 1
      end
    when LILIM_MAGUS, LILIM_GREAT_MAGUS
      if npc.script_value?(0)
        npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::WHO_DARES_ENTER_THIS_PLACE))
        npc.script_value = 1
      end
    when LILIM_KNIGHT_ERRANT, LILIM_KNIGHT
      if npc.script_value?(0)
        npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::THOSE_WHO_ARE_AFRAID_SHOULD_GET_AWAY_AND_THOSE_WHO_ARE_BRAVE_SHOULD_FIGHT))
        npc.script_value = 1
      end
    when LILIM_SLAYER
      if npc.script_value?(0)
        npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::LEAVE_NOW))
        npc.script_value = 1
      end
    else
      # automatically added
    end


    super
  end

  def on_attack(npc, pc, damage, is_summon)
    if InstanceManager.get_player_world(pc).is_a?(DNPWorld)
      if npc.script_value?(0)
        if npc.hp_percent < 10
          give_items(pc, SEAL_OF_BINDING, 1)
          pc.send_packet(SystemMessageId::THE_SEALING_DEVICE_ACTIVATION_COMPLETE)
          npc.script_value = 1
          start_quest_timer("FINISH", 1000, npc, pc)
          cancel_quest_timer("FIGHT", npc, pc)
        end
      end
      if Rnd.rand(100) < 50
        npc.do_cast(SEAL_ISOLATION)
      end
    end

    super
  end

  def on_first_talk(npc, pc)
    "#{npc.id}.htm"
  end

  def on_kill(npc, pc, is_summon)
    world = InstanceManager.get_player_world(pc)
    if world.is_a?(DNPWorld)
      check_doors(npc, world)
    end

    case npc.id
    when LILIM_MAGUS, LILIM_GREAT_MAGUS
      npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::LORD_SHILEN_SOME_DAY_YOU_WILL_ACCOMPLISH_THIS_MISSION))
    when LILIM_KNIGHT_ERRANT, LILIM_KNIGHT, LILIM_GUARD_KNIGHT
      npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::WHY_ARE_YOU_GETTING_IN_OUR_WAY))
    when LILIM_SLAYER
      npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::FOR_SHILEN))
    else
      # automatically added
    end


    super
  end

  def on_spawn(npc)
    npc.mortal = false
    super
  end

  def on_talk(npc, pc)
    unless qs = pc.get_quest_state(Q00196_SevenSignsSealOfTheEmperor.simple_name)
      return get_no_quest_msg(pc)
    end

    case npc.id
    when PROMISE_OF_MAMMON
      if qs.cond?(3) || qs.cond?(4)
        enter_instance(pc, DNPWorld.new, "DisciplesNecropolisPast.xml", TEMPLATE_ID)
        return ""
      end
    when LEON
      if qs.cond >= 3
        take_items(pc, SACRED_SWORD_OF_EINHASAD, -1)
        world = InstanceManager.get_player_world(pc).not_nil!
        world.remove_allowed(pc.l2id)
        pc.tele_to_location(EXIT, 0)
        html = "32587-01.html"
      end
    when DISCIPLES_GATEKEEPER
      if qs.cond >= 3
        world = InstanceManager.get_world(npc.instance_id)
        if world.is_a?(DNPWorld)
          open_door(DISCIPLES_NECROPOLIS_DOOR, world.instance_id)
          pc.show_quest_movie(12)
          start_quest_timer("FIGHT", 1000, nil, pc)
        end
      end
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end