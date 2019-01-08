class Quests::Q00220_TestimonyOfGlory < Quest
  # NPCs
  private PREFECT_KASMAN = 30501
  private PREFECT_VOKIAN = 30514
  private SEER_MANAKIA = 30515
  private FLAME_LORD_KAKAI = 30565
  private SEER_TANAPI = 30571
  private BREKA_CHIEF_VOLTAR = 30615
  private ENKU_CHIEF_KEPRA = 30616
  private TUREK_CHIEF_BURAI = 30617
  private LEUNT_CHIEF_HARAK = 30618
  private VUKU_CHIEF_DRIKO = 30619
  private GANDI_CHIEF_CHIANTA = 30642
  # Items
  private VOKIANS_ORDER = 3204
  private MANASHEN_SHARD = 3205
  private TYRANT_TALON = 3206
  private GUARDIAN_BASILISK_FANG = 3207
  private VOKIANS_ORDER2 = 3208
  private NECKLACE_OF_AUTHORITY = 3209
  private CHIANTA_1ST_ORDER = 3210
  private SCEPTER_OF_BREKA = 3211
  private SCEPTER_OF_ENKU = 3212
  private SCEPTER_OF_VUKU = 3213
  private SCEPTER_OF_TUREK = 3214
  private SCEPTER_OF_TUNATH = 3215
  private CHIANTA_2ND_ORDER = 3216
  private CHIANTA_3RD_ORDER = 3217
  private TAMLIN_ORC_SKULL = 3218
  private TIMAK_ORC_HEAD = 3219
  private SCEPTER_BOX = 3220
  private PASHIKAS_HEAD = 3221
  private VULTUS_HEAD = 3222
  private GLOVE_OF_VOLTAR = 3223
  private ENKU_OVERLORD_HEAD = 3224
  private GLOVE_OF_KEPRA = 3225
  private MAKUM_BUGBEAR_HEAD = 3226
  private GLOVE_OF_BURAI = 3227
  private MANAKIA_1ST_LETTER = 3228
  private MANAKIA_2ND_LETTER = 3229
  private KASMANS_1ST_LETTER = 3230
  private KASMANS_2ND_LETTER = 3231
  private KASMANS_3RD_LETTER = 3232
  private DRIKOS_CONTRACT = 3233
  private STAKATO_DRONE_HUSK = 3234
  private TANAPIS_ORDER = 3235
  private SCEPTER_OF_TANTOS = 3236
  private RITUAL_BOX = 3237
  # Reward
  private MARK_OF_GLORY = 3203
  private DIMENSIONAL_DIAMOND = 7562
  # Monster
  private TYRANT = 20192
  private TYRANT_KINGPIN = 20193
  private MARSH_STAKATO_DRONE = 20234
  private GUARDIAN_BASILISK = 20550
  private MANASHEN_GARGOYLE = 20563
  private TIMAK_ORC = 20583
  private TIMAK_ORC_ARCHER = 20584
  private TIMAK_ORC_SOLDIER = 20585
  private TIMAK_ORC_WARRIOR = 20586
  private TIMAK_ORC_SHAMAN = 20587
  private TIMAK_ORC_OVERLORD = 20588
  private TAMLIN_ORC = 20601
  private TAMLIN_ORC_ARCHER = 20602
  private RAGNA_ORC_OVERLORD = 20778
  private RAGNA_ORC_SEER = 20779
  # Quest Monster
  private PASHIKA_SON_OF_VOLTAR = 27080
  private VULTUS_SON_OF_VOLTAR = 27081
  private ENKU_ORC_OVERLORD = 27082
  private MAKUM_BUGBEAR_THUG = 27083
  private REVENANT_OF_TANTOS_CHIEF = 27086
  # Misc
  private MIN_LEVEL = 37

  def initialize
    super(220, self.class.simple_name, "Testimony Of Glory")

    add_start_npc(PREFECT_VOKIAN)
    add_talk_id(PREFECT_VOKIAN, PREFECT_KASMAN, SEER_MANAKIA, FLAME_LORD_KAKAI, SEER_TANAPI, BREKA_CHIEF_VOLTAR, ENKU_CHIEF_KEPRA, TUREK_CHIEF_BURAI, LEUNT_CHIEF_HARAK, VUKU_CHIEF_DRIKO, GANDI_CHIEF_CHIANTA)
    add_kill_id(TYRANT, TYRANT_KINGPIN, MARSH_STAKATO_DRONE, GUARDIAN_BASILISK, MANASHEN_GARGOYLE, TIMAK_ORC, TIMAK_ORC_ARCHER, TIMAK_ORC_SOLDIER, TIMAK_ORC_WARRIOR, TIMAK_ORC_SHAMAN, TIMAK_ORC_OVERLORD, TAMLIN_ORC, TAMLIN_ORC_ARCHER, RAGNA_ORC_OVERLORD, RAGNA_ORC_SEER, PASHIKA_SON_OF_VOLTAR, VULTUS_SON_OF_VOLTAR, ENKU_ORC_OVERLORD, MAKUM_BUGBEAR_THUG, REVENANT_OF_TANTOS_CHIEF)
    add_attack_id(RAGNA_ORC_OVERLORD, RAGNA_ORC_SEER, REVENANT_OF_TANTOS_CHIEF)
    register_quest_items(VOKIANS_ORDER, MANASHEN_SHARD, TYRANT_TALON, GUARDIAN_BASILISK_FANG, VOKIANS_ORDER2, NECKLACE_OF_AUTHORITY, CHIANTA_1ST_ORDER, SCEPTER_OF_BREKA, SCEPTER_OF_ENKU, SCEPTER_OF_VUKU, SCEPTER_OF_TUREK, SCEPTER_OF_TUNATH, CHIANTA_2ND_ORDER, CHIANTA_3RD_ORDER, TAMLIN_ORC_SKULL, TIMAK_ORC_HEAD, SCEPTER_BOX, PASHIKAS_HEAD, VULTUS_HEAD, GLOVE_OF_VOLTAR, ENKU_OVERLORD_HEAD, GLOVE_OF_KEPRA, MAKUM_BUGBEAR_HEAD, GLOVE_OF_BURAI, MANAKIA_1ST_LETTER, MANAKIA_2ND_LETTER, KASMANS_1ST_LETTER, KASMANS_2ND_LETTER, KASMANS_3RD_LETTER, DRIKOS_CONTRACT, STAKATO_DRONE_HUSK, TANAPIS_ORDER, SCEPTER_OF_TANTOS, RITUAL_BOX)
  end

  def on_adv_event(event, npc, player)
    raise "no npc" unless npc
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        play_sound(player, Sound::ITEMSOUND_QUEST_MIDDLE)
        give_items(player, VOKIANS_ORDER, 1)
        if player.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(player, DIMENSIONAL_DIAMOND, 109)
          player.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          htmltext = "30514-05a.htm"
        else
          htmltext = "30514-05.htm"
        end
      end
    when "30514-04.htm", "30514-07.html", "30571-02.html", "30615-03.html",
         "30616-03.html", "30642-02.html", "30642-06.html", "30642-08.html"
      htmltext = event
    when "30501-02.html"
      if has_quest_items?(player, SCEPTER_OF_VUKU)
        htmltext = event
      elsif !has_at_least_one_quest_item?(player, SCEPTER_OF_VUKU, KASMANS_1ST_LETTER)
        give_items(player, KASMANS_1ST_LETTER, 1)
        player.radar.add_marker(-2150, 124443, -3724)
        htmltext = "30501-03.html"
      elsif !has_quest_items?(player, SCEPTER_OF_VUKU) && has_at_least_one_quest_item?(player, KASMANS_1ST_LETTER, DRIKOS_CONTRACT)
        player.radar.add_marker(-2150, 124443, -3724)
        htmltext = "30501-04.html"
      end
    when "30501-05.html"
      if has_quest_items?(player, SCEPTER_OF_TUREK)
        htmltext = event
      elsif !has_at_least_one_quest_item?(player, SCEPTER_OF_TUREK, KASMANS_2ND_LETTER)
        give_items(player, KASMANS_2ND_LETTER, 1)
        player.radar.add_marker(-94294, 110818, -3563)
        htmltext = "30501-06.html"
      elsif !has_quest_items?(player, SCEPTER_OF_TUREK) && has_quest_items?(player, KASMANS_2ND_LETTER)
        player.radar.add_marker(-94294, 110818, -3563)
        htmltext = "30501-07.html"
      end
    when "30501-08.html"
      if has_quest_items?(player, SCEPTER_OF_TUNATH)
        htmltext = event
      elsif !has_at_least_one_quest_item?(player, SCEPTER_OF_TUNATH, KASMANS_3RD_LETTER)
        give_items(player, KASMANS_3RD_LETTER, 1)
        player.radar.add_marker(-55217, 200628, -3724)
        htmltext = "30501-09.html"
      elsif !has_quest_items?(player, SCEPTER_OF_TUNATH) && has_quest_items?(player, KASMANS_3RD_LETTER)
        player.radar.add_marker(-55217, 200628, -3724)
        htmltext = "30501-10.html"
      end
    when "30515-04.html"
      if !has_quest_items?(player, SCEPTER_OF_BREKA) && has_quest_items?(player, MANAKIA_1ST_LETTER)
        player.radar.add_marker(80100, 119991, -2264)
        htmltext = event
      elsif has_quest_items?(player, SCEPTER_OF_BREKA)
        htmltext = "30515-02.html"
      elsif !has_at_least_one_quest_item?(player, SCEPTER_OF_BREKA, MANAKIA_1ST_LETTER)
        give_items(player, MANAKIA_1ST_LETTER, 1)
        player.radar.add_marker(80100, 119991, -2264)
        htmltext = "30515-03.html"
      end
    when "30515-05.html"
      if has_quest_items?(player, SCEPTER_OF_ENKU)
        htmltext = event
      elsif !has_at_least_one_quest_item?(player, SCEPTER_OF_ENKU, MANAKIA_2ND_LETTER)
        give_items(player, MANAKIA_2ND_LETTER, 1)
        player.radar.add_marker(12805, 189249, -3616)
        htmltext = "30515-06.html"
      elsif !has_quest_items?(player, SCEPTER_OF_ENKU) && has_quest_items?(player, MANAKIA_2ND_LETTER)
        player.radar.add_marker(12805, 189249, -3616)
        htmltext = "30515-07.html"
      end
    when "30571-03.html"
      if has_quest_items?(player, SCEPTER_BOX)
        take_items(player, SCEPTER_BOX, 1)
        give_items(player, TANAPIS_ORDER, 1)
        qs.set_cond(9, true)
        htmltext = event
      end
    when "30615-04.html"
      if has_quest_items?(player, MANAKIA_1ST_LETTER)
        give_items(player, GLOVE_OF_VOLTAR, 1)
        take_items(player, MANAKIA_1ST_LETTER, 1)
        add_attack_desire(add_spawn(npc, PASHIKA_SON_OF_VOLTAR, npc, true, 200000), player)
        add_attack_desire(add_spawn(npc, VULTUS_SON_OF_VOLTAR, npc, true, 200000), player)
        htmltext = event
      end
    when "30616-04.html"
      if has_quest_items?(player, MANAKIA_2ND_LETTER)
        give_items(player, GLOVE_OF_KEPRA, 1)
        take_items(player, MANAKIA_2ND_LETTER, 1)
        add_attack_desire(add_spawn(npc, ENKU_ORC_OVERLORD, npc, true, 200000), player)
        add_attack_desire(add_spawn(npc, ENKU_ORC_OVERLORD, npc, true, 200000), player)
        add_attack_desire(add_spawn(npc, ENKU_ORC_OVERLORD, npc, true, 200000), player)
        add_attack_desire(add_spawn(npc, ENKU_ORC_OVERLORD, npc, true, 200000), player)
        htmltext = event
      end
    when "30617-03.html"
      if has_quest_items?(player, KASMANS_2ND_LETTER)
        give_items(player, GLOVE_OF_BURAI, 1)
        take_items(player, KASMANS_2ND_LETTER, 1)
        add_attack_desire(add_spawn(npc, MAKUM_BUGBEAR_THUG, npc, true, 200000), player)
        add_attack_desire(add_spawn(npc, MAKUM_BUGBEAR_THUG, npc, true, 200000), player)
        htmltext = event
      end
    when "30618-03.html"
      if has_quest_items?(player, KASMANS_3RD_LETTER)
        give_items(player, SCEPTER_OF_TUNATH, 1)
        take_items(player, KASMANS_3RD_LETTER, 1)
        if has_quest_items?(player, SCEPTER_OF_TUREK, SCEPTER_OF_ENKU, SCEPTER_OF_BREKA, SCEPTER_OF_VUKU)
          qs.set_cond(5, true)
        end
        htmltext = event
      end
    when "30619-03.html"
      if has_quest_items?(player, KASMANS_1ST_LETTER)
        give_items(player, DRIKOS_CONTRACT, 1)
        take_items(player, KASMANS_1ST_LETTER, 1)
        htmltext = event
      end
    when "30642-03.html"
      if has_quest_items?(player, VOKIANS_ORDER2)
        take_items(player, VOKIANS_ORDER2, 1)
        give_items(player, CHIANTA_1ST_ORDER, 1)
        qs.set_cond(4, true)
        htmltext = event
      end
    when "30642-07.html"
      if has_quest_items?(player, CHIANTA_1ST_ORDER, SCEPTER_OF_BREKA, SCEPTER_OF_VUKU, SCEPTER_OF_TUREK, SCEPTER_OF_TUNATH, SCEPTER_OF_ENKU)
        take_items(player, CHIANTA_1ST_ORDER, 1)
        take_items(player, SCEPTER_OF_BREKA, 1)
        take_items(player, SCEPTER_OF_ENKU, 1)
        take_items(player, SCEPTER_OF_VUKU, 1)
        take_items(player, SCEPTER_OF_TUREK, 1)
        take_items(player, SCEPTER_OF_TUNATH, 1)
        take_items(player, MANAKIA_1ST_LETTER, 1)
        take_items(player, MANAKIA_2ND_LETTER, 1)
        take_items(player, KASMANS_1ST_LETTER, 1)
        give_items(player, CHIANTA_3RD_ORDER, 1)
        qs.set_cond(6, true)
        htmltext = event
      end
    end

    htmltext
  end

  def on_attack(npc, attacker, damage, is_summon)
    qs = get_quest_state(attacker, false)
    if qs && qs.started?
      case npc.id
      when RAGNA_ORC_OVERLORD, RAGNA_ORC_SEER
        case npc.script_value
        when 0
          npc.variables["lastAttacker"] = attacker.l2id
          if !has_quest_items?(attacker, SCEPTER_OF_TANTOS)
            npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::IS_IT_A_LACKEY_OF_KAKAI))
            npc.script_value = 1
          end
        when 1
          npc.script_value = 2
        end
      when REVENANT_OF_TANTOS_CHIEF
        case npc.script_value
        when 0
          npc.variables["lastAttacker"] = attacker.l2id
          unless has_quest_items?(attacker, SCEPTER_OF_TANTOS)
            npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::HOW_REGRETFUL_UNJUST_DISHONOR))
            npc.script_value = 1
          end
        when 1
          if !has_quest_items?(attacker, SCEPTER_OF_TANTOS) && npc.current_hp < (npc.max_hp / 3)
            npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::INDIGNANT_AND_UNFAIR_DEATH))
            npc.script_value = 2
          end
        end
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when TYRANT, TYRANT_KINGPIN
        if has_quest_items?(killer, VOKIANS_ORDER) && get_quest_items_count(killer, TYRANT_TALON) < 10
          if get_quest_items_count(killer, TYRANT_TALON) == 9
            give_items(killer, TYRANT_TALON, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if get_quest_items_count(killer, MANASHEN_SHARD) >= 10 && get_quest_items_count(killer, GUARDIAN_BASILISK_FANG) >= 10
              qs.set_cond(2)
            end
          else
            give_items(killer, TYRANT_TALON, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when MARSH_STAKATO_DRONE
        if !has_quest_items?(killer, SCEPTER_OF_VUKU) && has_quest_items?(killer, NECKLACE_OF_AUTHORITY, CHIANTA_1ST_ORDER, DRIKOS_CONTRACT) && get_quest_items_count(killer, STAKATO_DRONE_HUSK) < 30
          if get_quest_items_count(killer, TYRANT_TALON) == 29
            give_items(killer, STAKATO_DRONE_HUSK, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            give_items(killer, STAKATO_DRONE_HUSK, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when GUARDIAN_BASILISK
        if has_quest_items?(killer, VOKIANS_ORDER) && get_quest_items_count(killer, GUARDIAN_BASILISK_FANG) < 10
          if get_quest_items_count(killer, GUARDIAN_BASILISK_FANG) == 9
            give_items(killer, GUARDIAN_BASILISK_FANG, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if get_quest_items_count(killer, MANASHEN_SHARD) >= 10 && get_quest_items_count(killer, TYRANT_TALON) >= 10
              qs.set_cond(2)
            end
          else
            give_items(killer, GUARDIAN_BASILISK_FANG, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when MANASHEN_GARGOYLE
        if has_quest_items?(killer, VOKIANS_ORDER) && get_quest_items_count(killer, MANASHEN_SHARD) < 10
          if get_quest_items_count(killer, MANASHEN_SHARD) == 9
            give_items(killer, MANASHEN_SHARD, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if get_quest_items_count(killer, TYRANT_TALON) >= 10 && get_quest_items_count(killer, GUARDIAN_BASILISK_FANG) >= 10
              qs.set_cond(2)
            end
          else
            give_items(killer, MANASHEN_SHARD, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when TIMAK_ORC, TIMAK_ORC_ARCHER, TIMAK_ORC_SOLDIER, TIMAK_ORC_WARRIOR, TIMAK_ORC_SHAMAN, TIMAK_ORC_OVERLORD
        if has_quest_items?(killer, NECKLACE_OF_AUTHORITY, CHIANTA_3RD_ORDER) && get_quest_items_count(killer, TIMAK_ORC_HEAD) < 20
          if get_quest_items_count(killer, MANASHEN_SHARD) == 19
            give_items(killer, TIMAK_ORC_HEAD, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if get_quest_items_count(killer, TAMLIN_ORC_SKULL) >= 20
              qs.set_cond(7)
            end
          else
            give_items(killer, TIMAK_ORC_HEAD, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when TAMLIN_ORC, TAMLIN_ORC_ARCHER
        if has_quest_items?(killer, NECKLACE_OF_AUTHORITY, CHIANTA_3RD_ORDER) && get_quest_items_count(killer, TAMLIN_ORC_SKULL) < 20
          if get_quest_items_count(killer, TAMLIN_ORC_SKULL) == 19
            give_items(killer, TAMLIN_ORC_SKULL, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if get_quest_items_count(killer, TIMAK_ORC_HEAD) >= 20
              qs.set_cond(7)
            end
          else
            give_items(killer, TAMLIN_ORC_SKULL, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when RAGNA_ORC_OVERLORD, RAGNA_ORC_SEER
        if has_quest_items?(killer, TANAPIS_ORDER) && !has_quest_items?(killer, SCEPTER_OF_TANTOS)
          add_spawn(REVENANT_OF_TANTOS_CHIEF, npc, true, 200000)
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::TOO_LATE))
        end
      when PASHIKA_SON_OF_VOLTAR
        if has_quest_items?(killer, NECKLACE_OF_AUTHORITY, CHIANTA_1ST_ORDER, GLOVE_OF_VOLTAR) && !has_quest_items?(killer, PASHIKAS_HEAD)
          if has_quest_items?(killer, VULTUS_HEAD)
            give_items(killer, PASHIKAS_HEAD, 1)
            take_items(killer, GLOVE_OF_VOLTAR, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            give_items(killer, PASHIKAS_HEAD, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when VULTUS_SON_OF_VOLTAR
        if has_quest_items?(killer, NECKLACE_OF_AUTHORITY, CHIANTA_1ST_ORDER, GLOVE_OF_VOLTAR) && !has_quest_items?(killer, VULTUS_HEAD)
          if has_quest_items?(killer, PASHIKAS_HEAD)
            give_items(killer, VULTUS_HEAD, 1)
            take_items(killer, GLOVE_OF_VOLTAR, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            give_items(killer, VULTUS_HEAD, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when ENKU_ORC_OVERLORD
        if has_quest_items?(killer, NECKLACE_OF_AUTHORITY, CHIANTA_1ST_ORDER, GLOVE_OF_KEPRA) && get_quest_items_count(killer, ENKU_OVERLORD_HEAD) < 4
          if get_quest_items_count(killer, ENKU_OVERLORD_HEAD) == 3
            give_items(killer, ENKU_OVERLORD_HEAD, 1)
            take_items(killer, GLOVE_OF_KEPRA, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            give_items(killer, ENKU_OVERLORD_HEAD, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when MAKUM_BUGBEAR_THUG
        if has_quest_items?(killer, NECKLACE_OF_AUTHORITY, CHIANTA_1ST_ORDER, GLOVE_OF_BURAI) && get_quest_items_count(killer, MAKUM_BUGBEAR_HEAD) < 2
          if get_quest_items_count(killer, MAKUM_BUGBEAR_HEAD) == 1
            give_items(killer, MAKUM_BUGBEAR_HEAD, 1)
            take_items(killer, GLOVE_OF_BURAI, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            give_items(killer, MAKUM_BUGBEAR_HEAD, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when REVENANT_OF_TANTOS_CHIEF
        if has_quest_items?(killer, TANAPIS_ORDER) && !has_quest_items?(killer, SCEPTER_OF_TANTOS)
          give_items(killer, SCEPTER_OF_TANTOS, 1)
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::ILL_GET_REVENGE_SOMEDAY))
          qs.set_cond(10, true)
        end
      end
    end

    super
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)
    if qs.created?
      if npc.id == PREFECT_VOKIAN
        if player.race.orc?
          if player.level >= MIN_LEVEL && player.in_category?(CategoryType::ORC_2ND_GROUP)
            htmltext = "30514-03.htm"
          elsif player.level >= MIN_LEVEL
            htmltext = "30514-01a.html"
          else
            htmltext = "30514-02.html"
          end
        else
          htmltext = "30514-01.html"
        end
      end
    elsif qs.started?
      case npc.id
      when PREFECT_VOKIAN
        if has_quest_items?(player, VOKIANS_ORDER)
          if get_quest_items_count(player, MANASHEN_SHARD) >= 10 && get_quest_items_count(player, TYRANT_TALON) >= 10 && get_quest_items_count(player, GUARDIAN_BASILISK_FANG) >= 10
            take_items(player, VOKIANS_ORDER, 1)
            take_items(player, MANASHEN_SHARD, -1)
            take_items(player, TYRANT_TALON, -1)
            take_items(player, GUARDIAN_BASILISK_FANG, -1)
            give_items(player, VOKIANS_ORDER2, 1)
            give_items(player, NECKLACE_OF_AUTHORITY, 1)
            qs.set_cond(3, true)
            htmltext = "30514-08.html"
          else
            htmltext = "30514-06.html"
          end
        elsif has_quest_items?(player, VOKIANS_ORDER2, NECKLACE_OF_AUTHORITY)
          htmltext = "30514-09.html"
        elsif !has_quest_items?(player, NECKLACE_OF_AUTHORITY) && has_at_least_one_quest_item?(player, VOKIANS_ORDER2, SCEPTER_BOX)
          htmltext = "30514-10.html"
        end
      when PREFECT_KASMAN
        if has_quest_items?(player, NECKLACE_OF_AUTHORITY, CHIANTA_1ST_ORDER)
          htmltext = "30501-01.html"
        elsif has_at_least_one_quest_item?(player, CHIANTA_2ND_ORDER, CHIANTA_3RD_ORDER, SCEPTER_BOX)
          htmltext = "30501-11.html"
        end
      when SEER_MANAKIA
        if has_quest_items?(player, NECKLACE_OF_AUTHORITY, CHIANTA_1ST_ORDER)
          htmltext = "30515-01.html"
        elsif has_at_least_one_quest_item?(player, CHIANTA_2ND_ORDER, CHIANTA_3RD_ORDER, SCEPTER_BOX)
          htmltext = "30515-08.html"
        end
      when FLAME_LORD_KAKAI
        if !has_quest_items?(player, RITUAL_BOX) && has_at_least_one_quest_item?(player, SCEPTER_BOX, TANAPIS_ORDER)
          htmltext = "30565-01.html"
        elsif has_quest_items?(player, RITUAL_BOX)
          give_adena(player, 262720, true)
          give_items(player, MARK_OF_GLORY, 1)
          add_exp_and_sp(player, 1448226, 96648)
          qs.exit_quest(false, true)
          player.send_packet(SocialAction.new(player.l2id, 3))
          htmltext = "30565-02.html"
        end
      when SEER_TANAPI
        if has_quest_items?(player, SCEPTER_BOX)
          htmltext = "30571-01.html"
        elsif has_quest_items?(player, TANAPIS_ORDER)
          if !has_quest_items?(player, SCEPTER_OF_TANTOS)
            htmltext = "30571-04.html"
          else
            take_items(player, TANAPIS_ORDER, 1)
            take_items(player, SCEPTER_OF_TANTOS, 1)
            give_items(player, RITUAL_BOX, 1)
            qs.set_cond(11, true)
            htmltext = "30571-05.html"
          end
        elsif has_quest_items?(player, RITUAL_BOX)
          htmltext = "30571-06.html"
        end
      when BREKA_CHIEF_VOLTAR
        if has_quest_items?(player, NECKLACE_OF_AUTHORITY, CHIANTA_1ST_ORDER)
          if !has_at_least_one_quest_item?(player, SCEPTER_OF_BREKA, MANAKIA_1ST_LETTER, GLOVE_OF_VOLTAR, PASHIKAS_HEAD, VULTUS_HEAD)
            htmltext = "30615-01.html"
          elsif has_quest_items?(player, MANAKIA_1ST_LETTER)
            htmltext = "30615-02.html"
            player.radar.remove_marker(80100, 119991, -2264)
          elsif !has_quest_items?(player, SCEPTER_OF_BREKA) && has_quest_items?(player, GLOVE_OF_VOLTAR) && ((get_quest_items_count(player, PASHIKAS_HEAD) + get_quest_items_count(player, VULTUS_HEAD)) < 2)
            if npc.summoned_npc_count < 2
              add_attack_desire(add_spawn(npc, PASHIKA_SON_OF_VOLTAR, npc, true, 200000), player)
              add_attack_desire(add_spawn(npc, VULTUS_SON_OF_VOLTAR, npc, true, 200000), player)
            end
            htmltext = "30615-05.html"
          elsif has_quest_items?(player, PASHIKAS_HEAD, VULTUS_HEAD)
            give_items(player, SCEPTER_OF_BREKA, 1)
            take_items(player, PASHIKAS_HEAD, 1)
            take_items(player, VULTUS_HEAD, 1)
            if has_quest_items?(player, SCEPTER_OF_ENKU, SCEPTER_OF_VUKU, SCEPTER_OF_TUREK, SCEPTER_OF_TUNATH)
              qs.set_cond(5, true)
            end
            htmltext = "30615-06.html"
          elsif has_quest_items?(player, SCEPTER_OF_BREKA)
            htmltext = "30615-07.html"
          end
        elsif has_at_least_one_quest_item?(player, CHIANTA_2ND_ORDER, CHIANTA_3RD_ORDER, SCEPTER_BOX)
          htmltext = "30615-08.html"
        end
      when ENKU_CHIEF_KEPRA
        if has_quest_items?(player, NECKLACE_OF_AUTHORITY, CHIANTA_1ST_ORDER)
          if !has_at_least_one_quest_item?(player, SCEPTER_OF_ENKU, MANAKIA_2ND_LETTER, GLOVE_OF_KEPRA) && ((get_quest_items_count(player, ENKU_OVERLORD_HEAD)) < 4)
            htmltext = "30616-01.html"
          elsif has_quest_items?(player, MANAKIA_2ND_LETTER)
            player.radar.remove_marker(12805, 189249, -3616)
            htmltext = "30616-02.html"
          elsif has_quest_items?(player, GLOVE_OF_KEPRA) && get_quest_items_count(player, ENKU_OVERLORD_HEAD) < 4
            if npc.summoned_npc_count < 5
              add_attack_desire(add_spawn(npc, ENKU_ORC_OVERLORD, npc, true, 200000), player)
            end
            htmltext = "30616-05.html"
          elsif get_quest_items_count(player, ENKU_OVERLORD_HEAD) >= 4
            give_items(player, SCEPTER_OF_ENKU, 1)
            take_items(player, ENKU_OVERLORD_HEAD, -1)
            if has_quest_items?(player, SCEPTER_OF_BREKA, SCEPTER_OF_VUKU, SCEPTER_OF_TUREK, SCEPTER_OF_TUNATH)
              qs.set_cond(5, true)
            end
            htmltext = "30616-06.html"
          elsif has_quest_items?(player, SCEPTER_OF_ENKU)
            htmltext = "30616-07.html"
          end
        elsif has_at_least_one_quest_item?(player, CHIANTA_2ND_ORDER, CHIANTA_3RD_ORDER, SCEPTER_BOX)
          htmltext = "30616-08.html"
        end
      when TUREK_CHIEF_BURAI
        if has_quest_items?(player, NECKLACE_OF_AUTHORITY, CHIANTA_1ST_ORDER)
          if !has_at_least_one_quest_item?(player, SCEPTER_OF_TUREK, KASMANS_2ND_LETTER, GLOVE_OF_BURAI, MAKUM_BUGBEAR_HEAD)
            htmltext = "30617-01.html"
          elsif has_quest_items?(player, KASMANS_2ND_LETTER)
            player.radar.remove_marker(-94294, 110818, -3563)
            htmltext = "30617-02.html"
          elsif has_quest_items?(player, GLOVE_OF_BURAI)
            if npc.summoned_npc_count < 3
              add_attack_desire(add_spawn(npc, MAKUM_BUGBEAR_THUG, npc, true, 200000), player)
              add_attack_desire(add_spawn(npc, MAKUM_BUGBEAR_THUG, npc, true, 200000), player)
            end
            htmltext = "30617-04.html"
          elsif get_quest_items_count(player, MAKUM_BUGBEAR_HEAD) >= 2
            give_items(player, SCEPTER_OF_TUREK, 1)
            take_items(player, MAKUM_BUGBEAR_HEAD, -1)
            if has_quest_items?(player, SCEPTER_OF_ENKU, SCEPTER_OF_BREKA, SCEPTER_OF_VUKU, SCEPTER_OF_TUNATH)
              qs.set_cond(5, true)
            end
            htmltext = "30617-05.html"
          elsif has_quest_items?(player, SCEPTER_OF_TUREK)
            htmltext = "30617-06.html"
          end
        elsif has_quest_items?(player, NECKLACE_OF_AUTHORITY) && has_at_least_one_quest_item?(player, CHIANTA_2ND_ORDER, CHIANTA_3RD_ORDER, SCEPTER_BOX)
          htmltext = "30617-07.html"
        end
      when LEUNT_CHIEF_HARAK
        if has_quest_items?(player, NECKLACE_OF_AUTHORITY, CHIANTA_1ST_ORDER)
          if !has_at_least_one_quest_item?(player, SCEPTER_OF_TUNATH, KASMANS_3RD_LETTER)
            htmltext = "30618-01.html"
          elsif !has_quest_items?(player, SCEPTER_OF_TUNATH) && has_quest_items?(player, KASMANS_3RD_LETTER)
            player.radar.remove_marker(-55217, 200628, -3724)
            htmltext = "30618-02.html"
          elsif has_quest_items?(player, SCEPTER_OF_TUNATH)
            htmltext = "30618-04.html"
          end
        elsif has_at_least_one_quest_item?(player, CHIANTA_2ND_ORDER, CHIANTA_3RD_ORDER, SCEPTER_BOX)
          htmltext = "30618-05.html"
        end
      when VUKU_CHIEF_DRIKO
        if has_quest_items?(player, NECKLACE_OF_AUTHORITY, CHIANTA_1ST_ORDER)
          if !has_at_least_one_quest_item?(player, SCEPTER_OF_VUKU, KASMANS_1ST_LETTER, DRIKOS_CONTRACT)
            htmltext = "30619-01.html"
          elsif !has_quest_items?(player, SCEPTER_OF_VUKU) && has_quest_items?(player, KASMANS_1ST_LETTER)
            player.radar.remove_marker(-2150, 124443, -3724)
            htmltext = "30619-02.html"
          elsif !has_quest_items?(player, SCEPTER_OF_VUKU) && has_quest_items?(player, DRIKOS_CONTRACT)
            if get_quest_items_count(player, STAKATO_DRONE_HUSK) < 30
              htmltext = "30619-04.html"
            else
              give_items(player, SCEPTER_OF_VUKU, 1)
              take_items(player, DRIKOS_CONTRACT, 1)
              take_items(player, STAKATO_DRONE_HUSK, -1)
              if has_quest_items?(player, SCEPTER_OF_TUREK, SCEPTER_OF_ENKU, SCEPTER_OF_BREKA, SCEPTER_OF_TUNATH)
                qs.set_cond(5, true)
              end
              htmltext = "30619-05.html"
            end
          elsif has_quest_items?(player, SCEPTER_OF_VUKU)
            htmltext = "30619-06.html"
          end
        elsif has_quest_items?(player, NECKLACE_OF_AUTHORITY) && has_at_least_one_quest_item?(player, CHIANTA_2ND_ORDER, CHIANTA_3RD_ORDER, SCEPTER_BOX)
          htmltext = "30619-07.html"
        end
      when GANDI_CHIEF_CHIANTA
        if has_quest_items?(player, NECKLACE_OF_AUTHORITY, VOKIANS_ORDER2)
          htmltext = "30642-01.html"
        elsif has_quest_items?(player, NECKLACE_OF_AUTHORITY, CHIANTA_1ST_ORDER)
          if (get_quest_items_count(player, SCEPTER_OF_BREKA) + get_quest_items_count(player, SCEPTER_OF_VUKU) + get_quest_items_count(player, SCEPTER_OF_TUREK) + get_quest_items_count(player, SCEPTER_OF_TUNATH) + get_quest_items_count(player, SCEPTER_OF_ENKU)) < 5
            htmltext = "30642-04.html"
          elsif has_quest_items?(player, SCEPTER_OF_BREKA, SCEPTER_OF_VUKU, SCEPTER_OF_TUREK, SCEPTER_OF_TUNATH, SCEPTER_OF_ENKU)
            htmltext = "30642-05.html"
          end
        elsif has_quest_items?(player, NECKLACE_OF_AUTHORITY, CHIANTA_2ND_ORDER)
          give_items(player, CHIANTA_3RD_ORDER, 1)
          take_items(player, CHIANTA_2ND_ORDER, 1)
          htmltext = "30642-09.html"
        elsif has_quest_items?(player, NECKLACE_OF_AUTHORITY, CHIANTA_3RD_ORDER)
          if get_quest_items_count(player, TAMLIN_ORC_SKULL) >= 20 && get_quest_items_count(player, TIMAK_ORC_HEAD) >= 20
            take_items(player, NECKLACE_OF_AUTHORITY, 1)
            take_items(player, CHIANTA_3RD_ORDER, 1)
            take_items(player, TAMLIN_ORC_SKULL, -1)
            take_items(player, TIMAK_ORC_HEAD, -1)
            give_items(player, SCEPTER_BOX, 1)
            qs.set_cond(8, true)
            htmltext = "30642-11.html"
          else
            htmltext = "30642-10.html"
          end
        elsif has_quest_items?(player, SCEPTER_BOX)
          htmltext = "30642-12.html"
        elsif has_at_least_one_quest_item?(player, TANAPIS_ORDER, RITUAL_BOX)
          htmltext = "30642-13.html"
        end
      end
    elsif qs.completed?
      if npc.id == PREFECT_VOKIAN
        htmltext = get_already_completed_msg(player)
      end
    end

    htmltext
  end
end
