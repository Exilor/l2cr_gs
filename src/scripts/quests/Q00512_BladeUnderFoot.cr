class Scripts::Q00512_BladeUnderFoot < Quest
  private record DropInfo, first_chance : Int32, second_chance : Int32

  # NPCs
  private WARDEN = {
    36403, # Gludio
    36404, # Dion
    36405, # Giran
    36406, # Oren
    36407, # Aden
    36408, # Innadril
    36409, # Goddard
    36410, # Rune
    36411  # Schuttgart
  }

  # Misc
  private MIN_LEVEL = 70
  # Item
  private FRAGMENT_OF_THE_DUNGEON_LEADER_MARK = 9798
  # Reward
  private KNIGHTS_EPAULETTE = 9912
  # Raid Bosses
  private RAID_BOSSES = {
    25563 => DropInfo.new(175, 1443), # Beautiful Atrielle
    25566 => DropInfo.new(176, 1447), # Nagen the Tomboy
    25569 => DropInfo.new(177, 1450)  # Jax the Destroyer
  }

  def initialize
    super(512, self.class.simple_name, "Blade Under Foot")

    add_start_npc(WARDEN)
    add_talk_id(WARDEN)
    add_kill_id(RAID_BOSSES.keys)
    register_quest_items(FRAGMENT_OF_THE_DUNGEON_LEADER_MARK)
  end

  def action_for_each_player(pc, npc, is_summon)
    st = get_quest_state(pc, false)
    if st && Util.in_range?(1500, npc, pc, false)
      pc_count = pc.party.not_nil!.size
      item_count = RAID_BOSSES[npc.id].second_chance

      if pc_count > 0
        item_count //= pc_count
      end

      st.give_items(FRAGMENT_OF_THE_DUNGEON_LEADER_MARK, item_count)
      st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
    end
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "36403-02.htm"
      if pc.level >= MIN_LEVEL
        npc = npc.not_nil!
        return unless clan = pc.clan
        if npc.my_lord?(pc) || (npc.castle.residence_id == clan.castle_id && clan.castle_id > 0)
          st.start_quest
          html = event
        else
          html = "36403-03.htm"
        end
      end
    when "36403-04.html", "36403-05.html", "36403-06.html", "36403-07.html",
         "36403-10.html"
      html = event
    when "36403-11.html"
      st.exit_quest(true, true)
      html = event
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    if st = get_quest_state(pc, false)
      if pc.in_party?
        execute_for_each_player(pc, npc, is_summon, true, false)
      else
        st.give_items(FRAGMENT_OF_THE_DUNGEON_LEADER_MARK, RAID_BOSSES[npc.id].first_chance)
        st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.created?
      if pc.level >= MIN_LEVEL
        if npc.my_lord?(pc) || ((clan = pc.clan) && npc.castle.residence_id == clan.castle_id && clan.castle_id > 0)
          html = "36403-01.htm"
        else
          html = "36403-03.htm"
        end
      else
        html = "36403-08.htm"
      end
    elsif st.started?
      if has_quest_items?(pc, FRAGMENT_OF_THE_DUNGEON_LEADER_MARK)
        give_items(pc, KNIGHTS_EPAULETTE, get_quest_items_count(pc, FRAGMENT_OF_THE_DUNGEON_LEADER_MARK))
        take_items(pc, FRAGMENT_OF_THE_DUNGEON_LEADER_MARK, -1)
        html = "36403-09.html"
      else
        html = "36403-12.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
