class Scripts::Q00604_DaimonTheWhiteEyedPart2 < Quest
  # NPCs
  private DAIMONS_ALTAR = 31541
  private EYE_OF_ARGOS = 31683
  # Raid Boss
  private DAIMON_THE_WHITE_EYED = 25290
  # Items
  private UNFINISHED_SUMMON_CRYSTAL = 7192
  private SUMMON_CRYSTAL = 7193
  private ESSENCE_OF_DAIMON = 7194
  # Misc
  private MIN_LEVEL = 73
  # Location
  private DAIMON_THE_WHITE_EYED_LOC = Location.new(186320, -43904, -3175)
  # Rewards
  private DYE_I2M2_C = 4595 # Greater Dye of INT <Int+2 Men-2>
  private DYE_I2W2_C = 4596 # Greater Dye of INT <Int+2 Wit-2>
  private DYE_M2I2_C = 4597 # Greater Dye of MEN <Men+2 Int-2>
  private DYE_M2W2_C = 4598 # Greater Dye of MEN <Men+2 Wit-2>
  private DYE_W2I2_C = 4599 # Greater Dye of WIT <Wit+2 Int-2>
  private DYE_W2M2_C = 4600 # Greater Dye of WIT <Wit+2 Men-2>

  def initialize
    super(604, self.class.simple_name, "Daimon the White-Eyed - Part 2")

    add_start_npc(EYE_OF_ARGOS)
    add_talk_id(EYE_OF_ARGOS, DAIMONS_ALTAR)
    add_spawn_id(DAIMON_THE_WHITE_EYED)
    add_kill_id(DAIMON_THE_WHITE_EYED)
    register_quest_items(SUMMON_CRYSTAL, ESSENCE_OF_DAIMON)
  end

  def action_for_each_player(pc, npc, is_summon)
    qs = get_quest_state(pc, false)
    if qs && qs.memo_state >= 11 && qs.memo_state <= 21
      if Util.in_range?(1500, npc, pc, false)
        if has_quest_items?(pc, ESSENCE_OF_DAIMON)
          qs.set_cond(3, true)
          qs.memo_state = 22
        end

        give_items(pc, ESSENCE_OF_DAIMON, 1)
        qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end
  end

  def on_adv_event(event, npc, pc)
    if event == "DESPAWN"
      npc = npc.not_nil!
      if daimon_spawned?
        say = NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.template.display_id, NpcString::CAN_LIGHT_EXIST_WITHOUT_DARKNESS)
        npc.broadcast_packet(say)
        npc.delete_me
      end

      return super
    end

    pc = pc.not_nil!

    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "31683-04.htm"
      take_items(pc, UNFINISHED_SUMMON_CRYSTAL, 1)
      qs.start_quest
      qs.memo_state = 11
      give_items(pc, SUMMON_CRYSTAL, 1)
      html = event
    when "31683-07.html"
      if has_quest_items?(pc, ESSENCE_OF_DAIMON)
        random = rand(1000)
        take_items(pc, ESSENCE_OF_DAIMON, 1)
        if random < 167
          reward = DYE_I2M2_C
        elsif random < 334
          reward = DYE_I2W2_C
        elsif random < 501
          reward = DYE_M2I2_C
        elsif random < 668
          reward = DYE_M2W2_C
        elsif random < 835
          reward = DYE_W2I2_C
        else
          reward = DYE_W2M2_C
        end

        reward_items(pc, reward, 5)
        qs.exit_quest(true, true)
        html = event
      else
        html = "31683-08.html"
      end
    when "31541-02.html"
      if has_quest_items?(pc, SUMMON_CRYSTAL)
        if !daimon_spawned?
          npc = npc.not_nil!
          take_items(pc, SUMMON_CRYSTAL, 1)
          html = event
          add_spawn(DAIMON_THE_WHITE_EYED, DAIMON_THE_WHITE_EYED_LOC)
          npc.delete_me
          qs.memo_state = 21
          qs.set_cond(2, true)
        else
          html = "31541-03.html"
        end
      else
        html = "31541-04.html"
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    execute_for_each_player(killer, npc, is_summon, true, false)
    super
  end

  def on_spawn(npc)
    start_quest_timer("DESPAWN", 1200000, npc, nil)
    npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.template.display_id, NpcString::WHO_IS_CALLING_ME))

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    if qs.created?
      if pc.level < MIN_LEVEL
        html = "31683-01.htm"
      elsif !has_quest_items?(pc, UNFINISHED_SUMMON_CRYSTAL)
        html = "31683-02.htm"
      else
        html = "31683-03.htm"
      end
    elsif qs.started?
      if npc.id == EYE_OF_ARGOS
        if qs.memo_state?(11)
          html = "31683-05.html"
        elsif qs.memo_state >= 22
          if has_quest_items?(pc, ESSENCE_OF_DAIMON)
            html = "31683-06.html"
          else
            html = "31683-09.html"
          end
        end
      else
        if qs.memo_state?(11)
          if has_quest_items?(pc, SUMMON_CRYSTAL)
            html = "31541-01.html"
          end
        elsif qs.memo_state?(21)
          if !daimon_spawned?
            add_spawn(DAIMON_THE_WHITE_EYED, DAIMON_THE_WHITE_EYED_LOC)
            npc.delete_me
            html = "31541-02.html"
          else
            html = "31541-03.html"
          end
        elsif qs.memo_state >= 22
          html = "31541-05.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end

  private def daimon_spawned? : Bool
    !!SpawnTable.find_any(DAIMON_THE_WHITE_EYED)
  end
end
