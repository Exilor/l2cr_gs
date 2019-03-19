class Quests::Q00463_IMustBeaGenius < Quest
  private record DropInfo, count : Int32, special_chance : Int32

  # NPC
  private GUTENHAGEN = 32069
  # Items
  private CORPSE_LOG = 15510
  private COLLECTION = 15511

  # Mobs
  private MOBS = {
    22801 => DropInfo.new(5, 0),
    22802 => DropInfo.new(5, 0),
    22803 => DropInfo.new(5, 0),
    22804 => DropInfo.new(-2, 1),
    22805 => DropInfo.new(-2, 1),
    22806 => DropInfo.new(-2, 1),
    22807 => DropInfo.new(-1, -1),
    22809 => DropInfo.new(2, 2),
    22810 => DropInfo.new(-3, 3),
    22811 => DropInfo.new(3, -1),
    22812 => DropInfo.new(1, -1)
  }

  private REWARD = {
    # exp, sp, html
    {198725, 15892, 8},
    {278216, 22249, 8},
    {317961, 25427, 8},
    {357706, 28606, 9},
    {397451, 31784, 9},
    {596176, 47677, 9},
    {715411, 57212, 10},
    {794901, 63569, 10},
    {914137, 73104, 10},
    {1192352, 95353, 11}
  }

  private MIN_LEVEL = 70

  def initialize
    super(463, self.class.simple_name, "I Must Be a Genius")

    add_start_npc(GUTENHAGEN)
    add_talk_id(GUTENHAGEN)
    add_kill_id(MOBS.keys)
    register_quest_items(COLLECTION, CORPSE_LOG)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "32069-03.htm"
      st.start_quest
      number = rand(51) + 550
      st.set("number", number.to_s)
      st.set("chance", rand(4).to_s)
      html = get_htm(pc, event).sub("%num%", number)
    when "32069-05.htm"
      html = get_htm(pc, event).sub("%num%", st.get("number"))
    when "reward"
      if st.cond?(2)
        rnd = rand(REWARD.size)
        str = REWARD[rnd][2] < 10 ? "0#{REWARD[rnd][2]}" : REWARD[rnd][2].to_s
        st.add_exp_and_sp(REWARD[rnd][0], REWARD[rnd][1])
        st.exit_quest(QuestType::DAILY, true)
        html = "32069-#{str}.html"
      end
    when "32069-02.htm"
      # do nothing
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless st = get_quest_state(pc, false)
      return super
    end

    if st.cond?(1)
      msg = false
      number = MOBS[npc.id].count

      if MOBS[npc.id].special_chance == st.get_int("chance")
        number = rand(100) + 1
      end

      if number > 0
        st.give_items(CORPSE_LOG, number)
        msg = true
      elsif number < 0 && st.get_quest_items_count(CORPSE_LOG + number) > 0
        st.take_items(CORPSE_LOG, number.abs)
        msg = true
      end

      if msg
        ns = NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::ATT_ATTACK_S1_RO_ROGUE_S2)
        ns.add_string_parameter(pc.name)
        ns.add_string_parameter(number.to_s)
        npc.broadcast_packet(ns)

        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        if st.get_quest_items_count(CORPSE_LOG) == st.get_int("number")
          st.take_items(CORPSE_LOG, -1)
          st.give_items(COLLECTION, 1)
          st.set_cond(2, true)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case st.state
    when State::COMPLETED
      unless st.now_available?
        html = "32069-07.htm"
      end
      st.state = State::CREATED
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "32069-01.htm" : "32069-00.htm"
    when State::STARTED
      if st.cond?(1)
        html = "32069-04.html"
      else
        if st.get_int("var") == 1
          html = "32069-06a.html"
        else
          st.take_items(COLLECTION, -1)
          st.set("var", "1")
          html = "32069-06.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
