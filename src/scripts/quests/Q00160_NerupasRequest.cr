class Quests::Q00160_NerupasRequest < Quest
  # NPCs
  private NERUPA = 30370
  private UNOREN = 30147
  private CREAMEES = 30149
  private JULIA = 30152
  # Items
  private SILVERY_SPIDERSILK = 1026
  private UNOS_RECEIPT = 1027
  private CELS_TICKET = 1028
  private NIGHTSHADE_LEAF = 1029
  # Reward
  private LESSER_HEALING_POTION = 1060
  # Misc
  private MIN_LEVEL = 3

  def initialize
    super(160, self.class.simple_name, "Nerupa's Request")

    add_start_npc(NERUPA)
    add_talk_id(NERUPA, UNOREN, CREAMEES, JULIA)
    register_quest_items(SILVERY_SPIDERSILK, UNOS_RECEIPT, CELS_TICKET, NIGHTSHADE_LEAF)
  end

  def on_adv_event(event, npc, player)
    return unless player
    qs = get_quest_state(player, false)
    if qs && event == "30370-04.htm"
      qs.start_quest
      if !has_quest_items?(player, SILVERY_SPIDERSILK)
        give_items(player, SILVERY_SPIDERSILK, 1)
      end

      return event
    end
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)
    case qs.state
    when State::COMPLETED
      htmltext = get_already_completed_msg(player)
    when State::CREATED
      if npc.id == NERUPA
        if !player.race.elf?
          htmltext = "30370-01.htm"
        elsif player.level < MIN_LEVEL
          htmltext = "30370-02.htm"
        else
          htmltext = "30370-03.htm"
        end
      end
    when State::STARTED
      case npc.id
      when NERUPA
        if has_at_least_one_quest_item?(player, SILVERY_SPIDERSILK, UNOS_RECEIPT, CELS_TICKET)
          htmltext = "30370-05.html"
        elsif has_quest_items?(player, NIGHTSHADE_LEAF)
          reward_items(player, LESSER_HEALING_POTION, 5)
          add_exp_and_sp(player, 1000, 0)
          qs.exit_quest(false, true)
          htmltext = "30370-06.html"
        end
      when UNOREN
        if has_quest_items?(player, SILVERY_SPIDERSILK)
          take_items(player, SILVERY_SPIDERSILK, -1)
          if !has_quest_items?(player, UNOS_RECEIPT)
            give_items(player, UNOS_RECEIPT, 1)
          end
          qs.set_cond(2, true)
          htmltext = "30147-01.html"
        elsif has_quest_items?(player, UNOS_RECEIPT)
          htmltext = "30147-02.html"
        elsif has_quest_items?(player, NIGHTSHADE_LEAF)
          htmltext = "30147-03.html"
        end
      when CREAMEES
        if has_quest_items?(player, UNOS_RECEIPT)
          take_items(player, UNOS_RECEIPT, -1)
          if !has_quest_items?(player, CELS_TICKET)
            give_items(player, CELS_TICKET, 1)
          end
          qs.set_cond(3, true)
          htmltext = "30149-01.html"
        elsif has_quest_items?(player, CELS_TICKET)
          htmltext = "30149-02.html"
        elsif has_quest_items?(player, NIGHTSHADE_LEAF)
          htmltext = "30149-03.html"
        end
      when JULIA
        if has_quest_items?(player, CELS_TICKET)
          take_items(player, CELS_TICKET, -1)
          if !has_quest_items?(player, NIGHTSHADE_LEAF)
            give_items(player, NIGHTSHADE_LEAF, 1)
          end
          qs.set_cond(4, true)
          htmltext = "30152-01.html"

        elsif has_quest_items?(player, NIGHTSHADE_LEAF)
          htmltext = "30152-02.html"
        end
      end
    end

    htmltext
  end
end
