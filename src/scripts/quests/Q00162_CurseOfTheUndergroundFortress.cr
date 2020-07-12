class Scripts::Q00162_CurseOfTheUndergroundFortress < Quest
  # NPC
  private UNOREN = 30147
  # Monsters
  private MONSTERS_SKULLS = {
    20033 => 25, # Shade Horror
    20345 => 26, # Dark Terror
    20371 => 23  # Mist Terror
  }
  private MONSTERS_BONES = {
    20463 => 25, # Dungeon Skeleton Archer
    20464 => 23, # Dungeon Skeleton
    20504 => 26  # Dread Soldier
  }
  # Items
  private BONE_SHIELD = 625
  private BONE_FRAGMENT = 1158
  private ELF_SKULL = 1159
  # Misc
  private MIN_LVL = 12
  private REQUIRED_COUNT = 13

  def initialize
    super(162, self.class.simple_name, "Curse of the Underground Fortress")

    add_start_npc(UNOREN)
    add_talk_id(UNOREN)
    add_kill_id(MONSTERS_SKULLS.keys)
    add_kill_id(MONSTERS_BONES.keys)
    register_quest_items(BONE_FRAGMENT, ELF_SKULL)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)

    if st
      case event
      when "30147-03.htm"
        html = event
      when "30147-04.htm"
        st.start_quest
        html = event
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(1)
      if tmp = MONSTERS_SKULLS[npc.id]?
        if Rnd.rand(100) < tmp
          skulls = st.get_quest_items_count(ELF_SKULL)
          if skulls < 3
            st.give_items(ELF_SKULL, 1)
            skulls &+= 1
            if skulls >= 3 && st.get_quest_items_count(BONE_FRAGMENT) >= 10
              st.set_cond(2, true)
            else
              st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      elsif tmp = MONSTERS_BONES[npc.id]?
        if Rnd.rand(100) < tmp
          bones = st.get_quest_items_count(BONE_FRAGMENT)
          if bones < 10
            st.give_items(BONE_FRAGMENT, 1)
            bones &+= 1
            if bones >= 10 && st.get_quest_items_count(ELF_SKULL) >= 3
              st.set_cond(2, true)
            else
              st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    if st = get_quest_state(pc, true)
      case st.state
      when State::CREATED
        if !pc.race.dark_elf?
          if pc.level >= MIN_LVL
            html = "30147-02.htm"
          else
            html = "30147-01.htm"
          end
        else
          html = "30147-00.htm"
        end
      when State::STARTED
        if st.get_quest_items_count(BONE_FRAGMENT) + st.get_quest_items_count(ELF_SKULL) >= REQUIRED_COUNT
          st.give_items(BONE_SHIELD, 1)
          st.add_exp_and_sp(22652, 1004)
          st.give_adena(24000, true)
          st.exit_quest(false, true)
          html = "30147-06.html"
        else
          html = "30147-05.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
