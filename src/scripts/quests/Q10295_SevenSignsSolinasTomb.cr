class Scripts::Q10295_SevenSignsSolinasTomb < Quest
  # NPCs
  private ELCADIA = 32787
  private ERISS_EVIL_THOUGHTS = 32792
  private SOLINAS_EVIL_THOUGHTS = 32793
  private SOLINA = 32794
  private ERIS = 32795
  private ANAIS = 32796
  private JUDE_VAN_ETINA = 32797
  private TELEPORT_CONTROL_DEVICE_1 = 32837
  private POWERFUL_DEVICE_1 = 32838
  private POWERFUL_DEVICE_2 = 32839
  private POWERFUL_DEVICE_3 = 32840
  private POWERFUL_DEVICE_4 = 32841
  private TELEPORT_CONTROL_DEVICE_2 = 32842
  private TOMB_OF_THE_SAINTESS = 32843
  private TELEPORT_CONTROL_DEVICE_3 = 32844
  private ALTAR_OF_HALLOWS_1 = 32857
  private ALTAR_OF_HALLOWS_2 = 32858
  private ALTAR_OF_HALLOWS_3 = 32859
  private ALTAR_OF_HALLOWS_4 = 32860
  # Items
  private SCROLL_OF_ABSTINENCE = 17228
  private SHIELD_OF_SACRIFICE = 17229
  private SWORD_OF_HOLY_SPIRIT = 17230
  private STAFF_OF_BLESSING = 17231
  # Misc
  private MIN_LEVEL = 81

  def initialize
    super(10295, self.class.simple_name, "Seven Signs, Solina's Tomb")

    add_start_npc(ERISS_EVIL_THOUGHTS)
    add_talk_id(
      ERISS_EVIL_THOUGHTS, SOLINAS_EVIL_THOUGHTS, SOLINA, ERIS, ANAIS,
      JUDE_VAN_ETINA, TELEPORT_CONTROL_DEVICE_1, POWERFUL_DEVICE_1,
      POWERFUL_DEVICE_2, POWERFUL_DEVICE_3, POWERFUL_DEVICE_4,
      TELEPORT_CONTROL_DEVICE_2, TOMB_OF_THE_SAINTESS,
      TELEPORT_CONTROL_DEVICE_3, ALTAR_OF_HALLOWS_1, ALTAR_OF_HALLOWS_2,
      ALTAR_OF_HALLOWS_3, ALTAR_OF_HALLOWS_4, ELCADIA
    )
    register_quest_items(
      SCROLL_OF_ABSTINENCE, SHIELD_OF_SACRIFICE, SWORD_OF_HOLY_SPIRIT,
      STAFF_OF_BLESSING
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "32792-02.htm", "32792-04.htm", "32792-05.htm", "32792-06.htm",
         "32793-06.html"
      html = event
    when "32792-03.htm"
      st.start_quest
      st.memo_state = 1
      html = event
    when "32793-02.html", "32793-03.html"
      if st.memo_state?(3)
        html = event
      end
    when "32793-04.html"
      if st.memo_state?(3)
        st.memo_state = 4
        st.set_cond(2, true)
        html = event
      end
    when "32793-05.html", "32794-02.html"
      if st.memo_state?(4)
        st.memo_state = 5
        html = event
      end
    when "32793-07.html"
      if st.memo_state?(5)
        html = event
      end
    when "32793-08.html"
      if st.memo_state?(5)
        st.memo_state = 6
        st.set_cond(3, true)
        html = event
      end
    when "32837-02.html"
      if st.memo_state > 1
        take_items(pc, -1, {SCROLL_OF_ABSTINENCE, SHIELD_OF_SACRIFICE, SWORD_OF_HOLY_SPIRIT, STAFF_OF_BLESSING})
        html = event
      end
    when "32838-02.html"
      if st.memo_state?(1)
        if has_quest_items?(pc, SCROLL_OF_ABSTINENCE)
          html = event
        else
          html = "32838-03.html"
        end
      end
    when "32839-02.html"
      if st.memo_state?(1)
        if has_quest_items?(pc, SHIELD_OF_SACRIFICE)
          html = event
        else
          html = "32839-03.html"
        end
      end
    when "32840-02.html"
      if st.memo_state?(1)
        if has_quest_items?(pc, SWORD_OF_HOLY_SPIRIT)
          html = event
        else
          html = "32840-03.html"
        end
      end
    when "32841-02.html"
      if st.memo_state?(1)
        if has_quest_items?(pc, STAFF_OF_BLESSING)
          html = event
        else
          html = "32841-03.html"
        end
      end
    when "32857-02.html"
      if st.memo_state?(1)
        if has_quest_items?(pc, STAFF_OF_BLESSING)
          html = event
        else
          give_items(pc, STAFF_OF_BLESSING, 1)
          html = "32857-03.html"
        end
      end
    when "32858-02.html"
      if st.memo_state?(1)
        if has_quest_items?(pc, SWORD_OF_HOLY_SPIRIT)
          html = event
        else
          give_items(pc, SWORD_OF_HOLY_SPIRIT, 1)
          html = "32858-03.html"
        end
      end
    when "32859-02.html"
      if st.memo_state?(1)
        if has_quest_items?(pc, SCROLL_OF_ABSTINENCE)
          html = event
        else
          give_items(pc, SCROLL_OF_ABSTINENCE, 1)
          html = "32859-03.html"
        end
      end
    when "32860-02.html"
      if st.memo_state?(1)
        if has_quest_items?(pc, SHIELD_OF_SACRIFICE)
          html = event
        else
          give_items(pc, SHIELD_OF_SACRIFICE, 1)
          html = "32860-03.html"
        end
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.completed?
      if npc.id == ERISS_EVIL_THOUGHTS
        html = "32792-07.html"
      end
    elsif st.created?
      if pc.level >= MIN_LEVEL && pc.quest_completed?(Q10294_SevenSignsToTheMonasteryOfSilence.simple_name)
        html = "32792-01.htm"
      end
    elsif st.started?
      case npc.id
      when ERISS_EVIL_THOUGHTS
        memo_state = st.memo_state
        if memo_state == 1
          html = "32792-12.html"
        elsif memo_state == 2
          html = "32792-08.html"
        elsif memo_state > 2 && memo_state < 6
          html = "32792-09.html"
        elsif memo_state == 6
          if pc.subclass_active?
            html = "32792-10.html"
          else
            add_exp_and_sp(pc, 125000000, 12500000)
            st.exit_quest(false, true)
            html = "32792-11.html"
          end
        end
      when SOLINAS_EVIL_THOUGHTS
        case st.memo_state
        when 3
          html = "32793-01.html"
        when 4
          html = "32793-09.html"
        when 5
          html = "32793-10.html"
        when 6
          html = "32793-11.html"
        else
          # [automatically added else]
        end

      when SOLINA
        if st.memo_state?(4)
          html = "32794-01.html"
        elsif st.memo_state?(5)
          html = "32794-03.html"
        end
      when ERIS
        if st.memo_state?(4)
          html = "32795-01.html"
        elsif st.memo_state?(5)
          html = "32795-02.html"
        end
      when ANAIS
        if st.memo_state?(4)
          html = "32796-01.html"
        elsif st.memo_state?(5)
          html = "32796-02.html"
        end
      when JUDE_VAN_ETINA
        if st.memo_state?(4)
          html = "32797-01.html"
        elsif st.memo_state?(5)
          html = "32797-02.html"
        end
      when TELEPORT_CONTROL_DEVICE_1
        if st.memo_state > 1
          take_items(pc, -1, {SCROLL_OF_ABSTINENCE, SHIELD_OF_SACRIFICE, SWORD_OF_HOLY_SPIRIT, STAFF_OF_BLESSING})
          html = "32837-01.html"
        elsif st.memo_state?(1)
          html = "32837-03.html"
        end
      when POWERFUL_DEVICE_1
        if st.memo_state?(1)
          html = "32838-01.html"
        end
      when POWERFUL_DEVICE_2
        if st.memo_state?(1)
          html = "32839-01.html"
        end
      when POWERFUL_DEVICE_3
        if st.memo_state?(1)
          html = "32840-01.html"
        end
      when POWERFUL_DEVICE_4
        if st.memo_state?(1)
          html = "32841-01.html"
        end
      when TELEPORT_CONTROL_DEVICE_2
        if st.memo_state > 2
          html = "32842-01.html"
        end
      when TOMB_OF_THE_SAINTESS
        if st.memo_state?(2)
          html = "32843-01.html"
        elsif st.memo_state > 2
          html = "32843-02.html"
        end
      when TELEPORT_CONTROL_DEVICE_3
        if st.memo_state > 2
          html = "32844-01.html"
        end
      when ALTAR_OF_HALLOWS_1
        if st.memo_state?(1)
          html = "32857-01.html"
        end
      when ALTAR_OF_HALLOWS_2
        if st.memo_state?(1)
          html = "32858-01.html"
        end
      when ALTAR_OF_HALLOWS_3
        if st.memo_state?(1)
          html = "32859-01.html"
        end
      when ALTAR_OF_HALLOWS_4
        if st.memo_state?(1)
          html = "32860-01.html"
        end
      when ELCADIA
        memo_state = st.memo_state
        if memo_state < 1
          html = "32787-01.html"
        else
          case memo_state
          when 1
            html = "32787-02.html"
          when 2
            html = "32787-03.html"
          when 3
            html = "32787-04.html"
          when 4
            html = "32787-05.html"
          when 5
            html = "32787-06.html"
          else
            # [automatically added else]
          end

        end
      else
        # [automatically added else]
      end

    end

    html || get_no_quest_msg(pc)
  end
end
