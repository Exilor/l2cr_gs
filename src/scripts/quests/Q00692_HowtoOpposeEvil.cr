class Scripts::Q00692_HowtoOpposeEvil < Quest
  private DILIOS = 32549
  private KIRKLAN = 32550
  private LEKONS_CERTIFICATE = 13857
  private QUEST_ITEMS = {
    13863,
    13864,
    13865,
    13866,
    13867,
    15535,
    15536
  }

  private QUEST_MOBS = {
    # Seed of Infinity
    22509 => ItemHolder.new(13863, 500),
    22510 => ItemHolder.new(13863, 500),
    22511 => ItemHolder.new(13863, 500),
    22512 => ItemHolder.new(13863, 500),
    22513 => ItemHolder.new(13863, 500),
    22514 => ItemHolder.new(13863, 500),
    22515 => ItemHolder.new(13863, 500),
    # Seed of Destruction
    22537 => ItemHolder.new(13865, 250),
    22538 => ItemHolder.new(13865, 250),
    22539 => ItemHolder.new(13865, 250),
    22540 => ItemHolder.new(13865, 250),
    22541 => ItemHolder.new(13865, 250),
    22542 => ItemHolder.new(13865, 250),
    22543 => ItemHolder.new(13865, 250),
    22544 => ItemHolder.new(13865, 250),
    22546 => ItemHolder.new(13865, 250),
    22547 => ItemHolder.new(13865, 250),
    22548 => ItemHolder.new(13865, 250),
    22549 => ItemHolder.new(13865, 250),
    22550 => ItemHolder.new(13865, 250),
    22551 => ItemHolder.new(13865, 250),
    22552 => ItemHolder.new(13865, 250),
    22593 => ItemHolder.new(13865, 250),
    22596 => ItemHolder.new(13865, 250),
    22597 => ItemHolder.new(13865, 250),
    # Seed of Annihilation
    22746 => ItemHolder.new(15536, 125),
    22747 => ItemHolder.new(15536, 125),
    22748 => ItemHolder.new(15536, 125),
    22749 => ItemHolder.new(15536, 125),
    22750 => ItemHolder.new(15536, 125),
    22751 => ItemHolder.new(15536, 125),
    22752 => ItemHolder.new(15536, 125),
    22753 => ItemHolder.new(15536, 125),
    22754 => ItemHolder.new(15536, 125),
    22755 => ItemHolder.new(15536, 125),
    22756 => ItemHolder.new(15536, 125),
    22757 => ItemHolder.new(15536, 125),
    22758 => ItemHolder.new(15536, 125),
    22759 => ItemHolder.new(15536, 125),
    22760 => ItemHolder.new(15536, 125),
    22761 => ItemHolder.new(15536, 125),
    22762 => ItemHolder.new(15536, 125),
    22763 => ItemHolder.new(15536, 125),
    22764 => ItemHolder.new(15536, 125),
    22765 => ItemHolder.new(15536, 125)
  }

  def initialize
    super(692, self.class.simple_name, "How to Oppose Evil")

    add_start_npc(DILIOS)
    add_talk_id(DILIOS, KIRKLAN)
    add_kill_id(QUEST_MOBS.keys)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    if event.casecmp?("32549-03.htm")
      st.start_quest
    elsif event.casecmp?("32550-04.htm")
      st.set_cond(3)
    elsif event.casecmp?("32550-07.htm")
      unless give_reward(st, 13863, 5, 13796, 1)
        return "32550-08.htm"
      end
    elsif event.casecmp?("32550-09.htm")
      unless give_reward(st, 13798, 1, 57, 5000)
        return "32550-10.htm"
      end
    elsif event.casecmp?("32550-12.htm")
      unless give_reward(st, 13865, 5, 13841, 1)
        return "32550-13.htm"
      end
    elsif event.casecmp?("32550-14.htm")
      unless give_reward(st, 13867, 1, 57, 5000)
        return "32550-15.htm"
      end
    elsif event.casecmp?("32550-17.htm")
      unless give_reward(st, 15536, 5, 15486, 1)
        return "32550-18.htm"
      end
    elsif event.casecmp?("32550-19.htm")
      unless give_reward(st, 15535, 1, 57, 5000)
        return "32550-20.htm"
      end
    end

    event
  end

  def on_kill(npc, pc, is_summon)
    unless member = get_random_party_member(pc, 3)
      return
    end

    st = get_quest_state(member, false)
    npc_id = npc.id
    if st && (tmp = QUEST_MOBS[npc_id]?)
      chance = (QUEST_MOBS[npc_id].count * Config.rate_quest_drop).to_i
      num_items = chance // 1000
      chance = chance % 1000
      if Rnd.rand(1000) < chance
        num_items += 1
      end
      if num_items > 0
        st.give_items(tmp.id, num_items)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.created?
      html = pc.level >= 75 ? "32549-01.htm" : "32549-00.htm"
    else
      if npc.id == DILIOS
        if st.cond?(1) && st.has_quest_items?(LEKONS_CERTIFICATE)
          html = "32549-04.htm"
          st.take_items(LEKONS_CERTIFICATE, -1)
          st.set_cond(2)
        elsif st.cond?(2)
          html = "32549-05.htm"
        end
      else
        if st.cond?(2)
          html = "32550-01.htm"
        elsif st.cond?(3)
          QUEST_ITEMS.each do |i|
            if st.get_quest_items_count(i) > 0
              return "32550-05.htm"
            end
          end
          html = "32550-04.htm"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end

  private def give_reward(st, item_id, min_count, reward_item_id, reward_count)
    count = st.get_quest_items_count(item_id)
    if count < min_count
      return false
    end

    count //= min_count
    st.take_items(item_id, count * min_count)
    st.reward_items(reward_item_id, reward_count * count)

    true
  end
end
