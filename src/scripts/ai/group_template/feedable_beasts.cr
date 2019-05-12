class Scripts::FeedableBeasts < AbstractNpcAI
  private GOLDEN_SPICE = 6643
  private CRYSTAL_SPICE = 6644
  private SKILL_GOLDEN_SPICE = 2188
  private SKILL_CRYSTAL_SPICE = 2189
  private FOOD_SKILL_DIFF = GOLDEN_SPICE - SKILL_GOLDEN_SPICE
  # Tamed Wild Beasts
  private TRAINED_BUFFALO1 = 16013
  private TRAINED_BUFFALO2 = 16014
  private TRAINED_COUGAR1 = 16015
  private TRAINED_COUGAR2 = 16016
  private TRAINED_KOOKABURRA1 = 16017
  private TRAINED_KOOKABURRA2 = 16018
  # private TRAINED_TINY_BABY_BUFFALO = 16020 # TODO: Implement.
  # private TRAINED_TINY_BABY_COUGAR = 16022 # TODO: Implement.
  # private TRAINED_TINY_BABY_KOOKABURRA = 16024 # TODO: Implement.
  private TAMED_BEASTS = {
    TRAINED_BUFFALO1, TRAINED_BUFFALO2, TRAINED_COUGAR1, TRAINED_COUGAR2,
    TRAINED_KOOKABURRA1, TRAINED_KOOKABURRA2
  }
  # all mobs that can eat...
  private FEEDABLE_BEASTS = {
    21451, 21452, 21453, 21454, 21455, 21456, 21457, 21458, 21459, 21460,
    21461, 21462, 21463, 21464, 21465, 21466, 21467, 21468, 21469, 21470,
    21471, 21472, 21473, 21474, 21475, 21476, 21477, 21478, 21479, 21480,
    21481, 21482, 21483, 21484, 21485, 21486, 21487, 21488, 21489, 21490,
    21491, 21492, 21493, 21494, 21495, 21496, 21497, 21498, 21499, 21500,
    21501, 21502, 21503, 21504, 21505, 21506, 21507, 21824, 21825, 21826,
    21827, 21828, 21829,
    TRAINED_BUFFALO1, TRAINED_BUFFALO2, TRAINED_COUGAR1, TRAINED_COUGAR2,
    TRAINED_KOOKABURRA1, TRAINED_KOOKABURRA2
  }

  private MAD_COW_POLYMORPH = {
    21824 => 21468,
    21825 => 21469,
    21826 => 21487,
    21827 => 21488,
    21828 => 21506,
    21829 => 21507
  }

  private TEXT = {
    {
      NpcString::WHAT_DID_YOU_JUST_DO_TO_ME,
      NpcString::ARE_YOU_TRYING_TO_TAME_ME_DONT_DO_THAT,
      NpcString::DONT_GIVE_SUCH_A_THING_YOU_CAN_ENDANGER_YOURSELF,
      NpcString::YUCK_WHAT_IS_THIS_IT_TASTES_TERRIBLE,
      NpcString::IM_HUNGRY_GIVE_ME_A_LITTLE_MORE_PLEASE,
      NpcString::WHAT_IS_THIS_IS_THIS_EDIBLE,
      NpcString::DONT_WORRY_ABOUT_ME,
      NpcString::THANK_YOU_THAT_WAS_DELICIOUS,
      NpcString::I_THINK_I_AM_STARTING_TO_LIKE_YOU,
      NpcString::EEEEEK_EEEEEK
    },
    {
      NpcString::DONT_KEEP_TRYING_TO_TAME_ME_I_DONT_WANT_TO_BE_TAMED,
      NpcString::IT_IS_JUST_FOOD_TO_ME_ALTHOUGH_IT_MAY_ALSO_BE_YOUR_HAND,
      NpcString::IF_I_KEEP_EATING_LIKE_THIS_WONT_I_BECOME_FAT_CHOMP_CHOMP,
      NpcString::WHY_DO_YOU_KEEP_FEEDING_ME,
      NpcString::DONT_TRUST_ME_IM_AFRAID_I_MAY_BETRAY_YOU_LATER
    },
    {
      NpcString::GRRRRR,
      NpcString::YOU_BROUGHT_THIS_UPON_YOURSELF,
      NpcString::I_FEEL_STRANGE_I_KEEP_HAVING_THESE_EVIL_THOUGHTS,
      NpcString::ALAS_SO_THIS_IS_HOW_IT_ALL_ENDS,
      NpcString::I_DONT_FEEL_SO_GOOD_OH_MY_MIND_IS_VERY_TROUBLED
    }
  }

  private TAMED_TEXT = {
    NpcString::S1_SO_WHAT_DO_YOU_THINK_IT_IS_LIKE_TO_BE_TAMED,
    NpcString::S1_WHENEVER_I_SEE_SPICE_I_THINK_I_WILL_MISS_YOUR_HAND_THAT_USED_TO_FEED_IT_TO_ME,
    NpcString::S1_DONT_GO_TO_THE_VILLAGE_I_DONT_HAVE_THE_STRENGTH_TO_FOLLOW_YOU,
    NpcString::THANK_YOU_FOR_TRUSTING_ME_S1_I_HOPE_I_WILL_BE_HELPFUL_TO_YOU,
    NpcString::S1_WILL_I_BE_ABLE_TO_HELP_YOU,
    NpcString::I_GUESS_ITS_JUST_MY_ANIMAL_MAGNETISM,
    NpcString::TOO_MUCH_SPICY_FOOD_MAKES_ME_SWEAT_LIKE_A_BEAST,
    NpcString::ANIMALS_NEED_LOVE_TOO
  }

  private FEED_INFO = {} of Int32 => Int32
  private GROWTH_CAPABLE_MONSTERS = {} of Int32 => GrowthCapableMob

  # all mobs that grow by eating
  private struct GrowthCapableMob
    @spice_to_mob = {} of Int32 => Array(Array(Int32))

    getter_initializer growth_level: Int32, chance: Int32

    def add_mobs(spice, mobs)
      @spice_to_mob[spice] = mobs
    end

    def get_mob(spice,mob_type,class_type)
      @spice_to_mob.dig?(spice, mob_type, class_type)
    end

    def get_rand_mob(spice)
      @spice_to_mob[spice][0].sample
    end
  end

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_kill_id(FEEDABLE_BEASTS)
    add_skill_see_id(FEEDABLE_BEASTS)

    # TODO: no grendels?

    kookabura_0_gold = [[21452, 21453, 21454, 21455]]
    kookabura_0_crystal = [[21456, 21457, 21458, 21459]]
    kookabura_1_gold_1= [[21460, 21462]]
    kookabura_1_gold_2 = [[21461, 21463]]
    kookabura_1_crystal_1 = [[21464, 21466]]
    kookabura_1_crystal_2 = [[21465, 21467]]
    kookabura_2_1 = [[21468, 21824], [TRAINED_KOOKABURRA1, TRAINED_KOOKABURRA2]]
    kookabura_2_2 = [[21469, 21825], [TRAINED_KOOKABURRA1, TRAINED_KOOKABURRA2]]

    buffalo_0_gold = [[21471, 21472, 21473, 21474]]
    buffalo_0_crystal = [[21475, 21476, 21477, 21478]]
    buffalo_1_gold_1 = [[21479, 21481]]
    buffalo_1_gold_2 = [[21481, 21482]]
    buffalo_1_crystal_1 = [[21483, 21485]]
    buffalo_1_crystal_2 = [[21484, 21486]]
    buffalo_2_1 = [[21487, 21826], [TRAINED_BUFFALO1, TRAINED_BUFFALO2]]
    buffalo_2_2 = [[21488, 21827], [TRAINED_BUFFALO1, TRAINED_BUFFALO2]]

    cougar_0_gold = [[21490, 21491, 21492, 21493]]
    cougar_0_crystal = [[21494, 21495, 21496, 21497]]
    cougar_1_gold_1 = [[21498, 21500]]
    cougar_1_gold_2 = [[21499, 21501]]
    cougar_1_crystal_1 = [[21502, 21504]]
    cougar_1_crystal_2 = [[21503, 21505]]
    cougar_2_1 = [[21506, 21828], [TRAINED_COUGAR1, TRAINED_COUGAR2]]
    cougar_2_2 = [[21507, 21829], [TRAINED_COUGAR1, TRAINED_COUGAR2]]

    # Alpen Kookabura
    temp = GrowthCapableMob.new(0, 100)
    temp.add_mobs(GOLDEN_SPICE, kookabura_0_gold)
    temp.add_mobs(CRYSTAL_SPICE, kookabura_0_crystal)
    GROWTH_CAPABLE_MONSTERS[21451] = temp

    temp = GrowthCapableMob.new(1, 40)
    temp.add_mobs(GOLDEN_SPICE, kookabura_1_gold_1)
    GROWTH_CAPABLE_MONSTERS[21452] = temp
    GROWTH_CAPABLE_MONSTERS[21454] = temp

    temp = GrowthCapableMob.new(1, 40)
    temp.add_mobs(GOLDEN_SPICE, kookabura_1_gold_2)
    GROWTH_CAPABLE_MONSTERS[21453] = temp
    GROWTH_CAPABLE_MONSTERS[21455] = temp

    temp = GrowthCapableMob.new(1, 40)
    temp.add_mobs(CRYSTAL_SPICE, kookabura_1_crystal_1)
    GROWTH_CAPABLE_MONSTERS[21456] = temp
    GROWTH_CAPABLE_MONSTERS[21458] = temp

    temp = GrowthCapableMob.new(1, 40)
    temp.add_mobs(CRYSTAL_SPICE, kookabura_1_crystal_2)
    GROWTH_CAPABLE_MONSTERS[21457] = temp
    GROWTH_CAPABLE_MONSTERS[21459] = temp

    temp = GrowthCapableMob.new(2, 25)
    temp.add_mobs(GOLDEN_SPICE, kookabura_2_1)
    GROWTH_CAPABLE_MONSTERS[21460] = temp
    GROWTH_CAPABLE_MONSTERS[21462] = temp

    temp = GrowthCapableMob.new(2, 25)
    temp.add_mobs(GOLDEN_SPICE, kookabura_2_2)
    GROWTH_CAPABLE_MONSTERS[21461] = temp
    GROWTH_CAPABLE_MONSTERS[21463] = temp

    temp = GrowthCapableMob.new(2, 25)
    temp.add_mobs(CRYSTAL_SPICE, kookabura_2_1)
    GROWTH_CAPABLE_MONSTERS[21464] = temp
    GROWTH_CAPABLE_MONSTERS[21466] = temp

    temp = GrowthCapableMob.new(2, 25)
    temp.add_mobs(CRYSTAL_SPICE, kookabura_2_2)
    GROWTH_CAPABLE_MONSTERS[21465] = temp
    GROWTH_CAPABLE_MONSTERS[21467] = temp

    # Alpen Buffalo
    temp = GrowthCapableMob.new(0, 100)
    temp.add_mobs(GOLDEN_SPICE, buffalo_0_gold)
    temp.add_mobs(CRYSTAL_SPICE, buffalo_0_crystal)
    GROWTH_CAPABLE_MONSTERS[21470] = temp

    temp = GrowthCapableMob.new(1, 40)
    temp.add_mobs(GOLDEN_SPICE, buffalo_1_gold_1)
    GROWTH_CAPABLE_MONSTERS[21471] = temp
    GROWTH_CAPABLE_MONSTERS[21473] = temp

    temp = GrowthCapableMob.new(1, 40)
    temp.add_mobs(GOLDEN_SPICE, buffalo_1_gold_2)
    GROWTH_CAPABLE_MONSTERS[21472] = temp
    GROWTH_CAPABLE_MONSTERS[21474] = temp

    temp = GrowthCapableMob.new(1, 40)
    temp.add_mobs(CRYSTAL_SPICE, buffalo_1_crystal_1)
    GROWTH_CAPABLE_MONSTERS[21475] = temp
    GROWTH_CAPABLE_MONSTERS[21477] = temp

    temp = GrowthCapableMob.new(1, 40)
    temp.add_mobs(CRYSTAL_SPICE, buffalo_1_crystal_2)
    GROWTH_CAPABLE_MONSTERS[21476] = temp
    GROWTH_CAPABLE_MONSTERS[21478] = temp

    temp = GrowthCapableMob.new(2, 25)
    temp.add_mobs(GOLDEN_SPICE, buffalo_2_1)
    GROWTH_CAPABLE_MONSTERS[21479] = temp
    GROWTH_CAPABLE_MONSTERS[21481] = temp

    temp = GrowthCapableMob.new(2, 25)
    temp.add_mobs(GOLDEN_SPICE, buffalo_2_2)
    GROWTH_CAPABLE_MONSTERS[21480] = temp
    GROWTH_CAPABLE_MONSTERS[21482] = temp

    temp = GrowthCapableMob.new(2, 25)
    temp.add_mobs(CRYSTAL_SPICE, buffalo_2_1)
    GROWTH_CAPABLE_MONSTERS[21483] = temp
    GROWTH_CAPABLE_MONSTERS[21485] = temp

    temp = GrowthCapableMob.new(2, 25)
    temp.add_mobs(CRYSTAL_SPICE, buffalo_2_2)
    GROWTH_CAPABLE_MONSTERS[21484] = temp
    GROWTH_CAPABLE_MONSTERS[21486] = temp

    # Alpen Cougar
    temp = GrowthCapableMob.new(0, 100)
    temp.add_mobs(GOLDEN_SPICE, cougar_0_gold)
    temp.add_mobs(CRYSTAL_SPICE, cougar_0_crystal)
    GROWTH_CAPABLE_MONSTERS[21489] = temp

    temp = GrowthCapableMob.new(1, 40)
    temp.add_mobs(GOLDEN_SPICE, cougar_1_gold_1)
    GROWTH_CAPABLE_MONSTERS[21490] = temp
    GROWTH_CAPABLE_MONSTERS[21492] = temp

    temp = GrowthCapableMob.new(1, 40)
    temp.add_mobs(GOLDEN_SPICE, cougar_1_gold_2)
    GROWTH_CAPABLE_MONSTERS[21491] = temp
    GROWTH_CAPABLE_MONSTERS[21493] = temp

    temp = GrowthCapableMob.new(1, 40)
    temp.add_mobs(CRYSTAL_SPICE, cougar_1_crystal_1)
    GROWTH_CAPABLE_MONSTERS[21494] = temp
    GROWTH_CAPABLE_MONSTERS[21496] = temp

    temp = GrowthCapableMob.new(1, 40)
    temp.add_mobs(CRYSTAL_SPICE, cougar_1_crystal_2)
    GROWTH_CAPABLE_MONSTERS[21495] = temp
    GROWTH_CAPABLE_MONSTERS[21497] = temp

    temp = GrowthCapableMob.new(2, 25)
    temp.add_mobs(GOLDEN_SPICE, cougar_2_1)
    GROWTH_CAPABLE_MONSTERS[21498] = temp
    GROWTH_CAPABLE_MONSTERS[21500] = temp

    temp = GrowthCapableMob.new(2, 25)
    temp.add_mobs(GOLDEN_SPICE, cougar_2_2)
    GROWTH_CAPABLE_MONSTERS[21499] = temp
    GROWTH_CAPABLE_MONSTERS[21501] = temp

    temp = GrowthCapableMob.new(2, 25)
    temp.add_mobs(CRYSTAL_SPICE, cougar_2_1)
    GROWTH_CAPABLE_MONSTERS[21502] = temp
    GROWTH_CAPABLE_MONSTERS[21504] = temp

    temp = GrowthCapableMob.new(2, 25)
    temp.add_mobs(CRYSTAL_SPICE, cougar_2_2)
    GROWTH_CAPABLE_MONSTERS[21503] = temp
    GROWTH_CAPABLE_MONSTERS[21505] = temp
  end

  private def spawn_next(npc, growth_level, player, food)
    npc_id = npc.id
    next_npc_id = 0

    # find the next mob to spawn, based on the current npc_id, growth_level, and food.
    if growth_level == 2
      # if tamed, the mob that will spawn depends on the class type (fighter/mage) of the player!
      if rand(2) == 0
        if player.class_id.mage_class?
          next_npc_id = GROWTH_CAPABLE_MONSTERS[npc_id].get_mob(food, 1, 1)
        else
          next_npc_id = GROWTH_CAPABLE_MONSTERS[npc_id].get_mob(food, 1, 0)
      end
      else
        # if not tamed, there is a small chance that have "mad cow" disease.
        # that is a stronger-than-normal animal that attacks its feeder
        if rand(5) == 0
          next_npc_id = GROWTH_CAPABLE_MONSTERS[npc_id].get_mob(food, 0, 1)
        else
          next_npc_id = GROWTH_CAPABLE_MONSTERS[npc_id].get_mob(food, 0, 0)
        end
      end
    else
      # all other levels of growth are straight-forward
      next_npc_id = GROWTH_CAPABLE_MONSTERS[npc_id].get_rand_mob(food)
    end

    # remove the feedinfo of the mob that got despawned, if any
    if tmp = FEED_INFO[npc.l2id]?
      if tmp == player.l2id
        FEED_INFO.delete(npc.l2id)
      end
    end
    # despawn the old mob
    # TODO: same code? FIXED?
    # /*
    #  * if _GrowthCapableMobs[npc_id].growth_level == 0)
    #     npc.delete_me
    #   }
    #   else
    #  */
    npc.delete_me
    # }
    next_npc_id = next_npc_id.not_nil!
    # if this is finally a trained mob, then despawn any other trained mobs that the
    # player might have and initialize the Tamed Beast.
    if TAMED_BEASTS.includes?(next_npc_id)
      player.tamed_beasts.each do |old_trained|
        old_trained.delete_me
      end

      next_npc = L2TamedBeastInstance.new(next_npc_id, player, food - FOOD_SKILL_DIFF, *npc.xyz)
      next_npc.set_running
      Scripts::Q00020_BringUpWithLove.check_jewel_of_innocence(player)

      # Support for A Grand Plan for Taming Wild Beasts (655) quest.
      Scripts::Q00655_AGrandPlanForTamingWildBeasts.reward(player, next_npc)

      # also, perform a rare random chat
      if rand(20) == 0
        message = NpcString[rand(2024..2029)]
        packet = NpcSay.new(next_npc, 0, message)
        if message.param_count > 0 # player name, $s1
          packet.add_string_parameter(player.name)
        end
        npc.broadcast_packet(packet)
      end
    #   /*
    #   TODO: The tamed beast consumes one golden/crystal spice
    #   every 60 seconds with an initial delay of 60 seconds
    #   if tamed beast exists and is alive)
    #     if player has 1+ golden/crystal spice)
    #       take one golden/crystal spice
    #       say random NpcString(rand(2029, 2038))
    #   end
    # end
    #   */
    else
      # if not trained, the newly spawned mob will automatically be aggro against its feeder
      # (what happened to "never bite the hand that feeds you" anyway?!)
      next_npc = add_spawn(next_npc_id, npc).as(L2Attackable)

      if MAD_COW_POLYMORPH.has_key?(next_npc_id)
        start_quest_timer("polymorph Mad Cow", 10000, next_npc, player)
      end

      # register the player in the feedinfo for the mob that just spawned
      FEED_INFO[next_npc.l2id] = player.l2id
      next_npc.set_running
      next_npc.add_damage_hate(player, 0, 99999)
      next_npc.set_intention(AI::ATTACK, player)
    end
  end

  def on_adv_event(event, npc, player)
    if npc && player && event.casecmp?("polymorph Mad Cow")
      if MAD_COW_POLYMORPH.has_key?(npc.id)
        # remove the feed info from the previous mob
        if FEED_INFO[npc.l2id] == player.l2id
          FEED_INFO.delete(npc.l2id)
        end
        # despawn the mad cow
        npc.delete_me
        # spawn the new mob
        next_npc = add_spawn(MAD_COW_POLYMORPH[npc.id], npc).as(L2Attackable)

        # register the player in the feedinfo for the mob that just spawned
        FEED_INFO[next_npc.l2id] = player.l2id
        next_npc.set_running
        next_npc.add_damage_hate(player, 0, 99999)
        next_npc.set_intention(AI::ATTACK, player)
      end
    end

    super
  end

  def on_skill_see(npc, caster, skill, targets, is_summon)
    debug "on_skill_see npc: #{npc}, caster: #{caster}, skill: #{skill}, targets: #{targets}, is_summon: #{is_summon}"
    # this behavior is only run when the target of skill is the passed npc (chest)
    # i.e. when the player is attempting to open the chest using a skill
    unless targets.includes?(npc)
      debug "targets doesn't include npc"
      return super
    end
    # gather some values on local variables
    npc_id = npc.id
    skill_id = skill.id
    # check if the npc and skills used are valid for this script. Exit if invalid.
    if skill_id != SKILL_GOLDEN_SPICE && skill_id != SKILL_CRYSTAL_SPICE
      debug "skill isn't golden or crystal spice"
      return super
    end

    # first gather some values on local variables
    l2id = npc.l2id
    growth_level = 3 # if a mob is in FEEDABLE_BEASTS but not in _GrowthCapableMobs, then it's at max growth (3)
    if GROWTH_CAPABLE_MONSTERS.has_key?(npc_id)
      growth_level = GROWTH_CAPABLE_MONSTERS[npc_id].growth_level
    end

    # prevent exploit which allows 2 players to simultaneously raise the same 0-growth beast
    # If the mob is at 0th level (when it still listens to all feeders) lock it to the first feeder!
    if growth_level == 0 && FEED_INFO.has_key?(l2id)
      debug "growth level is 0 or FEED_INFO doesn't have key #{l2id}"
      return super
    end

    FEED_INFO[l2id] = caster.l2id

    food = 0
    if skill_id == SKILL_GOLDEN_SPICE
      food = GOLDEN_SPICE
    elsif skill_id == SKILL_CRYSTAL_SPICE
      food = CRYSTAL_SPICE
    end

    # display the social action of the beast eating the food.
    npc.broadcast_social_action(2)

    # if this pet can't grow, it's all done.
    if tmp = GROWTH_CAPABLE_MONSTERS[npc_id]?
      # do nothing if this mob doesn't eat the specified food (food gets consumed but has no effect).
      if tmp.get_mob(food, 0, 0).nil?
        debug "didn't find mob npc_id #{npc_id} for foor #{food}"
        return super
      end

      # rare random talk...
      if rand(20) == 0
        message = TEXT[growth_level].sample
        packet = NpcSay.new(npc, 0, message)
        if message.param_count > 0 # player name, $s1
          packet.add_string_parameter(caster.name)
        end
        npc.broadcast_packet(packet)
      end

      if growth_level > 0 && FEED_INFO[l2id] != caster.l2id
        debug "growth_level > 0 && FEED_INFO[l2id] != caster.l2id"
        # check if this is the same player as the one who raised it from growth 0.
        # if no, then do not allow a chance to raise the pet (food gets consumed but has no effect).
        return super
      end

      # Polymorph the mob, with a certain chance, given its current growth level
      if rand(100) < GROWTH_CAPABLE_MONSTERS[npc_id].chance
        spawn_next(npc, growth_level, caster, food)
      end
    elsif TAMED_BEASTS.includes?(npc_id) && npc.is_a?(L2TamedBeastInstance)
      if skill_id == npc.food_type
        npc.on_receive_food
        message = TAMED_TEXT.sample
        packet = NpcSay.new(npc, 0, message)
        if message.param_count > 0
          packet.add_string_parameter(caster.name)
        end
        npc.broadcast_packet(packet)
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    FEED_INFO.delete(npc.l2id)
    super
  end
end
