class Scripts::Q00408_PathOfTheElvenWizard < Quest
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
    register_quest_items(
      ROSELLAS_LETTER, RED_DOWN, MAGICAL_POWERS_RUBY, PURE_AQUAMARINE,
      APPETIZING_APPLE, GOLD_LEAVES, IMMORTAL_LOVE, AMETHYST, NOBILITY_AMETHYST,
      FERTILITY_PERIDOT, GREENISS_CHARM, SAP_OF_THE_MOTHER_TREE, LUCKY_POTPOURRI
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if !pc.class_id.elven_mage?
        if pc.class_id.elven_wizard?
          html = "30414-02a.htm"
        else
          html = "30414-03.htm"
        end
      elsif pc.level < MIN_LEVEL
        html = "30414-04.htm"
      elsif has_quest_items?(pc, ETERNITY_DIAMOND)
        html = "30414-05.htm"
      else
        unless has_quest_items?(pc, FERTILITY_PERIDOT)
          give_items(pc, FERTILITY_PERIDOT, 1)
        end
        qs.start_quest
        html = "30414-06.htm"
      end
    when "30414-02.htm"
      html = event
    when "30414-10.html"
      if has_quest_items?(pc, MAGICAL_POWERS_RUBY)
        html = event
      elsif !has_quest_items?(pc, MAGICAL_POWERS_RUBY) && has_quest_items?(pc, FERTILITY_PERIDOT)
        unless has_quest_items?(pc, ROSELLAS_LETTER)
          give_items(pc, ROSELLAS_LETTER, 1)
        end
        html = "30414-07.html"
      end
    when "30414-12.html"
      if has_quest_items?(pc, PURE_AQUAMARINE)
        html = event
      elsif !has_quest_items?(pc, PURE_AQUAMARINE) && has_quest_items?(pc, FERTILITY_PERIDOT)
        unless has_quest_items?(pc, APPETIZING_APPLE)
          give_items(pc, APPETIZING_APPLE, 1)
        end
        html = "30414-13.html"
      end
    when "30414-16.html"
      if has_quest_items?(pc, NOBILITY_AMETHYST)
        html = event
      elsif !has_quest_items?(pc, NOBILITY_AMETHYST) && has_quest_items?(pc, FERTILITY_PERIDOT)
        unless has_quest_items?(pc, IMMORTAL_LOVE)
          give_items(pc, IMMORTAL_LOVE, 1)
        end
        html = "30414-17.html"
      end
    when "30157-02.html"
      if has_quest_items?(pc, ROSELLAS_LETTER)
        take_items(pc, ROSELLAS_LETTER, 1)
        unless has_quest_items?(pc, GREENISS_CHARM)
          give_items(pc, GREENISS_CHARM, 1)
        end
      end
      html = event
    when "30371-02.html"
      if has_quest_items?(pc, APPETIZING_APPLE)
        take_items(pc, APPETIZING_APPLE, 1)
        unless has_quest_items?(pc, SAP_OF_THE_MOTHER_TREE)
          give_items(pc, SAP_OF_THE_MOTHER_TREE, 1)
        end
      end
      html = event
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when DRYAD_ELDER
        if has_quest_items?(killer, SAP_OF_THE_MOTHER_TREE)
          if get_quest_items_count(killer, GOLD_LEAVES) < 5 && Rnd.rand(100) < 40
            give_items(killer, GOLD_LEAVES, 1)
            if get_quest_items_count(killer, GOLD_LEAVES) == 5
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when SUKAR_WERERAT_LEADER
        if has_quest_items?(killer, LUCKY_POTPOURRI)
          if get_quest_items_count(killer, AMETHYST) < 2 && Rnd.rand(100) < 40
            give_items(killer, AMETHYST, 1)
            if get_quest_items_count(killer, AMETHYST) == 2
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when PINCER_SPIDER
        if has_quest_items?(killer, GREENISS_CHARM)
          if get_quest_items_count(killer, RED_DOWN) < 5 && Rnd.rand(100) < 70
            give_items(killer, RED_DOWN, 1)
            if get_quest_items_count(killer, RED_DOWN) == 5
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      end

    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created? || qs.completed?
      if npc.id == ROSELLA
        html = "30414-01.htm"
      end
    elsif qs.started?
      case npc.id
      when ROSELLA
        if !has_at_least_one_quest_item?(pc, ROSELLAS_LETTER, APPETIZING_APPLE, IMMORTAL_LOVE, GREENISS_CHARM, SAP_OF_THE_MOTHER_TREE, LUCKY_POTPOURRI) && has_quest_items?(pc, FERTILITY_PERIDOT) && !has_quest_items?(pc, MAGICAL_POWERS_RUBY, NOBILITY_AMETHYST, PURE_AQUAMARINE)
          html = "30414-11.html"
        elsif has_quest_items?(pc, ROSELLAS_LETTER)
          html = "30414-08.html"
        elsif has_quest_items?(pc, GREENISS_CHARM)
          if get_quest_items_count(pc, RED_DOWN) < 5
            html = "30414-09.html"
          else
            html = "30414-21.html"
          end
        elsif has_quest_items?(pc, APPETIZING_APPLE)
          html = "30414-14.html"
        elsif has_quest_items?(pc, SAP_OF_THE_MOTHER_TREE)
          if get_quest_items_count(pc, GOLD_LEAVES) < 5
            html = "30414-15.html"
          else
            html = "30414-22.html"
          end
        elsif has_quest_items?(pc, IMMORTAL_LOVE)
          html = "30414-18.html"
        elsif has_quest_items?(pc, LUCKY_POTPOURRI)
          if get_quest_items_count(pc, AMETHYST) < 2
            html = "30414-19.html"
          else
            html = "30414-23.html"
          end
        else
          if !has_at_least_one_quest_item?(pc, ROSELLAS_LETTER, APPETIZING_APPLE, IMMORTAL_LOVE, GREENISS_CHARM, SAP_OF_THE_MOTHER_TREE, LUCKY_POTPOURRI) && has_quest_items?(pc, FERTILITY_PERIDOT, MAGICAL_POWERS_RUBY, NOBILITY_AMETHYST, PURE_AQUAMARINE)
            give_adena(pc, 163800, true)
            unless has_quest_items?(pc, ETERNITY_DIAMOND)
              give_items(pc, ETERNITY_DIAMOND, 1)
            end
            level = pc.level
            if level >= 20
              add_exp_and_sp(pc, 320534, 22532)
            elsif level == 19
              add_exp_and_sp(pc, 456128, 29230)
            else
              add_exp_and_sp(pc, 591724, 35928)
            end
            qs.exit_quest(false, true)
            pc.send_packet(SocialAction.new(pc.l2id, 3))
            qs.save_global_quest_var("1ClassQuestFinished", "1")
            html = "30414-20.html"
          end
        end
      when GREENIS
        if has_quest_items?(pc, ROSELLAS_LETTER)
          html = "30157-01.html"
        elsif has_quest_items?(pc, GREENISS_CHARM)
          if get_quest_items_count(pc, RED_DOWN) < 5
            html = "30157-03.html"
          else
            take_items(pc, RED_DOWN, -1)
            unless has_quest_items?(pc, MAGICAL_POWERS_RUBY)
              give_items(pc, MAGICAL_POWERS_RUBY, 1)
            end
            take_items(pc, GREENISS_CHARM, 1)
            html = "30157-04.html"
          end
        end
      when THALIA
        if has_quest_items?(pc, APPETIZING_APPLE)
          html = "30371-01.html"
        elsif has_quest_items?(pc, SAP_OF_THE_MOTHER_TREE)
          if get_quest_items_count(pc, GOLD_LEAVES) < 5
            html = "30371-03.html"
          else
            unless has_quest_items?(pc, PURE_AQUAMARINE)
              give_items(pc, PURE_AQUAMARINE, 1)
            end
            take_items(pc, GOLD_LEAVES, -1)
            take_items(pc, SAP_OF_THE_MOTHER_TREE, 1)
            html = "30371-04.html"
          end
        end
      when NORTHWIND
        if has_quest_items?(pc, IMMORTAL_LOVE)
          take_items(pc, IMMORTAL_LOVE, 1)
          unless has_quest_items?(pc, LUCKY_POTPOURRI)
            give_items(pc, LUCKY_POTPOURRI, 1)
          end
          html = "30423-01.html"
        elsif has_quest_items?(pc, LUCKY_POTPOURRI)
          if get_quest_items_count(pc, AMETHYST) < 2
            html = "30423-02.html"
          else
            take_items(pc, AMETHYST, -1)
            unless has_quest_items?(pc, NOBILITY_AMETHYST)
              give_items(pc, NOBILITY_AMETHYST, 1)
            end
            take_items(pc, LUCKY_POTPOURRI, 1)
            html = "30423-03.html"
          end
        end
      end

    end

    html || get_no_quest_msg(pc)
  end
end
