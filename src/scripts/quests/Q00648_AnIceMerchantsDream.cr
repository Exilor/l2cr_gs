class Scripts::Q00648_AnIceMerchantsDream < Quest
  private record DropInfo, first_chance : Float64, second_chance : Float64

  # NPCs
  private RAFFORTY = 32020
  private ICE_SHELF = 32023
  # Items
  private SILVER_HEMOCYTE = 8057
  private SILVER_ICE_CRYSTAL = 8077
  private BLACK_ICE_CRYSTAL = 8078
  # Misc
  private MIN_LVL = 53
  # Monsters
  private MONSTERS = {
    22080 => DropInfo.new(0.285, 0.048), # Massive Maze Bandersnatch
    22081 => DropInfo.new(0.443, 0.0),   # Lost Watcher
    22082 => DropInfo.new(0.510, 0.0),   # Elder Lost Watcher
    22083 => DropInfo.new(0.477, 0.049), # Baby Panthera
    22084 => DropInfo.new(0.477, 0.049), # Panthera
    22085 => DropInfo.new(0.420, 0.043), # Lost Gargoyle
    22086 => DropInfo.new(0.490, 0.050), # Lost Gargoyle Youngling
    22087 => DropInfo.new(0.787, 0.081), # Pronghorn Spirit
    22088 => DropInfo.new(0.480, 0.049), # Pronghorn
    22089 => DropInfo.new(0.550, 0.056), # Ice Tarantula
    22090 => DropInfo.new(0.570, 0.058), # Frost Tarantula
    22091 => DropInfo.new(0.623, 0.0),   # Lost Iron Golem
    22092 => DropInfo.new(0.623, 0.0),   # Frost Iron Golem
    22093 => DropInfo.new(0.910, 0.093), # Lost Buffalo
    22094 => DropInfo.new(0.553, 0.057), # Frost Buffalo
    22095 => DropInfo.new(0.593, 0.061), # Ursus Cub
    22096 => DropInfo.new(0.593, 0.061), # Ursus
    22097 => DropInfo.new(0.693, 0.071), # Lost Yeti
    22098 => DropInfo.new(0.717, 0.074)  # Frost Yeti
  }

  def initialize
    super(648, self.class.simple_name, "An Ice Merchants Dream")

    add_start_npc(RAFFORTY)
    add_talk_id(RAFFORTY, ICE_SHELF)
    add_kill_id(MONSTERS.keys)
    register_quest_items(SILVER_HEMOCYTE, SILVER_ICE_CRYSTAL, BLACK_ICE_CRYSTAL)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end
    q115 = pc.get_quest_state(Q00115_TheOtherSideOfTruth.simple_name)

    case event
    when "ACCEPT"
      st.start_quest
      if q115 && q115.completed?
        html = "32020-04.htm"
      else
        st.set_cond(2)
        html = "32020-05.htm"
      end
    when "ASK"
      if st.cond >= 1
        html = q115 && !q115.completed? ? "32020-14.html" : "32020-15.html"
      end
    when "LATER"
      if st.cond >= 1
        html = q115 && !q115.completed? ? "32020-19.html" : "32020-20.html"
      end
    when "REWARD"
      if st.cond >= 1
        silver_count = get_quest_items_count(pc, SILVER_ICE_CRYSTAL)
        black_count = get_quest_items_count(pc, BLACK_ICE_CRYSTAL)
        if silver_count + black_count > 0
          give_adena(pc, (silver_count * 300) + (black_count * 1200), true)
          take_items(pc, -1, {SILVER_ICE_CRYSTAL, BLACK_ICE_CRYSTAL})
          html = q115 && !q115.completed? ? "32020-16.html" : "32020-17.html"
        else
          html = "32020-18.html"
        end
      end
    when "QUIT"
      if st.cond >= 1
        if q115 && !q115.completed?
          html = "32020-21.html"
          st.exit_quest(true, true)
        else
          html = "32020-22.html"
        end
      end
    when "32020-06.html", "32020-07.html", "32020-08.html", "32020-09.html"
      if st.cond >= 1
        html = event
      end
    when "32020-23.html"
      if st.cond >= 1
        st.exit_quest(true, true)
        html = event
      end
    when "32023-04.html"
      if st.cond >= 1 && has_quest_items?(pc, SILVER_ICE_CRYSTAL)
        if st.get_int("ex") == 0
          st.set("ex", (Rnd.rand(4) + 1) * 10)
          html = event
        end
      end
    when "32023-05.html"
      if st.cond >= 1 && has_quest_items?(pc, SILVER_ICE_CRYSTAL)
        if st.get_int("ex") > 0
          take_items(pc, SILVER_ICE_CRYSTAL, 1)
          val = st.get_int("ex") + 1
          st.set("ex", val)
          play_sound(pc, Sound::ITEMSOUND_BROKEN_KEY)
          html = event
        end
      end
    when "32023-06.html"
      if st.cond >= 1 && has_quest_items?(pc, SILVER_ICE_CRYSTAL)
        if st.get_int("ex") > 0
          take_items(pc, SILVER_ICE_CRYSTAL, 1)
          val = st.get_int("ex") + 2
          st.set("ex", val)
          play_sound(pc, Sound::ITEMSOUND_BROKEN_KEY)
          html = event
        end
      end
    when "REPLY4"
      if st.cond >= 1 && st.get_int("ex") > 0
        ex = st.get_int("ex")
        val1 = ex // 10
        val2 = ex - (val1 * 10)
        if val1 == val2
          html = "32023-07.html"
          give_items(pc, BLACK_ICE_CRYSTAL, 1)
          play_sound(pc, Sound::ITEMSOUND_ENCHANT_SUCCESS)
        else
          html = "32023-08.html"
          play_sound(pc, Sound::ITEMSOUND_ENCHANT_FAILED)
        end
        st.set("ex", 0)
      end
    when "REPLY5"
      if st.cond >= 1 && st.get_int("ex") > 0
        ex = st.get_int("ex")
        val1 = ex // 10
        val2 = (ex - (val1 * 10)) + 2
        if val1 == val2
          html = "32023-07.html"
          give_items(pc, BLACK_ICE_CRYSTAL, 1)
          play_sound(pc, Sound::ITEMSOUND_ENCHANT_SUCCESS)
        else
          html = "32023-08.html"
          play_sound(pc, Sound::ITEMSOUND_ENCHANT_FAILED)
        end
        st.set("ex", 0)
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    if st = get_random_party_member_state(killer, -1, 3, npc)
      info = MONSTERS[npc.id]
      if st.cond >= 1
        give_item_randomly(st.player, npc, SILVER_ICE_CRYSTAL, 1, 0, info.first_chance, true)
      end

      if info.second_chance > 0
        st2 = st.player.get_quest_state(Q00115_TheOtherSideOfTruth.simple_name)
        if st.cond >= 2 && st2 && st2.completed?
          give_item_randomly(st.player, npc, SILVER_HEMOCYTE, 1, 0, info.second_chance, true)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when RAFFORTY
      if st.created?
        if pc.level < MIN_LVL
          html = "32020-01.htm"
        else
          if pc.quest_completed?(Q00115_TheOtherSideOfTruth.simple_name)
            html = "32020-02.htm"
          else
            html = "32020-03.htm"
          end
        end
      elsif st.started?
        count = get_quest_items_count(pc, SILVER_ICE_CRYSTAL, BLACK_ICE_CRYSTAL)
        if pc.quest_completed?(Q00115_TheOtherSideOfTruth.simple_name)
          html = count > 0 ? "32020-13.html" : "32020-11.html"
          if st.cond?(1)
            st.set_cond(2, true)
          end
        else
          html = count > 0 ? "32020-12.html" : "32020-10.html"
        end
      end
    when ICE_SHELF
      # TODO: In High Five this quest have an updated reward system.
      if st.started?
        if has_quest_items?(pc, SILVER_ICE_CRYSTAL)
          val = st.get_int("ex") % 10
          if val == 0
            html = "32023-03.html"
            st.set("ex", 0)
          else
            html = "32023-09.html"
          end
        else
          html = "32023-02.html"
        end
      else
        html = "32023-01.html"
      end
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
