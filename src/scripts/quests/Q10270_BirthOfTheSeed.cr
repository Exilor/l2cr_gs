class Scripts::Q10270_BirthOfTheSeed < Quest
  # NPCs
  private ARTIUS = 32559
  private PLENOS = 32563
  private GINBY = 32566
  private LELRIKIA = 32567
  # Monsters
  private COHEMENES = 25634
  private YEHAN_KLODEKUS = 25665
  private YEHAN_KLANIKUS = 25666
  # Items
  private YEHAN_KLODEKUS_BADGE = 13868
  private YEHAN_KLANIKUS_BADGE = 13869
  private LICH_CRYSTAL = 13870
  # Misc
  private MIN_LEVEL = 75
  # Location
  private INSTANCE_EXIT = Location.new(-185057, 242821, 1576)

  def initialize
    super(10270, self.class.simple_name, "Birth of the Seed")

    add_start_npc(PLENOS)
    add_talk_id(PLENOS, GINBY, LELRIKIA, ARTIUS)
    add_kill_id(COHEMENES, YEHAN_KLODEKUS, YEHAN_KLANIKUS)
    register_quest_items(YEHAN_KLODEKUS_BADGE, YEHAN_KLANIKUS_BADGE, LICH_CRYSTAL)
  end

  def action_for_each_player(pc, npc, is_summon)
    st = get_quest_state(pc, false)
    if st && st.memo_state?(2) && Util.in_range?(1500, npc, pc, false)
      case npc.id
      when YEHAN_KLODEKUS
        unless st.has_quest_items?(YEHAN_KLODEKUS_BADGE)
          st.give_items(YEHAN_KLODEKUS_BADGE, 1)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      when YEHAN_KLANIKUS
        unless st.has_quest_items?(YEHAN_KLANIKUS_BADGE)
          st.give_items(YEHAN_KLANIKUS_BADGE, 1)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      when COHEMENES
        unless st.has_quest_items?(LICH_CRYSTAL)
          st.give_items(LICH_CRYSTAL, 1)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end

    end
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!
    unless st = get_quest_state(pc, false)
      return
    end

    html = nil
    case event
    when "32563-02.htm"
      html = event
    when "32563-03.htm"
      st.start_quest(false)
      st.memo_state = 1
      play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
      html = event
    when "32566-02.html"
      if st.memo_state?(4)
        st1 = pc.get_quest_state(Q10272_LightFragment.simple_name)
        if st1.nil? || (st1.started? && st1.memo_state < 10)
          html = event
        elsif st1.started? && (st1.memo_state >= 10 || st1.completed?)
          html = "32566-03.html"
        end
      end
    when "32566-04.html"
      if st.memo_state?(4)
        if get_quest_items_count(pc, Inventory::ADENA_ID) < 10000
          html = event
        else
          take_items(pc, Inventory::ADENA_ID, 10000)
          st.memo_state = 5
          html = "32566-05.html"
        end
      end
    when "32566-06.html"
      if st.memo_state?(5)
        html = event
      end
    when "32567-02.html", "32567-03.html"
      if st.memo_state?(10)
        html = event
      end
    when "32567-04.html"
      if st.memo_state?(10)
        st.memo_state = 11
        st.set_cond(5, true)
        html = event
      end
    when "32567-05.html"
      if st.memo_state?(11)
        st.memo_state = 20
        pc.instance_id = 0
        pc.tele_to_location(INSTANCE_EXIT, true)
        html = event
      end
    when "32559-02.html"
      if st.memo_state?(1)
        st.memo_state = 2
        st.set_cond(2, true)
        html = event
      end
    when "32559-08.html"
      if st.memo_state?(3)
        st1 = pc.get_quest_state(Q10272_LightFragment.simple_name)
        if st1.nil? || (st1.started? && st1.memo_state < 10)
          st.memo_state = 4
          st.set_cond(4, true)
          html = event
        end
      end
    when "32559-10.html"
      if st.memo_state?(3)
        st1 = pc.get_quest_state(Q10272_LightFragment.simple_name)
        if st1 && ((st1.started? && st1.memo_state >= 10) || st1.completed?)
          st.memo_state = 4
          st.set_cond(4, true)
          html = event
        end
      end
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    execute_for_each_player(killer, npc, is_summon, true, false)
    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.completed?
      if npc.id == PLENOS
        html = "32563-05.html"
      elsif npc.id == ARTIUS
        html = "32559-03.html"
      end
    elsif st.created?
      html = pc.level >= MIN_LEVEL ? "32563-01.htm" : "32563-04.htm"
    elsif st.started?
      case npc.id
      when PLENOS
        if st.memo_state?(1)
          html = "32563-06.html"
        end
      when GINBY
        memo_state = st.memo_state
        if memo_state == 4
          html = "32566-01.html"
        elsif memo_state < 4
          html = "32566-07.html"
        elsif memo_state == 5
          html = "32566-06.html"
        elsif memo_state >= 10 && memo_state < 20
          html = "32566-08.html"
        elsif memo_state == 20
          html = "32566-09.html"
        end
      when LELRIKIA
        memo_state = st.memo_state
        if memo_state == 10
          html = "32567-01.html"
        elsif memo_state == 11
          html = "32567-06.html"
        end
      when ARTIUS
        case st.memo_state
        when 1
          html = "32559-01.html"
        when 2
          if has_quest_items?(pc, YEHAN_KLODEKUS_BADGE, YEHAN_KLANIKUS_BADGE, LICH_CRYSTAL)
            st.memo_state = 3
            st.set_cond(3, true)
            take_items(pc, -1, {YEHAN_KLODEKUS_BADGE, YEHAN_KLANIKUS_BADGE, LICH_CRYSTAL})
            html = "32559-04.html"
          else
            if !has_quest_items?(pc, YEHAN_KLODEKUS_BADGE) && !has_quest_items?(pc, YEHAN_KLANIKUS_BADGE) && !has_quest_items?(pc, LICH_CRYSTAL)
              html = "32559-05.html"
            else
              html = "32559-06.html"
            end
          end
        when 3
          st1 = pc.get_quest_state(Q10272_LightFragment.simple_name)
          if st1.nil? || (st1.started? && st1.memo_state < 10)
            html = "32559-07.html"
          elsif st1.started? && (st1.memo_state >= 10 || st1.completed?)
            html = "32559-09.html"
          end
        when 20
          if pc.level >= MIN_LEVEL
            give_adena(pc, 133590, true)
            add_exp_and_sp(pc, 625343, 48222)
            st.exit_quest(false, true)
            html = "32559-11.html"
          end
        end

      end

    end

    html || get_no_quest_msg(pc)
  end
end
