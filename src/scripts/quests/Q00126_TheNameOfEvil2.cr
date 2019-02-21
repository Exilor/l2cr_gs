class Quests::Q00126_TheNameOfEvil2 < Quest
  # NPCs
  private SHILENS_STONE_STATUE = 32109
  private MUSHIKA = 32114
  private ASAMAH = 32115
  private ULU_KAIMU = 32119
  private BALU_KAIMU = 32120
  private CHUTA_KAIMU = 32121
  private WARRIORS_GRAVE = 32122
  # Items
  private GAZKH_FRAGMENT = 8782
  private BONE_POWDER = 8783
  # Reward
  private ENCHANT_WEAPON_A = 729

  def initialize
    super(126, self.class.simple_name, "The Name of Evil - 2")

    add_start_npc(ASAMAH)
    add_talk_id(
      ASAMAH, ULU_KAIMU, BALU_KAIMU, CHUTA_KAIMU, WARRIORS_GRAVE,
      SHILENS_STONE_STATUE, MUSHIKA
    )
    register_quest_items(GAZKH_FRAGMENT, BONE_POWDER)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return get_no_quest_msg(player)
    end

    case event
    when "32115-1.html"
      st.start_quest
    when "32115-1b.html"
      if st.cond?(1)
        st.set_cond(2, true)
      end
    when "32119-3.html"
      if st.cond?(2)
        st.set_cond(3, true)
      end
    when "32119-4.html"
      if st.cond?(3)
        st.set_cond(4, true)
      end
    when "32119-4a.html", "32119-5b.html"
      st.play_sound(Sound::ETCSOUND_ELROKI_SONG_1ST)
    when "32119-5.html"
      if st.cond?(4)
        st.set_cond(5, true)
      end
    when "32120-3.html"
      if st.cond?(5)
        st.set_cond(6, true)
      end
    when "32120-4.html"
      if st.cond?(6)
        st.set_cond(7, true)
      end
    when "32120-4a.html", "32120-5b.html"
      st.play_sound(Sound::ETCSOUND_ELROKI_SONG_2ND)
    when "32120-5.html"
      if st.cond?(7)
        st.set_cond(8, true)
      end
    when "32121-3.html"
      if st.cond?(8)
        st.set_cond(9, true)
      end
    when "32121-4.html"
      if st.cond?(9)
        st.set_cond(10, true)
      end
    when "32121-4a.html", "32121-5b.html"
      st.play_sound(Sound::ETCSOUND_ELROKI_SONG_3RD)
    when "32121-5.html"
      if st.cond?(10)
        st.give_items(GAZKH_FRAGMENT, 1)
        st.set_cond(11, true)
      end
    when "32122-2a.html"
      npc = npc.not_nil!
      npc.broadcast_packet(MagicSkillUse.new(npc, player, 5089, 1, 1000, 0))
    when "32122-2d.html"
      st.take_items(GAZKH_FRAGMENT, -1)
    when "32122-3.html"
      if st.cond?(12)
        st.set_cond(13, true)
      end
    when "32122-4.html"
      if st.cond?(13)
        st.set_cond(14, true)
      end
    when "DO_One"
      st.set("DO", "1")
      event = "32122-4d.html"
    when "MI_One"
      st.set("MI", "1")
      event = "32122-4f.html"
    when "FA_One"
      st.set("FA", "1")
      event = "32122-4h.html"
    when "SOL_One"
      st.set("SOL", "1")
      event = "32122-4j.html"
    when "FA2_One"
      st.set("FA2", "1")
      if st.cond?(14) && st.get_int("DO") > 0 && st.get_int("MI") > 0 && st.get_int("FA") > 0 && st.get_int("SOL") > 0 && st.get_int("FA2") > 0
        event = "32122-4n.html"
        st.set_cond(15, true)
      else
        event = "32122-4m.html"
      end
      st.unset("DO")
      st.unset("MI")
      st.unset("FA")
      st.unset("SOL")
      st.unset("FA2")
    when "32122-4m.html"
      st.unset("DO")
      st.unset("MI")
      st.unset("FA")
      st.unset("SOL")
      st.unset("FA2")
    when "FA_Two"
      st.set("FA", "1")
      event = "32122-5a.html"
    when "SOL_Two"
      st.set("SOL", "1")
      event = "32122-5c.html"
    when "TI_Two"
      st.set("TI", "1")
      event = "32122-5e.html"
    when "SOL2_Two"
      st.set("SOL2", "1")
      event = "32122-5g.html"
    when "FA2_Two"
      st.set("FA2", "1")
      if st.cond?(15) && st.get_int("FA") > 0 && st.get_int("SOL") > 0 && st.get_int("TI") > 0 && st.get_int("SOL2") > 0 && st.get_int("FA2") > 0
        event = "32122-5j.html"
        st.set_cond(16, true)
      else
        event = "32122-5i.html"
      end
      st.unset("FA")
      st.unset("SOL")
      st.unset("TI")
      st.unset("SOL2")
      st.unset("FA2")
    when "32122-5i.html"
      st.unset("FA")
      st.unset("SOL")
      st.unset("TI")
      st.unset("SOL2")
      st.unset("FA2")
    when "SOL_Three"
      st.set("SOL", "1")
      event = "32122-6a.html"
    when "FA_Three"
      st.set("FA", "1")
      event = "32122-6c.html"
    when "MI_Three"
      st.set("MI", "1")
      event = "32122-6e.html"
    when "FA2_Three"
      st.set("FA2", "1")
      event = "32122-6g.html"
    when "MI2_Three"
      st.set("MI2", "1")
      if st.cond?(16) && st.get_int("SOL") > 0 && st.get_int("FA") > 0 && st.get_int("MI") > 0 && st.get_int("FA2") > 0 && st.get_int("MI2") > 0
        event = "32122-6j.html"
        st.set_cond(17, true)
      else
        event = "32122-6i.html"
      end
      st.unset("SOL")
      st.unset("FA")
      st.unset("MI")
      st.unset("FA2")
      st.unset("MI2")
    when "32122-6i.html"
      st.unset("SOL")
      st.unset("FA")
      st.unset("MI")
      st.unset("FA2")
      st.unset("MI2")
    when "32122-7.html"
      npc = npc.not_nil!
      st.give_items(BONE_POWDER, 1)
      st.play_sound(Sound::ETCSOUND_ELROKI_SONG_FULL)
      npc.broadcast_packet(MagicSkillUse.new(npc, player, 5089, 1, 1000, 0))
    when "32122-8.html"
      if st.cond?(17)
        st.set_cond(18, true)
      end
    when "32109-2.html"
      if st.cond?(18)
        st.set_cond(19, true)
      end
    when "32109-3.html"
      if st.cond?(19)
        st.take_items(BONE_POWDER, -1)
        st.set_cond(20, true)
      end
    when "32115-4.html"
      if st.cond?(20)
        st.set_cond(21, true)
      end
    when "32115-5.html"
      if st.cond?(21)
        st.set_cond(22, true)
      end
    when "32114-2.html"
      if st.cond?(22)
        st.set_cond(23, true)
      end
    when "32114-3.html"
      st.reward_items(ENCHANT_WEAPON_A, 1)
      st.give_adena(460483, true)
      st.add_exp_and_sp(1015973, 102802)
      st.exit_quest(false, true)
    end

    event
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    case npc.id
    when ASAMAH
      case st.state
      when State::CREATED
        if player.level < 77
          htmltext = "32115-0.htm"
        else
          if player.quest_completed?(Q00125_TheNameOfEvil1.simple_name)
            htmltext = "32115-0a.htm"
          else
            htmltext = "32115-0b.htm"
          end
        end
      when State::STARTED
        case st.cond
        when 1
          htmltext = "32115-1d.html"
        when 2
          htmltext = "32115-1c.html"
        when 3..19
          htmltext = "32115-2.html"
        when 20
          htmltext = "32115-3.html"
        when 21
          htmltext = "32115-4j.html"
        when 22
          htmltext = "32115-5a.html"
        end
      when State::COMPLETED
        htmltext = get_already_completed_msg(player)
      end
    when ULU_KAIMU
      if st.started?
        case st.cond
        when 1
          htmltext = "32119-1.html"
        when 2
          htmltext = "32119-2.html"
          npc.broadcast_packet(MagicSkillUse.new(npc, player, 5089, 1, 1000, 0))
        when 3
          htmltext = "32119-3c.html"
        when 4
          htmltext = "32119-4c.html"
        when 5
          htmltext = "32119-5a.html"
        end
      end
    when BALU_KAIMU
      if st.started?
        case st.cond
        when 1..4
          htmltext = "32120-1.html"
        when 5
          htmltext = "32120-2.html"
          npc.broadcast_packet(MagicSkillUse.new(npc, player, 5089, 1, 1000, 0))
        when 6
          htmltext = "32120-3c.html"
        when 7
          htmltext = "32120-4c.html"
        else
          htmltext = "32120-5a.html"
        end
      end
    when CHUTA_KAIMU
      if st.started?
        case st.cond
        when 1..7
          htmltext = "32121-1.html"
        when 8
          htmltext = "32121-2.html"
          npc.broadcast_packet(MagicSkillUse.new(npc, player, 5089, 1, 1000, 0))
        when 9
          htmltext = "32121-3e.html"
        when 10
          htmltext = "32121-4e.html"
        else
          htmltext = "32121-5a.html"
        end
      end
    when WARRIORS_GRAVE
      if st.started?
        case st.cond
        when 1..10
          htmltext = "32122-1.html"
        when 11
          htmltext = "32122-2.html"
          st.set_cond(12, true)
        when 12
          htmltext = "32122-2l.html"
        when 13
          htmltext = "32122-3b.html"
        when 14
          htmltext = "32122-4.html"
          st.unset("DO")
          st.unset("MI")
          st.unset("FA")
          st.unset("SOL")
          st.unset("FA2")
        when 15
          htmltext = "32122-5.html"
          st.unset("FA")
          st.unset("SOL")
          st.unset("TI")
          st.unset("SOL2")
          st.unset("FA2")
        when 16
          htmltext = "32122-6.html"
          st.unset("SOL")
          st.unset("FA")
          st.unset("MI")
          st.unset("FA2")
          st.unset("MI2")
        when 17
          htmltext = st.has_quest_items?(BONE_POWDER) ? "32122-7.html" : "32122-7b.html"
        when 18
          htmltext = "32122-8.html"
        else
          htmltext = "32122-9.html"
        end
      end
    when SHILENS_STONE_STATUE
      if st.started?
        case st.cond
        when 1..17
          htmltext = "32109-1a.html"
        when 18
          if st.has_quest_items?(BONE_POWDER)
            htmltext = "32109-1.html"
          end
        when 19
          htmltext = "32109-2l.html"
        when 20
          htmltext = "32109-5.html"
        else
          htmltext = "32109-4.html"
        end
      end
    when MUSHIKA
      if st.started?
        if st.cond < 22
          htmltext = "32114-4.html"
        elsif st.cond?(22)
          htmltext = "32114-1.html"
        else
          htmltext = "32114-2.html"
        end
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
