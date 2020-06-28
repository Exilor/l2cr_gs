class Scripts::Q00367_ElectrifyingRecharge < Quest
  # NPC
  private LORAIN = 30673
  # Monster
  private CATHEROK = 21035
  # Items
  private TITAN_LAMP1 = 5875
  private TITAN_LAMP2 = 5876
  private TITAN_LAMP3 = 5877
  private TITAN_LAMP4 = 5878
  private TITAN_LAMP5 = 5879
  private BROKEN_TITAN_LAMP = 5880
  # Misc
  private MIN_LEVEL = 37
  # Skill
  private NPC_THUNDER_STORM = SkillHolder.new(4072, 4)

  def initialize
    super(367, self.class.simple_name, "Electrifying Recharge!")

    add_start_npc(LORAIN)
    add_talk_id(LORAIN)
    add_attack_id(CATHEROK)
    register_quest_items(
      TITAN_LAMP1, TITAN_LAMP2, TITAN_LAMP3, TITAN_LAMP4, TITAN_LAMP5,
      BROKEN_TITAN_LAMP
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30673-02.htm"
      st.start_quest
      give_items(pc, TITAN_LAMP1, 1)
      html = event
    when "30673-05.html"
      html = event
    when "30673-06.html"
      st.exit_quest(true, true)
      html = event
    end


    html
  end

  def on_attack(npc, attacker, damage, is_summon)
    if npc.script_value?(367)
      return super
    end

    qs = get_quest_state(attacker, false)
    if qs.nil? || !qs.started?
      return super
    end

    npc.script_value = 367

    if skill = NPC_THUNDER_STORM.skill?
      if skill.mp_consume2 < npc.current_mp # has enough MP
        if skill.hp_consume < npc.current_hp # has enough HP
          if npc.get_skill_remaining_reuse_time(skill.hash) <= 0 # no reuse delay
            npc.do_cast(skill, attacker, nil)
          end
        end
      end
    end

    unless winner = get_random_party_member(attacker, npc)
      return super
    end

    qs = get_quest_state(winner, false)

    if qs && qs.started? && !has_quest_items?(winner, TITAN_LAMP5)
      random = Rnd.rand(37)
      if random == 0
        if has_quest_items?(winner, TITAN_LAMP1)
          give_items(winner, TITAN_LAMP2, 1)
          take_items(winner, TITAN_LAMP1, -1)
          play_sound(winner, Sound::ITEMSOUND_QUEST_MIDDLE)
        elsif has_quest_items?(winner, TITAN_LAMP2)
          give_items(winner, TITAN_LAMP3, 1)
          take_items(winner, TITAN_LAMP2, -1)
          play_sound(winner, Sound::ITEMSOUND_QUEST_MIDDLE)
        elsif has_quest_items?(winner, TITAN_LAMP3)
          give_items(winner, TITAN_LAMP4, 1)
          take_items(winner, TITAN_LAMP3, -1)
          play_sound(winner, Sound::ITEMSOUND_QUEST_MIDDLE)
        elsif has_quest_items?(winner, TITAN_LAMP4)
          give_items(winner, TITAN_LAMP5, 1)
          take_items(winner, TITAN_LAMP4, -1)
          get_quest_state!(winner, false).set_cond(2, true)
        end
      elsif random == 1 && !has_quest_items?(winner, BROKEN_TITAN_LAMP)
        give_items(winner, BROKEN_TITAN_LAMP, 1)
        take_items(winner, -1, {TITAN_LAMP1, TITAN_LAMP2, TITAN_LAMP3, TITAN_LAMP4})
        play_sound(winner, Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.created?
      html = pc.level >= MIN_LEVEL ? "30673-01.htm" : "30673-03.html"
    elsif st.started?
      if !has_at_least_one_quest_item?(pc, TITAN_LAMP5, BROKEN_TITAN_LAMP)
        html = "30673-04.html"
      elsif has_quest_items?(pc, BROKEN_TITAN_LAMP)
        give_items(pc, TITAN_LAMP1, 1)
        take_items(pc, BROKEN_TITAN_LAMP, -1)
        html = "30673-07.html"
      elsif has_quest_items?(pc, TITAN_LAMP5)
        case Rnd.rand(14)
        when 0
          item_id = 4553 # Greater Dye of STR <Str+1 Con-1>
        when 1
          item_id = 4554 # Greater Dye of STR <Str+1 Dex-1>
        when 2
          item_id = 4555 # Greater Dye of CON <Con+1 Str-1>
        when 3
          item_id = 4556 # Greater Dye of CON <Con+1 Dex-1>
        when 4
          item_id = 4557 # Greater Dye of DEX <Dex+1 Str-1>
        when 5
          item_id = 4558 # Greater Dye of DEX <Dex+1 Con-1>
        when 6
          item_id = 4559 # Greater Dye of INT <Int+1 Men-1>
        when 7
          item_id = 4560 # Greater Dye of INT <Int+1 Wit-1>
        when 8
          item_id = 4561 # Greater Dye of MEN <Men+1 Int-1>
        when 9
          item_id = 4562 # Greater Dye of MEN <Men+1 Wit-1>
        when 10
          item_id = 4563 # Greater Dye of WIT <Wit+1 Int-1>
        when 11
          item_id = 4564 # Greater Dye of WIT <Wit+1 Men-1>
        else
          item_id = 4445 # Dye of STR <Str+1 Con-3>
        end

        reward_items(pc, item_id, 1)
        take_items(pc, TITAN_LAMP5, -1)
        give_items(pc, TITAN_LAMP1, 1)
        html = "30673-08.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
