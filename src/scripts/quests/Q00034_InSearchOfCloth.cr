class Scripts::Q00034_InSearchOfCloth < Quest
  # NPCs
  private RADIA = 30088
  private RALFORD = 30165
  private VARAN = 30294
  # Monsters
  private MOBS = {
    20560, # Trisalim Spider
    20561  # Trisalim Tarantula
  }
  # Items
  private SUEDE = 1866
  private THREAD = 1868
  private MYSTERIOUS_CLOTH = 7076
  private SKEIN_OF_YARN = 7161
  private SPINNERET = 7528
  # Misc
  private MIN_LEVEL = 60
  private SPINNERET_COUNT = 10
  private SUEDE_COUNT = 3000
  private THREAD_COUNT = 5000

  def initialize
    super(34, self.class.simple_name, "In Search of Cloth")

    add_start_npc(RADIA)
    add_talk_id(RADIA, RALFORD, VARAN)
    add_kill_id(MOBS)
    register_quest_items(SKEIN_OF_YARN, SPINNERET)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "30088-03.htm"
      st.start_quest
    when "30294-02.html"
      st.set_cond(2, true)
    when "30088-06.html"
      st.set_cond(3, true)
    when "30165-02.html"
      st.set_cond(4, true)
    when "30165-05.html"
      if st.get_quest_items_count(SPINNERET) < SPINNERET_COUNT
        return get_no_quest_msg(pc)
      end
      st.take_items(SPINNERET, SPINNERET_COUNT)
      st.give_items(SKEIN_OF_YARN, 1)
      st.set_cond(6, true)
    when "30088-10.html"
      if st.get_quest_items_count(SUEDE) >= SUEDE_COUNT && st.get_quest_items_count(THREAD) >= THREAD_COUNT && st.has_quest_items?(SKEIN_OF_YARN)
        st.take_items(SKEIN_OF_YARN, 1)
        st.take_items(SUEDE, SUEDE_COUNT)
        st.take_items(THREAD, THREAD_COUNT)
        st.give_items(MYSTERIOUS_CLOTH, 1)
        st.exit_quest(false, true)
      else
        html = "30088-11.html"
      end
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    member = get_random_party_member(pc, 4)
    if member && Rnd.bool
      st = get_quest_state(member, false).not_nil!
      st.give_items(SPINNERET, 1)
      if st.get_quest_items_count(SPINNERET) >= SPINNERET_COUNT
        st.set_cond(5, true)
      else
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when RADIA
      case st.state
      when State::CREATED
        html = pc.level >= MIN_LEVEL ? "30088-01.htm" : "30088-02.html"
      when State::STARTED
        case st.cond
        when 1
          html = "30088-04.html"
        when 2
          html = "30088-05.html"
        when 3
          html = "30088-07.html"
        when 6
          if st.get_quest_items_count(SUEDE) >= SUEDE_COUNT && st.get_quest_items_count(THREAD) >= THREAD_COUNT
            html = "30088-08.html"
          else
            html = "30088-09.html"
          end
        else
          # [automatically added else]
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # [automatically added else]
      end
    when VARAN
      if st.started?
        case st.cond
        when 1
          html = "30294-01.html"
        when 2
          html = "30294-03.html"
        else
          # [automatically added else]
        end
      end
    when RALFORD
      if st.started?
        case st.cond
        when 3
          html = "30165-01.html"
        when 4
          html = "30165-03.html"
        when 5
          html = "30165-04.html"
        when 6
          html = "30165-06.html"
        else
          # [automatically added else]
        end
      end
    else
      # [automatically added else]
    end

    html || get_no_quest_msg(pc)
  end
end
