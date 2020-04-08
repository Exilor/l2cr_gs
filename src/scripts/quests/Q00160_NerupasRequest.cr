class Scripts::Q00160_NerupasRequest < Quest
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
    register_quest_items(
      SILVERY_SPIDERSILK, UNOS_RECEIPT, CELS_TICKET, NIGHTSHADE_LEAF
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    qs = get_quest_state(pc, false)
    if qs && event == "30370-04.htm"
      qs.start_quest
      unless has_quest_items?(pc, SILVERY_SPIDERSILK)
        give_items(pc, SILVERY_SPIDERSILK, 1)
      end

      return event
    end
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case qs.state
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    when State::CREATED
      if npc.id == NERUPA
        if !pc.race.elf?
          html = "30370-01.htm"
        elsif pc.level < MIN_LEVEL
          html = "30370-02.htm"
        else
          html = "30370-03.htm"
        end
      end
    when State::STARTED
      case npc.id
      when NERUPA
        if has_at_least_one_quest_item?(pc, SILVERY_SPIDERSILK, UNOS_RECEIPT, CELS_TICKET)
          html = "30370-05.html"
        elsif has_quest_items?(pc, NIGHTSHADE_LEAF)
          reward_items(pc, LESSER_HEALING_POTION, 5)
          add_exp_and_sp(pc, 1000, 0)
          qs.exit_quest(false, true)
          html = "30370-06.html"
        end
      when UNOREN
        if has_quest_items?(pc, SILVERY_SPIDERSILK)
          take_items(pc, SILVERY_SPIDERSILK, -1)
          unless has_quest_items?(pc, UNOS_RECEIPT)
            give_items(pc, UNOS_RECEIPT, 1)
          end
          qs.set_cond(2, true)
          html = "30147-01.html"
        elsif has_quest_items?(pc, UNOS_RECEIPT)
          html = "30147-02.html"
        elsif has_quest_items?(pc, NIGHTSHADE_LEAF)
          html = "30147-03.html"
        end
      when CREAMEES
        if has_quest_items?(pc, UNOS_RECEIPT)
          take_items(pc, UNOS_RECEIPT, -1)
          unless has_quest_items?(pc, CELS_TICKET)
            give_items(pc, CELS_TICKET, 1)
          end
          qs.set_cond(3, true)
          html = "30149-01.html"
        elsif has_quest_items?(pc, CELS_TICKET)
          html = "30149-02.html"
        elsif has_quest_items?(pc, NIGHTSHADE_LEAF)
          html = "30149-03.html"
        end
      when JULIA
        if has_quest_items?(pc, CELS_TICKET)
          take_items(pc, CELS_TICKET, -1)
          unless has_quest_items?(pc, NIGHTSHADE_LEAF)
            give_items(pc, NIGHTSHADE_LEAF, 1)
          end
          qs.set_cond(4, true)
          html = "30152-01.html"

        elsif has_quest_items?(pc, NIGHTSHADE_LEAF)
          html = "30152-02.html"
        end
      else
        # automatically added
      end

    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end