class Quests::Q00001_LettersOfLove < Quest
  # NPCs
  private DARIN = 30048
  private ROXXY = 30006
  private BAULRO = 30033
  # Items
  private DARINS_LETTER = 687
  private ROXXYS_KERCHIEF = 688
  private DARINS_RECEIPT = 1079
  private BAULROS_POTION = 1080
  private NECKLACE_OF_KNOWLEDGE = 906
  # Misc
  private MIN_LEVEL = 2

  def initialize
    super(1, self.class.simple_name, "Letters of Love")

    add_start_npc(DARIN)
    add_talk_id(DARIN, ROXXY, BAULRO)
    register_quest_items(
      DARINS_LETTER,
      ROXXYS_KERCHIEF,
      DARINS_RECEIPT,
      BAULROS_POTION
    )
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!
    return unless st = get_quest_state(pc, false)

    case event
    when "30048-03.html", "30048-04.html", "30048-05.html"
      event
    when "30048-06.htm"
      if pc.level >= MIN_LEVEL
        st.start_quest
        give_items(pc, DARINS_LETTER, 1)
        event
      end
    end
  end

  def on_talk(npc, pc)
    return unless st = get_quest_state(pc, true)
    htmltext = get_no_quest_msg(pc)

    case st.state
    when State::CREATED
      htmltext = pc.level < MIN_LEVEL ? "30048-01.html" : "30048-02.html"
    when State::STARTED
      case st.cond
      when 1
        case npc.id
        when DARIN
          htmltext = "30048-07.html"
        when ROXXY
          if has_quest_items?(pc, DARINS_LETTER) && !has_quest_items?(pc, ROXXYS_KERCHIEF)
            take_items(pc, DARINS_LETTER, -1)
            give_items(pc, ROXXYS_KERCHIEF, 1)
            st.set_cond(2, true)
            htmltext = "30006-01.html"
          end
        end
      when 2
        case npc.id
        when DARIN
          if has_quest_items?(pc, ROXXYS_KERCHIEF)
            take_items(pc, ROXXYS_KERCHIEF, -1)
            give_items(pc, DARINS_RECEIPT, 1)
            st.set_cond(3, true)
            htmltext = "30048-08.html"
          end
        when ROXXY
          if has_quest_items?(pc, ROXXYS_KERCHIEF)
            htmltext = "30006-02.html"
          end
        end
      when 3
        case npc.id
        when DARIN
          if has_quest_items?(pc, DARINS_RECEIPT) || !has_quest_items?(pc, BAULROS_POTION)
            htmltext = "30048-09.html"
          end
        when ROXXY
          if has_quest_items?(pc, DARINS_RECEIPT) || !has_quest_items?(pc, BAULROS_POTION)
            htmltext = "30006-03.html"
          end
        when BAULRO
          if has_quest_items?(pc, DARINS_RECEIPT)
            take_items(pc, DARINS_RECEIPT, -1)
            give_items(pc, BAULROS_POTION, 1)
            st.set_cond(4, true)
            htmltext = "30033-01.html"
          elsif has_quest_items?(pc, BAULROS_POTION)
            htmltext = "30033-02.html"
          end
        end
      when 4
        case npc.id
        when DARIN
          show_on_screen_msg(pc, NpcString::DELIVERY_DUTY_COMPLETE_N_GO_FIND_THE_NEWBIE_GUIDE, 2, 5000)
          give_items(pc, NECKLACE_OF_KNOWLEDGE, 1)
          add_exp_and_sp(pc, 5672, 446)
          give_adena(pc, 2466, false)
          st.exit_quest(false, true)
          htmltext = "30048-10.html"
        when BAULRO
          if has_quest_items?(pc, BAULROS_POTION)
            htmltext = "30033-02.html"
          end
        when ROXXY
          if has_quest_items?(pc, BAULROS_POTION)
            htmltext = "30006-03.html"
          end
        end
      end
    when State::COMPLETED
      htmltext = get_already_completed_msg(pc)
    end

    htmltext
  end
end
