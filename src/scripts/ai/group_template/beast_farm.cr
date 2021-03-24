class Scripts::BeastFarm < AbstractNpcAI
  private record TamedBeast, name : String, skills : Array(SkillHolder)

  private GOLDEN_SPICE = 15474
  private CRYSTAL_SPICE = 15475
  private SKILL_GOLDEN_SPICE = 9049
  private SKILL_CRYSTAL_SPICE = 9050
  private SKILL_BLESSED_GOLDEN_SPICE = 9051
  private SKILL_BLESSED_CRYSTAL_SPICE = 9052
  private SKILL_SGRADE_GOLDEN_SPICE = 9053
  private SKILL_SGRADE_CRYSTAL_SPICE = 9054
  private TAMED_BEASTS = {
    18869,
    18870,
    18871,
    18872
  }
  private TAME_CHANCE = 20
  private SPECIAL_SPICE_CHANCES = {
    33,
    75
  }

  # all mobs that can eat...
  private FEEDABLE_BEASTS = {
    # Kookaburras
    18873,
    18874,
    18875,
    18876,
    18877,
    18878,
    18879,
    # Cougars
    18880,
    18881,
    18882,
    18883,
    18884,
    18885,
    18886,
    # Buffalos
    18887,
    18888,
    18889,
    18890,
    18891,
    18892,
    18893,
    # Grendels
    18894,
    18895,
    18896,
    18897,
    18898,
    18899,
    18900
  }

  private FEED_INFO = Concurrent::Map(Int32, Int32).new
  private GROWTH_CAPABLE_MONSTERS = {} of Int32 => GrowthCapableMob
  private TAMED_BEAST_DATA = [] of TamedBeast

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_skill_see_id(FEEDABLE_BEASTS)
    add_kill_id(FEEDABLE_BEASTS)

    # Kookabura
    temp = GrowthCapableMob.new(100, 0, 18869)
    temp.add_npc_id_for_skill_id(SKILL_GOLDEN_SPICE, 18874)
    temp.add_npc_id_for_skill_id(SKILL_CRYSTAL_SPICE, 18875)
    temp.add_npc_id_for_skill_id(SKILL_BLESSED_GOLDEN_SPICE, 18869)
    temp.add_npc_id_for_skill_id(SKILL_BLESSED_CRYSTAL_SPICE, 18869)
    temp.add_npc_id_for_skill_id(SKILL_SGRADE_GOLDEN_SPICE, 18878)
    temp.add_npc_id_for_skill_id(SKILL_SGRADE_CRYSTAL_SPICE, 18879)
    GROWTH_CAPABLE_MONSTERS[18873] = temp

    temp = GrowthCapableMob.new(40, 1, 18869)
    temp.add_npc_id_for_skill_id(SKILL_GOLDEN_SPICE, 18876)
    GROWTH_CAPABLE_MONSTERS[18874] = temp

    temp = GrowthCapableMob.new(40, 1, 18869)
    temp.add_npc_id_for_skill_id(SKILL_CRYSTAL_SPICE, 18877)
    GROWTH_CAPABLE_MONSTERS[18875] = temp

    temp = GrowthCapableMob.new(25, 2, 18869)
    temp.add_npc_id_for_skill_id(SKILL_GOLDEN_SPICE, 18878)
    GROWTH_CAPABLE_MONSTERS[18876] = temp

    temp = GrowthCapableMob.new(25, 2, 18869)
    temp.add_npc_id_for_skill_id(SKILL_CRYSTAL_SPICE, 18879)
    GROWTH_CAPABLE_MONSTERS[18877] = temp

    # Cougar
    temp = GrowthCapableMob.new(100, 0, 18870)
    temp.add_npc_id_for_skill_id(SKILL_GOLDEN_SPICE, 18881)
    temp.add_npc_id_for_skill_id(SKILL_CRYSTAL_SPICE, 18882)
    temp.add_npc_id_for_skill_id(SKILL_BLESSED_GOLDEN_SPICE, 18870)
    temp.add_npc_id_for_skill_id(SKILL_BLESSED_CRYSTAL_SPICE, 18870)
    temp.add_npc_id_for_skill_id(SKILL_SGRADE_GOLDEN_SPICE, 18885)
    temp.add_npc_id_for_skill_id(SKILL_SGRADE_CRYSTAL_SPICE, 18886)
    GROWTH_CAPABLE_MONSTERS[18880] = temp

    temp = GrowthCapableMob.new(40, 1, 18870)
    temp.add_npc_id_for_skill_id(SKILL_GOLDEN_SPICE, 18883)
    GROWTH_CAPABLE_MONSTERS[18881] = temp

    temp = GrowthCapableMob.new(40, 1, 18870)
    temp.add_npc_id_for_skill_id(SKILL_CRYSTAL_SPICE, 18884)
    GROWTH_CAPABLE_MONSTERS[18882] = temp

    temp = GrowthCapableMob.new(25, 2, 18870)
    temp.add_npc_id_for_skill_id(SKILL_GOLDEN_SPICE, 18885)
    GROWTH_CAPABLE_MONSTERS[18883] = temp

    temp = GrowthCapableMob.new(25, 2, 18870)
    temp.add_npc_id_for_skill_id(SKILL_CRYSTAL_SPICE, 18886)
    GROWTH_CAPABLE_MONSTERS[18884] = temp

    # Buffalo
    temp = GrowthCapableMob.new(100, 0, 18871)
    temp.add_npc_id_for_skill_id(SKILL_GOLDEN_SPICE, 18888)
    temp.add_npc_id_for_skill_id(SKILL_CRYSTAL_SPICE, 18889)
    temp.add_npc_id_for_skill_id(SKILL_BLESSED_GOLDEN_SPICE, 18871)
    temp.add_npc_id_for_skill_id(SKILL_BLESSED_CRYSTAL_SPICE, 18871)
    temp.add_npc_id_for_skill_id(SKILL_SGRADE_GOLDEN_SPICE, 18892)
    temp.add_npc_id_for_skill_id(SKILL_SGRADE_CRYSTAL_SPICE, 18893)
    GROWTH_CAPABLE_MONSTERS[18887] = temp

    temp = GrowthCapableMob.new(40, 1, 18871)
    temp.add_npc_id_for_skill_id(SKILL_GOLDEN_SPICE, 18890)
    GROWTH_CAPABLE_MONSTERS[18888] = temp

    temp = GrowthCapableMob.new(40, 1, 18871)
    temp.add_npc_id_for_skill_id(SKILL_CRYSTAL_SPICE, 18891)
    GROWTH_CAPABLE_MONSTERS[18889] = temp

    temp = GrowthCapableMob.new(25, 2, 18871)
    temp.add_npc_id_for_skill_id(SKILL_GOLDEN_SPICE, 18892)
    GROWTH_CAPABLE_MONSTERS[18890] = temp

    temp = GrowthCapableMob.new(25, 2, 18871)
    temp.add_npc_id_for_skill_id(SKILL_CRYSTAL_SPICE, 18893)
    GROWTH_CAPABLE_MONSTERS[18891] = temp

    # Grendel
    temp = GrowthCapableMob.new(100, 0, 18872)
    temp.add_npc_id_for_skill_id(SKILL_GOLDEN_SPICE, 18895)
    temp.add_npc_id_for_skill_id(SKILL_CRYSTAL_SPICE, 18896)
    temp.add_npc_id_for_skill_id(SKILL_BLESSED_GOLDEN_SPICE, 18872)
    temp.add_npc_id_for_skill_id(SKILL_BLESSED_CRYSTAL_SPICE, 18872)
    temp.add_npc_id_for_skill_id(SKILL_SGRADE_GOLDEN_SPICE, 18899)
    temp.add_npc_id_for_skill_id(SKILL_SGRADE_CRYSTAL_SPICE, 18900)
    GROWTH_CAPABLE_MONSTERS[18894] = temp

    temp = GrowthCapableMob.new(40, 1, 18872)
    temp.add_npc_id_for_skill_id(SKILL_GOLDEN_SPICE, 18897)
    GROWTH_CAPABLE_MONSTERS[18895] = temp

    temp = GrowthCapableMob.new(40, 1, 18872)
    temp.add_npc_id_for_skill_id(SKILL_CRYSTAL_SPICE, 18898)
    GROWTH_CAPABLE_MONSTERS[18896] = temp

    temp = GrowthCapableMob.new(25, 2, 18872)
    temp.add_npc_id_for_skill_id(SKILL_GOLDEN_SPICE, 18899)
    GROWTH_CAPABLE_MONSTERS[18897] = temp

    temp = GrowthCapableMob.new(25, 2, 18872)
    temp.add_npc_id_for_skill_id(SKILL_CRYSTAL_SPICE, 18900)
    GROWTH_CAPABLE_MONSTERS[18898] = temp

    # Tamed beasts data
    TAMED_BEAST_DATA << TamedBeast.new("%name% of Focus", [SkillHolder.new(6432), SkillHolder.new(6668)])
    TAMED_BEAST_DATA << TamedBeast.new("%name% of Guiding", [SkillHolder.new(6433), SkillHolder.new(6670)])
    TAMED_BEAST_DATA << TamedBeast.new("%name% of Swifth", [SkillHolder.new(6434), SkillHolder.new(6667)])
    TAMED_BEAST_DATA << TamedBeast.new("Berserker %name%", [SkillHolder.new(6671)])
    TAMED_BEAST_DATA << TamedBeast.new("%name% of Protect", [SkillHolder.new(6669), SkillHolder.new(6672)])
    TAMED_BEAST_DATA << TamedBeast.new("%name% of Vigor", [SkillHolder.new(6431), SkillHolder.new(6666)])
  end

  def spawn_next(npc, pc, next_npc_id, food)
    # remove the feedinfo of the mob that got despawned, if any
    if tmp = FEED_INFO[npc.l2id]?
      if tmp == pc.l2id
        FEED_INFO.delete(npc.l2id)
      end
    end
    # despawn the old mob
    # TODO: same code? FIXED?
    # /*
    #  * if _GrowthCapableMobs.get(npc.npc_id).growth_level == 0) { npc.delete_me; end else {
    #  */
    npc.delete_me
    # }

    # if this is finally a trained mob, then despawn any other trained mobs that the
    # pc might have and initialize the Tamed Beast.
    if TAMED_BEASTS.includes?(next_npc_id)
      next_npc = L2TamedBeastInstance.new(next_npc_id, pc, food, *npc.xyz, true)

      beast = TAMED_BEAST_DATA.sample(random: Rnd)
      name = beast.name
      case next_npc_id
      when 18869
        name = name.sub("%name%", "Alpine Kookaburra")
      when 18870
        name = name.sub("%name%", "Alpine Cougar")
      when 18871
        name = name.sub("%name%", "Alpine Buffalo")
      when 18872
        name = name.sub("%name%", "Alpine Grendel")
      end

      next_npc.name = name
      next_npc.broadcast_packet(NpcInfo.new(next_npc, pc))
      next_npc.set_running

      beast.skills.each do |sh|
        next_npc.add_beast_skill(sh.skill)
      end

      Scripts::Q00020_BringUpWithLove.check_jewel_of_innocence(pc)
    else
      # if not trained, the newly spawned mob will automatically be agro against its feeder
      # (what happened to "never bite the hand that feeds you" anyway?!)
      next_npc = add_spawn(next_npc_id, npc).as(L2Attackable)

      # register the pc in the feedinfo for the mob that just spawned
      FEED_INFO[next_npc.l2id] = pc.l2id
      next_npc.set_running
      next_npc.add_damage_hate(pc, 0, 99999)
      next_npc.set_intention(AI::ATTACK, pc)

      pc.target = next_npc
    end
  end

  def on_skill_see(npc, caster, skill, targets, is_summon)
    # this behavior is only run when the target of skill is the passed npc (chest)
    # i.e. when the player is attempting to open the chest using a skill
    unless targets.includes?(npc)
      return super
    end
    # gather some values on local variables
    npc_id = npc.id
    skill_id = skill.id
    # check if the npc and skills used are valid for this script. Exit if invalid.
    if !FEEDABLE_BEASTS.includes?(npc_id) || (skill_id != SKILL_GOLDEN_SPICE && skill_id != SKILL_CRYSTAL_SPICE && skill_id != SKILL_BLESSED_GOLDEN_SPICE && skill_id != SKILL_BLESSED_CRYSTAL_SPICE && skill_id != SKILL_SGRADE_GOLDEN_SPICE && skill_id != SKILL_SGRADE_CRYSTAL_SPICE)
      return super
    end
    # check if this can be done in ruby
    # if !FEEDABLE_BEASTS.includes?(npc_id) || !skill_id.in?(SKILL_GOLDEN_SPICE, SKILL_CRYSTAL_SPICE, SKILL_BLESSED_GOLDEN_SPICE, SKILL_BLESSED_CRYSTAL_SPICE, SKILL_SGRADE_GOLDEN_SPICE, SKILL_SGRADE_CRYSTAL_SPICE)
    #   return super
    # end

    # first gather some values on local variables
    l2id = npc.l2id
    growth_level = 3 # if a mob is in FEEDABLE_BEASTS but not in _GrowthCapableMobs, then it's at max growth (3)
    if tmp = GROWTH_CAPABLE_MONSTERS[npc_id]?
      growth_level = tmp.growth_level
    end

    # prevent exploit which allows 2 players to simultaneously raise the same 0-growth beast
    # If the mob is at 0th level (when it still listens to all feeders) lock it to the first feeder!
    if growth_level == 0 && FEED_INFO.has_key?(l2id)
      return super
    end

    FEED_INFO[l2id] = caster.l2id

    # display the social action of the beast eating the food.
    npc.broadcast_social_action(2)

    food = 0
    if skill_id == SKILL_GOLDEN_SPICE || skill_id == SKILL_BLESSED_GOLDEN_SPICE
      food = GOLDEN_SPICE
    elsif skill_id == SKILL_CRYSTAL_SPICE || skill_id == SKILL_BLESSED_CRYSTAL_SPICE
      food = CRYSTAL_SPICE
    end

    # if this pet can't grow, it's all done.
    if tmp = GROWTH_CAPABLE_MONSTERS[npc_id]?
      # do nothing if this mob doesn't eat the specified food (food gets consumed but has no effect).
      new_npc_id = tmp.get_leveled_npc_id(skill_id)
      if new_npc_id == -1
        if growth_level == 0
          FEED_INFO.delete(l2id)
          npc.set_running
          npc.as(L2Attackable).add_damage_hate(caster, 0, 1)
          npc.set_intention(AI::ATTACK, caster)
        end
        return super
      elsif growth_level > 0 && FEED_INFO[l2id] != caster.l2id
        # check if this is the same player as the one who raised it from growth 0.
        # if no, then do not allow a chance to raise the pet (food gets consumed but has no effect).
        return super
      end
      spawn_next(npc, caster, new_npc_id, food)
    else
      caster.send_message("The beast spit out the feed instead of eating it.")
      npc.drop_item(caster, food, 1)
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    FEED_INFO.delete(npc.l2id)
    super
  end

  # all mobs that grow by eating
  private class GrowthCapableMob
    @skill_success_npc_id_list = {} of Int32 => Int32

    getter growth_level

    initializer chance : Int32, growth_level : Int32, tame_npc_id : Int32

    def add_npc_id_for_skill_id(skill_id, npc_id)
      @skill_success_npc_id_list[skill_id] = npc_id
    end

    def get_leveled_npc_id(skill_id)
      if !@skill_success_npc_id_list.has_key?(skill_id)
        -1
      elsif skill_id.in?(SKILL_BLESSED_GOLDEN_SPICE, SKILL_BLESSED_CRYSTAL_SPICE, SKILL_SGRADE_GOLDEN_SPICE, SKILL_SGRADE_CRYSTAL_SPICE)
        if Rnd.rand(100) < SPECIAL_SPICE_CHANCES[0]
          if Rnd.rand(100) < SPECIAL_SPICE_CHANCES[1]
            return @skill_success_npc_id_list[skill_id]
          elsif skill_id.in?(SKILL_BLESSED_GOLDEN_SPICE, SKILL_SGRADE_GOLDEN_SPICE)
            return @skill_success_npc_id_list[SKILL_GOLDEN_SPICE]
          else
            return @skill_success_npc_id_list[SKILL_CRYSTAL_SPICE]
          end
        end

        -1
      elsif @growth_level == 2 && Rnd.rand(100) < TAME_CHANCE
        @tame_npc_id
      elsif Rnd.rand(100) < @chance
        @skill_success_npc_id_list[skill_id]
      else
        -1
      end
    end
  end
end
