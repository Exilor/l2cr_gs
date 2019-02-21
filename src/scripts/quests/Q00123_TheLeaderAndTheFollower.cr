class Quests::Q00123_TheLeaderAndTheFollower < Quest
  # NPC
  private HEAD_BLACKSMITH_NEWYEAR = 31961
  # Items
  private CRYSTAL_D = 1458
  private BRUIN_LIZARDMAN_BLOOD = 8549
  private PICOT_ARANEIDS_LEG = 8550
  # Reward
  private CLAN_OATH_HELM = 7850
  private CLAN_OATH_ARMOR = 7851
  private CLAN_OATH_GAUNTLETS_HEAVY_ARMOR = 7852
  private CLAN_OATH_SABATON_HEAVY_ARMOR = 7853
  private CLAN_OATH_BRIGANDINE = 7854
  private CLAN_OATH_LEATHER_GLOVES_LIGHT_ARMOR = 7855
  private CLAN_OATH_BOOTS_LIGHT_ARMOR = 7856
  private CLAN_OATH_AKETON = 7857
  private CLAN_OATH_PADDED_GLOVES_ROBE = 7858
  private CLAN_OATH_SANDALS_ROBE = 7859
  # Quest Monster
  private BRUIN_LIZARDMAN = 27321
  private PICOT_ARANEID = 27322
  # Misc
  private MIN_LEVEL = 19
  private CRYSTAL_COUNT_1 = 922
  private CRYSTAL_COUNT_2 = 771

  def initialize
    super(123, self.class.simple_name, "The Leader And The Follower")

    add_start_npc(HEAD_BLACKSMITH_NEWYEAR)
    add_talk_id(HEAD_BLACKSMITH_NEWYEAR)
    add_kill_id(BRUIN_LIZARDMAN, PICOT_ARANEID)
    register_quest_items(BRUIN_LIZARDMAN_BLOOD, PICOT_ARANEIDS_LEG)
  end

  def on_adv_event(event, npc, player)
    player = player.not_nil!
    # Manage Sponsor's quest events.
    if player.apprentice > 0
      unless apprentice = L2World.get_player(player.apprentice)
        return
      end

      q123 = apprentice.get_quest_state(self.class.simple_name)
      case event
      when "sponsor"
        if !Util.in_range?(1500, npc, apprentice, true)
          htmltext = "31961-09.html"
        else
          if q123.nil? || (!q123.memo_state?(2) && !q123.memo_state?(3))
            htmltext = "31961-14.html"
          elsif q123.memo_state?(2)
            htmltext = "31961-08.html"
          elsif q123.memo_state?(3)
            htmltext = "31961-12.html"
          end
        end
      when "31961-10.html"
        if Util.in_range?(1500, npc, apprentice, true) && q123 && q123.memo_state?(2)
          case q123.get_memo_state_ex(1)
          when 1
            if get_quest_items_count(player, CRYSTAL_D) >= CRYSTAL_COUNT_1
              take_items(player, CRYSTAL_D, CRYSTAL_COUNT_1)
              q123.memo_state = 3
              q123.set_cond(6, true)
              htmltext = event
            else
              htmltext = "31961-11.html"
            end
          when 2, 3
            if get_quest_items_count(player, CRYSTAL_D) >= CRYSTAL_COUNT_2
              take_items(player, CRYSTAL_D, CRYSTAL_COUNT_2)
              q123.memo_state = 3
              q123.set_cond(6, true)
              htmltext = event
            else
              htmltext = "31961-11a.html"
            end
          end
        end
      end

      return htmltext
    end

    unless qs = get_quest_state(player, false)
      return
    end

    case event
    when "31961-03.htm"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        htmltext = event
      end
    when "31961-05a.html", "31961-05b.html", "31961-05c.html", "31961-05g.html"
      htmltext = event
    when "31961-05d.html"
      if qs.memo_state?(1) && get_quest_items_count(player, BRUIN_LIZARDMAN_BLOOD) >= 10
        take_items(player, BRUIN_LIZARDMAN_BLOOD, -1)
        qs.memo_state = 2
        qs.set_memo_state_ex(1, 1)
        qs.set_cond(3, true)
        htmltext = event
      end
    when "31961-05e.html"
      if qs.memo_state?(1) && get_quest_items_count(player, BRUIN_LIZARDMAN_BLOOD) >= 10
        take_items(player, BRUIN_LIZARDMAN_BLOOD, -1)
        qs.memo_state = 2
        qs.set_memo_state_ex(1, 2)
        qs.set_cond(4, true)
        htmltext = event
      end
    when "31961-05f.html"
      if qs.memo_state?(1) && get_quest_items_count(player, BRUIN_LIZARDMAN_BLOOD) >= 10
        take_items(player, BRUIN_LIZARDMAN_BLOOD, -1)
        qs.memo_state = 2
        qs.set_memo_state_ex(1, 3)
        qs.set_cond(5, true)
        htmltext = event
      end
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started?
      case npc.id
      when BRUIN_LIZARDMAN
        if qs.memo_state?(1)
          if give_item_randomly(killer, npc, BRUIN_LIZARDMAN_BLOOD, 1, 10, 7, true)
            qs.set_cond(2)
          end
        end
      when PICOT_ARANEID
        if qs.memo_state?(4)
          if killer.sponsor > 0
            c0 = L2World.get_player(killer.sponsor)
            if c0 && Util.in_range?(1500, npc, c0, true)
              if give_item_randomly(killer, npc, PICOT_ARANEIDS_LEG, 1, 8, 7, true)
                qs.set_cond(8)
              end
            end
          end
        end
      end
    end

    super
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)
    q118 = player.get_quest_state(Q00118_ToLeadAndBeLed.simple_name)

    case qs.state
    when State::CREATED
      if q118 && q118.started?
        htmltext = "31961-02b.htm"
      elsif q118 && q118.completed?
        htmltext = "31961-02a.html"
      elsif player.level >= MIN_LEVEL && player.pledge_type == -1 && player.sponsor > 0
        htmltext = "31961-01.htm"
      else
        htmltext = "31961-02.htm"
      end
    when State::STARTED
      if qs.memo_state?(1)
        if get_quest_items_count(player, BRUIN_LIZARDMAN_BLOOD) < 10
          htmltext = "31961-04.html"
        else
          htmltext = "31961-05.html"
        end
      elsif qs.memo_state?(2)
        if player.sponsor == 0
          if qs.get_memo_state_ex(1) == 1
            htmltext = "31961-06a.html"
          elsif qs.get_memo_state_ex(1) == 2
            htmltext = "31961-06b.html"
          elsif qs.get_memo_state_ex(1) == 3
            htmltext = "31961-06c.html"
          end
        else
          c0 = L2World.get_player(player.sponsor)
          if c0 && Util.in_range?(1500, npc, c0, true)
            htmltext = "31961-07.html"
          else
            if qs.get_memo_state_ex(1) == 1
              htmltext = "31961-06.html"
            elsif qs.get_memo_state_ex(1) == 2
              htmltext = "31961-06d.html"
            elsif qs.get_memo_state_ex(1) == 3
              htmltext = "31961-06e.html"
            end
          end
        end
      elsif qs.memo_state?(3)
        qs.memo_state = 4
        qs.set_cond(7, true)
        htmltext = "31961-15.html"
      elsif qs.memo_state?(4)
        if get_quest_items_count(player, PICOT_ARANEIDS_LEG) < 8
          htmltext = "31961-16.html"
        else
          if qs.get_memo_state_ex(1) == 1
            give_items(player, CLAN_OATH_HELM, 1)
            give_items(player, CLAN_OATH_ARMOR, 1)
            give_items(player, CLAN_OATH_GAUNTLETS_HEAVY_ARMOR, 1)
            give_items(player, CLAN_OATH_SABATON_HEAVY_ARMOR, 1)
            take_items(player, PICOT_ARANEIDS_LEG, -1)
          elsif qs.get_memo_state_ex(1) == 2
            give_items(player, CLAN_OATH_HELM, 1)
            give_items(player, CLAN_OATH_BRIGANDINE, 1)
            give_items(player, CLAN_OATH_LEATHER_GLOVES_LIGHT_ARMOR, 1)
            give_items(player, CLAN_OATH_BOOTS_LIGHT_ARMOR, 1)
            take_items(player, PICOT_ARANEIDS_LEG, -1)
          elsif qs.get_memo_state_ex(1) == 3
            give_items(player, CLAN_OATH_HELM, 1)
            give_items(player, CLAN_OATH_AKETON, 1)
            give_items(player, CLAN_OATH_PADDED_GLOVES_ROBE, 1)
            give_items(player, CLAN_OATH_SANDALS_ROBE, 1)
            take_items(player, PICOT_ARANEIDS_LEG, -1)
          end
          qs.exit_quest(false, true)
          htmltext = "31961-17.html"
        end
      end
    when State::COMPLETED
      htmltext = get_already_completed_msg(player)
    end

    htmltext || get_no_quest_msg(player)
  end
end
