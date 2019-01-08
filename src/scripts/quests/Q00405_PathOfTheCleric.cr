class Quests::Q00405_PathOfTheCleric < Quest
  # NPCs
  private GALLINT = 30017
  private ZIGAUNT = 30022
  private VIVYAN = 30030
  private TRADER_SIMPLON = 30253
  private GUARD_PRAGA = 30333
  private LIONEL = 30408
  # Items
  private LETTER_OF_ORDER_1ST = 1191
  private LETTER_OF_ORDER_2ND = 1192
  private LIONELS_BOOK = 1193
  private BOOK_OF_VIVYAN = 1194
  private BOOK_OF_SIMPLON = 1195
  private BOOK_OF_PRAGA = 1196
  private CERTIFICATE_OF_GALLINT = 1197
  private PENDANT_OF_MOTHER = 1198
  private NECKLACE_OF_MOTHER = 1199
  private LEMONIELLS_COVENANT = 1200
  # Reward
  private MARK_OF_FAITH = 1201
  # Monster
  private RUIN_ZOMBIE = 20026
  private RUIN_ZOMBIE_LEADER = 20029
  # Misc
  private MIN_LEVEL = 18

  def initialize
    super(405, self.class.simple_name, "Path Of The Cleric")

    add_start_npc(ZIGAUNT)
    add_talk_id(ZIGAUNT, GALLINT, VIVYAN, TRADER_SIMPLON, GUARD_PRAGA, LIONEL)
    add_kill_id(RUIN_ZOMBIE, RUIN_ZOMBIE_LEADER)
    register_quest_items(
      LETTER_OF_ORDER_1ST, LETTER_OF_ORDER_2ND, LIONELS_BOOK, BOOK_OF_VIVYAN,
      BOOK_OF_SIMPLON, BOOK_OF_PRAGA, CERTIFICATE_OF_GALLINT,
      PENDANT_OF_MOTHER, NECKLACE_OF_MOTHER, LEMONIELLS_COVENANT
    )
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "ACCEPT"
      if player.class_id.mage?
        if player.level >= MIN_LEVEL
          if has_quest_items?(player, MARK_OF_FAITH)
            htmltext = "30022-04.htm"
          else
            qs.start_quest
            give_items(player, LETTER_OF_ORDER_1ST, 1)
            htmltext = "30022-05.htm"
          end
        else
          htmltext = "30022-03.htm"
        end
      elsif player.class_id.cleric?
        htmltext = "30022-02a.htm"
      else
        htmltext = "30022-02.htm"
      end
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      if has_quest_items?(killer, NECKLACE_OF_MOTHER)
        unless has_quest_items?(killer, PENDANT_OF_MOTHER)
          give_items(killer, PENDANT_OF_MOTHER, 1)
          play_sound(qs.player, Sound::ITEMSOUND_QUEST_MIDDLE)
        end
      end
    end

    super
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)
    if qs.created? || qs.completed?
      if npc.id == ZIGAUNT
        if !has_quest_items?(player, MARK_OF_FAITH)
          htmltext = "30022-01.htm"
        else
          htmltext = "30022-04.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when ZIGAUNT
        if !has_quest_items?(player, LEMONIELLS_COVENANT) && has_quest_items?(player, LETTER_OF_ORDER_2ND)
          htmltext = "30022-07.html"
        elsif has_quest_items?(player, LETTER_OF_ORDER_2ND, LEMONIELLS_COVENANT)
          give_adena(player, 163800, true)
          take_items(player, LETTER_OF_ORDER_2ND, 1)
          take_items(player, LEMONIELLS_COVENANT, 1)
          give_items(player, MARK_OF_FAITH, 1)
          level = player.level
          if level >= 20
            add_exp_and_sp(player, 320534, 23152)
          elsif level == 19
            add_exp_and_sp(player, 456128, 28630)
          else
            add_exp_and_sp(player, 591724, 35328)
          end
          qs.exit_quest(false, true)
          player.send_packet(SocialAction.new(player.l2id, 3))
          qs.save_global_quest_var("1ClassQuestFinished", "1")
          htmltext = "30022-09.html"
        elsif has_quest_items?(player, LETTER_OF_ORDER_1ST)
          if has_quest_items?(player, BOOK_OF_VIVYAN, BOOK_OF_SIMPLON, BOOK_OF_PRAGA)
            take_items(player, LETTER_OF_ORDER_1ST, 1)
            give_items(player, LETTER_OF_ORDER_2ND, 1)
            take_items(player, BOOK_OF_VIVYAN, 1)
            take_items(player, BOOK_OF_SIMPLON, -1)
            take_items(player, BOOK_OF_PRAGA, 1)
            qs.set_cond(3, true)
            htmltext = "30022-08.html"
          else
            htmltext = "30022-06.html"
          end
        end
      when GALLINT
        if !has_quest_items?(player, LEMONIELLS_COVENANT) && has_quest_items?(player, LETTER_OF_ORDER_2ND)
          if !has_quest_items?(player, CERTIFICATE_OF_GALLINT) && has_quest_items?(player, LIONELS_BOOK)
            take_items(player, LIONELS_BOOK, 1)
            give_items(player, CERTIFICATE_OF_GALLINT, 1)
            qs.set_cond(5, true)
            htmltext = "30017-01.html"
          else
            htmltext = "30017-02.html"
          end
        end
      when VIVYAN
        if has_quest_items?(player, LETTER_OF_ORDER_1ST)
          if !has_quest_items?(player, BOOK_OF_VIVYAN)
            give_items(player, BOOK_OF_VIVYAN, 1)
            if get_quest_items_count(player, BOOK_OF_SIMPLON) >= 3 && get_quest_items_count(player, BOOK_OF_VIVYAN) >= 0 && get_quest_items_count(player, BOOK_OF_PRAGA) >= 1
              qs.set_cond(2, true)
            end
            htmltext = "30030-01.html"
          else
            htmltext = "30030-02.html"
          end
        end
      when TRADER_SIMPLON
        if has_quest_items?(player, LETTER_OF_ORDER_1ST)
          if !has_quest_items?(player, BOOK_OF_SIMPLON)
            give_items(player, BOOK_OF_SIMPLON, 3)
            if get_quest_items_count(player, BOOK_OF_SIMPLON) >= 0 && get_quest_items_count(player, BOOK_OF_VIVYAN) >= 1 && get_quest_items_count(player, BOOK_OF_PRAGA) >= 1
              qs.set_cond(2, true)
            end
            htmltext = "30253-01.html"
          else
            htmltext = "30253-02.html"
          end
        end
      when GUARD_PRAGA
        if has_quest_items?(player, LETTER_OF_ORDER_1ST)
          if !has_at_least_one_quest_item?(player, BOOK_OF_PRAGA, NECKLACE_OF_MOTHER)
            give_items(player, NECKLACE_OF_MOTHER, 1)
            htmltext = "30333-01.html"
          elsif !has_at_least_one_quest_item?(player, BOOK_OF_PRAGA, PENDANT_OF_MOTHER) && has_quest_items?(player, NECKLACE_OF_MOTHER)
            htmltext = "30333-02.html"
          elsif !has_quest_items?(player, BOOK_OF_PRAGA) && has_quest_items?(player, NECKLACE_OF_MOTHER, PENDANT_OF_MOTHER)
            give_items(player, BOOK_OF_PRAGA, 1)
            take_items(player, PENDANT_OF_MOTHER, 1)
            take_items(player, NECKLACE_OF_MOTHER, 1)
            if get_quest_items_count(player, BOOK_OF_SIMPLON) >= 3 && get_quest_items_count(player, BOOK_OF_VIVYAN) >= 1 && get_quest_items_count(player, BOOK_OF_PRAGA) >= 0
              qs.set_cond(2, true)
            end
            htmltext = "30333-03.html"
          elsif has_quest_items?(player, BOOK_OF_PRAGA)
            htmltext = "30333-04.html"
          end
        end
      when LIONEL
        if !has_quest_items?(player, LETTER_OF_ORDER_2ND)
          htmltext = "30408-02.html"
        elsif !has_at_least_one_quest_item?(player, LIONELS_BOOK, LEMONIELLS_COVENANT, CERTIFICATE_OF_GALLINT) && has_quest_items?(player, LETTER_OF_ORDER_2ND)
          give_items(player, LIONELS_BOOK, 1)
          qs.set_cond(4, true)
          htmltext = "30408-01.html"
        elsif !has_at_least_one_quest_item?(player, LEMONIELLS_COVENANT, CERTIFICATE_OF_GALLINT) && has_quest_items?(player, LETTER_OF_ORDER_2ND, LIONELS_BOOK)
          htmltext = "30408-03.html"
        elsif !has_at_least_one_quest_item?(player, LIONELS_BOOK, LEMONIELLS_COVENANT) && has_quest_items?(player, LETTER_OF_ORDER_2ND, CERTIFICATE_OF_GALLINT)
          take_items(player, CERTIFICATE_OF_GALLINT, 1)
          give_items(player, LEMONIELLS_COVENANT, 1)
          qs.set_cond(6, true)
          htmltext = "30408-04.html"
        elsif !has_at_least_one_quest_item?(player, LIONELS_BOOK, CERTIFICATE_OF_GALLINT) && has_quest_items?(player, LETTER_OF_ORDER_2ND, LEMONIELLS_COVENANT)
          htmltext = "30408-05.html"
        end
      end
    end

    htmltext
  end
end
