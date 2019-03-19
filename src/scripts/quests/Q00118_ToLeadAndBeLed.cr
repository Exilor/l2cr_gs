class Quests::Q00118_ToLeadAndBeLed < Quest
  # NPC
  private BLACKSMITH_PINTER = 30298
  # Items
  private CRYSTAL_D = 1458
  private BLOOD_OF_MAILLE_LIZARDMAN = 8062
  private LEG_OF_KING_ARANEID = 8063
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
  # Monster
  private MAILLE_LIZARDMAN = 20919
  private MAILLE_LIZARDMAN_SCOUT = 20920
  private MAILLE_LIZARDMAN_GUARD = 20921
  private KING_OF_THE_ARANEID = 20927
  # Misc
  private MIN_LEVEL = 19
  private CRYSTAL_COUNT_1 = 922
  private CRYSTAL_COUNT_2 = 771

  def initialize
    super(118, self.class.simple_name, "To Lead And Be Led")

    add_start_npc(BLACKSMITH_PINTER)
    add_talk_id(BLACKSMITH_PINTER)
    add_kill_id(
      MAILLE_LIZARDMAN, MAILLE_LIZARDMAN_SCOUT, MAILLE_LIZARDMAN_GUARD,
      KING_OF_THE_ARANEID
    )
    register_quest_items(LEG_OF_KING_ARANEID, BLOOD_OF_MAILLE_LIZARDMAN)
  end

  def on_adv_event(event, npc, player)
    player = player.not_nil!
    # Manage Sponsor's quest events.
    if player.apprentice > 0
      unless apprentice = L2World.get_player(player.apprentice)
        return
      end

      q118 = apprentice.get_quest_state(Q00118_ToLeadAndBeLed.simple_name)
      case event
      when "sponsor"
        if !Util.in_range?(1500, npc, apprentice, true)
          htmltext = "30298-09.html"
        else
          if q118.nil? || (!q118.memo_state?(2) && !q118.memo_state?(3))
            htmltext = "30298-14.html"
          elsif q118.memo_state?(2)
            htmltext = "30298-08.html"
          elsif q118.memo_state?(3)
            htmltext = "30298-12.html"
          end
        end
      when "30298-10.html"
        if Util.in_range?(1500, npc, apprentice, true) && q118 && q118.memo_state?(2)
          case q118.get_memo_state_ex(1)
          when 1
            if get_quest_items_count(player, CRYSTAL_D) >= CRYSTAL_COUNT_1
              take_items(player, CRYSTAL_D, CRYSTAL_COUNT_1)
              q118.memo_state = 3
              q118.set_cond(6, true)
              htmltext = event
            else
              htmltext = "30298-11.html"
            end
          when 2, 3
            if get_quest_items_count(player, CRYSTAL_D) >= CRYSTAL_COUNT_2
              take_items(player, CRYSTAL_D, CRYSTAL_COUNT_2)
              q118.memo_state = 3
              q118.set_cond(6, true)
              htmltext = event
            else
              htmltext = "30298-11a.html"
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
    when "30298-03.htm"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        htmltext = event
      end
    when "30298-05a.html", "30298-05b.html", "30298-05c.html", "30298-05g.html"
      htmltext = event
    when "30298-05d.html"
      if qs.memo_state?(1) && get_quest_items_count(player, BLOOD_OF_MAILLE_LIZARDMAN) >= 10
        take_items(player, BLOOD_OF_MAILLE_LIZARDMAN, -1)
        qs.memo_state = 2
        qs.set_memo_state_ex(1, 1)
        qs.set_cond(3, true)
        htmltext = event
      end
    when "30298-05e.html"
      if qs.memo_state?(1) && get_quest_items_count(player, BLOOD_OF_MAILLE_LIZARDMAN) >= 10
        take_items(player, BLOOD_OF_MAILLE_LIZARDMAN, -1)
        qs.memo_state = 2
        qs.set_memo_state_ex(1, 2)
        qs.set_cond(4, true)
        htmltext = event
      end
    when "30298-05f.html"
      if qs.memo_state?(1) && get_quest_items_count(player, BLOOD_OF_MAILLE_LIZARDMAN) >= 10
        take_items(player, BLOOD_OF_MAILLE_LIZARDMAN, -1)
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
      when MAILLE_LIZARDMAN, MAILLE_LIZARDMAN_SCOUT, MAILLE_LIZARDMAN_GUARD
        if qs.memo_state?(1)
          if give_item_randomly(killer, npc, BLOOD_OF_MAILLE_LIZARDMAN, 1, 10, 7, true)
            qs.set_cond(2)
          end
        end
      when KING_OF_THE_ARANEID
        if qs.memo_state?(4)
          if killer.sponsor > 0
            c0 = L2World.get_player(killer.sponsor)
            if c0 && Util.in_range?(1500, npc, c0, true)
              if give_item_randomly(killer, npc, LEG_OF_KING_ARANEID, 1, 8, 7, true)
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
    q123 = player.get_quest_state(Q00123_TheLeaderAndTheFollower.simple_name)

    case qs.state
    when State::CREATED
      if q123 && q123.started?
        htmltext = "30298-02b.html"
      elsif q123 && q123.completed?
        htmltext = "30298-02a.htm"
      elsif player.level >= MIN_LEVEL && player.pledge_type == -1 && player.sponsor > 0
        htmltext = "30298-01.htm"
      else
        htmltext = "30298-02.htm"
      end
    when State::STARTED
      if qs.memo_state?(1)
        if get_quest_items_count(player, BLOOD_OF_MAILLE_LIZARDMAN) < 10
          htmltext = "30298-04.html"
        else
          htmltext = "30298-05.html"
        end
      elsif qs.memo_state?(2)
        if player.sponsor == 0
          if qs.get_memo_state_ex(1) == 1
            htmltext = "30298-06a.html"
          elsif qs.get_memo_state_ex(1) == 2
            htmltext = "30298-06b.html"
          elsif qs.get_memo_state_ex(1) == 3
            htmltext = "30298-06c.html"
          end
        else
          c0 = L2World.get_player(player.sponsor)
          if c0 && Util.in_range?(1500, npc, c0, true)
            htmltext = "30298-07.html"
          else
            if qs.get_memo_state_ex(1) == 1
              htmltext = "30298-06.html"
            elsif qs.get_memo_state_ex(1) == 2
              htmltext = "30298-06d.html"
            elsif qs.get_memo_state_ex(1) == 3
              htmltext = "30298-06e.html"
            end
          end
        end
      elsif qs.memo_state?(3)
        qs.memo_state = 4
        qs.set_cond(7, true)
        htmltext = "30298-15.html"
      elsif qs.memo_state?(4)
        if get_quest_items_count(player, LEG_OF_KING_ARANEID) < 8
          htmltext = "30298-16.html"
        else
          if qs.get_memo_state_ex(1) == 1
            give_items(player, CLAN_OATH_HELM, 1)
            give_items(player, CLAN_OATH_ARMOR, 1)
            give_items(player, CLAN_OATH_GAUNTLETS_HEAVY_ARMOR, 1)
            give_items(player, CLAN_OATH_SABATON_HEAVY_ARMOR, 1)
            take_items(player, LEG_OF_KING_ARANEID, -1)
          elsif qs.get_memo_state_ex(1) == 2
            give_items(player, CLAN_OATH_HELM, 1)
            give_items(player, CLAN_OATH_BRIGANDINE, 1)
            give_items(player, CLAN_OATH_LEATHER_GLOVES_LIGHT_ARMOR, 1)
            give_items(player, CLAN_OATH_BOOTS_LIGHT_ARMOR, 1)
            take_items(player, LEG_OF_KING_ARANEID, -1)
          elsif qs.get_memo_state_ex(1) == 3
            give_items(player, CLAN_OATH_HELM, 1)
            give_items(player, CLAN_OATH_AKETON, 1)
            give_items(player, CLAN_OATH_PADDED_GLOVES_ROBE, 1)
            give_items(player, CLAN_OATH_SANDALS_ROBE, 1)
            take_items(player, LEG_OF_KING_ARANEID, -1)
          end
          qs.exit_quest(false, true)
          htmltext = "30298-17.html"
        end
      end
    when State::COMPLETED
      htmltext = get_already_completed_msg(player)
    end

    htmltext || get_no_quest_msg(player)
  end
end
