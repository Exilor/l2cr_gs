class Scripts::Q00227_TestOfTheReformer < Quest
  # NPCs
  private PRIESTESS_PUPINA = 30118
  private PREACHER_SLA = 30666
  private RAMUS = 30667
  private KATARI = 30668
  private KAKAN = 30669
  private NYAKURI = 30670
  private OL_MAHUM_PILGRIM = 30732
  # Items
  private BOOK_OF_REFORM = 2822
  private LETTER_OF_INTRODUCTION = 2823
  private SLAS_LETTER = 2824
  private GREETINGS = 2825
  private Ol_MAHUM_MONEY = 2826
  private KATARIS_LETTER = 2827
  private NYAKURIS_LETTER = 2828
  private UNDEAD_LIST = 2829
  private RAMUSS_LETTER = 2830
  private RIPPED_DIARY = 2831
  private HUGE_NAIL = 2832
  private LETTER_OF_BETRAYER = 2833
  private BONE_FRAGMENT4 = 2834
  private BONE_FRAGMENT5 = 2835
  private BONE_FRAGMENT6 = 2836
  private BONE_FRAGMENT7 = 2837
  private BONE_FRAGMENT8 = 2838
  private KAKANS_LETTER = 3037
  private LETTER_GREETINGS1 = 5567
  private LETTER_GREETINGS2 = 5568
  # Rewards
  private MARK_OF_REFORMER = 2821
  private DIMENSIONAL_DIAMOND = 7562
  # Monsters
  private MISERY_SKELETON = 20022
  private SKELETON_ARCHER = 20100
  private SKELETON_MARKSMAN = 20102
  private SKELETON_LORD = 20104
  private SILENT_HORROR = 20404
  # Quest Monsters
  private NAMELESS_REVENANT = 27099
  private ARURAUNE = 27128
  private OL_MAHUM_INSPECTOR = 27129
  private OL_MAHUM_BETRAYER = 27130
  private CRIMSON_WEREWOLF = 27131
  private KRUDEL_LIZARDMAN = 27132
  # Skills
  private DISRUPT_UNDEAD = 1031
  private SLEEP = 1069
  private VAMPIRIC_TOUCH = 1147
  private CURSE_WEAKNESS = 1164
  private CURSE_POISON = 1168
  private WIND_STRIKE = 1177
  private ICE_BOLT = 1184
  private DRYAD_ROOT = 1201
  private WIND_SHACKLE = 1206
  private SKILLS = {
    DISRUPT_UNDEAD, SLEEP, VAMPIRIC_TOUCH, CURSE_WEAKNESS, CURSE_POISON,
    WIND_STRIKE, ICE_BOLT, DRYAD_ROOT, WIND_SHACKLE
  }
  # Location
  private MOVE_TO = Location.new(36787, -3709, 10000)
  # Misc
  private MIN_LEVEL = 39

  def initialize
    super(227, self.class.simple_name, "Test Of The Reformer")

    add_start_npc(PRIESTESS_PUPINA)
    add_talk_id(
      PRIESTESS_PUPINA, PREACHER_SLA, RAMUS, KATARI, KAKAN, NYAKURI,
      OL_MAHUM_PILGRIM
    )
    add_attack_id(NAMELESS_REVENANT, CRIMSON_WEREWOLF)
    add_kill_id(
      MISERY_SKELETON, SKELETON_ARCHER, SKELETON_MARKSMAN, SKELETON_LORD,
      SILENT_HORROR, NAMELESS_REVENANT, ARURAUNE, OL_MAHUM_INSPECTOR,
      OL_MAHUM_BETRAYER, CRIMSON_WEREWOLF, KRUDEL_LIZARDMAN
    )
    add_spawn_id(
      OL_MAHUM_PILGRIM, OL_MAHUM_INSPECTOR, OL_MAHUM_BETRAYER, CRIMSON_WEREWOLF,
      KRUDEL_LIZARDMAN
    )
    register_quest_items(
      BOOK_OF_REFORM, LETTER_OF_INTRODUCTION, SLAS_LETTER, GREETINGS,
      Ol_MAHUM_MONEY, KATARIS_LETTER, NYAKURIS_LETTER, UNDEAD_LIST,
      RAMUSS_LETTER, RAMUSS_LETTER, RIPPED_DIARY, HUGE_NAIL, LETTER_OF_BETRAYER,
      BONE_FRAGMENT4, BONE_FRAGMENT5, BONE_FRAGMENT6, BONE_FRAGMENT7,
      BONE_FRAGMENT8, KAKANS_LETTER, LETTER_GREETINGS1, LETTER_GREETINGS2
    )
  end

  def on_adv_event(event, npc, pc)
    if event == "DESPAWN"
      npc = npc.not_nil!
      spawned = npc.variables.get_i32("SPAWNED", 0)
      if spawned < 60
        npc.variables["SPAWNED"] = spawned + 1
      else
        npc.delete_me
      end

      return super
    end

    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
        give_items(pc, BOOK_OF_REFORM, 1)
        if pc.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(pc, DIMENSIONAL_DIAMOND, 60)
          pc.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          html = "30118-04b.htm"
        else
          html = "30118-04.htm"
        end
      end
    when "30118-06.html"
      if has_quest_items?(pc, BOOK_OF_REFORM)
        take_items(pc, BOOK_OF_REFORM, 1)
        give_items(pc, LETTER_OF_INTRODUCTION, 1)
        take_items(pc, HUGE_NAIL, 1)
        qs.memo_state = 4
        qs.set_cond(4, true)
        html = event
      end
    when "30666-02.html", "30666-03.html", "30669-02.html", "30669-05.html",
         "30670-02.html"
      html = event
    when "30666-04.html"
      take_items(pc, LETTER_OF_INTRODUCTION, 1)
      give_items(pc, SLAS_LETTER, 1)
      qs.memo_state = 5
      qs.set_cond(5, true)
      html = event
    when "30669-03.html"
      npc = npc.not_nil!
      qs.set_cond(12, true)
      if npc.summoned_npc_count < 1
        pilgrim = add_spawn(OL_MAHUM_PILGRIM, -9282, -89975, -2331, 0, false, 0)
        wolf = add_spawn(CRIMSON_WEREWOLF, -9382, -89852, -2333, 0, false, 0)
        wolf.as(L2Attackable).add_damage_hate(pilgrim, 99999, 99999)
        wolf.set_intention(AI::ATTACK, pilgrim)
      end
      html = event
    when "30670-03.html"
      npc = npc.not_nil!
      qs.set_cond(15, true)
      if npc.summoned_npc_count < 1
        pilgrim = add_spawn(OL_MAHUM_PILGRIM, 125947, -180049, -1778, 0, false, 0)
        lizard = add_spawn(KRUDEL_LIZARDMAN, 126019, -179983, -1781, 0, false, 0)
        lizard.as(L2Attackable).add_damage_hate(pilgrim, 99999, 99999)
        lizard.set_intention(AI::ATTACK, pilgrim)
      end
      html = event
    else
      # [automatically added else]
    end


    html
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    qs = get_quest_state(attacker, false)
    if qs && qs.started?
      case npc.id
      when NAMELESS_REVENANT
        if skill
          if skill.id == DISRUPT_UNDEAD
            npc.script_value = 1
          else
            npc.script_value = 2
          end
        end
      when CRIMSON_WEREWOLF
        if skill.nil? || !SKILLS.includes?(skill.id)
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::COWARDLY_GUY))
          npc.delete_me
        end
        if attacker.player?
          npc.script_value = attacker.l2id
        end
      else
        # [automatically added else]
      end

    end

    super
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when MISERY_SKELETON
        if qs.memo_state?(16) && !has_quest_items?(killer, BONE_FRAGMENT7)
          give_items(killer, BONE_FRAGMENT7, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          if has_quest_items?(killer, BONE_FRAGMENT4, BONE_FRAGMENT5, BONE_FRAGMENT6, BONE_FRAGMENT8)
            qs.memo_state = 17
            qs.set_cond(19)
          end
        end
      when SKELETON_ARCHER
        if qs.memo_state?(16) && !has_quest_items?(killer, BONE_FRAGMENT8)
          give_items(killer, BONE_FRAGMENT8, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          if has_quest_items?(killer, BONE_FRAGMENT4, BONE_FRAGMENT5, BONE_FRAGMENT6, BONE_FRAGMENT7)
            qs.memo_state = 17
            qs.set_cond(19)
          end
        end
      when SKELETON_MARKSMAN
        if qs.memo_state?(16) && !has_quest_items?(killer, BONE_FRAGMENT6)
          give_items(killer, BONE_FRAGMENT6, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          if has_quest_items?(killer, BONE_FRAGMENT4, BONE_FRAGMENT5, BONE_FRAGMENT7, BONE_FRAGMENT8)
            qs.memo_state = 17
            qs.set_cond(19)
          end
        end
      when SKELETON_LORD
        if qs.memo_state?(16) && !has_quest_items?(killer, BONE_FRAGMENT5)
          give_items(killer, BONE_FRAGMENT5, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          if has_quest_items?(killer, BONE_FRAGMENT4, BONE_FRAGMENT6, BONE_FRAGMENT7, BONE_FRAGMENT8)
            qs.memo_state = 17
            qs.set_cond(19)
          end
        end
      when SILENT_HORROR
        if qs.memo_state?(16) && !has_quest_items?(killer, BONE_FRAGMENT4)
          give_items(killer, BONE_FRAGMENT4, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          if has_quest_items?(killer, BONE_FRAGMENT5, BONE_FRAGMENT6, BONE_FRAGMENT7, BONE_FRAGMENT8)
            qs.memo_state = 17
            qs.set_cond(19)
          end
        end
      when NAMELESS_REVENANT
        if qs.memo_state?(1) && npc.script_value?(1) && !has_quest_items?(killer, HUGE_NAIL) && has_quest_items?(killer, BOOK_OF_REFORM) && (get_quest_items_count(killer, RIPPED_DIARY) < 7)
          if get_quest_items_count(killer, RIPPED_DIARY) == 6
            add_spawn(ARURAUNE, npc, true, 0, false)
            take_items(killer, RIPPED_DIARY, -1)
            qs.set_cond(2)
          else
            give_items(killer, RIPPED_DIARY, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when ARURAUNE
        if !has_quest_items?(killer, HUGE_NAIL)
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::THE_CONCEALED_TRUTH_WILL_ALWAYS_BE_REVEALED))
          give_items(killer, HUGE_NAIL, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          qs.memo_state = 3
          qs.set_cond(3)
        end
      when OL_MAHUM_INSPECTOR
        if qs.memo_state?(6)
          qs.memo_state = 7
          qs.set_cond(7, true)
        end
      when OL_MAHUM_BETRAYER
        if qs.memo_state?(8)
          qs.memo_state = 9
          qs.set_cond(9)
          give_items(killer, LETTER_OF_BETRAYER, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      when CRIMSON_WEREWOLF
        if npc.script_value?(killer.l2id) && qs.memo_state?(11)
          qs.memo_state = 12
          qs.set_cond(13, true)
        end
      when KRUDEL_LIZARDMAN
        if qs.memo_state?(13)
          qs.memo_state = 14
          qs.set_cond(16, true)
        end
      else
        # [automatically added else]
      end

    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    memo_state = qs.memo_state

    if qs.created?
      if npc.id == PRIESTESS_PUPINA
        if pc.class_id.cleric? || pc.class_id.shillien_oracle?
          if pc.level >= MIN_LEVEL
            html = "30118-03.htm"
          else
            html = "30118-01.html"
          end
        else
          html = "30118-02.html"
        end
      end
    elsif qs.started?
      case npc.id
      when PRIESTESS_PUPINA
        if memo_state == 3
          if has_quest_items?(pc, HUGE_NAIL)
            html = "30118-05.html"
          end
        elsif memo_state >= 1 && memo_state < 3
          html = "30118-04a.html"
        elsif memo_state >= 4
          html = "30118-07.html"
        end
      when PREACHER_SLA
        if memo_state == 4
          if has_quest_items?(pc, LETTER_OF_INTRODUCTION)
            html = "30666-01.html"
          end
        elsif memo_state >= 11 && memo_state < 18
          html = "30666-06b.html"
        elsif memo_state == 5
          if has_quest_items?(pc, SLAS_LETTER)
            html = "30666-05.html"
          end
        elsif memo_state == 10
          if has_quest_items?(pc, Ol_MAHUM_MONEY)
            take_items(pc, Ol_MAHUM_MONEY, 1)
            give_items(pc, GREETINGS, 1)
            give_items(pc, LETTER_GREETINGS1, 1)
            give_items(pc, LETTER_GREETINGS2, 1)
            qs.memo_state = 11
            qs.set_cond(11, true)
            html = "30666-06.html"
          else
            give_items(pc, GREETINGS, 1)
            give_items(pc, LETTER_GREETINGS1, 1)
            give_items(pc, LETTER_GREETINGS2, 1)
            qs.memo_state = 11
            qs.set_cond(11, true)
            html = "30666-06a.html"
          end
        elsif memo_state == 18
          if has_quest_items?(pc, KATARIS_LETTER, KAKANS_LETTER, NYAKURIS_LETTER, RAMUSS_LETTER)
            give_adena(pc, 226528, true)
            give_items(pc, MARK_OF_REFORMER, 1)
            add_exp_and_sp(pc, 1252844, 85972)
            qs.exit_quest(false, true)
            pc.send_packet(SocialAction.new(pc.l2id, 3))
            html = "30666-07.html"
          end
        end
      when RAMUS
        if memo_state == 15
          if has_quest_items?(pc, LETTER_GREETINGS2) && !has_quest_items?(pc, UNDEAD_LIST)
            give_items(pc, UNDEAD_LIST, 1)
            take_items(pc, LETTER_GREETINGS2, 1)
            qs.memo_state = 16
            qs.set_cond(18, true)
            html = "30667-01.html"
          end
        elsif memo_state == 16
          html = "30667-02.html"
        elsif memo_state == 17
          if has_quest_items?(pc, UNDEAD_LIST)
            take_items(pc, UNDEAD_LIST, 1)
            give_items(pc, RAMUSS_LETTER, 1)
            take_items(pc, BONE_FRAGMENT4, 1)
            take_items(pc, BONE_FRAGMENT5, 1)
            take_items(pc, BONE_FRAGMENT6, 1)
            take_items(pc, BONE_FRAGMENT7, 1)
            take_items(pc, BONE_FRAGMENT8, 1)
            qs.memo_state = 18
            qs.set_cond(20, true)
            html = "30667-03.html"
          end
        end
      when KATARI
        if memo_state == 5 || memo_state == 6
          take_items(pc, SLAS_LETTER, 1)
          qs.memo_state = 6
          qs.set_cond(6, true)
          if npc.summoned_npc_count < 1
            pilgrim = add_spawn(OL_MAHUM_PILGRIM, -4015, 40141, -3664, 0, false, 0)
            inspector = add_spawn(OL_MAHUM_INSPECTOR, -4034, 40201, -3665, 0, false, 0)
            inspector.as(L2Attackable).add_damage_hate(pilgrim, 99999, 99999)
            inspector.set_intention(AI::ATTACK, pilgrim)
          end
          html = "30668-01.html"
        elsif memo_state == 7 || memo_state == 8
          if memo_state == 7
            qs.memo_state = 8
          end
          qs.set_cond(8, true)
          if npc.summoned_npc_count < 3
            add_spawn(OL_MAHUM_BETRAYER, -4106, 40174, -3660, 0, false, 0)
          end
          html = "30668-02.html"
        elsif memo_state == 9
          if has_quest_items?(pc, LETTER_OF_BETRAYER)
            give_items(pc, KATARIS_LETTER, 1)
            take_items(pc, LETTER_OF_BETRAYER, 1)
            qs.memo_state = 10
            qs.set_cond(10, true)
            html = "30668-03.html"
          end
        elsif memo_state >= 10
          html = "30668-04.html"
        end
      when KAKAN
        if memo_state == 11
          if has_quest_items?(pc, GREETINGS)
            html = "30669-01.html"
          end
        elsif memo_state == 12
          if has_quest_items?(pc, GREETINGS) && !has_quest_items?(pc, KAKANS_LETTER)
            take_items(pc, GREETINGS, 1)
            give_items(pc, KAKANS_LETTER, 1)
            qs.memo_state = 13
            qs.set_cond(14, true)
            html = "30669-04.html"
          end
        end
      when NYAKURI
        if memo_state == 13
          if has_quest_items?(pc, LETTER_GREETINGS1)
            html = "30670-01.html"
          end
        elsif memo_state == 14
          if has_quest_items?(pc, LETTER_GREETINGS1) && !has_quest_items?(pc, NYAKURIS_LETTER)
            give_items(pc, NYAKURIS_LETTER, 1)
            take_items(pc, LETTER_GREETINGS1, 1)
            qs.memo_state = 15
            qs.set_cond(17, true)
            html = "30670-04.html"
          end
        end
      when OL_MAHUM_PILGRIM
        if memo_state == 7
          give_items(pc, Ol_MAHUM_MONEY, 1)
          qs.memo_state = 8
          html = "30732-01.html"
        end
      else
        # [automatically added else]
      end

    elsif qs.completed?
      if npc.id == PRIESTESS_PUPINA
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end

  def on_spawn(npc)
    case npc.id
    when OL_MAHUM_INSPECTOR, CRIMSON_WEREWOLF, KRUDEL_LIZARDMAN, OL_MAHUM_PILGRIM
      start_quest_timer("DESPAWN", 5000, npc, nil, true)
      npc.variables["SPAWNED"] = 0
    when OL_MAHUM_BETRAYER
      start_quest_timer("DESPAWN", 5000, npc, nil, true)
      npc.running = true
      npc.set_intention(AI::MOVE_TO, MOVE_TO)
      npc.variables["SPAWNED"] = 0
    else
      # [automatically added else]
    end


    super
  end
end
