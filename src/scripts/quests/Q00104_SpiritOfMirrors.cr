class Scripts::Q00104_SpiritOfMirrors < Quest
  # NPCs
  private GALLINT   = 30017
  private ARNOLD    = 30041
  private JOHNSTONE = 30043
  private KENYOS    = 30045
  # Items
  private GALLINTS_OAK_WAND = 748
  private SPIRITBOUND_WAND1 = 1135
  private SPIRITBOUND_WAND2 = 1136
  private SPIRITBOUND_WAND3 = 1137
  # Monsters
  private MONSTERS = {
    27003 => SPIRITBOUND_WAND1, # Spirit Of Mirrors
    27004 => SPIRITBOUND_WAND2, # Spirit Of Mirrors
    27005 => SPIRITBOUND_WAND3  # Spirit Of Mirrors
  }
  # Rewards
  private REWARDS = {
    ItemHolder.new(1060, 100), # Lesser Healing Potion
    ItemHolder.new(4412, 10),  # Echo Crystal - Theme of Battle
    ItemHolder.new(4413, 10),  # Echo Crystal - Theme of Love
    ItemHolder.new(4414, 10),  # Echo Crystal - Theme of Solitude
    ItemHolder.new(4415, 10),  # Echo Crystal - Theme of Feast
    ItemHolder.new(4416, 10),  # Echo Crystal - Theme of Celebration
    ItemHolder.new(747, 1),    # Wand of Adept
  }
  # Misc
  private MIN_LVL = 10

  def initialize
    super(104, self.class.simple_name, "Spirit of Mirrors")

    add_start_npc(GALLINT)
    add_talk_id(ARNOLD, GALLINT, JOHNSTONE, KENYOS)
    add_kill_id(MONSTERS.keys)
    register_quest_items(
      GALLINTS_OAK_WAND, SPIRITBOUND_WAND1, SPIRITBOUND_WAND2, SPIRITBOUND_WAND3
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    qs = get_quest_state(pc, false)

    if qs && event.casecmp?("30017-04.htm")
      qs.start_quest
      qs.give_items(GALLINTS_OAK_WAND, 3)
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)

    if qs && (qs.cond?(1) || qs.cond?(2))
      if qs.get_item_equipped(Inventory::RHAND) == GALLINTS_OAK_WAND
        unless qs.has_quest_items?(MONSTERS[npc.id])
          qs.take_items(GALLINTS_OAK_WAND, 1)
          qs.give_items(MONSTERS[npc.id], 1)

          if qs.has_quest_items?(SPIRITBOUND_WAND1, SPIRITBOUND_WAND2, SPIRITBOUND_WAND3)
            qs.set_cond(3, true)
          else
            qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    unless qs = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    case npc.id
    when GALLINT
      case qs.state
      when State::CREATED
        if pc.race.human?
          if pc.level >= MIN_LVL
            html = "30017-03.htm"
          else
            html = "30017-02.htm"
          end
        else
          html = "30017-01.htm"
        end
      when State::STARTED
        if qs.cond?(3) && qs.has_quest_items?(SPIRITBOUND_WAND1, SPIRITBOUND_WAND2, SPIRITBOUND_WAND3)
          Q00281_HeadForTheHills.give_newbie_reward(pc)
          REWARDS.each { |reward| qs.give_items(reward) }
          qs.add_exp_and_sp(39_750, 3407)
          qs.give_adena(16_866, true)
          qs.exit_quest(false, true)
          html = "30017-06.html"
        else
          html = "30017-05.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # [automatically added else]
      end
    when ARNOLD, JOHNSTONE, KENYOS
      if qs.cond?(1)
        unless qs.set?(npc.name)
          qs.set(npc.name, "1")
        end
        if qs.set?("Arnold") && qs.set?("Johnstone") && qs.set?("Kenyos")
          qs.set_cond(2, true)
        end
      end

      html = "#{npc.id}-01.html"
    else
      # [automatically added else]
    end

    html || get_no_quest_msg(pc)
  end
end
