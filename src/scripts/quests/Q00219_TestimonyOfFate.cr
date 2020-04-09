class Scripts::Q00219_TestimonyOfFate < Quest
  # NPCs
  private MAGISTER_ROA = 30114
  private WAREHOUSE_KEEPER_NORMAN = 30210
  private TETRARCH_THIFIELL = 30358
  private ARKENIA = 30419
  private MASTER_IXIA = 30463
  private MAGISTER_KAIRA = 30476
  private ALDERS_SPIRIT = 30613
  private BROTHER_METHEUS = 30614
  private BLOODY_PIXY = 31845
  private BLIGHT_TREANT = 31850
  # Items
  private KAIRAS_LETTER = 3173
  private METHEUSS_FUNERAL_JAR = 3174
  private KASANDRAS_REMAINS = 3175
  private HERBALISM_TEXTBOOK = 3176
  private IXIAS_LIST = 3177
  private MEDUSAS_ICHOR = 3178
  private MARSH_SPIDER_FLUIDS = 3179
  private DEAD_SEEKER_DUNG = 3180
  private TYRANTS_BLOOD = 3181
  private NIGHTSHADE_ROOT = 3182
  private BELLADONNA = 3183
  private ALDERS_SKULL1 = 3184
  private ALDERS_SKULL2 = 3185
  private ALDERS_RECEIPT = 3186
  private REVELATIONS_MANUSCRIPT = 3187
  private KAIRAS_RECOMMENDATION = 3189
  private KAIRAS_INSTRUCTIONS = 3188
  private PALUS_CHARM = 3190
  private THIFIELLS_LETTER = 3191
  private ARKENIAS_NOTE = 3192
  private PIXY_GARNET = 3193
  private GRANDISS_SKULL = 3194
  private KARUL_BUGBEAR_SKULL = 3195
  private BREKA_OVERLORD_SKULL = 3196
  private LETO_OVERLORD_SKULL = 3197
  private RED_FAIRY_DUST = 3198
  private TIMIRIRAN_SEED = 3199
  private BLACK_WILLOW_LEAF = 3200
  private BLIGHT_TREANT_SAP = 3201
  private ARKENIAS_LETTER = 3202
  # Reward
  private MARK_OF_FATE = 3172
  private DIMENSIONAL_DIAMOND = 7562
  # Monster
  private HANGMAN_TREE = 20144
  private MARSH_STAKATO = 20157
  private MEDUSA = 20158
  private TYRANT = 20192
  private TYRANT_KINGPIN = 20193
  private DEAD_SEEKER = 20202
  private MARSH_STAKATO_WORKER = 20230
  private MARSH_STAKATO_SOLDIER = 20232
  private MARSH_SPIDER = 20233
  private MARSH_STAKATO_DRONE = 20234
  private BREKA_ORC_OVERLORD = 20270
  private GRANDIS = 20554
  private LETO_LIZARDMAN_OVERLORD = 20582
  private KARUL_BUGBEAR = 20600
  # Quest Monster
  private BLACK_WILLOW_LURKER = 27079
  # Misc
  private MIN_LEVEL = 37

  def initialize
    super(219, self.class.simple_name, "Testimony Of Fate")

    add_start_npc(MAGISTER_KAIRA)
    add_talk_id(
      MAGISTER_KAIRA, MAGISTER_ROA, WAREHOUSE_KEEPER_NORMAN, TETRARCH_THIFIELL,
      ARKENIA, MASTER_IXIA, ALDERS_SPIRIT, BROTHER_METHEUS, BLOODY_PIXY,
      BLIGHT_TREANT
    )
    add_kill_id(
      HANGMAN_TREE, MARSH_STAKATO, MEDUSA, TYRANT, TYRANT_KINGPIN, DEAD_SEEKER,
      MARSH_STAKATO_WORKER, MARSH_STAKATO_SOLDIER, MARSH_SPIDER,
      MARSH_STAKATO_DRONE, BREKA_ORC_OVERLORD, GRANDIS, LETO_LIZARDMAN_OVERLORD,
      KARUL_BUGBEAR, BLACK_WILLOW_LURKER
    )
    register_quest_items(
      KAIRAS_LETTER, METHEUSS_FUNERAL_JAR, KASANDRAS_REMAINS,
      HERBALISM_TEXTBOOK, IXIAS_LIST, MEDUSAS_ICHOR, MARSH_SPIDER_FLUIDS,
      DEAD_SEEKER_DUNG, TYRANTS_BLOOD, NIGHTSHADE_ROOT, BELLADONNA,
      ALDERS_SKULL1, ALDERS_SKULL2, ALDERS_RECEIPT, REVELATIONS_MANUSCRIPT,
      KAIRAS_RECOMMENDATION, KAIRAS_INSTRUCTIONS, PALUS_CHARM, THIFIELLS_LETTER,
      ARKENIAS_NOTE, PIXY_GARNET, GRANDISS_SKULL, KARUL_BUGBEAR_SKULL,
      BREKA_OVERLORD_SKULL, LETO_OVERLORD_SKULL, RED_FAIRY_DUST, TIMIRIRAN_SEED,
      BLACK_WILLOW_LEAF, BLIGHT_TREANT_SAP, ARKENIAS_LETTER
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
        give_items(pc, KAIRAS_LETTER, 1)
        if pc.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(pc, DIMENSIONAL_DIAMOND, 98)
          pc.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          html = "30476-05a.htm"
        else
          html = "30476-05.htm"
        end
      end
    when "30476-04.htm", "30476-13.html", "30476-14.html", "30114-02.html",
         "30114-03.html", "30463-02a.html"
      html = event
    when "30476-12.html"
      if has_quest_items?(pc, REVELATIONS_MANUSCRIPT)
        take_items(pc, REVELATIONS_MANUSCRIPT, 1)
        give_items(pc, KAIRAS_RECOMMENDATION, 1)
        qs.set_cond(15, true)
        html = event
      end
    when "30114-04.html"
      if has_quest_items?(pc, ALDERS_SKULL2)
        take_items(pc, ALDERS_SKULL2, 1)
        give_items(pc, ALDERS_RECEIPT, 1)
        qs.set_cond(12, true)
        html = event
      end
    when "30419-02.html"
      if has_quest_items?(pc, THIFIELLS_LETTER)
        take_items(pc, THIFIELLS_LETTER, 1)
        give_items(pc, ARKENIAS_NOTE, 1)
        qs.set_cond(17, true)
        html = event
      end
    when "30419-05.html"
      if has_quest_items?(pc, ARKENIAS_NOTE, RED_FAIRY_DUST, BLIGHT_TREANT_SAP)
        take_items(pc, ARKENIAS_NOTE, 1)
        take_items(pc, RED_FAIRY_DUST, 1)
        take_items(pc, BLIGHT_TREANT_SAP, 1)
        give_items(pc, ARKENIAS_LETTER, 1)
        qs.set_cond(18, true)
        html = event
      end
    when "31845-02.html"
      give_items(pc, PIXY_GARNET, 1)
      html = event
    when "31850-02.html"
      give_items(pc, TIMIRIRAN_SEED, 1)
      html = event
    else
      # [automatically added else]
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when HANGMAN_TREE
        if has_quest_items?(killer, METHEUSS_FUNERAL_JAR) && !has_quest_items?(killer, KASANDRAS_REMAINS)
          take_items(killer, METHEUSS_FUNERAL_JAR, 1)
          give_items(killer, KASANDRAS_REMAINS, 1)
          qs.set_cond(3, true)
        end
      when MARSH_STAKATO, MARSH_STAKATO_WORKER, MARSH_STAKATO_SOLDIER, MARSH_STAKATO_DRONE
        if has_quest_items?(killer, IXIAS_LIST) && (get_quest_items_count(killer, NIGHTSHADE_ROOT) < 10)
          if get_quest_items_count(killer, NIGHTSHADE_ROOT) == 9
            give_items(killer, NIGHTSHADE_ROOT, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if (get_quest_items_count(killer, MEDUSAS_ICHOR) >= 10) && (get_quest_items_count(killer, MARSH_SPIDER_FLUIDS) >= 10) && (get_quest_items_count(killer, DEAD_SEEKER_DUNG) >= 10) && (get_quest_items_count(killer, TYRANTS_BLOOD) >= 10)
              qs.set_cond(7)
            end
          else
            give_items(killer, NIGHTSHADE_ROOT, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when MEDUSA
        if has_quest_items?(killer, IXIAS_LIST) && (get_quest_items_count(killer, MEDUSAS_ICHOR) < 10)
          if get_quest_items_count(killer, MEDUSAS_ICHOR) == 9
            give_items(killer, MEDUSAS_ICHOR, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if (get_quest_items_count(killer, MARSH_SPIDER_FLUIDS) >= 10) && (get_quest_items_count(killer, DEAD_SEEKER_DUNG) >= 10) && (get_quest_items_count(killer, TYRANTS_BLOOD) >= 10) && (get_quest_items_count(killer, NIGHTSHADE_ROOT) >= 10)
              qs.set_cond(7)
            end
          else
            give_items(killer, MEDUSAS_ICHOR, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when TYRANT, TYRANT_KINGPIN
        if has_quest_items?(killer, IXIAS_LIST) && (get_quest_items_count(killer, TYRANTS_BLOOD) < 10)
          if get_quest_items_count(killer, TYRANTS_BLOOD) == 9
            give_items(killer, TYRANTS_BLOOD, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if (get_quest_items_count(killer, MEDUSAS_ICHOR) >= 10) && (get_quest_items_count(killer, MARSH_SPIDER_FLUIDS) >= 10) && (get_quest_items_count(killer, DEAD_SEEKER_DUNG) >= 10) && (get_quest_items_count(killer, NIGHTSHADE_ROOT) >= 10)
              qs.set_cond(7)
            end
          else
            give_items(killer, TYRANTS_BLOOD, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when DEAD_SEEKER
        if has_quest_items?(killer, IXIAS_LIST) && get_quest_items_count(killer, DEAD_SEEKER_DUNG) < 10
          if get_quest_items_count(killer, DEAD_SEEKER_DUNG) == 9
            give_items(killer, DEAD_SEEKER_DUNG, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if get_quest_items_count(killer, MEDUSAS_ICHOR) >= 10 && get_quest_items_count(killer, MARSH_SPIDER_FLUIDS) >= 10 && get_quest_items_count(killer, TYRANTS_BLOOD) >= 10 && get_quest_items_count(killer, NIGHTSHADE_ROOT) >= 10
              qs.set_cond(7)
            end
          else
            give_items(killer, DEAD_SEEKER_DUNG, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when MARSH_SPIDER
        if has_quest_items?(killer, IXIAS_LIST) && get_quest_items_count(killer, MARSH_SPIDER_FLUIDS) < 10
          if get_quest_items_count(killer, MARSH_SPIDER_FLUIDS) == 9
            give_items(killer, MARSH_SPIDER_FLUIDS, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if get_quest_items_count(killer, MEDUSAS_ICHOR) >= 10 && get_quest_items_count(killer, DEAD_SEEKER_DUNG) >= 10 && get_quest_items_count(killer, TYRANTS_BLOOD) >= 10 && get_quest_items_count(killer, NIGHTSHADE_ROOT) >= 10
              qs.set_cond(7)
            end
          else
            give_items(killer, MARSH_SPIDER_FLUIDS, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when BREKA_ORC_OVERLORD
        if has_quest_items?(killer, PALUS_CHARM, ARKENIAS_NOTE, PIXY_GARNET) && !has_quest_items?(killer, RED_FAIRY_DUST, BREKA_OVERLORD_SKULL)
          unless has_quest_items?(killer, BREKA_OVERLORD_SKULL)
            give_items(killer, BREKA_OVERLORD_SKULL, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          end
        end
      when GRANDIS
        if has_quest_items?(killer, PALUS_CHARM, ARKENIAS_NOTE, PIXY_GARNET) && !has_quest_items?(killer, RED_FAIRY_DUST, GRANDISS_SKULL)
          unless has_quest_items?(killer, GRANDISS_SKULL)
            give_items(killer, GRANDISS_SKULL, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          end
        end
      when LETO_LIZARDMAN_OVERLORD
        if has_quest_items?(killer, PALUS_CHARM, ARKENIAS_NOTE, PIXY_GARNET) && !has_quest_items?(killer, RED_FAIRY_DUST, LETO_OVERLORD_SKULL)
          unless has_quest_items?(killer, LETO_OVERLORD_SKULL)
            give_items(killer, LETO_OVERLORD_SKULL, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          end
        end
      when KARUL_BUGBEAR
        if has_quest_items?(killer, PALUS_CHARM, ARKENIAS_NOTE, PIXY_GARNET) && !has_quest_items?(killer, RED_FAIRY_DUST, KARUL_BUGBEAR_SKULL)
          unless has_quest_items?(killer, KARUL_BUGBEAR_SKULL)
            give_items(killer, KARUL_BUGBEAR_SKULL, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          end
        end
      when BLACK_WILLOW_LURKER
        if has_quest_items?(killer, PALUS_CHARM, ARKENIAS_NOTE, TIMIRIRAN_SEED) && !has_quest_items?(killer, BLIGHT_TREANT_SAP, BLACK_WILLOW_LEAF)
          give_items(killer, BLACK_WILLOW_LEAF, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
        end
      else
        # [automatically added else]
      end

    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if npc.id == MAGISTER_KAIRA
        if pc.race.dark_elf?
          if pc.level >= MIN_LEVEL && pc.in_category?(CategoryType::DELF_2ND_GROUP)
            html = "30476-03.htm"
          elsif pc.level >= MIN_LEVEL
            html = "30476-01a.html"
          else
            html = "30476-02.html"
          end
        else
          html = "30476-01.html"
        end
      end
    elsif qs.started?
      case npc.id
      when MAGISTER_KAIRA
        if has_quest_items?(pc, KAIRAS_LETTER)
          html = "30476-06.html"
        elsif has_at_least_one_quest_item?(pc, METHEUSS_FUNERAL_JAR, KASANDRAS_REMAINS)
          html = "30476-07.html"
        elsif has_at_least_one_quest_item?(pc, HERBALISM_TEXTBOOK, IXIAS_LIST)
          qs.set_cond(5, true)
          html = "30476-08.html"
        elsif has_quest_items?(pc, ALDERS_SKULL1)
          take_items(pc, ALDERS_SKULL1, 1)
          give_items(pc, ALDERS_SKULL2, 1)
          add_spawn(ALDERS_SPIRIT, 78977, 149036, -3597, 0, false, 200000, false)
          qs.set_cond(10, true)
          html = "30476-09.html"
        elsif has_at_least_one_quest_item?(pc, ALDERS_SKULL2, ALDERS_RECEIPT)
          qs.set_cond(11, true)
          html = "30476-10.html"
        elsif has_quest_items?(pc, REVELATIONS_MANUSCRIPT)
          html = "30476-11.html"
        elsif has_quest_items?(pc, KAIRAS_INSTRUCTIONS)
          give_items(pc, KAIRAS_RECOMMENDATION, 1)
          take_items(pc, KAIRAS_INSTRUCTIONS, 1)
          qs.set_cond(15, true)
          html = "30476-15.html"
        elsif has_quest_items?(pc, KAIRAS_RECOMMENDATION)
          html = "30476-16.html"
        elsif has_quest_items?(pc, PALUS_CHARM)
          html = "30476-17.html"
        end
      when BROTHER_METHEUS
        if has_quest_items?(pc, KAIRAS_LETTER)
          take_items(pc, KAIRAS_LETTER, 1)
          give_items(pc, METHEUSS_FUNERAL_JAR, 1)
          qs.set_cond(2, true)
          html = "30614-01.html"
        elsif has_quest_items?(pc, METHEUSS_FUNERAL_JAR) && !has_quest_items?(pc, KASANDRAS_REMAINS)
          html = "30614-02.html"
        elsif has_quest_items?(pc, KASANDRAS_REMAINS) && !has_quest_items?(pc, METHEUSS_FUNERAL_JAR)
          take_items(pc, KASANDRAS_REMAINS, 1)
          give_items(pc, HERBALISM_TEXTBOOK, 1)
          qs.set_cond(4, true)
          html = "30614-03.html"
        elsif has_at_least_one_quest_item?(pc, HERBALISM_TEXTBOOK, IXIAS_LIST)
          qs.set_cond(5, true)
          html = "30614-04.html"
        elsif has_quest_items?(pc, BELLADONNA)
          take_items(pc, BELLADONNA, 1)
          give_items(pc, ALDERS_SKULL1, 1)
          qs.set_cond(9, true)
          html = "30614-05.html"
        elsif has_at_least_one_quest_item?(pc, ALDERS_SKULL1, ALDERS_SKULL2, ALDERS_RECEIPT, REVELATIONS_MANUSCRIPT, KAIRAS_INSTRUCTIONS, KAIRAS_RECOMMENDATION)
          html = "30614-06.html"
        end
      when MASTER_IXIA
        if has_quest_items?(pc, HERBALISM_TEXTBOOK)
          take_items(pc, HERBALISM_TEXTBOOK, 1)
          give_items(pc, IXIAS_LIST, 1)
          qs.set_cond(6, true)
          html = "30463-01.html"
        elsif has_quest_items?(pc, IXIAS_LIST)
          if get_quest_items_count(pc, MEDUSAS_ICHOR) >= 10 && get_quest_items_count(pc, MARSH_SPIDER_FLUIDS) >= 10 && get_quest_items_count(pc, DEAD_SEEKER_DUNG) >= 10 && get_quest_items_count(pc, TYRANTS_BLOOD) >= 10 && get_quest_items_count(pc, NIGHTSHADE_ROOT) >= 10
            take_items(pc, IXIAS_LIST, 1)
            take_items(pc, MEDUSAS_ICHOR, -1)
            take_items(pc, MARSH_SPIDER_FLUIDS, -1)
            take_items(pc, DEAD_SEEKER_DUNG, -1)
            take_items(pc, TYRANTS_BLOOD, -1)
            take_items(pc, NIGHTSHADE_ROOT, -1)
            give_items(pc, BELLADONNA, 1)
            qs.set_cond(8, true)
            html = "30463-03.html"
          else
            html = "30463-02.html"
          end
        elsif has_quest_items?(pc, BELLADONNA)
          html = "30463-04.html"
        elsif has_at_least_one_quest_item?(pc, ALDERS_SKULL1, ALDERS_SKULL2, ALDERS_RECEIPT, REVELATIONS_MANUSCRIPT, KAIRAS_INSTRUCTIONS, KAIRAS_RECOMMENDATION)
          html = "30463-05.html"
        end
      when MAGISTER_ROA
        if has_quest_items?(pc, ALDERS_SKULL2)
          html = "30114-01.html"
        elsif has_quest_items?(pc, ALDERS_RECEIPT)
          html = "30114-05.html"
        elsif has_at_least_one_quest_item?(pc, REVELATIONS_MANUSCRIPT, KAIRAS_INSTRUCTIONS, KAIRAS_RECOMMENDATION)
          html = "30114-06.html"
        end
      when WAREHOUSE_KEEPER_NORMAN
        if has_quest_items?(pc, ALDERS_RECEIPT)
          take_items(pc, ALDERS_RECEIPT, 1)
          give_items(pc, REVELATIONS_MANUSCRIPT, 1)
          qs.set_cond(13, true)
          html = "30210-01.html"
        elsif has_quest_items?(pc, REVELATIONS_MANUSCRIPT)
          html = "30210-02.html"
        end
      when TETRARCH_THIFIELL
        if has_quest_items?(pc, KAIRAS_RECOMMENDATION)
          take_items(pc, KAIRAS_RECOMMENDATION, 1)
          give_items(pc, PALUS_CHARM, 1)
          give_items(pc, THIFIELLS_LETTER, 1)
          qs.set_cond(16, true)
          html = "30358-01.html"
        elsif has_quest_items?(pc, PALUS_CHARM)
          if has_quest_items?(pc, THIFIELLS_LETTER)
            html = "30358-02.html"
          elsif has_quest_items?(pc, ARKENIAS_NOTE)
            html = "30358-03.html"
          elsif has_quest_items?(pc, ARKENIAS_LETTER)
            give_adena(pc, 247708, true)
            give_items(pc, MARK_OF_FATE, 1)
            add_exp_and_sp(pc, 1365470, 91124)
            qs.exit_quest(false, true)
            pc.send_packet(SocialAction.new(pc.l2id, 3))
            html = "30358-04.html"
          end
        end
      when ARKENIA
        if has_quest_items?(pc, PALUS_CHARM)
          if has_quest_items?(pc, THIFIELLS_LETTER)
            html = "30419-01.html"
          elsif has_quest_items?(pc, ARKENIAS_NOTE) && !has_quest_items?(pc, RED_FAIRY_DUST, BLIGHT_TREANT_SAP)
            html = "30419-03.html"
          elsif has_quest_items?(pc, ARKENIAS_NOTE, RED_FAIRY_DUST, BLIGHT_TREANT_SAP)
            html = "30419-04.html"
          elsif has_quest_items?(pc, ARKENIAS_LETTER)
            html = "30419-06.html"
          end
        end
      when ALDERS_SPIRIT
        if has_at_least_one_quest_item?(pc, ALDERS_SKULL1, ALDERS_SKULL2)
          html = "30613-01.html"
        end
      when BLOODY_PIXY
        if has_quest_items?(pc, PALUS_CHARM, ARKENIAS_NOTE)
          if !has_at_least_one_quest_item?(pc, RED_FAIRY_DUST, PIXY_GARNET)
            html = "31845-01.html"
          elsif !has_quest_items?(pc, RED_FAIRY_DUST) && has_quest_items?(pc, PIXY_GARNET) && !has_at_least_one_quest_item?(pc, GRANDISS_SKULL, KARUL_BUGBEAR_SKULL, BREKA_OVERLORD_SKULL, LETO_OVERLORD_SKULL)
            html = "31845-03.html"
          elsif !has_quest_items?(pc, RED_FAIRY_DUST) && has_quest_items?(pc, PIXY_GARNET, GRANDISS_SKULL, KARUL_BUGBEAR_SKULL, BREKA_OVERLORD_SKULL, LETO_OVERLORD_SKULL)
            take_items(pc, PIXY_GARNET, 1)
            take_items(pc, GRANDISS_SKULL, 1)
            take_items(pc, KARUL_BUGBEAR_SKULL, 1)
            take_items(pc, BREKA_OVERLORD_SKULL, 1)
            take_items(pc, LETO_OVERLORD_SKULL, 1)
            give_items(pc, RED_FAIRY_DUST, 1)
            html = "31845-04.html"
          elsif !has_quest_items?(pc, PIXY_GARNET) && has_quest_items?(pc, PALUS_CHARM, ARKENIAS_NOTE, RED_FAIRY_DUST)
            html = "31845-05.html"
          end
        end
      when BLIGHT_TREANT
        if has_quest_items?(pc, PALUS_CHARM, ARKENIAS_NOTE)
          if !has_at_least_one_quest_item?(pc, BLIGHT_TREANT_SAP, TIMIRIRAN_SEED)
            html = "31850-01.html"
          elsif has_quest_items?(pc, TIMIRIRAN_SEED) && !has_at_least_one_quest_item?(pc, BLIGHT_TREANT_SAP, BLACK_WILLOW_LEAF)
            html = "31850-03.html"
          elsif has_quest_items?(pc, TIMIRIRAN_SEED, BLACK_WILLOW_LEAF) && !has_quest_items?(pc, BLIGHT_TREANT_SAP)
            take_items(pc, TIMIRIRAN_SEED, 1)
            take_items(pc, BLACK_WILLOW_LEAF, 1)
            give_items(pc, BLIGHT_TREANT_SAP, 1)
            html = "31850-04.html"
          elsif has_quest_items?(pc, BLIGHT_TREANT_SAP) && !has_quest_items?(pc, TIMIRIRAN_SEED)
            html = "31850-05.html"
          end
        end
      else
        # [automatically added else]
      end

    elsif qs.completed?
      if npc.id == MAGISTER_KAIRA
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
