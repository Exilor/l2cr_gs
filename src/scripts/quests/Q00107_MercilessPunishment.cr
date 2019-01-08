class Quests::Q00107_MercilessPunishment < Quest
  # Npc
  private URUTU_CHIEF_HATOS = 30568
  private CENTURION_PARUGON = 30580
  # Items
  private HATOSS_ORDER_1 = 1553
  private HATOSS_ORDER_2 = 1554
  private HATOSS_ORDER_3 = 1555
  private LETTER_TO_DARK_ELF = 1556
  private LETTER_TO_HUMAN = 1557
  private LETTER_TO_ELF = 1558
  # Monster
  private BARANKA_MESSENGER = 27041
  # Rewards
  private BUTCHER = 1510
  private REWARDS = {
    ItemHolder.new(1060, 100), # Lesser Healing Potion
    ItemHolder.new(4412, 10),  # Echo Crystal - Theme of Battle
    ItemHolder.new(4413, 10),  # Echo Crystal - Theme of Love
    ItemHolder.new(4414, 10),  # Echo Crystal - Theme of Solitude
    ItemHolder.new(4415, 10),  # Echo Crystal - Theme of Feast
    ItemHolder.new(4416, 10),  # Echo Crystal - Theme of Celebration
  }
  # Misc
  private MIN_LVL = 10

  def initialize
    super(107, Q00107_MercilessPunishment.simple_name, "Merciless Punishment")

    add_start_npc(URUTU_CHIEF_HATOS)
    add_talk_id(URUTU_CHIEF_HATOS, CENTURION_PARUGON)
    add_kill_id(BARANKA_MESSENGER)
    register_quest_items(HATOSS_ORDER_1, HATOSS_ORDER_2, HATOSS_ORDER_3, LETTER_TO_DARK_ELF, LETTER_TO_HUMAN, LETTER_TO_ELF)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "30568-04.htm"
      if qs.created?
        qs.start_quest
        give_items(player, HATOSS_ORDER_1, 1)
        htmltext = event
      end
    when "30568-07.html"
      give_adena(player, 200, true)
      play_sound(player, Sound::ITEMSOUND_QUEST_GIVEUP)
      qs.exit_quest(true)
      htmltext = event
    when "30568-08.html"
      if qs.cond?(3) && has_quest_items?(player, HATOSS_ORDER_1)
        qs.set_cond(4)
        take_items(player, HATOSS_ORDER_1, -1)
        give_items(player, HATOSS_ORDER_2, 1)
        htmltext = event
      end
    when "30568-10.html"
      if qs.cond?(5) && has_quest_items?(player, HATOSS_ORDER_2)
        qs.set_cond(6)
        take_items(player, HATOSS_ORDER_2, -1)
        give_items(player, HATOSS_ORDER_3, 1)
        htmltext = event
      end
    end

    htmltext
  end

  def on_talk(npc, talker)
    qs = get_quest_state!(talker)
    htmltext = get_no_quest_msg(talker)

    case npc.id
    when URUTU_CHIEF_HATOS
      case qs.state
      when State::CREATED
        if !talker.race.orc?
          htmltext = "30568-01.htm"
        elsif talker.level < MIN_LVL
          htmltext = "30568-02.htm"
        else
          htmltext = "30568-03.htm"
        end
      when State::STARTED
        case qs.cond
        when 1, 2
          if has_quest_items?(talker, HATOSS_ORDER_1)
            htmltext = "30568-05.html"
          end
        when 3
          if has_quest_items?(talker, HATOSS_ORDER_1, LETTER_TO_HUMAN)
            htmltext = "30568-06.html"
          end
        when 4
          if has_quest_items?(talker, HATOSS_ORDER_2, LETTER_TO_HUMAN)
            htmltext = "30568-08.html"
          end
        when 5
          if has_quest_items?(talker, HATOSS_ORDER_2, LETTER_TO_HUMAN, LETTER_TO_DARK_ELF)
            htmltext = "30568-09.html"
          end
        when 6
          if has_quest_items?(talker, HATOSS_ORDER_3, LETTER_TO_HUMAN, LETTER_TO_DARK_ELF)
            htmltext = "30568-10.html"
          end
        when 7
          if has_quest_items?(talker, HATOSS_ORDER_3, LETTER_TO_HUMAN, LETTER_TO_DARK_ELF, LETTER_TO_ELF)
            Q00281_HeadForTheHills.give_newbie_reward(talker)
            add_exp_and_sp(talker, 34565, 2962)
            give_adena(talker, 14666, true)
            REWARDS.each { |reward| give_items(talker, reward) }
            give_items(talker, BUTCHER, 1)
            qs.exit_quest(false, true)
            talker.send_packet(SocialAction.new(talker.l2id, 3))
            htmltext = "30568-11.html"
          end
        end
      when State::COMPLETED
        htmltext = get_already_completed_msg(talker)
      end
    when CENTURION_PARUGON
      if qs.started?
        if qs.cond?(1) && has_quest_items?(talker, HATOSS_ORDER_1)
          qs.set_cond(2, true)
          htmltext = "30580-01.html"
        end
      end
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && Util.in_range?(1500, npc, killer, true)
      case qs.cond
      when 2
        if has_quest_items?(killer, HATOSS_ORDER_1)
          give_items(killer, LETTER_TO_HUMAN, 1)
          qs.set_cond(3, true)
        end
      when 4
        if has_quest_items?(killer, HATOSS_ORDER_2)
          give_items(killer, LETTER_TO_DARK_ELF, 1)
          qs.set_cond(5, true)
        end
      when 6
        if has_quest_items?(killer, HATOSS_ORDER_3)
          give_items(killer, LETTER_TO_ELF, 1)
          qs.set_cond(7, true)
        end
      end
    end

    super
  end
end
