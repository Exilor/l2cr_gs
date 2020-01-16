class Scripts::Q00242_PossessorOfAPreciousSoul2 < Quest
  # NPCs
  private VIRGIL = 31742
  private KASSANDRA = 31743
  private OGMAR = 31744
  private FALLEN_UNICORN = 31746
  private PURE_UNICORN = 31747
  private CORNERSTONE = 31748
  private MYSTERIOUS_KNIGHT = 31751
  private ANGEL_CORPSE = 31752
  private KALIS = 30759
  private MATILD = 30738
  private RESTRAINER_OF_GLORY = 27317
  # Items
  private VIRGILS_LETTER = 7677
  private GOLDEN_HAIR = 7590
  private ORB_OF_BINDING = 7595
  private SORCERY_INGREDIENT = 7596
  private CARADINE_LETTER = 7678
  # Rewards
  private CHANCE_FOR_HAIR = 20
  # Skill
  private QUEST_COMMUNE_TO_SLATE = SkillHolder.new(4546)

  def initialize
    super(242, self.class.simple_name, "Possessor Of A Precious Soul 2")

    add_start_npc(VIRGIL)
    add_talk_id(
      VIRGIL, KASSANDRA, OGMAR, MYSTERIOUS_KNIGHT, ANGEL_CORPSE, KALIS, MATILD,
      FALLEN_UNICORN, CORNERSTONE, PURE_UNICORN
    )
    add_kill_id(RESTRAINER_OF_GLORY)
    register_quest_items(GOLDEN_HAIR, ORB_OF_BINDING, SORCERY_INGREDIENT)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end
    unless pc.subclass_active?
      return "no_sub.html"
    end

    npc = npc.not_nil!

    case event
    when "31742-02.html"
      st.start_quest
      st.take_items(VIRGILS_LETTER, -1)
    when "31743-05.html"
      if st.cond?(1)
        st.set_cond(2, true)
      end
    when "31744-02.html"
      if st.cond?(2)
        st.set_cond(3, true)
      end
    when "31751-02.html"
      if st.cond?(3)
        st.set_cond(4, true)
      end
    when "30759-02.html"
      if st.cond?(6)
        st.set_cond(7, true)
      end
    when "30738-02.html"
      if st.cond?(7)
        st.set_cond(8, true)
        st.give_items(SORCERY_INGREDIENT, 1)
      end
    when "30759-05.html"
      if st.cond?(8)
        st.take_items(GOLDEN_HAIR, -1)
        st.take_items(SORCERY_INGREDIENT, -1)
        st.set("awaitsDrops", "1")
        st.set_cond(9, true)
        st.set("cornerstones", "0")
      end
    when "PURE_UNICORN"
      npc.spawn.stop_respawn
      npc.delete_me
      npc_pure = st.add_spawn(PURE_UNICORN, 85884, -76588, -3470, 30000)
      start_quest_timer("FALLEN_UNICORN", 30000, npc_pure, pc)
      return
    when "FALLEN_UNICORN"
      npc_fallen = st.add_spawn(FALLEN_UNICORN, 85884, -76588, -3470, 0)
      npc_fallen.spawn.start_respawn
      return
    end

    event
  end

  def on_kill(npc, pc, is_summon)
    unless m = get_random_party_member(pc, "awaitsDrops", "1")
      return super
    end

    st = get_quest_state(m, false).not_nil!
    if st.cond?(9) && st.get_quest_items_count(ORB_OF_BINDING) < 4
      st.give_items(ORB_OF_BINDING, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end
    if st.get_quest_items_count(ORB_OF_BINDING) >= 4
      st.unset("awaitsDrops")
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    if st.started? && !pc.subclass_active?
      return "no_sub.html"
    end

    case npc.id
    when VIRGIL
      case st.state
      when State::CREATED
        if pc.quest_completed?(Q00241_PossessorOfAPreciousSoul1.simple_name)
          if pc.subclass_active? && pc.level >= 60
            html = "31742-01.htm"
          else
            html = "31742-00.htm"
          end
        end
      when State::STARTED
        case st.cond
        when 1
          html = "31742-03.html"
        when 11
          html = "31742-04.html"
          st.give_items(CARADINE_LETTER, 1)
          st.add_exp_and_sp(455764, 0)
          st.exit_quest(false, true)
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    when KASSANDRA
      case st.cond
      when 1
        html = "31743-01.html"
      when 2
        html = "31743-06.html"
      when 11
        html = "31743-07.html"
      end
    when OGMAR
      case st.cond
      when 2
        html = "31744-01.html"
      when 3
        html = "31744-03.html"
      end
    when MYSTERIOUS_KNIGHT
      case st.cond
      when 3
        html = "31751-01.html"
      when 4
        html = "31751-03.html"
      when 5
        if st.has_quest_items?(GOLDEN_HAIR)
          st.set_cond(6, true)
          html = "31751-04.html"
        end
      when 6
        html = "31751-05.html"
      end
    when ANGEL_CORPSE
      case st.cond
      when 4
        npc.do_die(npc)
        if CHANCE_FOR_HAIR >= Rnd.rand(100)
          st.give_items(GOLDEN_HAIR, 1)
          st.set_cond(5, true)
          html = "31752-01.html"
        else
          html = "31752-02.html"
        end
      when 5
        html = "31752-02.html"
      end
    when KALIS
      case st.cond
      when 6
        html = "30759-01.html"
      when 7
        html = "30759-03.html"
      when 8
        if st.has_quest_items?(SORCERY_INGREDIENT)
          html = "30759-04.html"
        end
      when 9
        html = "30759-06.html"
      end
    when MATILD
      case st.cond
      when 7
        html = "30738-01.html"
      when 8
        html = "30738-03.html"
      end
    when CORNERSTONE
      if st.cond?(9)
        if st.has_quest_items?(ORB_OF_BINDING)
          html = "31748-02.html"
          st.take_items(ORB_OF_BINDING, 1)
          npc.do_die(npc)

          st.set("cornerstones", (st.get_int("cornerstones") + 1).to_s)
          if st.get_int("cornerstones") == 4
            st.set_cond(10)
          end
          st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          npc.target = pc
          npc.do_cast(QUEST_COMMUNE_TO_SLATE)
        else
          html = "31748-01.html"
        end
      end
    when FALLEN_UNICORN
      case st.cond
      when 9
        html = "31746-01.html"
      when 10
        html = "31746-02.html"
        start_quest_timer("PURE_UNICORN", 3000, npc, pc)
      end
    when PURE_UNICORN
      case st.cond
      when 10
        st.set_cond(11, true)
        html = "31747-01.html"
      when 11
        html = "31747-02.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
