require "../known_list/trap_known_list"
require "../tasks/trap/trap_task"
require "../tasks/trap/trap_trigger_task"
require "../tasks/trap/trap_unsummon_task"
require "../../../enums/trap_action"

class L2TrapInstance < L2Npc
  private TICK = 1000

  @players_who_detected_me = [] of Int32
  @owner : L2PcInstance?
  @trap_task : Runnable::PeriodicTask?
  @skill : SkillHolder?
  @in_arena = false
  getter life_time : Int32 = 0
  getter? triggered = false
  property remaining_time : Int32 = 0
  property? has_life_time : Bool = false

  def initialize(template : L2NpcTemplate, instance_id : Int32, life_time : Int32)
    super(template)

    @skill = template.parameters.get_object("trap_skill", SkillHolder)
    @has_life_time = life_time >= 0
    @life_time = life_time != 0 ? life_time : 30_000
    @remaining_time = @life_time


    if @skill
      task = TrapTask.new(self)
      @trap_task = ThreadPoolManager.schedule_general_at_fixed_rate(task, TICK, TICK)
    end
  end

  def initialize(template : L2NpcTemplate, @owner : L2PcInstance, life_time : Int32)
    initialize(template, owner.instance_id, life_time)
  end

  def initialize(template : L2NpcTemplate)
    super
    raise "This constructor must not be called"
  end

  def owner? : L2PcInstance?
    @owner
  end

  def owner : L2PcInstance
    @owner.not_nil!
  end

  def acting_player? : L2PcInstance?
    @owner
  end

  def instance_type : InstanceType
    InstanceType::L2TrapInstance
  end

  def broadcast_packet(gsp : GameServerPacket)
    known_list.known_players.each_value do |pc|
      if @triggered || can_be_seen?(pc)
        pc.send_packet(gsp)
      end
    end
  end

  def broadcast_packet(gsp : GameServerPacket, radius : Number)
    known_list.known_players.each_value do |pc|
      if inside_radius?(pc, radius, false, false)
        if @triggered || can_be_seen?(pc)
          pc.send_packet(gsp)
        end
      end
    end
  end

  def can_be_seen?(char : L2Character?) : Bool
    if char && @players_who_detected_me.includes?(char.l2id)
      return true
    end

    unless char && @owner
      return false
    end

    if char == owner
      return true
    end

    if char.is_a?(L2PcInstance)
      if char.in_observer_mode?
        return false
      end

      if owner.in_olympiad_mode? && char.in_olympiad_mode?
        if char.olympiad_side != owner.olympiad_side
          return false
        end
      end
    end

    if @in_arena
      return true
    end

    if owner.in_party? && char.in_party?
      if owner.party.leader_l2id == char.party.leader_l2id
        return true
      end
    end

    false
  end

  def check_target(target : L2Character) : Bool
    unless target.inside_radius?(self, 150, false, false)
      return false
    end

    unless Skill.check_for_area_offensive_skills(self, target, skill, @in_arena)
      return false
    end

    if target.player? && target.acting_player.in_observer_mode?
      return false
    end

    if @owner && owner.in_olympiad_mode?
      pc = target.acting_player?
      if pc && pc.in_olympiad_mode? && pc.olympiad_side == owner.olympiad_side
        return false
      end
    end

    if @in_arena
      return true
    end

    if @owner
      if target.attackable?
        return true
      end

      pc = target.acting_player?
      if pc && pc.pvp_flag == 0 && pc.karma == 0
        return false
      end
    end

    true
  end

  def delete_me
    if owner = @owner
      owner.trap = nil
      @owner = nil
    end

    super
  end

  def active_weapon_item? : L2Weapon?
    # return nil
  end

  def secondary_weapon_instance? : L2ItemInstance?
    # return nil
  end

  def secondary_weapon_item? : L2Weapon?
    # return nil
  end

  def karma
    @owner.try &.karma || 0
  end

  def pvp_flag
    @owner.try &.pvp_flag || 0
  end

  def skill
    @skill.not_nil!.skill
  end

  def init_known_list
    @known_list = TrapKnownList.new(self)
  end

  def auto_attackable?(attacker : L2Character) : Bool
    !can_be_seen?(attacker)
  end

  def trap? : Bool
    true
  end

  def on_spawn
    super

    @in_arena = inside_pvp_zone? && !inside_siege_zone?
    @players_who_detected_me.clear
  end

  def send_damage_message(target, damage, mcrit, pcrit, miss)
    if miss || @owner.nil?
      return
    end

    if owner.in_olympiad_mode? && target.is_a?(L2PcInstance)
      if target.in_olympiad_mode?
        if target.olympiad_game_id == owner.olympiad_game_id
          OlympiadGameManager.notify_competitor_damage(owner, damage.to_i)
        end
      end
    end

    if target.invul? || target.hp_blocked? && !target.npc?
      owner.send_packet(SystemMessageId::ATTACK_WAS_BLOCKED)
    else
      sm = SystemMessage.c1_done_s3_damage_to_c2
      sm.add_char_name(self)
      sm.add_char_name(target)
      sm.add_int(damage)
      owner.send_packet(sm)
    end
  end

  def send_info(pc : L2PcInstance)
    if @triggered || can_be_seen?(pc)
      pc.send_packet(TrapInfo.new(self, pc))
    end
  end

  def set_detected(detector : L2Character)
    if @in_arena
      if detector.playable?
        send_info(detector.acting_player)
      end

      return
    end

    if @owner && owner.pvp_flag == 0 && owner.karma == 0
      return
    end

    @players_who_detected_me << detector.l2id

    OnTrapAction.new(self, detector, TrapAction::DETECTED).async(self)

    if detector.playable?
      send_info(detector.acting_player)
    end
  end

  def stop_decay
    DecayTaskManager.cancel(self)
  end

  def trigger_trap(target : L2Character)
    if task = @trap_task
      task.cancel
      @trap_task = nil
    end

    @triggered = true
    broadcast_packet(TrapInfo.new(self, nil))
    self.target = target

    OnTrapAction.new(self, target, TrapAction::TRIGGERED).async(self)

    task = TrapTriggerTask.new(self)
    ThreadPoolManager.schedule_general(task, 500)
  end

  def unsummon
    if task = @trap_task
      task.cancel
      @trap_task = nil
    end

    if owner = @owner
      owner.trap = nil
      @owner = nil
    end

    if visible? && !dead?
      world_region?.try &.remove_from_zones(self)
      delete_me
    end
  end

  def update_abnormal_effect
    # no-op
  end
end
