class Scripts::Q00216_TrialOfTheGuildsman < Quest
  private WAREHOUSE_KEEPER_VALKON = 30103
  private WAREHOUSE_KEEPER_NORMAN = 30210
  private BLACKSMITH_ALTRAN = 30283
  private BLACKSMITH_PINTER = 30298
  private BLACKSMITH_DUNING = 30688
  # Items
  private RECIPE_JOURNEYMAN_RING = 3024
  private RECIPE_AMBER_BEAD = 3025
  private VALKONS_RECOMMENDATION = 3120
  private MANDRAGORA_BERRY = 3121
  private ALLTRANS_INSTRUCTIONS = 3122
  private ALLTRANS_1ST_RECOMMENDATION = 3123
  private ALLTRANS_2ND_RECOMMENDATION = 3124
  private NORMANS_INSTRUCTIONS = 3125
  private NORMANS_RECEIPT = 3126
  private DUNINGS_INSTRUCTIONS = 3127
  private DUNINGS_KEY = 3128
  private NORMANS_LIST = 3129
  private GRAY_BONE_POWDER = 3130
  private GRANITE_WHETSTONE = 3131
  private RED_PIGMENT = 3132
  private BRAIDED_YARN = 3133
  private JOURNEYMAN_GEM = 3134
  private PINTERS_INSTRUCTIONS = 3135
  private AMBER_BEAD = 3136
  private AMBER_LUMP = 3137
  private JOURNEYMAN_DECO_BEADS = 3138
  private JOURNEYMAN_RING = 3139
  # Reward
  private MARK_OF_GUILDSMAN = 3119
  private DIMENSIONAL_DIAMOND = 7562
  # Monsters
  private ANT = 20079
  private ANT_CAPTAIN = 20080
  private ANT_OVERSEER = 20081
  private GRANITE_GOLEM = 20083
  private MANDRAGORA_SPROUT1 = 20154
  private MANDRAGORA_SAPLONG = 20155
  private MANDRAGORA_BLOSSOM = 20156
  private SILENOS = 20168
  private STRAIN = 20200
  private GHOUL = 20201
  private DEAD_SEEKER = 20202
  private MANDRAGORA_SPROUT2 = 20223
  private BREKA_ORC = 20267
  private BREKA_ORC_ARCHER = 20268
  private BREKA_ORC_SHAMAN = 20269
  private BREKA_ORC_OVERLORD = 20270
  private BREKA_ORC_WARRIOR = 20271
  # Misc
  private MIN_LVL = 35

  def initialize
    super(216, self.class.simple_name, "Trial Of The Guildsman")

    add_start_npc(WAREHOUSE_KEEPER_VALKON)
    add_talk_id(
      WAREHOUSE_KEEPER_VALKON, WAREHOUSE_KEEPER_NORMAN, BLACKSMITH_ALTRAN,
      BLACKSMITH_PINTER, BLACKSMITH_DUNING
    )
    add_kill_id(
      ANT, ANT_CAPTAIN, ANT_OVERSEER, GRANITE_GOLEM, MANDRAGORA_SPROUT1,
      MANDRAGORA_SAPLONG, MANDRAGORA_BLOSSOM, SILENOS, STRAIN, GHOUL,
      DEAD_SEEKER, MANDRAGORA_SPROUT2, BREKA_ORC, BREKA_ORC_ARCHER,
      BREKA_ORC_SHAMAN, BREKA_ORC_OVERLORD, BREKA_ORC_WARRIOR
    )
    register_quest_items(
      RECIPE_JOURNEYMAN_RING, RECIPE_AMBER_BEAD, VALKONS_RECOMMENDATION,
      MANDRAGORA_BERRY, ALLTRANS_INSTRUCTIONS, ALLTRANS_1ST_RECOMMENDATION,
      ALLTRANS_2ND_RECOMMENDATION, NORMANS_INSTRUCTIONS, NORMANS_RECEIPT,
      DUNINGS_INSTRUCTIONS, DUNINGS_KEY, NORMANS_LIST, GRAY_BONE_POWDER,
      GRANITE_WHETSTONE, RED_PIGMENT, BRAIDED_YARN, JOURNEYMAN_GEM,
      PINTERS_INSTRUCTIONS, AMBER_BEAD, AMBER_LUMP, JOURNEYMAN_DECO_BEADS,
      JOURNEYMAN_RING
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if get_quest_items_count(pc, Inventory::ADENA_ID) >= 2000
        qs.start_quest
        take_items(pc, Inventory::ADENA_ID, 2000)
        if !has_quest_items?(pc, VALKONS_RECOMMENDATION)
          give_items(pc, VALKONS_RECOMMENDATION, 1)
        end
        play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
        if pc.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(pc, DIMENSIONAL_DIAMOND, 85)
          pc.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          html = "30103-06d.htm"
        else
          html = "30103-06.htm"
        end
      else
        html = "30103-05b.htm"
      end
    when "30103-04.htm", "30103-05.htm", "30103-05a.html", "30103-06a.html",
         "30103-06b.html", "30103-06c.html", "30103-07a.html",
         "30103-07b.html", "30103-07c.html", "30210-02.html", "30210-03.html",
         "30210-08.html", "30210-09.html", "30210-11a.html", "30283-03a.html",
         "30283-03b.html", "30283-04.html", "30298-03.html", "30298-05a.html"
      html = event
    when "30103-09a.html"
      if has_quest_items?(pc, ALLTRANS_INSTRUCTIONS)
        if get_quest_items_count(pc, JOURNEYMAN_RING) >= 7
          give_adena(pc, 187606, true)
          give_items(pc, MARK_OF_GUILDSMAN, 1)
          add_exp_and_sp(pc, 1029478, 66768)
          qs.exit_quest(false, true)
          pc.send_packet(SocialAction.new(pc.l2id, 3))
          html = event
        end
      end
    when "30103-09b.html"
      if has_quest_items?(pc, ALLTRANS_INSTRUCTIONS)
        if get_quest_items_count(pc, JOURNEYMAN_RING) >= 7
          give_adena(pc, 93803, true)
          give_items(pc, MARK_OF_GUILDSMAN, 1)
          add_exp_and_sp(pc, 514739, 33384)
          qs.exit_quest(false, true)
          pc.send_packet(SocialAction.new(pc.l2id, 3))
          html = event
        end
      end
    when "30210-04.html"
      if has_quest_items?(pc, ALLTRANS_1ST_RECOMMENDATION)
        take_items(pc, ALLTRANS_1ST_RECOMMENDATION, 1)
        give_items(pc, NORMANS_INSTRUCTIONS, 1)
        give_items(pc, NORMANS_RECEIPT, 1)
        html = event
      end
    when "30210-10.html"
      if has_quest_items?(pc, NORMANS_INSTRUCTIONS)
        take_items(pc, NORMANS_INSTRUCTIONS, 1)
        take_items(pc, DUNINGS_KEY, -1)
        give_items(pc, NORMANS_LIST, 1)
        html = event
      end
    when "30283-03.html"
      if has_quest_items?(pc, VALKONS_RECOMMENDATION, MANDRAGORA_BERRY)
        give_items(pc, RECIPE_JOURNEYMAN_RING, 1)
        take_items(pc, VALKONS_RECOMMENDATION, 1)
        take_items(pc, MANDRAGORA_BERRY, 1)
        give_items(pc, ALLTRANS_INSTRUCTIONS, 1)
        give_items(pc, ALLTRANS_1ST_RECOMMENDATION, 1)
        give_items(pc, ALLTRANS_2ND_RECOMMENDATION, 1)
        qs.set_cond(5, true)
        html = event
      end
    when "30298-04.html"
      if pc.class_id.scavenger?
        if has_quest_items?(pc, ALLTRANS_2ND_RECOMMENDATION)
          take_items(pc, ALLTRANS_2ND_RECOMMENDATION, 1)
          give_items(pc, PINTERS_INSTRUCTIONS, 1)
          html = event
        end
      elsif has_quest_items?(pc, ALLTRANS_2ND_RECOMMENDATION)
        give_items(pc, RECIPE_AMBER_BEAD, 1)
        take_items(pc, ALLTRANS_2ND_RECOMMENDATION, 1)
        give_items(pc, PINTERS_INSTRUCTIONS, 1)
        html = "30298-05.html"
      end
    when "30688-02.html"
      if has_quest_items?(pc, NORMANS_RECEIPT)
        take_items(pc, NORMANS_RECEIPT, 1)
        give_items(pc, DUNINGS_INSTRUCTIONS, 1)
        html = event
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    case npc.id
    when ANT, ANT_CAPTAIN, ANT_OVERSEER
      if qs = get_random_party_member_state(killer, -1, 2, npc)
        count = 0
        if qs.player.class_id.scavenger? && npc.sweep_active?
          count &+= 5
        end

        if Rnd.bool && qs.player.class_id.artisan?
          give_items(qs.player, AMBER_LUMP, 1)
          play_sound(qs.player, Sound::ITEMSOUND_QUEST_MIDDLE)
        end

        if get_quest_items_count(qs.player, AMBER_BEAD) + count < 70
          count &+= 5
        end

        if count > 0
          give_item_randomly(qs.player, npc, AMBER_BEAD, count, 70, 1.0, true)
        end
      end
    when GRANITE_GOLEM
      if qs = get_random_party_member_state(killer, -1, 2, npc)
        give_items(qs.player, GRANITE_WHETSTONE, 7)
        if get_quest_items_count(qs.player, GRANITE_WHETSTONE) == 70
          play_sound(qs.player, Sound::ITEMSOUND_QUEST_MIDDLE)
        else
          play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    when MANDRAGORA_SPROUT1, MANDRAGORA_SAPLONG, MANDRAGORA_BLOSSOM,
         MANDRAGORA_SPROUT2
      qs = get_quest_state(killer, false)
      if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
        if has_quest_items?(killer, VALKONS_RECOMMENDATION)
          unless has_quest_items?(killer, MANDRAGORA_BERRY)
            give_items(killer, MANDRAGORA_BERRY, 1)
            qs.set_cond(4, true)
          end
        end
      end
    when SILENOS
      if qs = get_random_party_member_state(killer, -1, 2, npc)
        give_items(qs.player, BRAIDED_YARN, 10)
        if get_quest_items_count(qs.player, BRAIDED_YARN) == 70
          play_sound(qs.player, Sound::ITEMSOUND_QUEST_MIDDLE)
        else
          play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    when STRAIN, GHOUL
      if qs = get_random_party_member_state(killer, -1, 2, npc)
        give_items(qs.player, GRAY_BONE_POWDER, 5)
        if get_quest_items_count(qs.player, GRAY_BONE_POWDER) == 70
          play_sound(qs.player, Sound::ITEMSOUND_QUEST_MIDDLE)
        else
          play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    when DEAD_SEEKER
      if qs = get_random_party_member_state(killer, -1, 2, npc)
        give_items(qs.player, RED_PIGMENT, 7)
        if get_quest_items_count(qs.player, RED_PIGMENT) == 70
          play_sound(qs.player, Sound::ITEMSOUND_QUEST_MIDDLE)
        else
          play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    when BREKA_ORC, BREKA_ORC_ARCHER, BREKA_ORC_SHAMAN, BREKA_ORC_OVERLORD,
         BREKA_ORC_WARRIOR
      if qs = get_random_party_member_state(killer, -1, 2, npc)
        if get_quest_items_count(qs.player, DUNINGS_KEY) >= 29
          give_items(qs.player, DUNINGS_KEY, 1)
          take_items(qs.player, DUNINGS_INSTRUCTIONS, 1)
          play_sound(qs.player, Sound::ITEMSOUND_QUEST_MIDDLE)
        else
          give_items(qs.player, DUNINGS_KEY, 1)
          play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if npc.id == WAREHOUSE_KEEPER_VALKON
        if pc.class_id.artisan? || pc.class_id.scavenger?
          if pc.level < MIN_LVL
            html = "30103-02.html"
          else
            html = "30103-03.htm"
          end
        else
          html = "30103-01.html"
        end
      end
    elsif qs.started?
      case npc.id
      when WAREHOUSE_KEEPER_VALKON
        if has_quest_items?(pc, VALKONS_RECOMMENDATION)
          qs.set_cond(3, true)
          html = "30103-07.html"
        elsif has_quest_items?(pc, ALLTRANS_INSTRUCTIONS)
          if get_quest_items_count(pc, JOURNEYMAN_RING) < 7
            html = "30103-08.html"
          else
            html = "30103-09.html"
          end
        end
      when WAREHOUSE_KEEPER_NORMAN
        if has_quest_items?(pc, ALLTRANS_INSTRUCTIONS)
          if has_quest_items?(pc, ALLTRANS_1ST_RECOMMENDATION)
            html = "30210-01.html"
          elsif has_quest_items?(pc, NORMANS_INSTRUCTIONS, NORMANS_RECEIPT)
            html = "30210-05.html"
          elsif has_quest_items?(pc, NORMANS_INSTRUCTIONS, DUNINGS_INSTRUCTIONS)
            html = "30210-06.html"
          elsif has_quest_items?(pc, NORMANS_INSTRUCTIONS) && get_quest_items_count(pc, DUNINGS_KEY) >= 30
            html = "30210-07.html"
          elsif has_quest_items?(pc, NORMANS_LIST)
            if get_quest_items_count(pc, GRAY_BONE_POWDER) >= 70 && get_quest_items_count(pc, GRANITE_WHETSTONE) >= 70 && get_quest_items_count(pc, RED_PIGMENT) >= 70 && get_quest_items_count(pc, BRAIDED_YARN) >= 70
              take_items(pc, NORMANS_LIST, 1)
              take_items(pc, GRAY_BONE_POWDER, -1)
              take_items(pc, GRANITE_WHETSTONE, -1)
              take_items(pc, RED_PIGMENT, -1)
              take_items(pc, BRAIDED_YARN, -1)
              give_items(pc, JOURNEYMAN_GEM, 7)
              if get_quest_items_count(pc, JOURNEYMAN_DECO_BEADS) >= 7
                qs.set_cond(6, true)
              end
              html = "30210-12.html"
            else
              html = "30210-11.html"
            end
          elsif !has_at_least_one_quest_item?(pc, NORMANS_INSTRUCTIONS, NORMANS_LIST)
            if has_at_least_one_quest_item?(pc, JOURNEYMAN_GEM, JOURNEYMAN_RING)
              html = "30210-13.html"
            end
          end
        end
      when BLACKSMITH_ALTRAN
        if has_quest_items?(pc, VALKONS_RECOMMENDATION)
          if !has_quest_items?(pc, MANDRAGORA_BERRY)
            qs.set_cond(2, true)
            html = "30283-01.html"
          else
            html = "30283-02.html"
          end
        elsif has_quest_items?(pc, ALLTRANS_INSTRUCTIONS)
          if get_quest_items_count(pc, JOURNEYMAN_RING) < 7
            html = "30283-04.html"
          else
            html = "30283-05.html"
          end
        end
      when BLACKSMITH_PINTER
        if has_quest_items?(pc, ALLTRANS_INSTRUCTIONS)
          if has_quest_items?(pc, ALLTRANS_2ND_RECOMMENDATION)
            html = "30298-02.html"
          elsif has_quest_items?(pc, PINTERS_INSTRUCTIONS)
            if get_quest_items_count(pc, AMBER_BEAD) < 70
              html = "30298-06.html"
            else
              take_items(pc, RECIPE_AMBER_BEAD, 1)
              take_items(pc, PINTERS_INSTRUCTIONS, 1)
              take_items(pc, AMBER_BEAD, -1)
              take_items(pc, AMBER_LUMP, -1)
              give_items(pc, JOURNEYMAN_DECO_BEADS, 7)
              if get_quest_items_count(pc, JOURNEYMAN_GEM) >= 7
                qs.set_cond(6, true)
              end
              html = "30298-07.html"
            end
          elsif !has_quest_items?(pc, PINTERS_INSTRUCTIONS)
            if has_at_least_one_quest_item?(pc, JOURNEYMAN_DECO_BEADS, JOURNEYMAN_RING)
              html = "30298-08.html"
            end
          end
        end
      when BLACKSMITH_DUNING
        if has_quest_items?(pc, ALLTRANS_INSTRUCTIONS, NORMANS_INSTRUCTIONS)
          if has_quest_items?(pc, NORMANS_RECEIPT) && !has_quest_items?(pc, DUNINGS_INSTRUCTIONS)
            html = "30688-01.html"
          end
          if has_quest_items?(pc, DUNINGS_INSTRUCTIONS) && !has_quest_items?(pc, NORMANS_RECEIPT) && (get_quest_items_count(pc, DUNINGS_KEY) < 30)
            html = "30688-03.html"
          elsif get_quest_items_count(pc, DUNINGS_KEY) >= 30
            unless has_quest_items?(pc, DUNINGS_INSTRUCTIONS)
              html = "30688-04.html"
            end
          end
        elsif has_quest_items?(pc, ALLTRANS_INSTRUCTIONS) &&
          unless has_at_least_one_quest_item?(pc, NORMANS_INSTRUCTIONS, DUNINGS_INSTRUCTIONS)
            html = "30688-05.html"
          end
        end
      end
    elsif qs.completed?
      if npc.id == WAREHOUSE_KEEPER_VALKON
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end

  def check_party_member(pc : L2PcInstance, npc : L2Npc) : Bool
    check = false
    case npc.id
    when ANT, ANT_CAPTAIN, ANT_OVERSEER
      check = has_quest_items?(pc, ALLTRANS_INSTRUCTIONS, PINTERS_INSTRUCTIONS) && get_quest_items_count(pc, AMBER_BEAD) < 70
    when GRANITE_GOLEM
      check = has_quest_items?(pc, ALLTRANS_INSTRUCTIONS, NORMANS_LIST) && get_quest_items_count(pc, GRANITE_WHETSTONE) < 70
    when SILENOS
      check = has_quest_items?(pc, ALLTRANS_INSTRUCTIONS, NORMANS_LIST) && get_quest_items_count(pc, BRAIDED_YARN) < 70
    when STRAIN, GHOUL
      check = has_quest_items?(pc, ALLTRANS_INSTRUCTIONS, NORMANS_LIST) && get_quest_items_count(pc, GRAY_BONE_POWDER) < 70
    when DEAD_SEEKER
      check = has_quest_items?(pc, ALLTRANS_INSTRUCTIONS, NORMANS_LIST) && get_quest_items_count(pc, RED_PIGMENT) < 70
    when BREKA_ORC, BREKA_ORC_ARCHER, BREKA_ORC_SHAMAN, BREKA_ORC_OVERLORD, BREKA_ORC_WARRIOR
      check = has_quest_items?(pc, ALLTRANS_INSTRUCTIONS, NORMANS_INSTRUCTIONS, DUNINGS_INSTRUCTIONS) && get_quest_items_count(pc, DUNINGS_KEY) < 30
    end

    check
  end
end
