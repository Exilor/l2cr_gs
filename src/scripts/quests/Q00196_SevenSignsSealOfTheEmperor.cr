class Scripts::Q00196_SevenSignsSealOfTheEmperor < Quest
  # NPCs
  private IASON_HEINE = 30969
  private MERCHANT_OF_MAMMON = 32584
  private SHUNAIMAN = 32586
  private WOOD = 32593
  private COURT_MAGICIAN = 32598
  # Items
  private ELMOREDEN_HOLY_WATER = 13808
  private COURT_MAGICIANS_MAGIC_STAFF = 13809
  private SEAL_OF_BINDING = 13846
  private SACRED_SWORD_OF_EINHASAD = 15310
  # Misc
  private MIN_LEVEL = 79

  @busy = false

  def initialize
    super(196, self.class.simple_name, "Seven Signs, Seal of the Emperor")

    add_first_talk_id(MERCHANT_OF_MAMMON)
    add_start_npc(IASON_HEINE)
    add_talk_id(
      IASON_HEINE, MERCHANT_OF_MAMMON, SHUNAIMAN, WOOD, COURT_MAGICIAN
    )
    register_quest_items(
      ELMOREDEN_HOLY_WATER, COURT_MAGICIANS_MAGIC_STAFF, SEAL_OF_BINDING,
      SACRED_SWORD_OF_EINHASAD
    )
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!

    if npc.id == MERCHANT_OF_MAMMON && event == "DESPAWN"
      @busy = false
      npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::THE_ANCIENT_PROMISE_TO_THE_EMPEROR_HAS_BEEN_FULFILLED))
      npc.delete_me

      return super
    end

    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30969-02.htm", "30969-03.htm", "30969-04.htm"
      html = event
    when "30969-05.html"
      st.start_quest
      html = event
    when "ssq_mammon"
      if st.cond?(1)
        if !@busy
          @busy = true
          npc.script_value = 1
           merchant = add_spawn(MERCHANT_OF_MAMMON, 109743, 219975, -3512, 0, false, 0, false)
          merchant.broadcast_packet(NpcSay.new(merchant.l2id, Say2::NPC_ALL, merchant.id, NpcString::WHO_DARES_SUMMON_THE_MERCHANT_OF_MAMMON))
          html = "30969-06.html"
          start_quest_timer("DESPAWN", 120000, merchant, nil)
        else
          html = "30969-07.html"
        end
      end
    when "30969-13.html"
      if st.cond?(5)
        html = event
      end
    when "30969-14.html"
      if st.cond?(5)
        st.set_cond(6, true)
        html = event
      end
    when "32584-02.html", "32584-03.html", "32584-04.html"
      if st.cond?(1)
        html = event
      end
    when "32584-05.html"
      if st.cond?(1)
        st.set_cond(2, true)
        html = event
        cancel_quest_timers("DESPAWN")
        npc.delete_me
        @busy = false
      end
    when "32586-02.html", "32586-03.html", "32586-04.html", "32586-06.html"
      if st.cond?(3)
        html = event
      end
    when "32586-07.html"
      if st.cond?(3)
        give_items(pc, ELMOREDEN_HOLY_WATER, 1)
        give_items(pc, SACRED_SWORD_OF_EINHASAD, 1)
        st.set_cond(4, true)
        pc.send_packet(SystemMessageId::BY_USING_THE_SKILL_OF_EINHASAD_S_HOLY_SWORD_DEFEAT_THE_EVIL_LILIMS)
        pc.send_packet(SystemMessageId::USING_EINHASAD_HOLY_WATER_TO_OPEN_DOOR)
        html = event
      end
    when "32586-11.html", "32586-12.html", "32586-13.html"
      if st.cond?(4) && get_quest_items_count(pc, SEAL_OF_BINDING) >= 4
        html = event
      end
    when "32586-14.html"
      if st.cond?(4) && get_quest_items_count(pc, SEAL_OF_BINDING) >= 4
        take_items(pc, -1, {ELMOREDEN_HOLY_WATER, COURT_MAGICIANS_MAGIC_STAFF, SEAL_OF_BINDING, SACRED_SWORD_OF_EINHASAD})
        st.set_cond(5, true)
        html = event
      end
    when "finish"
      if st.cond?(6)
        if pc.level >= MIN_LEVEL
          add_exp_and_sp(pc, 52518015, 5817677)
          st.exit_quest(false, true)
          html = "32593-02.html"
        else
          html = "level_check.html"
        end
      end
    when "32598-02.html"
      if st.cond?(3) || st.cond?(4)
        give_items(pc, COURT_MAGICIANS_MAGIC_STAFF, 1)
        html = event
      end
    end

    html
  end

  def on_first_talk(npc, pc)
    "32584.htm"
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    when State::CREATED
      if npc.id == IASON_HEINE
        if pc.level >= MIN_LEVEL && pc.quest_completed?(Q00195_SevenSignsSecretRitualOfThePriests.simple_name)
          html = "30969-01.htm"
        else
          html = "30969-08.html"
        end
      end
    when State::STARTED
      case npc.id
      when IASON_HEINE
        case st.cond
        when 1
          html = "30969-09.html"
        when 2
          st.set_cond(3, true)
          npc.script_value = 0
          html = "30969-10.html"
        when 3, 4
          html = "30969-11.html"
        when 5
          html = "30969-12.html"
        when 6
          html = "30969-15.html"
        end
      when MERCHANT_OF_MAMMON
        if st.cond?(1)
          if npc.script_value?(0)
            npc.script_value = pc.l2id
          end
          html = npc.script_value?(pc.l2id) ? "32584-01.html" : "32584-06.html"
        end
      when SHUNAIMAN
        case st.cond
        when 3
          html = "32586-01.html"
        when 4
          if get_quest_items_count(pc, SEAL_OF_BINDING) < 4
            if has_quest_items?(pc, ELMOREDEN_HOLY_WATER, SACRED_SWORD_OF_EINHASAD)
              html = "32586-08.html"
            elsif !has_quest_items?(pc, ELMOREDEN_HOLY_WATER) && has_quest_items?(pc, SACRED_SWORD_OF_EINHASAD)
              html = "32586-09.html"
              give_items(pc, ELMOREDEN_HOLY_WATER, 1)
            elsif has_quest_items?(pc, ELMOREDEN_HOLY_WATER) && !has_quest_items?(pc, SACRED_SWORD_OF_EINHASAD)
              html = "32586-09.html"
              give_items(pc, SACRED_SWORD_OF_EINHASAD, 1)
            end
            pc.send_packet(SystemMessageId::BY_USING_THE_SKILL_OF_EINHASAD_S_HOLY_SWORD_DEFEAT_THE_EVIL_LILIMS)
            pc.send_packet(SystemMessageId::USING_EINHASAD_HOLY_WATER_TO_OPEN_DOOR)
          else
            html = "32586-10.html"
          end
        when 5
          html = "32586-15.html"
        end
      when WOOD
        if st.cond?(6)
          html = "32593-01.html"
        end
      when COURT_MAGICIAN
        if st.cond?(3) || st.cond?(4)
          if has_quest_items?(pc, COURT_MAGICIANS_MAGIC_STAFF)
            html = "32598-03.html"
          else
            html = "32598-01.html"
          end
          pc.send_packet(SystemMessageId::USING_COURT_MAGICIANS_STAFF_TO_OPEN_DOOR)
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
