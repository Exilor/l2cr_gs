class Scripts::Q00003_WillTheSealBeBroken < Quest
  # NPC
  private TALLOTH = 30141
  # Monsters
  private OMEN_BEAST = 20031
  private TAINTED_ZOMBIE = 20041
  private STINK_ZOMBIE = 20046
  private LESSER_SUCCUBUS = 20048
  private LESSER_SUCCUBUS_TUREN = 20052
  private LESSER_SUCCUBUS_TILFO = 20057
  # Items
  private OMEN_BEAST_EYE = 1081
  private TAINT_STONE = 1082
  private SUCCUBUS_BLOOD = 1083
  private ENCHANT = 956
  # Misc
  private MIN_LEVEL = 16

  def initialize
    super(3, self.class.simple_name, "Will the Seal be Broken?")

    add_start_npc(TALLOTH)
    add_talk_id(TALLOTH)
    add_kill_id(
      OMEN_BEAST, TAINTED_ZOMBIE, STINK_ZOMBIE, LESSER_SUCCUBUS,
      LESSER_SUCCUBUS_TILFO, LESSER_SUCCUBUS_TUREN
    )
    register_quest_items(OMEN_BEAST_EYE, TAINT_STONE, SUCCUBUS_BLOOD)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "30141-03.htm"
      st.start_quest
      event
    when "30141-05.html"
      event
    end
  end

  def on_kill(npc, pc, is_summon)
    return super unless m = get_random_party_member(pc, 1)
    return super unless st = get_quest_state(m, false)

    case npc.id
    when OMEN_BEAST
      give_item(m, st, OMEN_BEAST_EYE, registered_item_ids)
    when STINK_ZOMBIE, TAINTED_ZOMBIE
      give_item(m, st, TAINT_STONE, registered_item_ids)
    when LESSER_SUCCUBUS, LESSER_SUCCUBUS_TILFO, LESSER_SUCCUBUS_TUREN
      give_item(m, st, SUCCUBUS_BLOOD, registered_item_ids)
    end

    super
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    case st.state
    when State::CREATED
      if !pc.race.dark_elf?
        html = "30141-00.htm"
      else
        if pc.level >= MIN_LEVEL
          html = "30141-02.htm"
        else
          html = "30141-01.html"
        end
      end
    when State::STARTED
      if st.cond? 1
        html = "30141-04.html"
      else
        give_items(pc, ENCHANT, 1)
        st.exit_quest(false, true)
        html = "30141-06.html"
      end
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    end

    html || get_no_quest_msg(pc)
  end

  private def give_item(pc, st, item, items)
    return if has_quest_items?(pc, item)
    give_items(pc, item, 1)
    play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
    if has_quest_items?(pc, items)
      st.set_cond(2, true)
    end
  end
end
