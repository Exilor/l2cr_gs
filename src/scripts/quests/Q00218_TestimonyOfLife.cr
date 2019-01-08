class Quests::Q00218_TestimonyOfLife < Quest
  # NPCs
  private HIERARCH_ASTERIOS = 30154
  private BLACKSMITH_PUSHKIN = 30300
  private THALIA = 30371
  private PRIEST_ADONIUS = 30375
  private ARKENIA = 30419
  private MASTER_CARDIEN = 30460
  private ISAEL_SILVERSHADOW = 30655
  # Items
  private TALINS_SPEAR = 3026
  private CARDIENS_LETTER = 3141
  private CAMOMILE_CHARM = 3142
  private HIERARCHS_LETTER = 3143
  private MOONFLOWER_CHARM = 3144
  private GRAIL_DIAGRAM = 3145
  private THALIAS_1ST_LETTER = 3146
  private THALIAS_2ND_LETTER = 3147
  private THALIAS_INSTRUCTIONS = 3148
  private PUSHKINS_LIST = 3149
  private PURE_MITHRIL_CUP = 3150
  private ARKENIAS_CONTRACT = 3151
  private ARKENIAS_INSTRUCTIONS = 3152
  private ADONIUS_LIST = 3153
  private ANDARIEL_SCRIPTURE_COPY = 3154
  private STARDUST = 3155
  private ISAELS_INSTRUCTIONS = 3156
  private ISAELS_LETTER = 3157
  private GRAIL_OF_PURITY = 3158
  private TEARS_OF_UNICORN = 3159
  private WATER_OF_LIFE = 3160
  private PURE_MITHRIL_ORE = 3161
  private ANT_SOLDIER_ACID = 3162
  private WYRMS_TALON = 3163
  private SPIDER_ICHOR = 3164
  private HARPYS_DOWN = 3165
  private TALINS_SPEAR_BLADE = 3166
  private TALINS_SPEAR_SHAFT = 3167
  private TALINS_RUBY = 3168
  private TALINS_AQUAMARINE = 3169
  private TALINS_AMETHYST = 3170
  private TALINS_PERIDOT = 3171
  # Reward
  private MARK_OF_LIFE = 3140
  private DIMENSIONAL_DIAMOND = 7562
  # Monster
  private ANT_RECRUIT = 20082
  private ANT_PATROL = 20084
  private ANT_GUARD = 20086
  private ANT_SOLDIER = 20087
  private ANT_WARRIOR_CAPTAIN = 20088
  private HARPY = 20145
  private WYRM = 20176
  private MARSH_SPIDER = 20233
  private GUARDIAN_BASILISK = 20550
  private LETO_LIZARDMAN_SHAMAN = 20581
  private LETO_LIZARDMAN_OVERLORD = 20582
  # Quest Monster
  private UNICORN_OF_EVA = 27077
  # Misc
  private MIN_LEVEL = 37
  private LEVEL = 38

  def initialize
    super(218, self.class.simple_name, "Testimony Of Life")

    add_start_npc(MASTER_CARDIEN)
    add_talk_id(MASTER_CARDIEN, HIERARCH_ASTERIOS, BLACKSMITH_PUSHKIN, THALIA, PRIEST_ADONIUS, ARKENIA, ISAEL_SILVERSHADOW)
    add_kill_id(ANT_RECRUIT, ANT_PATROL, ANT_GUARD, ANT_SOLDIER, ANT_WARRIOR_CAPTAIN, HARPY, WYRM, MARSH_SPIDER, GUARDIAN_BASILISK, LETO_LIZARDMAN_SHAMAN, LETO_LIZARDMAN_OVERLORD, UNICORN_OF_EVA)
    register_quest_items(TALINS_SPEAR, CARDIENS_LETTER, CAMOMILE_CHARM, HIERARCHS_LETTER, MOONFLOWER_CHARM, GRAIL_DIAGRAM, THALIAS_1ST_LETTER, THALIAS_2ND_LETTER, THALIAS_INSTRUCTIONS, PUSHKINS_LIST, PURE_MITHRIL_CUP, ARKENIAS_CONTRACT, ARKENIAS_INSTRUCTIONS, ADONIUS_LIST, ANDARIEL_SCRIPTURE_COPY, STARDUST, ISAELS_INSTRUCTIONS, ISAELS_LETTER, GRAIL_OF_PURITY, TEARS_OF_UNICORN, WATER_OF_LIFE, PURE_MITHRIL_ORE, ANT_SOLDIER_ACID, WYRMS_TALON, SPIDER_ICHOR, HARPYS_DOWN, TALINS_SPEAR_BLADE, TALINS_SPEAR_SHAFT, TALINS_RUBY, TALINS_AQUAMARINE, TALINS_AMETHYST, TALINS_PERIDOT)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        if !has_quest_items?(player, CARDIENS_LETTER)
          give_items(player, CARDIENS_LETTER, 1)
        end
        play_sound(player, Sound::ITEMSOUND_QUEST_MIDDLE)
        if player.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(player, DIMENSIONAL_DIAMOND, 102)
          player.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          htmltext = "30460-04a.htm"
        else
          htmltext = "30460-04.htm"
        end
      end
    when "30154-02.html", "30154-03.html", "30154-04.html", "30154-05.html",
         "30154-06.html", "30300-02.html", "30300-03.html", "30300-04.html",
         "30300-05.html", "30300-09.html", "30300-07a.html", "30371-02.html",
         "30371-10.html", "30419-02.html", "30419-03.html"
      htmltext = event
    when "30154-07.html"
      if has_quest_items?(player, CARDIENS_LETTER)
        take_items(player, CARDIENS_LETTER, 1)
        give_items(player, HIERARCHS_LETTER, 1)
        give_items(player, MOONFLOWER_CHARM, 1)
        qs.set_cond(2, true)
        htmltext = event
      end
    when "30300-06.html"
      if has_quest_items?(player, GRAIL_DIAGRAM)
        take_items(player, GRAIL_DIAGRAM, 1)
        give_items(player, PUSHKINS_LIST, 1)
        qs.set_cond(4, true)
        htmltext = event
      end
    when "30300-10.html"
      if has_quest_items?(player, PUSHKINS_LIST)
        take_items(player, PUSHKINS_LIST, 1)
        give_items(player, PURE_MITHRIL_CUP, 1)
        take_items(player, PURE_MITHRIL_ORE, -1)
        take_items(player, ANT_SOLDIER_ACID, -1)
        take_items(player, WYRMS_TALON, -1)
        qs.set_cond(6, true)
        htmltext = event
      end
    when "30371-03.html"
      if has_quest_items?(player, HIERARCHS_LETTER)
        take_items(player, HIERARCHS_LETTER, 1)
        give_items(player, GRAIL_DIAGRAM, 1)
        qs.set_cond(3, true)
        htmltext = event
      end
    when "30371-11.html"
      if has_quest_items?(player, STARDUST)
        give_items(player, THALIAS_2ND_LETTER, 1)
        take_items(player, STARDUST, 1)
        qs.set_cond(14, true)
        htmltext = event
      end
    when "30419-04.html"
      if has_quest_items?(player, THALIAS_1ST_LETTER)
        take_items(player, THALIAS_1ST_LETTER, 1)
        give_items(player, ARKENIAS_CONTRACT, 1)
        give_items(player, ARKENIAS_INSTRUCTIONS, 1)
        qs.set_cond(8, true)
        htmltext = event
      end
    when "30375-02.html"
      if has_quest_items?(player, ARKENIAS_INSTRUCTIONS)
        take_items(player, ARKENIAS_INSTRUCTIONS, 1)
        give_items(player, ADONIUS_LIST, 1)
        qs.set_cond(9, true)
        htmltext = event
      end
    when "30655-02.html"
      if has_quest_items?(player, THALIAS_2ND_LETTER)
        take_items(player, THALIAS_2ND_LETTER, 1)
        give_items(player, ISAELS_INSTRUCTIONS, 1)
        qs.set_cond(15, true)
        htmltext = event
      end
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when ANT_RECRUIT, ANT_PATROL, ANT_GUARD, ANT_SOLDIER, ANT_WARRIOR_CAPTAIN
        if has_quest_items?(killer, MOONFLOWER_CHARM, PUSHKINS_LIST) && get_quest_items_count(killer, ANT_SOLDIER_ACID) < 20
          give_items(killer, ANT_SOLDIER_ACID, 2)
          if get_quest_items_count(killer, ANT_SOLDIER_ACID) == 20
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if get_quest_items_count(killer, PURE_MITHRIL_ORE) >= 10 && get_quest_items_count(killer, WYRMS_TALON) >= 20
              qs.set_cond(5)
            end
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when HARPY
        if has_quest_items?(killer, MOONFLOWER_CHARM, ADONIUS_LIST) && get_quest_items_count(killer, HARPYS_DOWN) < 20
          give_items(killer, HARPYS_DOWN, 4)
          if get_quest_items_count(killer, HARPYS_DOWN) == 20

            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if get_quest_items_count(killer, SPIDER_ICHOR) >= 20
              qs.set_cond(10)
            end
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when WYRM
        if has_quest_items?(killer, MOONFLOWER_CHARM, PUSHKINS_LIST) && get_quest_items_count(killer, WYRMS_TALON) < 20
          give_items(killer, WYRMS_TALON, 4)
          if get_quest_items_count(killer, WYRMS_TALON) == 20
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if get_quest_items_count(killer, PURE_MITHRIL_ORE) >= 10 && get_quest_items_count(killer, ANT_SOLDIER_ACID) >= 20
              qs.set_cond(5)
            end
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when MARSH_SPIDER
        if has_quest_items?(killer, MOONFLOWER_CHARM, ADONIUS_LIST) && get_quest_items_count(killer, SPIDER_ICHOR) < 20
          give_items(killer, SPIDER_ICHOR, 4)
          if get_quest_items_count(killer, SPIDER_ICHOR) == 20
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if get_quest_items_count(killer, HARPYS_DOWN) >= 20
              qs.set_cond(10)
            end
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when GUARDIAN_BASILISK
        if has_quest_items?(killer, MOONFLOWER_CHARM, PUSHKINS_LIST) && get_quest_items_count(killer, PURE_MITHRIL_ORE) < 10
          give_items(killer, PURE_MITHRIL_ORE, 2)
          if get_quest_items_count(killer, PURE_MITHRIL_ORE) == 10
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if get_quest_items_count(killer, WYRMS_TALON) >= 20 && get_quest_items_count(killer, ANT_SOLDIER_ACID) >= 20
              qs.set_cond(5)
            end
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when LETO_LIZARDMAN_SHAMAN, LETO_LIZARDMAN_OVERLORD
        if has_quest_items?(killer, ISAELS_INSTRUCTIONS)
          if !has_quest_items?(killer, TALINS_SPEAR_BLADE)
            give_items(killer, TALINS_SPEAR_BLADE, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          elsif !has_quest_items?(killer, TALINS_SPEAR_SHAFT)
            give_items(killer, TALINS_SPEAR_SHAFT, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          elsif !has_quest_items?(killer, TALINS_RUBY)
            give_items(killer, TALINS_RUBY, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          elsif !has_quest_items?(killer, TALINS_AQUAMARINE)
            give_items(killer, TALINS_AQUAMARINE, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          elsif !has_quest_items?(killer, TALINS_AMETHYST)
            give_items(killer, TALINS_AMETHYST, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          elsif !has_quest_items?(killer, TALINS_PERIDOT)
            give_items(killer, TALINS_PERIDOT, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          end
        end
      when UNICORN_OF_EVA
        if !has_quest_items?(killer, TEARS_OF_UNICORN) && has_quest_items?(killer, MOONFLOWER_CHARM, TALINS_SPEAR, GRAIL_OF_PURITY)
          if npc.killing_blow_weapon == TALINS_SPEAR
            take_items(killer, TALINS_SPEAR, 1)
            take_items(killer, GRAIL_OF_PURITY, 1)
            give_items(killer, TEARS_OF_UNICORN, 1)
            qs.set_cond(19, true)
          end
        end
      end

    end

    super
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)
    if qs.created?
      if npc.id == MASTER_CARDIEN
        if player.race.elf?
          if player.level >= MIN_LEVEL && player.in_category?(CategoryType::ELF_2ND_GROUP)
            htmltext = "30460-03.htm"
          elsif player.level >= MIN_LEVEL
            htmltext = "30460-01a.html"
          else
            htmltext = "30460-02.html"
          end
        else
          htmltext = "30460-01.html"
        end
      end
    elsif qs.started?
      case npc.id
      when MASTER_CARDIEN
        if has_quest_items?(player, CARDIENS_LETTER)
          htmltext = "30460-05.html"
        elsif has_quest_items?(player, MOONFLOWER_CHARM)
          htmltext = "30460-06.html"
        elsif has_quest_items?(player, CAMOMILE_CHARM)
          give_adena(player, 342288, true)
          give_items(player, MARK_OF_LIFE, 1)
          add_exp_and_sp(player, 1886832, 125918)
          qs.exit_quest(false, true)
          player.send_packet(SocialAction.new(player.l2id, 3))
          htmltext = "30460-07.html"
        end
      when HIERARCH_ASTERIOS
        if has_quest_items?(player, CARDIENS_LETTER)
          htmltext = "30154-01.html"
        elsif has_quest_items?(player, MOONFLOWER_CHARM)
          if !has_quest_items?(player, WATER_OF_LIFE)
            htmltext = "30154-08.html"
          else
            give_items(player, CAMOMILE_CHARM, 1)
            take_items(player, MOONFLOWER_CHARM, 1)
            take_items(player, WATER_OF_LIFE, 1)
            qs.set_cond(21, true)
            htmltext = "30154-09.html"
          end
        elsif has_quest_items?(player, CAMOMILE_CHARM)
          htmltext = "30154-10.html"
        end
      when BLACKSMITH_PUSHKIN
        if has_quest_items?(player, MOONFLOWER_CHARM)
          if has_quest_items?(player, GRAIL_DIAGRAM)
            htmltext = "30300-01.html"
          elsif has_quest_items?(player, PUSHKINS_LIST)
            if get_quest_items_count(player, PURE_MITHRIL_ORE) >= 10 && get_quest_items_count(player, ANT_SOLDIER_ACID) >= 20 && get_quest_items_count(player, WYRMS_TALON) >= 20
              htmltext = "30300-08.html"
            else
              htmltext = "30300-07.html"
            end
          elsif has_quest_items?(player, PURE_MITHRIL_CUP)
            htmltext = "30300-11.html"
          elsif !has_at_least_one_quest_item?(player, GRAIL_DIAGRAM, PUSHKINS_LIST, PURE_MITHRIL_CUP)
            htmltext = "30300-12.html"
          end
        end
      when THALIA
        if has_quest_items?(player, MOONFLOWER_CHARM)
          if has_quest_items?(player, HIERARCHS_LETTER)
            htmltext = "30371-01.html"
          elsif has_quest_items?(player, GRAIL_DIAGRAM)
            htmltext = "30371-04.html"
          elsif has_quest_items?(player, PUSHKINS_LIST)
            htmltext = "30371-05.html"
          elsif has_quest_items?(player, PURE_MITHRIL_CUP)
            give_items(player, THALIAS_1ST_LETTER, 1)
            take_items(player, PURE_MITHRIL_CUP, 1)
            qs.set_cond(7, true)
            htmltext = "30371-06.html"
          elsif has_quest_items?(player, THALIAS_1ST_LETTER)
            htmltext = "30371-07.html"
          elsif has_quest_items?(player, ARKENIAS_CONTRACT)
            htmltext = "30371-08.html"
          elsif has_quest_items?(player, STARDUST)
            htmltext = "30371-09.html"
          elsif has_quest_items?(player, THALIAS_INSTRUCTIONS)
            if player.level >= LEVEL
              take_items(player, THALIAS_INSTRUCTIONS, 1)
              give_items(player, THALIAS_2ND_LETTER, 1)
              qs.set_cond(14, true)
              htmltext = "30371-13.html"
            else
              htmltext = "30371-12.html"
            end
          elsif has_quest_items?(player, THALIAS_2ND_LETTER)
            htmltext = "30371-14.html"
          elsif has_quest_items?(player, ISAELS_INSTRUCTIONS)
            htmltext = "30371-15.html"
          elsif has_quest_items?(player, TALINS_SPEAR, ISAELS_LETTER)
            take_items(player, ISAELS_LETTER, 1)
            give_items(player, GRAIL_OF_PURITY, 1)
            qs.set_cond(18, true)
            htmltext = "30371-16.html"
          elsif has_quest_items?(player, TALINS_SPEAR, GRAIL_OF_PURITY)
            htmltext = "30371-17.html"
          elsif has_quest_items?(player, TEARS_OF_UNICORN)
            take_items(player, TEARS_OF_UNICORN, 1)
            give_items(player, WATER_OF_LIFE, 1)
            qs.set_cond(20, true)
            htmltext = "30371-18.html"
          elsif has_at_least_one_quest_item?(player, CAMOMILE_CHARM, WATER_OF_LIFE)
            htmltext = "30371-19.html"
          end
        end
      when ARKENIA
        if has_quest_items?(player, MOONFLOWER_CHARM)
          if has_quest_items?(player, THALIAS_1ST_LETTER)
            htmltext = "30419-01.html"
          elsif has_at_least_one_quest_item?(player, ARKENIAS_INSTRUCTIONS, ADONIUS_LIST)
            htmltext = "30419-05.html"
          elsif has_quest_items?(player, ANDARIEL_SCRIPTURE_COPY)
            take_items(player, ARKENIAS_CONTRACT, 1)
            take_items(player, ANDARIEL_SCRIPTURE_COPY, 1)
            give_items(player, STARDUST, 1)
            qs.set_cond(12, true)
            htmltext = "30419-06.html"
          elsif has_quest_items?(player, STARDUST)
            htmltext = "30419-07.html"
          elsif !has_at_least_one_quest_item?(player, THALIAS_1ST_LETTER, ARKENIAS_CONTRACT, ANDARIEL_SCRIPTURE_COPY, STARDUST)
            htmltext = "30419-08.html"
          end
        end
      when PRIEST_ADONIUS
        if has_quest_items?(player, MOONFLOWER_CHARM)
          if has_quest_items?(player, ARKENIAS_INSTRUCTIONS)
            htmltext = "30375-01.html"
          elsif has_quest_items?(player, ADONIUS_LIST)
            if get_quest_items_count(player, SPIDER_ICHOR) >= 20 && get_quest_items_count(player, HARPYS_DOWN) >= 20
              take_items(player, ADONIUS_LIST, 1)
              give_items(player, ANDARIEL_SCRIPTURE_COPY, 1)
              take_items(player, SPIDER_ICHOR, -1)
              take_items(player, HARPYS_DOWN, -1)
              qs.set_cond(11, true)
              htmltext = "30375-04.html"
            else
              htmltext = "30375-03.html"
            end
          elsif has_quest_items?(player, ANDARIEL_SCRIPTURE_COPY)
            htmltext = "30375-05.html"
          elsif !has_at_least_one_quest_item?(player, ARKENIAS_INSTRUCTIONS, ADONIUS_LIST, ANDARIEL_SCRIPTURE_COPY)
            htmltext = "30375-06.html"
          end
        end
      when ISAEL_SILVERSHADOW
        if has_quest_items?(player, MOONFLOWER_CHARM)
          if has_quest_items?(player, THALIAS_2ND_LETTER)
            htmltext = "30655-01.html"
          elsif has_quest_items?(player, ISAELS_INSTRUCTIONS)
            if has_quest_items?(player, TALINS_SPEAR_BLADE, TALINS_SPEAR_SHAFT, TALINS_RUBY, TALINS_AQUAMARINE, TALINS_AMETHYST, TALINS_PERIDOT)
              give_items(player, TALINS_SPEAR, 1)
              take_items(player, ISAELS_INSTRUCTIONS, 1)
              give_items(player, ISAELS_LETTER, 1)
              take_items(player, TALINS_SPEAR_BLADE, 1)
              take_items(player, TALINS_SPEAR_SHAFT, 1)
              take_items(player, TALINS_RUBY, 1)
              take_items(player, TALINS_AQUAMARINE, 1)
              take_items(player, TALINS_AMETHYST, 1)
              take_items(player, TALINS_PERIDOT, 1)
              qs.set_cond(17, true)
              htmltext = "30655-04.html"
            else
              htmltext = "30655-03.html"
            end
          elsif has_quest_items?(player, TALINS_SPEAR, ISAELS_LETTER)
            htmltext = "30655-05.html"
          elsif has_at_least_one_quest_item?(player, GRAIL_OF_PURITY, WATER_OF_LIFE, CAMOMILE_CHARM)
            htmltext = "30655-06.html"
          end
        end
      end
    elsif qs.completed?
      if npc.id == MASTER_CARDIEN
        htmltext = get_already_completed_msg(player)
      end
    end

    htmltext
  end
end
