class Scripts::Q00025_HidingBehindTheTruth < Quest
  # NPCs
  private HIGH_PRIEST_AGRIPEL = 31348
  private PRIEST_BENEDICT = 31349
  private MYSTERIOUS_WIZARD = 31522
  private TOMBSTONE = 31531
  private MAID_OF_LIDIA = 31532
  private BROKEN_BOOKSHELF2 = 31533
  private BROKEN_BOOKSHELF3 = 31534
  private BROKEN_BOOKSHELF4 = 31535
  private COFFIN = 31536
  # Mobs
  private TRIOL_PAWN = 27218
  # Items
  private MAP_FOREST_OF_THE_DEAD = 7063
  private CONTRACT = 7066
  private LIDAS_DRESS = 7155
  private TOTEM_DOLL2 = 7156
  private GEMSTONE_KEY = 7157
  private TOTEM_DOLL3 = 7158
  # Rewards
  private NECKLACE_OF_BLESSING = 936
  private EARING_OF_BLESSING = 874
  private RING_OF_BLESSING = 905
  # Misc
  private MIN_LVL = 66
  private TRIOL_PAWN_LOC = {
    BROKEN_BOOKSHELF2 => Location.new(47142, -35941, -1623),
    BROKEN_BOOKSHELF3 => Location.new(50055, -47020, -3396),
    BROKEN_BOOKSHELF4 => Location.new(59712, -47568, -2720)
  }
  private COFFIN_LOC = Location.new(60104, -35820, -681)

  def initialize
    super(25, self.class.simple_name, "Hiding Behind the Truth")

    add_start_npc(PRIEST_BENEDICT)
    add_talk_id(HIGH_PRIEST_AGRIPEL, PRIEST_BENEDICT, MYSTERIOUS_WIZARD, TOMBSTONE, MAID_OF_LIDIA, BROKEN_BOOKSHELF2, BROKEN_BOOKSHELF3, BROKEN_BOOKSHELF4, COFFIN)
    register_quest_items(GEMSTONE_KEY, CONTRACT, TOTEM_DOLL3, TOTEM_DOLL2, LIDAS_DRESS)
    add_attack_id(TRIOL_PAWN)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "31349-06.html", "31349-07.html", "31349-08.html", "31349-09.html",
         "31522-08.html", "31522-09.html", "31522-07.html", "31522-11.html",
         "31348-04.html", "31348-05.html", "31348-06.html", "31348-11.html",
         "31348-07.html", "31348-12.html", "31348-14.html", "31532-04.html",
         "31532-05.html", "31532-06.html", "31532-14.html", "31532-15.html",
         "31532-16.html", "31532-19.html", "31532-20.html"
      html = event
    when "31349-03.html"
      if qs.created? && pc.level >= MIN_LVL
        if pc.quest_completed?(Q00024_InhabitantsOfTheForestOfTheDead.simple_name)
          qs.memo_state = 1
          qs.start_quest
          html = event
        end
      end
    when "31349-05.html"
      if qs.memo_state?(1)
        if has_quest_items?(pc, TOTEM_DOLL2)
          html = "31349-04.html"
        else
          qs.set_cond(2, true)
          html = event
        end
      end
    when "31349-10.html"
      if qs.memo_state?(1) && has_quest_items?(pc, TOTEM_DOLL2)
        qs.memo_state = 2
        qs.set_cond(4, true)
        html = event
      end
    when "31522-04.html"
      if qs.memo_state?(6) && has_quest_items?(pc, GEMSTONE_KEY)
        qs.memo_state = 7
        qs.set_memo_state_ex(1, 20)
        qs.set_cond(6, true)
        html = event
      end
    when "31522-10.html"
      if qs.memo_state?(16)
        qs.memo_state = 19
        html = event
      end
    when "31522-13.html"
      if qs.memo_state?(19)
        qs.memo_state = 20
        qs.set_cond(16, true)
        html = event
      end
    when "31522-16.html"
      if qs.memo_state?(24)
        take_items(pc, MAP_FOREST_OF_THE_DEAD, -1)
        reward_items(pc, EARING_OF_BLESSING, 1)
        reward_items(pc, NECKLACE_OF_BLESSING, 1)
        add_exp_and_sp(pc, 572277, 53750)
        qs.exit_quest(false, true)
        html = event
      end
    when "31348-02.html"
      if qs.memo_state?(2)
        take_items(pc, TOTEM_DOLL2, -1)
        qs.memo_state = 3
        html = event
      end
    when "31348-08.html"
      if qs.memo_state?(3)
        give_items(pc, GEMSTONE_KEY, 1)
        qs.memo_state = 6
        qs.set_cond(5, true)
        html = event
      end
    when "31348-10.html"
      if qs.memo_state?(20) && has_quest_items?(pc, TOTEM_DOLL3)
        take_items(pc, TOTEM_DOLL3, -1)
        qs.memo_state = 21
        html = event
      end
    when "31348-13.html"
      if qs.memo_state?(21)
        qs.memo_state = 22
        html = event
      end
    when "31348-16.html"
      if qs.memo_state?(22)
        qs.memo_state = 23
        qs.set_cond(17, true)
        html = event
      end
    when "31348-17.html"
      if qs.memo_state?(22)
        qs.memo_state = 24
        qs.set_cond(18, true)
        html = event
      end
    when "31533-04.html"
      npc = npc.not_nil!
      if qs.get_memo_state_ex(npc.id) != -1 # original: 0
        html = "31533-03.html"
      elsif Rnd.rand(60) > qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, qs.get_memo_state_ex(1) + 20)
        qs.set_memo_state_ex(npc.id, 1)
        html = "31533-03.html"
      else
        qs.memo_state = 8
        html = event
        play_sound(pc, Sound::AMDSOUND_HORROR_02)
      end
    when "31533-05.html"
      if qs.memo_state?(8)
        if !has_quest_items?(pc, TOTEM_DOLL3)
          npc = npc.not_nil!
          broken_desk_owner = npc.variables.get_i32("Q00025", 0)
          if broken_desk_owner == 0
            npc.variables["Q00025"] = pc.l2id
            triol = add_spawn(TRIOL_PAWN, TRIOL_PAWN_LOC[npc.id], true, 0)
            triol.variables["Q00025"] = npc
            triol.script_value = pc.l2id
            start_quest_timer("SAY_TRIYOL", 500, triol, pc)
            start_quest_timer("DESPAWN_TRIYOL", 120_000, triol, pc)
            triol.set_intention(AI::ATTACK, pc)

            html = event
            qs.set_cond(7)
          elsif broken_desk_owner == pc.l2id
            html = "31533-06.html"
          else
            html = "31533-07.html"
          end
        else
          html = "31533-08.html"
        end
      end
    when "31533-09.html"
      if qs.memo_state?(8) && has_quest_items?(pc, TOTEM_DOLL3, GEMSTONE_KEY)
        give_items(pc, CONTRACT, 1)
        take_items(pc, GEMSTONE_KEY, -1)
        qs.memo_state = 9
        qs.set_cond(9)
        html = event
      end
    when "SAY_TRIYOL"
      npc = npc.not_nil!
      npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::ALL, npc.id, NpcString::THAT_BOX_WAS_SEALED_BY_MY_MASTER_S1_DONT_TOUCH_IT).add_string_parameter(pc.name))
    when "DESPAWN_TRIYOL"
      npc = npc.not_nil!
      broken_desk = npc.variables.get_object("Q00025", L2Npc?)
      if broken_desk
        broken_desk.variables["Q00025"] = 0
      end
      npc.delete_me
    when "31532-02.html"
      if qs.memo_state?(9) && has_quest_items?(pc, CONTRACT)
        take_items(pc, CONTRACT, -1)
        qs.memo_state = 10
        html = event
      end
    when "31532-07.html"
      if qs.memo_state?(10)
        qs.memo_state = 11
        play_sound(pc, Sound::SKILLSOUND_HORROR_1)
        qs.set_cond(11)
        html = event
      end
    when "31532-11.html"
      if qs.memo_state?(13)
        memo_state_ex = qs.get_memo_state_ex(1)
        if memo_state_ex <= 3
          qs.set_memo_state_ex(1, memo_state_ex + 1)
          play_sound(pc, Sound::CHRSOUND_FDELF_CRY)
          html = event
        else
          qs.memo_state = 14
          html = "31532-12.html"
        end
      end
    when "31532-17.html"
      if qs.memo_state?(14)
        qs.memo_state = 15
        html = event
      end
    when "31532-21.html"
      if qs.memo_state?(15)
        qs.memo_state = 16
        qs.set_cond(15)
        html = event
      end
    when "31532-25.html"
      if qs.memo_state?(23)
        take_items(pc, MAP_FOREST_OF_THE_DEAD, -1)
        reward_items(pc, EARING_OF_BLESSING, 1)
        reward_items(pc, RING_OF_BLESSING, 2)
        add_exp_and_sp(pc, 572277, 53750)
        qs.exit_quest(false, true)
        html = event
      end
    when "31531-02.html"
      if qs.memo_state?(11)
        box = add_spawn(COFFIN, COFFIN_LOC, true, 0)
        start_quest_timer("DESPAWN_BOX", 20_000, box, pc)
        qs.set_cond(12, true)
        html = event
      end
    when "DESPAWN_BOX"
      npc.not_nil!.delete_me
    end

    html || get_no_quest_msg(pc)
  end

  def on_attack(npc, attacker, damage, is_summon)
    if npc.current_hp <= (0.30 * npc.max_hp)
      qs = get_quest_state(attacker, false)
      if qs && qs.memo_state?(8) && !has_quest_items?(attacker, TOTEM_DOLL3)
        if attacker.l2id == npc.script_value
          give_items(attacker, TOTEM_DOLL3, 1)
          qs.set_cond(8, true)
          npc.broadcast_packet(
            NpcSay.new(
              npc.l2id,
              Say2::ALL,
              npc.id,
              NpcString::YOUVE_ENDED_MY_IMMORTAL_LIFE_YOURE_PROTECTED_BY_THE_FEUDAL_LORD_ARENT_YOU
            )
          )

          broken_desk = npc.variables.get_object("Q00025", L2Npc?)
          if broken_desk
            broken_desk.variables["Q00025"] = 0
          end
          npc.delete_me
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case qs.state
    when State::CREATED
      if npc.id == PRIEST_BENEDICT
        q24 = pc.get_quest_state(Q00024_InhabitantsOfTheForestOfTheDead.simple_name)
        if q24 && q24.completed? && pc.level >= MIN_LVL
          html = "31349-01.htm"
        else
          html = "31349-02.html"
        end
      end
    when State::STARTED
      case npc.id
      when PRIEST_BENEDICT
        case qs.memo_state
        when 1
          html = "31349-03a.html"
        when 2
          html = "31349-11.html"
        end

      when MYSTERIOUS_WIZARD
        case qs.memo_state
        when 1
          if !has_quest_items?(pc, TOTEM_DOLL2)
            give_items(pc, TOTEM_DOLL2, 1)
            qs.set_cond(3, true)
            html = "31522-01.html"
          else
            html = "31522-02.html"
          end
        when 6
          if has_quest_items?(pc, GEMSTONE_KEY)
            html = "31522-03.html"
          end
        when 9
          if has_quest_items?(pc, CONTRACT)
            qs.set_cond(10, true)
            html = "31522-06.html"
          end
        when 16
          html = "31522-06a.html"
        when 19
          html = "31522-12.html"
        when 20
          html = "31522-14.html"
        when 24
          html = "31522-15.html"
        when 23
          html = "31522-15a.html"
        else
          if qs.memo_state % 100 == 7
            html = "31522-05.html"
          end
        end
      when HIGH_PRIEST_AGRIPEL
        case qs.memo_state
        when 2
          html = "31348-01.html"
        when 3
          html = "31348-03.html"
        when 6
          html = "31348-08a.html"
        when 20
          if has_quest_items?(pc, TOTEM_DOLL3)
            html = "31348-09.html"
          end
        when 21
          html = "31348-10a.html"
        when 22
          html = "31348-15.html"
        when 23
          html = "31348-18.html"
        when 24
          html = "31348-19.html"
        end
      when BROKEN_BOOKSHELF2, BROKEN_BOOKSHELF3, BROKEN_BOOKSHELF4
        if qs.memo_state % 100 == 7
          html = "31533-01.html"
        elsif qs.memo_state % 100 >= 9
          html = "31533-02.html"
        elsif qs.memo_state?(8)
          html = "31533-04.html"
        end
      when MAID_OF_LIDIA
        case qs.memo_state
        when 9
          if has_quest_items?(pc, CONTRACT)
            html = "31532-01.html"
          end
        when 10
          html = "31532-03.html"
        when 11
          play_sound(pc, Sound::SKILLSOUND_HORROR_1)
          html = "31532-08.html"
        when 12
          if has_quest_items?(pc, LIDAS_DRESS)
            take_items(pc, LIDAS_DRESS, -1)
            qs.memo_state = 13
            qs.set_cond(14, true)
            html = "31532-09.html"
          end
        when 13
          qs.set_memo_state_ex(1, 0)
          play_sound(pc, Sound::CHRSOUND_FDELF_CRY)
          html = "31532-10.html"
        when 14
          html = "31532-13.html"
        when 15
          html = "31532-18.html"
        when 16
          html = "31532-22.html"
        when 23
          html = "31532-23.html"
        when 24
          html = "31532-24.html"
        end
      when TOMBSTONE
        case qs.memo_state
        when 11
          html = "31531-01.html"
        when 12
          html = "31531-03.html"
        end
      when COFFIN
        if qs.memo_state?(11)
          give_items(pc, LIDAS_DRESS, 1)
          cancel_quest_timer("DESPAWN_BOX", npc, pc)
          start_quest_timer("DESPAWN_BOX", 3000, npc, pc)
          qs.memo_state = 12
          qs.set_cond(13, true)
          html = "31536-01.html"
        end
      end
    when State::COMPLETED
      if npc.id == PRIEST_BENEDICT
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
