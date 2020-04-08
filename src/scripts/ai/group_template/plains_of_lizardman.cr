class Scripts::PlainsOfLizardman < AbstractNpcAI
  # NPCs
  private INVISIBLE_NPC = 18919
  private TANTA_GUARD = 18862
  private FANTASY_MUSHROOM = 18864
  private STICKY_MUSHROOM = 18865
  private RAINBOW_FROG = 18866
  private ENERGY_PLANT = 18868
  private TANTA_SCOUT = 22768
  private TANTA_MAGICIAN = 22773
  private TANTA_SUMMONER = 22774
  private TANTA_LIZARDMEN = {
    22768, # Tanta Lizardman Scout
    22769, # Tanta Lizardman Warrior
    22770, # Tanta Lizardman Soldier
    22771, # Tanta Lizardman Berserker
    22772, # Tanta Lizardman Archer
    22773, # Tanta Lizardman Magician
    22774  # Tanta Lizardman Summoner
  }
  # Skills
  private STUN_EFFECT = SkillHolder.new(6622)
  private DEMOTIVATION_HEX = SkillHolder.new(6425)
  private FANTASY_MUSHROOM_SKILL = SkillHolder.new(6427)
  private RAINBOW_FROG_SKILL = SkillHolder.new(6429)
  private STICKY_MUSHROOM_SKILL = SkillHolder.new(6428)
  private ENERGY_PLANT_SKILL = SkillHolder.new(6430)
  # Misc
  private HP_PERCENTAGE = 60
  # Buffs
  private BUFFS = {
    SkillHolder.new(6625, 1), # Energy of Life
    SkillHolder.new(6626, 2), # Energy of Life's Power
    SkillHolder.new(6627, 3), # Energy of Life's Highest Power
    SkillHolder.new(6628, 1), # Energy of Mana
    SkillHolder.new(6629, 2), # Energy of Mana's Power
    SkillHolder.new(6630, 3), # Energy of Mana's Highest Power
    SkillHolder.new(6631, 1), # Energy of Power
    SkillHolder.new(6633, 1), # Energy of Attack Speed
    SkillHolder.new(6635, 1), # Energy of Crt Rate
    SkillHolder.new(6636, 1), # Energy of Moving Speed
    SkillHolder.new(6638, 1), # Aura of Mystery
    SkillHolder.new(6639, 1), # Bane of Auras - Damage
    SkillHolder.new(6640, 1), # Energizing Aura
    SkillHolder.new(6674, 1)  # Energy of Range Increment
  }
  # Misc
  private BUFF_LIST = {6, 7, 8, 11, 13}

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_attack_id(FANTASY_MUSHROOM, RAINBOW_FROG, STICKY_MUSHROOM, ENERGY_PLANT, TANTA_SUMMONER)
    add_kill_id(TANTA_LIZARDMEN)
  end

  def on_adv_event(event, npc, player)
    if npc && player && event == "fantasy_mushroom"
      npc.do_cast(FANTASY_MUSHROOM_SKILL)

      npc.known_list.each_character(200) do |target|
        if target.is_a?(L2Attackable)
          monster = target
          npc.target = monster
          npc.do_cast(STUN_EFFECT)
          add_attack_desire(monster, player)
        end
      end

      npc.do_die(player)
    end

    nil
  end

  def on_attack(npc, attacker, damage, is_summon)
    case npc.id
    when TANTA_SUMMONER
      if npc.hp_percent < HP_PERCENTAGE && npc.script_value?(0)
        npc.script_value = 1
        npc.do_cast(DEMOTIVATION_HEX)
        add_attack_desire(add_spawn(TANTA_SCOUT, *npc.xyz, 0, false, 0, false), attacker)
        add_attack_desire(add_spawn(TANTA_SCOUT, *npc.xyz, 0, false, 0, false), attacker)
      end
    when RAINBOW_FROG
      cast_skill(npc, attacker, RAINBOW_FROG_SKILL)
    when ENERGY_PLANT
      cast_skill(npc, attacker, ENERGY_PLANT_SKILL)
    when STICKY_MUSHROOM
      cast_skill(npc, attacker, STICKY_MUSHROOM_SKILL)
    when FANTASY_MUSHROOM
      if npc.script_value?(0)
        npc.script_value = 1
        npc.invul = true
        npc.known_list.each_character(1000) do |target|
          if target.is_a?(L2Attackable)
            if target.id == TANTA_MAGICIAN || target.id == TANTA_SCOUT
              target.running = true
              target.set_intention(AI::MOVE_TO, Location.new(*npc.xyz, 0))
            end
          end
        end
        start_quest_timer("fantasy_mushroom", 4000, npc, attacker)
      end
    else
      # automatically added
    end


    super
  end

  def on_kill(npc, killer, is_summon)
    # Tanta Guard
    if Rnd.rand(1000) == 0
      add_attack_desire(add_spawn(TANTA_GUARD, npc), killer)
    end

    # Invisible buff npc
    random = Rnd.rand(100)
    buffer = add_spawn(INVISIBLE_NPC, npc.location, false, 6000)
    buffer.target = killer

    if random <= 42
      cast_random_buff(buffer, 7, 45, BUFFS[0], BUFFS[1], BUFFS[2])
    end

    if random <= 11
      cast_random_buff(buffer, 8, 60, BUFFS[3], BUFFS[4], BUFFS[5])
      cast_random_buff(buffer, 3, 6, BUFFS[9], BUFFS[10], BUFFS[12])
    end

    if random <= 25
      buffer.do_cast(BUFFS[BUFF_LIST.sample(random: Rnd)])
    end

    if random <= 10
      buffer.do_cast(BUFFS[13].skill)
    end

    if random <= 1
      i = Rnd.rand(100)
      if i <= 34
        buffer.do_cast(BUFFS[6])
        buffer.do_cast(BUFFS[7])
        buffer.do_cast(BUFFS[8])
      elsif i < 67
        buffer.do_cast(BUFFS[13])
      else
        buffer.do_cast(BUFFS[2])
        buffer.do_cast(BUFFS[5])
      end
    end

    super
  end

  private def cast_random_buff(npc, chance1, chance2, *buffs)
    rnd = Rnd.rand(100)
    if rnd <= chance1
      npc.do_cast(buffs[2])
    elsif rnd <= chance2
      npc.do_cast(buffs[1])
    else
      npc.do_cast(buffs[0])
    end
  end

  private def cast_skill(npc, target, skill)
    npc.do_die(target)
    super
  end
end