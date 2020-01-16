class Scripts::Q10292_SevenSignsGirlOfDoubt < Quest
  # NPCs
  private HARDIN = 30832
  private WOOD = 32593
  private FRANZ = 32597
  private ELCADIA = 32784
  # Item
  private ELCADIAS_MARK = ItemHolder.new(17226, 10)
  # Misc
  private MIN_LEVEL = 81
  # Variables
  private I_QUEST1 = "I_QUEST1"
  # Monster
  private CREATURE_OF_THE_DUSK1 = 27422
  private CREATURE_OF_THE_DUSK2 = 27424
  private MOBS = {
    22801, # Cruel Pincer Golem
    22802, # Cruel Pincer Golem
    22803, # Cruel Pincer Golem
    22804, # Horrifying Jackhammer Golem
    22805, # Horrifying Jackhammer Golem
    22806  # Horrifying Jackhammer Golem
  }

  def initialize
    super(10292, self.class.simple_name, "Seven Signs, Girl of Doubt")

    add_start_npc(WOOD)
    add_spawn_id(ELCADIA)
    add_talk_id(WOOD, FRANZ, ELCADIA, HARDIN)
    add_kill_id(MOBS)
    add_kill_id(CREATURE_OF_THE_DUSK1, CREATURE_OF_THE_DUSK2)
    register_quest_items(ELCADIAS_MARK.id)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "32593-02.htm", "32593-04.htm", "32597-02.html", "32597-04.html"
      html = event
    when "32593-03.htm"
      st.start_quest
      st.memo_state = 1
      html = event
    when "32597-03.html"
      st.memo_state = 2
      st.set_cond(2, true)
      html = event
    when "32784-02.html"
      if st.memo_state?(2)
        html = event
      end
    when "32784-03.html"
      if st.memo_state?(2)
        st.memo_state = 3
        st.set_cond(3, true)
        html = event
      end
    when "32784-05.html"
      if st.memo_state?(4)
        html = event
      end
    when "32784-06.html"
      if st.memo_state?(4)
        st.memo_state = 5
        st.set_cond(5, true)
        html = event
      end
    when "SPAWN"
      npc = npc.not_nil!
      if !npc.variables.get_bool(I_QUEST1, false)
        npc.variables[I_QUEST1] = true
        add_spawn(CREATURE_OF_THE_DUSK1, 89440, -238016, -9632, Rnd.rand(360), false, 0, false, pc.instance_id)
        add_spawn(CREATURE_OF_THE_DUSK2, 89524, -238131, -9632, Rnd.rand(360), false, 0, false, pc.instance_id)
      else
        html = "32784-07.html"
      end
    when "32784-11.html", "32784-12.html"
      if st.memo_state?(6)
        html = event
      end
    when "32784-13.html"
      if st.memo_state?(6)
        st.memo_state = 7
        st.set_cond(7, true)
        html = event
      end
    when "30832-02.html"
      if st.memo_state?(7)
        st.memo_state = 8
        st.set_cond(8, true)
        html = event
      end
    when "30832-03.html"
      if st.memo_state?(8)
        html = event
      end
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    if st = get_random_party_member_state(pc, -1, 3, npc)
      if MOBS.includes?(npc.id)
        if give_item_randomly(st.player, npc, ELCADIAS_MARK.id, 1, ELCADIAS_MARK.count, 0.7, true) && st.memo_state?(3)
          st.set_cond(4, true)
        end
      else
        kill_count = st.get_int("kill_count")
        if kill_count < 0
          kill_count = 1
        else
          kill_count += 1
        end
        st.set("kill_count", kill_count.to_s)
        if kill_count == 2
          st.memo_state = 6
          st.set_cond(6)
        end
      end
    end

    super
  end

  def on_spawn(npc)
    npc.variables[I_QUEST1] = false
    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.completed?
      if npc.id == WOOD
        html = "32593-05.html"
      end
    elsif st.created?
      if pc.level >= MIN_LEVEL && pc.quest_completed?(Q00198_SevenSignsEmbryo.simple_name)
        html = "32593-01.htm"
      else
        html = "32593-06.htm"
      end
    elsif st.started?
      case npc.id
      when WOOD
        if st.memo_state > 0 && st.memo_state < 9
          html = "32593-07.html"
        end
      when FRANZ
        memo_state = st.memo_state
        if memo_state == 1
          html = "32597-01.html"
        elsif memo_state >= 2 && memo_state < 7
          html = "32597-05.html"
        elsif memo_state == 7
          html = "32597-06.html"
        end
      when ELCADIA
        case st.memo_state
        when 2
          html = "32784-01.html"
        when 3
          if !has_item?(pc, ELCADIAS_MARK)
            html = "32784-03.html"
          else
            take_item(pc, ELCADIAS_MARK)
            st.memo_state = 4
            st.set_cond(4, true)
            html = "32784-04.html"
          end
        when 4
          html = "32784-08.html"
        when 5
          html = "32784-09.html"
        when 6
          html = "32784-10.html"
        when 7
          html = "32784-14.html"
        when 8
          if pc.subclass_active?
            html = "32784-15.html"
          else
            add_exp_and_sp(pc, 10000000, 1000000)
            st.exit_quest(false, true)
            html = "32784-16.html"
          end
        end
      when HARDIN
        if st.memo_state?(7)
          html = "30832-01.html"
        elsif st.memo_state?(8)
          html = "30832-03.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
