class Scripts::PrimevalIsle < AbstractNpcAI
  # NPC
  private EGG = 18344 # Ancient Egg
  private SAILREN = 29065 # Sailren
  private ORNIT = 22742 # Ornithomimus
  private DEINO = 22743 # Deinonychus
  private SPRIGNANT = {
    18345, # Sprigant (Anesthesia)
    18346  # Sprigant (Deadly Poison)
  }
  private MONSTERS = {
    22196, # Velociraptor
    22198, # Velociraptor
    22200, # Ornithomimus
    22202, # Ornithomimus
    22203, # Deinonychus
    22205, # Deinonychus
    22208, # Pachycephalosaurus
    22210, # Pachycephalosaurus
    22211, # Wild Strider
    22213, # Wild Strider
    22223, # Velociraptor
    22224, # Ornithomimus
    22225, # Deinonychus
    22226, # Pachycephalosaurus
    22227, # Wild Strider
    22742, # Ornithomimus
    22743  # Deinonychus
  }
  private TREX = {
    22215, # Tyrannosaurus
    22216, # Tyrannosaurus
    22217  # Tyrannosaurus
  }
  private VEGETABLE = {
    22200, # Ornithomimus
    22201, # Ornithomimus
    22202, # Ornithomimus
    22203, # Deinonychus
    22204, # Deinonychus
    22205, # Deinonychus
    22224, # Ornithomimus
    22225  # Deinonychus
  }
  # Item
  private DEINONYCHUS = 14828 # Deinonychus Mesozoic Stone
  # Skill
  private ANESTHESIA = SkillHolder.new(5085, 1) # Anesthesia
  private DEADLY_POISON = SkillHolder.new(5086, 1) # Deadly Poison
  private SELFBUFF1 = SkillHolder.new(5087, 1) # Berserk
  private SELFBUFF2 = SkillHolder.new(5087, 2) # Berserk
  private LONGRANGEDMAGIC1 = SkillHolder.new(5120, 1) # Stun
  private PHYSICALSPECIAL1 = SkillHolder.new(5083, 4) # Stun
  private PHYSICALSPECIAL2 = SkillHolder.new(5081, 4) # Silence
  private PHYSICALSPECIAL3 = SkillHolder.new(5082, 4) # NPC Spinning, Slashing Trick
  private CREW_SKILL = SkillHolder.new(6172, 1) # Presentation - Tyranno
  private INVIN_BUFF_ON = SkillHolder.new(5225, 1) # Invincible

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_spawn_id(TREX)
    add_spawn_id(SPRIGNANT)
    add_spawn_id(MONSTERS)
    add_aggro_range_enter_id(TREX)
    add_spell_finished_id(TREX)
    add_attack_id(EGG)
    add_attack_id(TREX)
    add_attack_id(MONSTERS)
    add_kill_id(EGG, SAILREN, DEINO, ORNIT)
    add_see_creature_id(TREX)
    add_see_creature_id(MONSTERS)
  end

  def on_spell_finished(npc, player, skill)
    if skill.id == CREW_SKILL.skill_id
      start_quest_timer("START_INVUL", 4000, npc, nil)
      if target = npc.target.as?(L2Npc)
        target.do_die(npc)
      end
    end
    if npc.in_combat?
      mob = npc.as(L2Attackable)
      target = mob.most_hated
      if npc.hp_percent < 60
        if skill.id == SELFBUFF1.skill_id
          npc.script_value = 3
          if target
            npc.target = target
            mob.running = true
            mob.add_damage_hate(target, 0, 555)
            mob.set_intention(AI::ATTACK, target)
          end
        end
      elsif npc.hp_percent < 30
        if skill.id == SELFBUFF1.skill_id
          npc.script_value = 1
          if target
            npc.target = target
            mob.running = true
            mob.add_damage_hate(target, 0, 555)
            mob.set_intention(AI::ATTACK, target)
          end
        elsif skill.id == SELFBUFF2.skill_id
          npc.script_value = 5
          if target
            npc.target = target
            mob.running = true
            mob.add_damage_hate(target, 0, 555)
            mob.set_intention(AI::ATTACK, target)
          end
        end
      end
    end

    super
  end

  def on_adv_event(event, npc, pc)
    case event
    when "USE_SKILL"
      if npc && npc.alive?
        npc.do_cast(npc.id == SPRIGNANT[0] ? ANESTHESIA : DEADLY_POISON)
        start_quest_timer("USE_SKILL", 15000, npc, nil)
      end
    when "GHOST_DESPAWN"
      if npc && npc.alive?
        if !npc.in_combat?
          npc.delete_me
        else
          start_quest_timer("GHOST_DESPAWN", 1800000, npc, nil)
        end
      end
    when "TREX_ATTACK"
      if npc && pc
        npc.script_value = 0
        if pc.inside_radius?(npc, 800, true, false)
          npc.target = pc
          npc.do_cast(LONGRANGEDMAGIC1)
          add_attack_desire(npc, pc)
        end
      end
    when "START_INVUL"
      if npc && npc.alive?
        npc.do_cast(INVIN_BUFF_ON)
        start_quest_timer("START_INVUL_2", 30000, npc, nil)
      end
    when "START_INVUL_2"
      if npc && npc.alive?
        INVIN_BUFF_ON.skill.apply_effects(npc, npc)
      end
    else
      # automatically added
    end


    super
  end

  def on_see_creature(npc, creature, is_summon)
    if MONSTERS.includes?(npc.id)
      if creature.player?
        mob = npc.as(L2Attackable)
        ag_type = npc.template.parameters.get_i32("ag_type", 0)
        prob_physical_special1 = npc.template.parameters.get_i32("ProbPhysicalSpecial1", 0)
        prob_physical_special2 = npc.template.parameters.get_i32("ProbPhysicalSpecial2", 0)
        physical_special1 = npc.template.parameters.get_object("PhysicalSpecial1", SkillHolder)
        physical_special2 = npc.template.parameters.get_object("PhysicalSpecial2", SkillHolder)

        if (Rnd.rand(100) < 30 && npc.id == DEINO) || (npc.id == ORNIT && npc.script_value?(0))
          mob.clear_aggro_list
          npc.script_value = 1
          npc.set_running

          distance = 3000
          heading = Util.calculate_heading_from(creature, npc)
          angle = Util.convert_heading_to_degree(heading)
          radian = Math.to_radians(angle)
          sin = Math.sin(radian)
          cos = Math.cos(radian)
          new_x = (npc.x + (cos * distance)).to_i
          new_y = (npc.y + (sin * distance)).to_i
          loc = GeoData.move_check(*npc.xyz, new_x, new_y, npc.z, npc.instance_id)
          npc.set_intention(AI::MOVE_TO, loc) # L2J gives a 0 as a third arg
        elsif ag_type == 1
          if Rnd.rand(100) <= prob_physical_special1 * npc.variables.get_i32("SKILL_MULTIPLER")
            unless npc.skill_disabled?(physical_special1.skill_id)
              npc.target = creature
              npc.do_cast(physical_special1)
            end
          elsif Rnd.rand(100) <= prob_physical_special2 * npc.variables.get_i32("SKILL_MULTIPLER")
            unless npc.skill_disabled?(physical_special2.skill)
              npc.target = creature
              npc.do_cast(physical_special2)
            end
          end
        end
      end
    elsif VEGETABLE.includes?(creature.id)
      npc.target = creature
      npc.do_cast(CREW_SKILL)
      npc.running = true
      npc.set_intention(AI::ATTACK, creature)
    end

    super
  end

  def on_aggro_range_enter(npc, pc, is_summon)
    if npc.script_value?(0)
      npc.script_value = 1
      broadcast_npc_say(npc, Say2::NPC_ALL, "?")
      npc.as(L2Attackable).clear_aggro_list
      start_quest_timer("TREX_ATTACK", 6000, npc, pc)
    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon)
    if npc.id == EGG
      if Rnd.rand(100) <= 80 && npc.script_value?(0)
        npc.script_value = 1
        playable = (is_summon ? attacker.summon : attacker) || attacker
        npc.known_list.each_character(500) do |char|
          if char.is_a?(L2Attackable) && Rnd.bool
            add_attack_desire(char, playable)
          end
        end
      end
    elsif TREX.includes?(npc.id)
      mob = npc.as(L2Attackable)
      target = mob.most_hated

      if npc.hp_percent <= 30
        if npc.script_value?(3)
          unless npc.skill_disabled?(SELFBUFF1.skill)
            npc.do_cast(SELFBUFF1)
          end
        elsif npc.script_value?(1)
          unless npc.skill_disabled?(SELFBUFF2.skill)
            npc.do_cast(SELFBUFF2)
          end
        end
      elsif npc.hp_percent <= 60 && npc.script_value?(3)
        unless npc.skill_disabled?(SELFBUFF1.skill)
          npc.do_cast(SELFBUFF1)
        end
      end

      if Util.calculate_distance(npc, attacker, true, false) > 100
        if !npc.skill_disabled?(LONGRANGEDMAGIC1.skill) && Rnd.rand(100) <= 10 * npc.script_value
          npc.target = attacker
          npc.do_cast(LONGRANGEDMAGIC1)
        end
      else
        if !npc.skill_disabled?(LONGRANGEDMAGIC1.skill) && Rnd.rand(100) <= 10 * npc.script_value
          npc.target = target
          npc.do_cast(LONGRANGEDMAGIC1)
        end
        if !npc.skill_disabled?(PHYSICALSPECIAL1.skill) && Rnd.rand(100) <= 5 * npc.script_value
          npc.target = target
          npc.do_cast(PHYSICALSPECIAL1)
        end
        if !npc.skill_disabled?(PHYSICALSPECIAL2.skill) && Rnd.rand(100) <= 3 * npc.script_value
          npc.target = target
          npc.do_cast(PHYSICALSPECIAL2)
        end
        if !npc.skill_disabled?(PHYSICALSPECIAL3.skill) && Rnd.rand(100) <= 5 * npc.script_value
          npc.target = target
          npc.do_cast(PHYSICALSPECIAL3)
        end
      end
    else
      prob_physical_special1 = npc.template.parameters.get_i32("ProbPhysicalSpecial1", 0)
      prob_physical_special2 = npc.template.parameters.get_i32("ProbPhysicalSpecial2", 0)
      self_range_buff1 = npc.template.parameters.get_object("SelfRangeBuff1", SkillHolder)
      physical_special1 = npc.template.parameters.get_object("PhysicalSpecial1", SkillHolder)
      physical_special2 = npc.template.parameters.get_object("PhysicalSpecial2", SkillHolder)

      if npc.hp_percent <= 50
        npc.variables["SKILL_MULTIPLER"] = 2
      else
        npc.variables["SKILL_MULTIPLER"] = 1
      end

      if npc.hp_percent <= 30 && npc.variables.get_i32("SELFBUFF_USED") == 0
       mob = npc.as(L2Attackable)
        target = mob.most_hated
        mob.clear_aggro_list
        unless npc.skill_disabled?(self_range_buff1.skill_id)
          npc.variables["SELFBUFF_USED"] = 1
          npc.do_cast(self_range_buff1)
          npc.running = true
          npc.set_intention(AI::ATTACK, target)
        end
      end

      if target
        if Rnd.rand(100) <= prob_physical_special1 * npc.variables.get_i32("SKILL_MULTIPLER")
          unless npc.skill_disabled?(physical_special1.skill)
            npc.target = target
            npc.do_cast(physical_special1)
          end
        end
        if Rnd.rand(100) <= prob_physical_special2 * npc.variables.get_i32("SKILL_MULTIPLER")
          unless npc.skill_disabled?(physical_special2.skill)
            npc.target = target
            npc.do_cast(physical_special2)
          end
        end
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    if npc.id == DEINO || (npc.id == ORNIT && !npc.script_value?(1))
      return super
    end
    if npc.id == SAILREN || Rnd.rand(100) < 3
      pc = (npc.id == SAILREN ? get_random_party_member(killer) : killer).not_nil!
      if pc.inventory.get_size(false) <= pc.inventory_limit * 0.8
        give_items(pc, DEINONYCHUS, 1)
        unless summon_item = pc.inventory.get_item_by_item_id(DEINONYCHUS)
          warn "#{pc.name} was expected to have item with id #{DEINONYCHUS}."
          return super
        end
        handler = ItemHandler[summon_item.etc_item]
        if handler && !pc.has_pet?
          handler.use_item(pc, summon_item, true)
        end
        show_on_screen_msg(pc, NpcString::LIFE_STONE_FROM_THE_BEGINNING_ACQUIRED, 2, 6000)
      else
        show_on_screen_msg(pc, NpcString::WHEN_INVENTORY_WEIGHT_NUMBER_ARE_MORE_THAN_80_THE_LIFE_STONE_FROM_THE_BEGINNING_CANNOT_BE_ACQUIRED, 2, 6000)
      end
    end

    super
  end

  def on_spawn(npc)
    if SPRIGNANT.includes?(npc.id)
      start_quest_timer("USE_SKILL", 15000, npc, nil)
    elsif TREX.includes?(npc.id)
      collect_ghost = npc.template.parameters.get_i32("CollectGhost", 0)
      collect_despawn = npc.template.parameters.get_i32("CollectGhostDespawnTime", 30)

      if collect_ghost == 1
        start_quest_timer("GHOST_DESPAWN", collect_despawn * 60000, npc, nil)
      end
    else
      npc.variables["SELFBUFF_USED"] = 0
      npc.variables["SKILL_MULTIPLER"] = 1
    end

    super
  end
end