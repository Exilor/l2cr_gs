class Scripts::Venom < AbstractNpcAI
  private CASTLE = 8 # Rune

  private VENOM = 29054
  private TELEPORT_CUBE = 29055
  private DUNGEON_KEEPER = 35506

  private ALIVE = 0
  private DEAD = 1

  private HOURS_BEFORE = 24

  private TARGET_TELEPORTS = {
    Location.new(12860, -49158, 976),
    Location.new(14878, -51339, 1024),
    Location.new(15674, -49970, 864),
    Location.new(15696, -48326, 864),
    Location.new(14873, -46956, 1024),
    Location.new(12157, -49135, -1088),
    Location.new(12875, -46392, -288),
    Location.new(14087, -46706, -288),
    Location.new(14086, -51593, -288),
    Location.new(12864, -51898, -288),
    Location.new(15538, -49153, -1056),
    Location.new(17001, -49149, -1064)
  }

  private  TRHONE = Location.new(11025, -49152, -537)
  private  DUNGEON = Location.new(11882, -49216, -3008)
  private  TELEPORT = Location.new(12589, -49044, -3008)
  private  CUBE = Location.new(12047, -49211, -3009)

  private VENOM_STRIKE = SkillHolder.new(4993)
  private SONIC_STORM = SkillHolder.new(4994)
  private VENOM_TELEPORT = SkillHolder.new(4995)
  private RANGE_TELEPORT = SkillHolder.new(4996)

  private TARGET_TELEPORTS_OFFSET = {
    650, 100, 100, 100, 100, 650, 200, 200, 200, 200, 200, 650
  }
  private TARGETS = [] of L2PcInstance

  enum MoveTo : UInt8
    THRONE
    PRISON
  end

  @venom : L2Npc?
  @massymore : L2Npc?
  @loc : Location?
  @aggro_mode = false
  @prison_is_open = false

  def initialize
    super(self.class.simple_name, "ai/individual")

    add_start_npc(DUNGEON_KEEPER, TELEPORT_CUBE)
    add_first_talk_id(DUNGEON_KEEPER, TELEPORT_CUBE)
    add_talk_id(DUNGEON_KEEPER, TELEPORT_CUBE)
    add_spawn_id(VENOM, DUNGEON_KEEPER)
    add_spell_finished_id(VENOM)
    add_attack_id(VENOM)
    add_kill_id(VENOM)
    add_aggro_range_enter_id(VENOM)
    set_castle_siege_start_id(CASTLE, &->on_siege_start(OnCastleSiegeStart))
    set_castle_siege_finish_id(CASTLE, &->on_siege_finish(OnCastleSiegeFinish))

    current_time = Time.ms
    start_siege_date = CastleManager.get_castle_by_id(CASTLE).not_nil!.siege_date.ms
    opening_date = start_siege_date - (HOURS_BEFORE * 360_000)
    if current_time > opening_date && current_time < start_siege_date
      @prison_is_open = true
    end
  end

  def on_talk(npc, talker)
    case npc.id
    when TELEPORT_CUBE
      talker.tele_to_location(TeleportWhereType::TOWN)
    when DUNGEON_KEEPER
      if @prison_is_open
        talker.tele_to_location(TELEPORT)
      else
        return "35506-02.html"
      end
    end

    super
  end

  def on_adv_event(event, npc, pc)
    case event
    when "tower_check"
      if CastleManager.get_castle_by_id(CASTLE).not_nil!.siege.control_tower_count <= 1
        change_location(MoveTo::THRONE)
        broadcast_npc_say(@massymore.not_nil!, Say2::NPC_SHOUT, NpcString::OH_NO_THE_DEFENSES_HAVE_FAILED_IT_IS_TOO_DANGEROUS_TO_REMAIN_INSIDE_THE_CASTLE_FLEE_EVERY_MAN_FOR_HIMSELF)
        cancel_quest_timer("tower_check", npc, nil)
        start_quest_timer("raid_check", 10_000, npc, nil, true)
      end
    when "raid_check"
      npc = npc.not_nil!
      if !npc.inside_siege_zone? && !npc.teleporting?
        npc.tele_to_location(@loc.not_nil!)
      end
    when "cube_despawn"
      if npc
        npc.delete_me
      end
    end

    event
  end

  def on_aggro_range_enter(npc, pc, is_summon)
    if is_summon
      return super
    end

    if @aggro_mode && TARGETS.size < 10 && Rnd.rand(3) < 1 && pc.alive?
      TARGETS << pc
    end

    super
  end

  def on_siege_start(event : OnCastleSiegeStart)
    @aggro_mode = true
    @prison_is_open = false
    if (venom = @venom) && venom.alive?
      venom.current_hp = venom.max_hp.to_f
      venom.current_mp = venom.max_mp.to_f
      venom.enable_skill(VENOM_TELEPORT.skill)
      venom.enable_skill(RANGE_TELEPORT.skill)
      start_quest_timer("tower_check", 30_000, venom, nil, true)
    end
  end

  def on_siege_finish(event : OnCastleSiegeFinish)
    @aggro_mode = false
    if (venom = @venom) && venom.alive?
      change_location(MoveTo::PRISON)
      venom.disable_skill(VENOM_TELEPORT.skill, -1)
      venom.disable_skill(RANGE_TELEPORT.skill, -1)
    end
    update_status(ALIVE)
    cancel_quest_timer("tower_check", @venom, nil)
    cancel_quest_timer("raid_check", @venom, nil)
  end

  def on_spell_finished(npc, pc, skill)
    case skill.id
    when 4222
      npc.tele_to_location(@loc.not_nil!)
    when 4995
      teleport_target(pc)
      npc.as(L2Attackable).stop_hating(pc)
    when 4996
      teleport_target(pc)
      npc.as(L2Attackable).stop_hating(pc)
      unless TARGETS.empty?
        TARGETS.each do |target|
          x = pc.x - target.x
          y = pc.y - target.y
          z = pc.z - target.z
          range = 250
          if x.abs2 + y.abs2 + z.abs2 <= range.abs2
            teleport_target(target)
            npc.as(L2Attackable).stop_hating(target)
          end
        end
        TARGETS.clear
      end
    end

    super
  end

  def on_spawn(npc)
    case npc.id
    when DUNGEON_KEEPER
      @massymore = npc
    when VENOM
      npc = npc.as(L2Attackable)
      @venom = npc

      @loc = npc.location
      npc.disable_skill(VENOM_TELEPORT.skill, -1)
      npc.disable_skill(RANGE_TELEPORT.skill, -1)
      npc.do_revive
      broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::WHO_DARES_TO_COVET_THE_THRONE_OF_OUR_CASTLE_LEAVE_IMMEDIATELY_OR_YOU_WILL_PAY_THE_PRICE_OF_YOUR_AUDACITY_WITH_YOUR_VERY_OWN_BLOOD)
      npc.can_return_to_spawn_point = false
      if check_status == DEAD
        npc.delete_me
      end
    end

    if check_status == DEAD
      npc.delete_me
    else
      npc.do_revive
    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon)
    distance = npc.calculate_distance(attacker, false, false)
    if @aggro_mode && Rnd.rand(100) < 25
      npc.target = attacker
      npc.do_cast(VENOM_TELEPORT)
    elsif @aggro_mode && npc.current_hp < npc.max_hp / 3 && Rnd.rand(100) < 25 && !npc.casting_now?
      npc.target = attacker
      npc.do_cast(RANGE_TELEPORT)
    elsif distance > 300 && Rnd.rand(100) < 10 && !npc.casting_now?
      npc.target = attacker
      npc.do_cast(VENOM_STRIKE)
    elsif Rnd.rand(100) < 10 && !npc.casting_now?
      npc.target = attacker
      npc.do_cast(SONIC_STORM)
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    update_status(DEAD)
    broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::ITS_NOT_OVER_YET_IT_WONT_BE_OVER_LIKE_THIS_NEVER)
    unless CastleManager.get_castle_by_id(CASTLE).not_nil!.siege.in_progress?
      cube = add_spawn(TELEPORT_CUBE, CUBE, false, 0)
      start_quest_timer("cube_despawn", 120000, cube, nil)
    end
    cancel_quest_timer("raid_check", npc, nil)

    super
  end

  private def change_location(loc)
    case loc
    when MoveTo::THRONE
      @venom.not_nil!.tele_to_location(TRHONE, false)
    when MoveTo::PRISON
      venom = @venom
      if venom.nil? || (venom.dead? || venom.decayed?)
        @venom = add_spawn(VENOM, DUNGEON, false, 0)
      else
        venom.tele_to_location(DUNGEON, false)
      end
      cancel_quest_timer("raid_check", @venom, nil)
      cancel_quest_timer("tower_check", @venom, nil)
    end


    @loc.not_nil!.location = @venom.not_nil!.location
  end

  private def teleport_target(pc)
    if pc && pc.alive?
      rnd = Rnd.rand(11)
      pc.tele_to_location(TARGET_TELEPORTS[rnd], TARGET_TELEPORTS_OFFSET[rnd])
      pc.set_intention(AI::IDLE)
    end
  end

  private def check_status
    status = ALIVE

    if GlobalVariablesManager.instance.has_key?("VenomStatus")
      status = GlobalVariablesManager.instance.get_i32("VenomStatus")
    else
      GlobalVariablesManager.instance["VenomStatus"] = 0
    end

    status
  end

  private def update_status(status)
    GlobalVariablesManager.instance["VenomStatus"] = status.to_s
  end
end
