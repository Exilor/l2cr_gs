class Scripts::Q00270_TheOneWhoEndsSilence < Quest
  # NPC
  private FAKE_GREYMORE = 32757
  # Monsters
  private SEEKER_SOLINA = 22790
  private SAVIOR_SOLINA = 22791
  private ASCETIC_SOLINA = 22793
  private DIVINITY_JUDGE = 22794
  private DIVINITY_MANAGER = 22795
  private DIVINITY_SUPERVISOR = 22796
  private DIVINITY_WORSHIPPER = 22797
  private DIVINITY_PROTECTOR = 22798
  private DIVINITY_FIGHTER = 22799
  private DIVINITY_MAGUS = 22800
  # Items
  private TATTERED_MONK_CLOTHES = 15526
  # Misc
  private MIN_LEVEL = 82

  def initialize
    super(270, self.class.simple_name, "The One Who Ends Silence")

    add_start_npc(FAKE_GREYMORE)
    add_talk_id(FAKE_GREYMORE)
    add_kill_id(
      SEEKER_SOLINA, SAVIOR_SOLINA, ASCETIC_SOLINA, DIVINITY_JUDGE,
      DIVINITY_MANAGER, DIVINITY_SUPERVISOR, DIVINITY_WORSHIPPER,
      DIVINITY_PROTECTOR, DIVINITY_FIGHTER, DIVINITY_MAGUS
    )
    register_quest_items(TATTERED_MONK_CLOTHES)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    rags_count = st.get_quest_items_count(TATTERED_MONK_CLOTHES)
    case event
    when "32757-02.htm"
      qs = pc.get_quest_state(Q10288_SecretMission.simple_name)
      if pc.level >= MIN_LEVEL && qs && qs.completed?
        html = event
      end
    when "32757-04.html"
      qs = pc.get_quest_state(Q10288_SecretMission.simple_name)
      if pc.level >= MIN_LEVEL && qs && qs.completed?
        st.start_quest
        html = event
      end
    when "32757-08.html"
      if st.cond?(1)
        if rags_count == 0
          html = "32757-06.html"
        elsif rags_count < 100
          html = "32757-07.html"
        else
          html = event
        end
      end
    when "rags100"
      if rags_count >= 100
        if Rnd.rand(10) < 5
          if Rnd.rand(1000) < 438
            st.give_items(10373 + Rnd.rand(9), 1)
          else
            st.give_items(10397 + Rnd.rand(9), 1)
          end
        else
          reward_scroll(st, 1)
        end

        st.take_items(TATTERED_MONK_CLOTHES, 100)
        st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        html = "32757-09.html"
      else
        html = "32757-10.html"
      end
    when "rags200"
      if rags_count >= 200
        if Rnd.rand(1000) < 549
          st.give_items(10373 + Rnd.rand(9), 1)
        else
          st.give_items(10397 + Rnd.rand(9), 1)
        end
        reward_scroll(st, 2)

        st.take_items(TATTERED_MONK_CLOTHES, 200)
        st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        html = "32757-09.html"
      else
        html = "32757-10.html"
      end
    when "rags300"
      if rags_count >= 300
        st.give_items(10373 + Rnd.rand(9), 1)
        st.give_items(10397 + Rnd.rand(9), 1)
        reward_scroll(st, 3)

        st.take_items(TATTERED_MONK_CLOTHES, 300)
        st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        html = "32757-09.html"
      else
        html = "32757-10.html"
      end
    when "rags400"
      if rags_count >= 400
        st.give_items(10373 + Rnd.rand(9), 1)
        st.give_items(10397 + Rnd.rand(9), 1)
        reward_scroll(st, 3)

        if Rnd.rand(10) < 5
          if Rnd.rand(1000) < 438
            st.give_items(10373 + Rnd.rand(9), 1)
          else
            st.give_items(10397 + Rnd.rand(9), 1)
          end
        else
          reward_scroll(st, 1)
        end

        st.take_items(TATTERED_MONK_CLOTHES, 400)
        st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        html = "32757-09.html"
      else
        html = "32757-10.html"
      end
    when "rags500"
      if rags_count >= 500
        st.give_items(10373 + Rnd.rand(9), 1)
        st.give_items(10397 + Rnd.rand(9), 1)
        reward_scroll(st, 3)

        if Rnd.rand(1000) < 549
          st.give_items(10373 + Rnd.rand(9), 1)
        else
          st.give_items(10397 + Rnd.rand(9), 1)
        end

        reward_scroll(st, 2)
        st.take_items(TATTERED_MONK_CLOTHES, 500)
        st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        html = "32757-09.html"
      else
        html = "32757-10.html"
      end
    when "exit1"
      if st.cond?(1)
        if rags_count >= 1
          html = "32757-12.html"
        else
          st.exit_quest(true, true)
          html = "32757-13.html"
        end
      end
    when "exit2"
      if st.cond?(1)
        st.exit_quest(true, true)
        html = "32757-13.html"
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    case npc.id
    when SEEKER_SOLINA
      give_item(get_random_party_member(killer, 1), npc, 57, false)
    when SAVIOR_SOLINA
      give_item(get_random_party_member(killer, 1), npc, 55, false)
    when ASCETIC_SOLINA
      give_item(get_random_party_member(killer, 1), npc, 59, false)
    when DIVINITY_JUDGE
      give_item(get_random_party_member(killer, 1), npc, 698, false)
    when DIVINITY_MANAGER
      give_item(get_random_party_member(killer, 1), npc, 735, false)
    when DIVINITY_SUPERVISOR
      give_item(get_random_party_member(killer, 1), npc, 903, false)
    when DIVINITY_WORSHIPPER
      give_item(get_random_party_member(killer, 1), npc, 811, false)
    when DIVINITY_PROTECTOR
      give_item(get_random_party_member(killer, 1), npc, 884, true)
    when DIVINITY_FIGHTER
      give_item(get_random_party_member(killer, 1), npc, 893, true)
    when DIVINITY_MAGUS
      give_item(get_random_party_member(killer, 1), npc, 953, true)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case st.state
    when State::CREATED
      if pc.level >= MIN_LEVEL && pc.quest_completed?(Q10288_SecretMission.simple_name)
        html = "32757-01.htm"
      else
        html = "32757-03.html"
      end
    when State::STARTED
      if st.cond?(1)
        html = "32757-05.html"
      end
    end

    html || get_no_quest_msg(pc)
  end

  private def reward_scroll(qs, type)
    scroll_id = 5593
    case type
    when 1
      chance = Rnd.rand(100)
      if chance < 1
        scroll_id = 5593
      elsif chance < 28
        scroll_id = 5594
      elsif chance < 61
        scroll_id = 5595
      else
        scroll_id = 9898
      end
    when 2
      chance = Rnd.rand(100)
      if chance < 20
        scroll_id = 5593
      elsif chance < 40
        scroll_id = 5594
      elsif chance < 70
        scroll_id = 5595
      else
        scroll_id = 9898
      end
    when 3
      chance = Rnd.rand(1000)
      if chance < 242
        scroll_id = 5593
      elsif chance < 486
        scroll_id = 5594
      elsif chance < 742
        scroll_id = 5595
      else
        scroll_id = 9898
      end
    end

    qs.give_items(scroll_id, 1)
  end

  private def give_item(pc, npc, chance, at_least_one)
    if pc && Util.in_range?(1500, npc, pc, false)
      count = (Rnd.rand(1000) < chance ? 1 : 0) + (at_least_one ? 1 : 0)
      if count > 0
        qs = pc.get_quest_state(Q00270_TheOneWhoEndsSilence.simple_name).not_nil!
        qs.give_items(TATTERED_MONK_CLOTHES, count)
        qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end
  end
end
