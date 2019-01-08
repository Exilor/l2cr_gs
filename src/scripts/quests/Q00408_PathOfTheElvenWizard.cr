class Quests::Q00408_PathOfTheElvenWizard < Quest
  # NPCs
  private ROSELLA = 30414
  private GREENIS = 30157
  private THALIA = 30371
  private NORTHWIND = 30423
  # Items
  private ROSELLAS_LETTER = 1218
  private RED_DOWN = 1219
  private MAGICAL_POWERS_RUBY = 1220
  private PURE_AQUAMARINE = 1221
  private APPETIZING_APPLE = 1222
  private GOLD_LEAVES = 1223
  private IMMORTAL_LOVE = 1224
  private AMETHYST = 1225
  private NOBILITY_AMETHYST = 1226
  private FERTILITY_PERIDOT = 1229
  private GREENISS_CHARM = 1272
  private SAP_OF_THE_MOTHER_TREE = 1273
  private LUCKY_POTPOURRI = 1274
  # Reward
  private ETERNITY_DIAMOND = 1230
  # Monster
  private DRYAD_ELDER = 20019
  private SUKAR_WERERAT_LEADER = 20047
  private PINCER_SPIDER = 20466
  # Misc
  private MIN_LEVEL = 18

  def initialize
    super(408, self.class.simple_name, "Path Of The Elven Wizard")

    add_start_npc(ROSELLA)
    add_talk_id(ROSELLA, GREENIS, THALIA, NORTHWIND)
    add_kill_id(DRYAD_ELDER, SUKAR_WERERAT_LEADER, PINCER_SPIDER)
    register_quest_items(ROSELLAS_LETTER, RED_DOWN, MAGICAL_POWERS_RUBY, PURE_AQUAMARINE, APPETIZING_APPLE, GOLD_LEAVES, IMMORTAL_LOVE, AMETHYST, NOBILITY_AMETHYST, FERTILITY_PERIDOT, GREENISS_CHARM, SAP_OF_THE_MOTHER_TREE, LUCKY_POTPOURRI)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "ACCEPT"
      if !player.class_id.elven_mage?
        if player.class_id.elven_wizard?
          htmltext = "30414-02a.htm"
        else
          htmltext = "30414-03.htm"
        end
      elsif player.level < MIN_LEVEL
        htmltext = "30414-04.htm"
      elsif has_quest_items?(player, ETERNITY_DIAMOND)
        htmltext = "30414-05.htm"
      else
        if !has_quest_items?(player, FERTILITY_PERIDOT)
          give_items(player, FERTILITY_PERIDOT, 1)
        end
        qs.start_quest
        htmltext = "30414-06.htm"
      end
    when "30414-02.htm"
      htmltext = event
    when "30414-10.html"
      if has_quest_items?(player, MAGICAL_POWERS_RUBY)
        htmltext = event
      elsif !has_quest_items?(player, MAGICAL_POWERS_RUBY) && has_quest_items?(player, FERTILITY_PERIDOT)
        unless has_quest_items?(player, ROSELLAS_LETTER)
          give_items(player, ROSELLAS_LETTER, 1)
        end
        htmltext = "30414-07.html"
      end
    when "30414-12.html"
      if has_quest_items?(player, PURE_AQUAMARINE)
        htmltext = event
      elsif !has_quest_items?(player, PURE_AQUAMARINE) && has_quest_items?(player, FERTILITY_PERIDOT)
        unless has_quest_items?(player, APPETIZING_APPLE)
          give_items(player, APPETIZING_APPLE, 1)
        end
        htmltext = "30414-13.html"
      end
    when "30414-16.html"
      if has_quest_items?(player, NOBILITY_AMETHYST)
        htmltext = event
      elsif !has_quest_items?(player, NOBILITY_AMETHYST) && has_quest_items?(player, FERTILITY_PERIDOT)
        unless has_quest_items?(player, IMMORTAL_LOVE)
          give_items(player, IMMORTAL_LOVE, 1)
        end
        htmltext = "30414-17.html"
      end
    when "30157-02.html"
      if has_quest_items?(player, ROSELLAS_LETTER)
        take_items(player, ROSELLAS_LETTER, 1)
        unless has_quest_items?(player, GREENISS_CHARM)
          give_items(player, GREENISS_CHARM, 1)
        end
      end
      htmltext = event
    when "30371-02.html"
      if has_quest_items?(player, APPETIZING_APPLE)
        take_items(player, APPETIZING_APPLE, 1)
        unless has_quest_items?(player, SAP_OF_THE_MOTHER_TREE)
          give_items(player, SAP_OF_THE_MOTHER_TREE, 1)
        end
      end
      htmltext = event
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when DRYAD_ELDER
        if has_quest_items?(killer, SAP_OF_THE_MOTHER_TREE) && get_quest_items_count(killer, GOLD_LEAVES) < 5 && Rnd.rand(100) < 40
          give_items(killer, GOLD_LEAVES, 1)
          if get_quest_items_count(killer, GOLD_LEAVES) == 5
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when SUKAR_WERERAT_LEADER
        if has_quest_items?(killer, LUCKY_POTPOURRI) && get_quest_items_count(killer, AMETHYST) < 2 && Rnd.rand(100) < 40
          give_items(killer, AMETHYST, 1)
          if get_quest_items_count(killer, AMETHYST) == 2
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when PINCER_SPIDER
        if has_quest_items?(killer, GREENISS_CHARM) && get_quest_items_count(killer, RED_DOWN) < 5 && Rnd.rand(100) < 70
          give_items(killer, RED_DOWN, 1)
          if get_quest_items_count(killer, RED_DOWN) == 5
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)
    if qs.created? || qs.completed?
      if npc.id == ROSELLA
        htmltext = "30414-01.htm"
      end
    elsif qs.started?
      case npc.id
      when ROSELLA
        if !has_at_least_one_quest_item?(player, ROSELLAS_LETTER, APPETIZING_APPLE, IMMORTAL_LOVE, GREENISS_CHARM, SAP_OF_THE_MOTHER_TREE, LUCKY_POTPOURRI) && has_quest_items?(player, FERTILITY_PERIDOT) && !has_quest_items?(player, MAGICAL_POWERS_RUBY, NOBILITY_AMETHYST, PURE_AQUAMARINE)
          htmltext = "30414-11.html"
        elsif has_quest_items?(player, ROSELLAS_LETTER)
          htmltext = "30414-08.html"
        elsif has_quest_items?(player, GREENISS_CHARM)
          if get_quest_items_count(player, RED_DOWN) < 5
            htmltext = "30414-09.html"
          else
            htmltext = "30414-21.html"
          end
        elsif has_quest_items?(player, APPETIZING_APPLE)
          htmltext = "30414-14.html"
        elsif has_quest_items?(player, SAP_OF_THE_MOTHER_TREE)
          if get_quest_items_count(player, GOLD_LEAVES) < 5
            htmltext = "30414-15.html"
          else
            htmltext = "30414-22.html"
          end
        elsif has_quest_items?(player, IMMORTAL_LOVE)
          htmltext = "30414-18.html"
        elsif has_quest_items?(player, LUCKY_POTPOURRI)
          if get_quest_items_count(player, AMETHYST) < 2
            htmltext = "30414-19.html"
          else
            htmltext = "30414-23.html"
          end
        else
          if !has_at_least_one_quest_item?(player, ROSELLAS_LETTER, APPETIZING_APPLE, IMMORTAL_LOVE, GREENISS_CHARM, SAP_OF_THE_MOTHER_TREE, LUCKY_POTPOURRI) && has_quest_items?(player, FERTILITY_PERIDOT, MAGICAL_POWERS_RUBY, NOBILITY_AMETHYST, PURE_AQUAMARINE)
            give_adena(player, 163800, true)
            unless has_quest_items?(player, ETERNITY_DIAMOND)
              give_items(player, ETERNITY_DIAMOND, 1)
            end
            level = player.level
            if level >= 20
              add_exp_and_sp(player, 320534, 22532)
            elsif level == 19
              add_exp_and_sp(player, 456128, 29230)
            else
              add_exp_and_sp(player, 591724, 35928)
            end
            qs.exit_quest(false, true)
            player.send_packet(SocialAction.new(player.l2id, 3))
            qs.save_global_quest_var("1ClassQuestFinished", "1")
            htmltext = "30414-20.html"
          end
        end
      when GREENIS
        if has_quest_items?(player, ROSELLAS_LETTER)
          htmltext = "30157-01.html"
        elsif has_quest_items?(player, GREENISS_CHARM)
          if get_quest_items_count(player, RED_DOWN) < 5
            htmltext = "30157-03.html"
          else
            take_items(player, RED_DOWN, -1)
            unless has_quest_items?(player, MAGICAL_POWERS_RUBY)
              give_items(player, MAGICAL_POWERS_RUBY, 1)
            end
            take_items(player, GREENISS_CHARM, 1)
            htmltext = "30157-04.html"
          end
        end
      when THALIA
        if has_quest_items?(player, APPETIZING_APPLE)
          htmltext = "30371-01.html"
        elsif has_quest_items?(player, SAP_OF_THE_MOTHER_TREE)
          if get_quest_items_count(player, GOLD_LEAVES) < 5
            htmltext = "30371-03.html"
          else
            unless has_quest_items?(player, PURE_AQUAMARINE)
              give_items(player, PURE_AQUAMARINE, 1)
            end
            take_items(player, GOLD_LEAVES, -1)
            take_items(player, SAP_OF_THE_MOTHER_TREE, 1)
            htmltext = "30371-04.html"
          end
        end
      when NORTHWIND
        if has_quest_items?(player, IMMORTAL_LOVE)
          take_items(player, IMMORTAL_LOVE, 1)
          unless has_quest_items?(player, LUCKY_POTPOURRI)
            give_items(player, LUCKY_POTPOURRI, 1)
          end
          htmltext = "30423-01.html"
        elsif has_quest_items?(player, LUCKY_POTPOURRI)
          if get_quest_items_count(player, AMETHYST) < 2
            htmltext = "30423-02.html"
          else
            take_items(player, AMETHYST, -1)
            unless has_quest_items?(player, NOBILITY_AMETHYST)
              give_items(player, NOBILITY_AMETHYST, 1)
            end
            take_items(player, LUCKY_POTPOURRI, 1)
            htmltext = "30423-03.html"
          end
        end
      end
    end

    htmltext
  end
end
