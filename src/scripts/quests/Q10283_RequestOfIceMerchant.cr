class Scripts::Q10283_RequestOfIceMerchant < Quest
  # NPCs
  private RAFFORTY = 32020
  private KIER = 32022
  private JINIA = 32760
  # Misc
  private MIN_LEVEL = 82

  @busy = false
  @talker = 0

  def initialize
    super(10283, self.class.simple_name, "Request of Ice Merchant")

    add_start_npc(RAFFORTY)
    add_talk_id(RAFFORTY, KIER, JINIA)
  end

  def on_adv_event(event, npc, pc)
    return unless npc
    if npc.id == JINIA && event == "DESPAWN"
      @busy = false
      @talker = 0
      npc.delete_me
      return super
    end

    return unless pc && (st = get_quest_state(pc, false))

    case event
    when "32020-03.htm"
      html = event
    when "32020-04.htm"
      st.start_quest
      st.memo_state = 1
      html = event
    when "32020-05.html", "32020-06.html"
      if st.memo_state?(1)
        html = event
      end
    when "32020-07.html"
      if st.memo_state?(1)
        st.memo_state = 2
        st.set_cond(2)
        html = event
      end
    when "32022-02.html"
      if st.memo_state?(2)
        if !@busy
          @busy = true
          @talker = pc.l2id
          st.set_cond(3)
          add_spawn(JINIA, 104476, -107535, -3688, 44954, false, 0, false)
        else
          html = @talker == pc.l2id ? event : "32022-03.html"
        end
      end
    when "32760-02.html", "32760-03.html"
      if st.memo_state?(2)
        html = event
      end
    when "32760-04.html"
      if st.memo_state?(2)
        give_adena(pc, 190_000, true)
        add_exp_and_sp(pc, 627_000, 50_300)
        st.exit_quest(false, true)
        html = event
        start_quest_timer("DESPAWN", 2000, npc, nil)
      end
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.completed?
      if npc.id == RAFFORTY
        html = "32020-02.html"
      elsif npc.id == JINIA
        html = "32760-06.html"
      end
    elsif st.created?
      if pc.level >= MIN_LEVEL && pc.quest_completed?(Q00115_TheOtherSideOfTruth.simple_name)
        html = "32020-01.htm"
      else
        html = "32020-08.htm"
      end
    elsif st.started?
      case npc.id
      when RAFFORTY
        if st.memo_state?(1)
          html = "32020-09.html"
        elsif st.memo_state?(2)
          html = "32020-10.html"
        end
      when KIER
        if st.memo_state?(2)
          html = "32022-01.html"
        end
      when JINIA
        if st.memo_state?(2)
          html = @talker == pc.l2id ? "32760-01.html" : "32760-05.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
