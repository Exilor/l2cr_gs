class Scripts::Q00021_HiddenTruth < Quest
  # NPCs
  private INNOCENTIN = 31328
  private AGRIPEL = 31348
  private BENEDICT = 31349
  private DOMINIC = 31350
  private MYSTERIOUS_WIZARD = 31522
  private TOMBSTONE = 31523
  private GHOST_OF_VON_HELLMAN = 31524
  private GHOST_OF_VON_HELLMANS_PAGE = 31525
  private BROKEN_BOOKSHELF = 31526
  # Location
  private GHOST_LOC = Location.new(51432, -54570, -3136, 0)
  private PAGE_LOC = Location.new(51446, -54514, -3136, 0)
  # Items
  private CROSS_OF_EINHASAD = 7140
  private CROSS_OF_EINHASAD2 = 7141
  # Misc
  private MIN_LVL = 63
  private PAGE_ROUTE_NAME = "rune_ghost1b"

  @page_count = 0
  @ghost_spawned = false
  @page_spawned = false
  @move_ended = false

  def initialize
    super(21, self.class.simple_name, "Hidden Truth")

    add_start_npc(MYSTERIOUS_WIZARD)
    add_talk_id(
      MYSTERIOUS_WIZARD, TOMBSTONE, GHOST_OF_VON_HELLMAN,
      GHOST_OF_VON_HELLMANS_PAGE, BROKEN_BOOKSHELF, AGRIPEL, BENEDICT, DOMINIC,
      INNOCENTIN
    )
    add_see_creature_id(GHOST_OF_VON_HELLMANS_PAGE)
    add_route_finished_id(GHOST_OF_VON_HELLMANS_PAGE)
    register_quest_items(CROSS_OF_EINHASAD)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless st = get_quest_state(player, false)
    html = nil

    case event
    when "31328-02.html", "31328-03.html", "31328-04.html", "31522-01.htm",
         "31522-04.html", "31523-02.html", "31524-02.html", "31524-03.html",
         "31524-04.html", "31524-05.html", "31526-01.html", "31526-02.html",
         "31526-04.html", "31526-05.html", "31526-06.html", "31526-12.html",
         "31526-13.html"
      html = event
    when "31328-05.html"
      if st.cond?(7)
        st.give_items(CROSS_OF_EINHASAD2, 1)
        st.add_exp_and_sp(131228, 11978)
        st.exit_quest(false, true)
        html = event
      end
    when "31522-02.htm"
      if player.level < MIN_LVL
        html = "31522-03.htm"
      else
        st.start_quest
        html = event
      end
    when "31523-03.html"
      if @ghost_spawned
        html = "31523-04.html"
        st.play_sound(Sound::SKILLSOUND_HORROR_2)
      else
        ghost = add_spawn(GHOST_OF_VON_HELLMAN, GHOST_LOC, false, 0)
        say = NpcSay.new(ghost.l2id, 0, ghost.id, NpcString::WHO_AWOKE_ME)
        ghost.broadcast_packet(say)
        @ghost_spawned = true
        st.start_quest_timer("DESPAWN_GHOST", 300000, ghost)
        st.set_cond(2)
        st.play_sound(Sound::SKILLSOUND_HORROR_2)
        html = event
      end
    when "31524-06.html"
      if @page_count < 5
        page = add_spawn(GHOST_OF_VON_HELLMANS_PAGE, PAGE_LOC, false, 0)
        page.script_value = player.l2id
        page.broadcast_packet(NpcSay.new(page.l2id, Say2::NPC_ALL, page.id, NpcString::MY_MASTER_HAS_INSTRUCTED_ME_TO_BE_YOUR_GUIDE_S1).add_string_parameter(player.name))
        WalkingManager.start_moving(page, PAGE_ROUTE_NAME)
        @page_count += 1
        st.set_cond(3)
        html = event
      else
        html = "31524-06a.html"
      end
    when "31526-03.html"
      st.play_sound(Sound::ITEMSOUND_ARMOR_CLOTH)
      html = event
    when "31526-07.html"
      st.set_cond(4)
      html = event
    when "31526-08.html"
      if !st.cond?(5)
        st.play_sound(Sound::AMDSOUND_ED_CHIMES)
        st.set_cond(5)
        html = event
      else
        html = "31526-09.html"
      end
    when "31526-14.html"
      st.give_items(CROSS_OF_EINHASAD, 1)
      st.set_cond(6)
      html = event
    when "DESPAWN_GHOST"
      npc = npc.not_nil!
      @ghost_spawned = false
      npc.delete_me
    when "DESPAWN"
      npc = npc.not_nil!
      @page_count -= 1
      npc.delete_me
    end

    html
  end

  def on_talk(npc, pc)
    if st = get_quest_state(pc, true)
      case npc.id
      when MYSTERIOUS_WIZARD
        case st.state
        when State::CREATED
          html = "31522-01.htm"
        when State::STARTED
          html = "31522-05.html"
        when State::COMPLETED
          html = get_already_completed_msg(pc)
        end
      when TOMBSTONE
        html = "31523-01.html"
      when GHOST_OF_VON_HELLMAN
        case st.cond
        when 2
          html = "31524-01.html"
        when 3
          if @page_spawned
            html = "31524-07b.html"
          else
            if @page_count < 5
              page = add_spawn(GHOST_OF_VON_HELLMANS_PAGE, PAGE_LOC, true, 0)
              @page_count += 1
              @page_spawned = true
              page.script_value = pc.l2id
              WalkingManager.start_moving(page, PAGE_ROUTE_NAME)
              html = "31524-07.html"
            else
              html = "31524-07a.html"
            end
          end
        when 4
          html = "31524-07c.html"
        end
      when GHOST_OF_VON_HELLMANS_PAGE
        if st.cond?(3)
          if @move_ended
            html = "31525-02.html"
            st.start_quest_timer("DESPAWN", 3000, npc)
          else
            html = "31525-01.html"
          end
        end
      when BROKEN_BOOKSHELF
        case st.cond
        when 3
          html = "31526-01.html"
        when 4
          st.set_cond(5)
          st.play_sound(Sound::AMDSOUND_ED_CHIMES)
          html = "31526-10.html"
        when 5
          html = "31526-11.html"
        when 6
          html = "31526-15.html"
        end
      when AGRIPEL
        if st.has_quest_items?(CROSS_OF_EINHASAD) && st.cond?(6)
          st.set("AGRIPEL", "1")
          if st.get_int("AGRIPEL") == 1 && st.get_int("DOMINIC") == 1 && st.get_int("BENEDICT") == 1
            html = "31348-03.html"
            st.set_cond(7)
          elsif st.get_int("DOMINIC") == 1 || st.get_int("BENEDICT") == 1
            html = "31348-02.html"
          else
            html = "31348-01.html"
          end
        elsif st.cond?(7)
          html = "31348-03.html"
        end
      when BENEDICT
        if st.has_quest_items?(CROSS_OF_EINHASAD) && st.cond?(6)
          st.set("BENEDICT", "1")
          if st.get_int("AGRIPEL") == 1 && st.get_int("DOMINIC") == 1 && st.get_int("BENEDICT") == 1
            html = "31349-03.html"
            st.set_cond(7)
          elsif st.get_int("AGRIPEL") == 1 || st.get_int("DOMINIC") == 1
            html = "31349-02.html"
          else
            html = "31349-01.html"
          end
        elsif st.cond?(7)
          html = "31349-03.html"
        end
      when DOMINIC
        if st.has_quest_items?(CROSS_OF_EINHASAD) && st.cond?(6)
          st.set("DOMINIC", "1")
          if st.get_int("AGRIPEL") == 1 && st.get_int("DOMINIC") == 1 && st.get_int("BENEDICT") == 1
            html = "31350-03.html"
            st.set_cond(7)
          elsif st.get_int("AGRIPEL") == 1 || st.get_int("BENEDICT") == 1
            html = "31350-02.html"
          else
            html = "31350-01.html"
          end
        elsif st.cond?(7)
          html = "31350-03.html"
        end
      when INNOCENTIN
        if st.cond?(7) && st.has_quest_items?(CROSS_OF_EINHASAD)
          html = "31328-01.html"
        elsif st.completed?
          st = pc.get_quest_state(Q00022_TragedyInVonHellmannForest.simple_name)
          unless st
            html = "31328-06.html"
          end
        end
      end
    end

    html || get_no_quest_msg(pc)
  end

  def on_see_creature(npc, creature, is_summon)
    if creature.is_a?(L2PcInstance)
      play_sound(creature, Sound::HORROR_01)
    end

    super
  end

  def on_route_finished(npc)
    if st = L2World.get_player(npc.script_value).try &.get_quest_state(name)
      st.start_quest_timer("DESPAWN", 15000, npc)
      @move_ended = true
    end
  end
end
