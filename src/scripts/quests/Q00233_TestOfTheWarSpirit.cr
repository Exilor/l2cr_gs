class Scripts::Q00233_TestOfTheWarSpirit < Quest
  # NPCs
  private PRIESTESS_VIVYAN = 30030
  private TRADER_SARIEN = 30436
  private SEER_RACOY = 30507
  private SEER_SOMAK = 30510
  private SEER_MANAKIA = 30515
  private SHADOW_ORIM = 30630
  private ANCESTOR_MARTANKUS = 30649
  private SEER_PEKIRON = 30682
  # Items
  private VENDETTA_TOTEM = 2880
  private TAMLIN_ORC_HEAD = 2881
  private WARSPIRIT_TOTEM = 2882
  private ORIMS_CONTRACT = 2883
  private PORTAS_EYE = 2884
  private EXCUROS_SCALE = 2885
  private MORDEOS_TALON = 2886
  private BRAKIS_REMAINS1 = 2887
  private PEKIRONS_TOTEM = 2888
  private TONARS_SKULL = 2889
  private TONARS_RIB_BONE = 2890
  private TONARS_SPINE = 2891
  private TONARS_ARM_BONE = 2892
  private TONARS_THIGH_BONE = 2893
  private TONARS_REMAINS1 = 2894
  private MANAKIAS_TOTEM = 2895
  private HERMODTS_SKULL = 2896
  private HERMODTS_RIB_BONE = 2897
  private HERMODTS_SPINE = 2898
  private HERMODTS_ARM_BONE = 2899
  private HERMODTS_THIGH_BONE = 2900
  private HERMODTS_REMAINS1 = 2901
  private RACOYS_TOTEM = 2902
  private VIVIANTES_LETTER = 2903
  private INSECT_DIAGRAM_BOOK = 2904
  private KIRUNAS_SKULL = 2905
  private KIRUNAS_RIB_BONE = 2906
  private KIRUNAS_SPINE = 2907
  private KIRUNAS_ARM_BONE = 2908
  private KIRUNAS_THIGH_BONE = 2909
  private KIRUNAS_REMAINS1 = 2910
  private BRAKIS_REMAINS2 = 2911
  private TONARS_REMAINS2 = 2912
  private HERMODTS_REMAINS2 = 2913
  private KIRUNAS_REMAINS2 = 2914
  # Reward
  private MARK_OF_WARSPIRIT = 2879
  private DIMENSIONAL_DIAMOND = 7562
  # Monster
  private NOBLE_ANT = 20089
  private NOBLE_ANT_LEADER = 20090
  private MEDUSA = 20158
  private PORTA = 20213
  private EXCURO = 20214
  private MORDERO = 20215
  private LETO_LIZARDMAN_SHAMAN = 20581
  private LETO_LIZARDMAN_OVERLORD = 20582
  private TAMLIN_ORC = 20601
  private TAMLIN_ORC_ARCHER = 20602
  # Quest Monster
  private STENOA_GORGON_QUEEN = 27108
  # Misc
  private MIN_LEVEL = 39

  def initialize
    super(233, self.class.simple_name, "Test Of The War Spirit")

    add_start_npc(SEER_SOMAK)
    add_talk_id(
      SEER_SOMAK, PRIESTESS_VIVYAN, TRADER_SARIEN, SEER_RACOY, SEER_MANAKIA,
      SHADOW_ORIM, ANCESTOR_MARTANKUS, SEER_PEKIRON
    )
    add_kill_id(
      NOBLE_ANT, NOBLE_ANT_LEADER, MEDUSA, PORTA, EXCURO, MORDERO,
      LETO_LIZARDMAN_SHAMAN, LETO_LIZARDMAN_OVERLORD, TAMLIN_ORC,
      TAMLIN_ORC_ARCHER, STENOA_GORGON_QUEEN
    )
    register_quest_items(
      VENDETTA_TOTEM, TAMLIN_ORC_HEAD, WARSPIRIT_TOTEM, ORIMS_CONTRACT,
      PORTAS_EYE, EXCUROS_SCALE, MORDEOS_TALON, BRAKIS_REMAINS1,
      PEKIRONS_TOTEM, TONARS_SKULL, TONARS_RIB_BONE, TONARS_SPINE,
      TONARS_ARM_BONE, TONARS_THIGH_BONE, TONARS_REMAINS1, MANAKIAS_TOTEM,
      HERMODTS_SKULL, HERMODTS_RIB_BONE, HERMODTS_SPINE, HERMODTS_ARM_BONE,
      HERMODTS_THIGH_BONE, HERMODTS_REMAINS1, RACOYS_TOTEM, VIVIANTES_LETTER,
      INSECT_DIAGRAM_BOOK, KIRUNAS_SKULL, KIRUNAS_RIB_BONE, KIRUNAS_SPINE,
      KIRUNAS_ARM_BONE, KIRUNAS_THIGH_BONE, KIRUNAS_REMAINS1, BRAKIS_REMAINS2,
      TONARS_REMAINS2, HERMODTS_REMAINS2, KIRUNAS_REMAINS2
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (qs = get_quest_state(pc, false))

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        if pc.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(pc, DIMENSIONAL_DIAMOND, 92)
          pc.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          html = "30510-05e.htm"
        else
          html = "30510-05.htm"
        end
      end
    when "30510-05a.html", "30510-05b.html", "30510-05c.html", "30510-05d.html",
         "30510-05.html", "30030-02.html", "30030-03.html", "30630-02.html",
         "30630-03.html", "30649-02.html"
      html = event
    when "30030-04.html"
      give_items(pc, VIVIANTES_LETTER, 1)
      html = event
    when "30507-02.html"
      give_items(pc, RACOYS_TOTEM, 1)
      html = event
    when "30515-02.html"
      give_items(pc, MANAKIAS_TOTEM, 1)
      html = event
    when "30630-04.html"
      give_items(pc, ORIMS_CONTRACT, 1)
      html = event
    when "30649-03.html"
      if has_quest_items?(pc, TONARS_REMAINS2)
        give_adena(pc, 161_806, true)
        give_items(pc, MARK_OF_WARSPIRIT, 1)
        add_exp_and_sp(pc, 894_888, 61_408)
        qs.exit_quest(false, true)
        pc.send_packet(SocialAction.new(pc.l2id, 3))
        html = event
      end
    when "30682-02.html"
      give_items(pc, PEKIRONS_TOTEM, 1)
      html = event
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when NOBLE_ANT, NOBLE_ANT_LEADER
        if has_quest_items?(killer, RACOYS_TOTEM, INSECT_DIAGRAM_BOOK)
          i0 = Rnd.rand(100)
          if i0 > 65
            if !has_quest_items?(killer, KIRUNAS_THIGH_BONE)
              give_items(killer, KIRUNAS_THIGH_BONE, 1)
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            elsif !has_quest_items?(killer, KIRUNAS_ARM_BONE)
              give_items(killer, KIRUNAS_ARM_BONE, 1)
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            end
          elsif i0 > 30
            if !has_quest_items?(killer, KIRUNAS_SPINE)
              give_items(killer, KIRUNAS_SPINE, 1)
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            elsif !has_quest_items?(killer, KIRUNAS_RIB_BONE)
              give_items(killer, KIRUNAS_RIB_BONE, 1)
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            end
          elsif i0 > 0
            if !has_quest_items?(killer, KIRUNAS_SKULL)
              give_items(killer, KIRUNAS_SKULL, 1)
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            end
          end
        end
      when MEDUSA
        if has_quest_items?(killer, MANAKIAS_TOTEM)
          if !has_quest_items?(killer, HERMODTS_RIB_BONE)
            give_items(killer, HERMODTS_RIB_BONE, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          elsif !has_quest_items?(killer, HERMODTS_SPINE)
            give_items(killer, HERMODTS_SPINE, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          elsif !has_quest_items?(killer, HERMODTS_ARM_BONE)
            give_items(killer, HERMODTS_ARM_BONE, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          elsif !has_quest_items?(killer, HERMODTS_THIGH_BONE)
            give_items(killer, HERMODTS_THIGH_BONE, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          end
        end
      when PORTA
        if has_quest_items?(killer, ORIMS_CONTRACT)
          give_item_randomly(killer, npc, PORTAS_EYE, 2, 10, 1.0, true)
        end
      when EXCURO
        if has_quest_items?(killer, ORIMS_CONTRACT)
          give_item_randomly(killer, npc, EXCUROS_SCALE, 5, 10, 1.0, true)
        end
      when MORDERO
        if has_quest_items?(killer, ORIMS_CONTRACT)
          give_item_randomly(killer, npc, MORDEOS_TALON, 5, 10, 1.0, true)
        end
      when LETO_LIZARDMAN_SHAMAN, LETO_LIZARDMAN_OVERLORD
        if has_quest_items?(killer, PEKIRONS_TOTEM)
          if !has_quest_items?(killer, TONARS_SKULL)
            give_items(killer, TONARS_SKULL, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          elsif !has_quest_items?(killer, TONARS_RIB_BONE)
            give_items(killer, TONARS_RIB_BONE, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          elsif !has_quest_items?(killer, TONARS_SPINE)
            give_items(killer, TONARS_SPINE, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          elsif !has_quest_items?(killer, TONARS_ARM_BONE)
            give_items(killer, TONARS_ARM_BONE, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          elsif !has_quest_items?(killer, TONARS_THIGH_BONE)
            give_items(killer, TONARS_THIGH_BONE, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          end
        end
      when TAMLIN_ORC, TAMLIN_ORC_ARCHER
        if has_quest_items?(killer, VENDETTA_TOTEM)
          if give_item_randomly(killer, npc, TAMLIN_ORC_HEAD, 1, 13, 1.0, true)
            qs.set_cond(4, true)
          end
        end
      when STENOA_GORGON_QUEEN
        if has_quest_items?(killer, MANAKIAS_TOTEM) && !has_quest_items?(killer, HERMODTS_SKULL)
          give_items(killer, HERMODTS_SKULL, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if npc.id == SEER_SOMAK
        if pc.race == Race::ORC
          if pc.class_id.orc_shaman?
            if pc.level < MIN_LEVEL
              html = "30510-03.html"
            else
              html = "30510-04.htm"
            end
          else
            html = "30510-02.html"
          end
        else
          html = "30510-01.html"
        end
      end
    elsif qs.started?
      case npc.id
      when SEER_SOMAK
        if !has_at_least_one_quest_item?(pc, VENDETTA_TOTEM, WARSPIRIT_TOTEM)
          if has_quest_items?(pc, BRAKIS_REMAINS1, HERMODTS_REMAINS1, KIRUNAS_REMAINS1, TONARS_REMAINS1)
            give_items(pc, VENDETTA_TOTEM, 1)
            take_items(pc, BRAKIS_REMAINS1, 1)
            take_items(pc, TONARS_REMAINS1, 1)
            take_items(pc, HERMODTS_REMAINS1, 1)
            take_items(pc, KIRUNAS_REMAINS1, 1)
            qs.set_cond(3)
            html = "30510-07.html"
          else
            html = "30510-06.html"
          end
        elsif has_quest_items?(pc, VENDETTA_TOTEM)
          if get_quest_items_count(pc, TAMLIN_ORC_HEAD) < 13
            html = "30510-08.html"
          else
            take_items(pc, VENDETTA_TOTEM, 1)
            give_items(pc, WARSPIRIT_TOTEM, 1)
            give_items(pc, BRAKIS_REMAINS2, 1)
            give_items(pc, TONARS_REMAINS2, 1)
            give_items(pc, HERMODTS_REMAINS2, 1)
            give_items(pc, KIRUNAS_REMAINS2, 1)
            qs.set_cond(5)
            html = "30510-09.html"
          end
        elsif has_quest_items?(pc, WARSPIRIT_TOTEM)
          html = "30510-10.html"
        end
      when PRIESTESS_VIVYAN
        if has_quest_items?(pc, RACOYS_TOTEM) && !has_at_least_one_quest_item?(pc, VIVIANTES_LETTER, INSECT_DIAGRAM_BOOK)
          html = "30030-01.html"
        elsif has_quest_items?(pc, RACOYS_TOTEM, VIVIANTES_LETTER) && !has_quest_items?(pc, INSECT_DIAGRAM_BOOK)
          html = "30030-05.html"
        elsif has_quest_items?(pc, RACOYS_TOTEM, INSECT_DIAGRAM_BOOK) && !has_quest_items?(pc, VIVIANTES_LETTER)
          html = "30030-06.html"
        elsif !has_quest_items?(pc, RACOYS_TOTEM) && has_at_least_one_quest_item?(pc, KIRUNAS_REMAINS1, KIRUNAS_REMAINS2, VENDETTA_TOTEM)
          html = "30030-07.html"
        end
      when TRADER_SARIEN
        if has_quest_items?(pc, RACOYS_TOTEM, VIVIANTES_LETTER) && !has_quest_items?(pc, INSECT_DIAGRAM_BOOK)
          take_items(pc, VIVIANTES_LETTER, 1)
          give_items(pc, INSECT_DIAGRAM_BOOK, 1)
          html = "30436-01.html"
        elsif has_quest_items?(pc, RACOYS_TOTEM, INSECT_DIAGRAM_BOOK) && !has_quest_items?(pc, VIVIANTES_LETTER)
          html = "30436-02.html"
        elsif !has_quest_items?(pc, RACOYS_TOTEM) && has_at_least_one_quest_item?(pc, KIRUNAS_REMAINS1, KIRUNAS_REMAINS2, VENDETTA_TOTEM)
          html = "30436-03.html"
        end
      when SEER_RACOY
        if !has_at_least_one_quest_item?(pc, RACOYS_TOTEM, KIRUNAS_REMAINS1, KIRUNAS_REMAINS2, VENDETTA_TOTEM)
          html = "30507-01.html"
        elsif has_quest_items?(pc, RACOYS_TOTEM) && !has_at_least_one_quest_item?(pc, VIVIANTES_LETTER, INSECT_DIAGRAM_BOOK)
          html = "30507-03.html"
        elsif has_quest_items?(pc, RACOYS_TOTEM, VIVIANTES_LETTER) && !has_quest_items?(pc, INSECT_DIAGRAM_BOOK)
          html = "30507-04.html"
        elsif has_quest_items?(pc, RACOYS_TOTEM, INSECT_DIAGRAM_BOOK) && !has_quest_items?(pc, VIVIANTES_LETTER)
          if has_quest_items?(pc, KIRUNAS_SKULL, KIRUNAS_RIB_BONE, KIRUNAS_SPINE, KIRUNAS_ARM_BONE, KIRUNAS_THIGH_BONE)
            take_items(pc, RACOYS_TOTEM, 1)
            take_items(pc, INSECT_DIAGRAM_BOOK, 1)
            take_items(pc, KIRUNAS_SKULL, 1)
            take_items(pc, KIRUNAS_RIB_BONE, 1)
            take_items(pc, KIRUNAS_SPINE, 1)
            take_items(pc, KIRUNAS_ARM_BONE, 1)
            take_items(pc, KIRUNAS_THIGH_BONE, 1)
            give_items(pc, KIRUNAS_REMAINS1, 1)
            if has_quest_items?(pc, BRAKIS_REMAINS1, HERMODTS_REMAINS1, TONARS_REMAINS1)
              qs.set_cond(2)
            end
            html = "30507-06.html"
          else
            html = "30507-05.html"
          end
        elsif !has_quest_items?(pc, RACOYS_TOTEM)
          if has_at_least_one_quest_item?(pc, KIRUNAS_REMAINS1, KIRUNAS_REMAINS2, VENDETTA_TOTEM)
            html = "30507-07.html"
          end
        end
      when SEER_MANAKIA
        if !has_at_least_one_quest_item?(pc, MANAKIAS_TOTEM, HERMODTS_REMAINS2, VENDETTA_TOTEM, HERMODTS_REMAINS1)
          html = "30515-01.html"
        elsif has_quest_items?(pc, MANAKIAS_TOTEM)
          if has_quest_items?(pc, HERMODTS_SKULL, HERMODTS_RIB_BONE, HERMODTS_SPINE, HERMODTS_ARM_BONE, HERMODTS_THIGH_BONE)
            take_items(pc, MANAKIAS_TOTEM, 1)
            take_items(pc, HERMODTS_SKULL, 1)
            take_items(pc, HERMODTS_RIB_BONE, 1)
            take_items(pc, HERMODTS_SPINE, 1)
            take_items(pc, HERMODTS_ARM_BONE, 1)
            take_items(pc, HERMODTS_THIGH_BONE, 1)
            give_items(pc, HERMODTS_REMAINS1, 1)
            if has_quest_items?(pc, BRAKIS_REMAINS1, KIRUNAS_REMAINS1, TONARS_REMAINS1)
              qs.set_cond(2)
            end
            html = "30515-04.html"
          else
            html = "30515-03.html"
          end
        elsif !has_quest_items?(pc, MANAKIAS_TOTEM) && has_at_least_one_quest_item?(pc, HERMODTS_REMAINS1, HERMODTS_REMAINS2, VENDETTA_TOTEM)
          html = "30515-05.html"
        end
      when SHADOW_ORIM
        if !has_at_least_one_quest_item?(pc, ORIMS_CONTRACT, BRAKIS_REMAINS1, BRAKIS_REMAINS2, VENDETTA_TOTEM)
          html = "30630-01.html"
        elsif has_quest_items?(pc, ORIMS_CONTRACT)
          if get_quest_items_count(pc, PORTAS_EYE) &+ get_quest_items_count(pc, EXCUROS_SCALE) &+ get_quest_items_count(pc, MORDEOS_TALON) < 30
            html = "30630-05.html"
          else
            take_items(pc, ORIMS_CONTRACT, 1)
            take_items(pc, PORTAS_EYE, -1)
            take_items(pc, EXCUROS_SCALE, -1)
            take_items(pc, MORDEOS_TALON, -1)
            give_items(pc, BRAKIS_REMAINS1, 1)
            if has_quest_items?(pc, HERMODTS_REMAINS1, KIRUNAS_REMAINS1, TONARS_REMAINS1)
              qs.set_cond(2)
            end
            html = "30630-06.html"
          end
        elsif !has_quest_items?(pc, ORIMS_CONTRACT) && has_at_least_one_quest_item?(pc, BRAKIS_REMAINS1, BRAKIS_REMAINS2, VENDETTA_TOTEM)
          html = "30630-07.html"
        end
      when ANCESTOR_MARTANKUS
        if has_quest_items?(pc, WARSPIRIT_TOTEM)
          html = "30649-01.html"
        end
      when SEER_PEKIRON
        if !has_at_least_one_quest_item?(pc, PEKIRONS_TOTEM, TONARS_REMAINS1, TONARS_REMAINS2, VENDETTA_TOTEM)
          html = "30682-01.html"
        elsif has_quest_items?(pc, PEKIRONS_TOTEM)
          if has_quest_items?(pc, TONARS_SKULL, TONARS_RIB_BONE, TONARS_SPINE, TONARS_ARM_BONE, TONARS_THIGH_BONE)
            take_items(pc, PEKIRONS_TOTEM, 1)
            take_items(pc, TONARS_SKULL, 1)
            take_items(pc, TONARS_RIB_BONE, 1)
            take_items(pc, TONARS_SPINE, 1)
            take_items(pc, TONARS_ARM_BONE, 1)
            take_items(pc, TONARS_THIGH_BONE, 1)
            give_items(pc, TONARS_REMAINS1, 1)
            if has_quest_items?(pc, BRAKIS_REMAINS1, HERMODTS_REMAINS1, KIRUNAS_REMAINS1)
              qs.set_cond(2)
            end
            html = "30682-04.html"
          else
            html = "30682-03.html"
          end
        elsif !has_quest_items?(pc, PEKIRONS_TOTEM)
          if has_at_least_one_quest_item?(pc, TONARS_REMAINS1, TONARS_REMAINS2, VENDETTA_TOTEM)
            html = "30682-05.html"
          end
        end
      end
    elsif qs.completed?
      if npc.id == SEER_SOMAK
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
