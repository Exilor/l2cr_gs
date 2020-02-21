require "../l2_object"
require "../interfaces/skills_holder"
require "./stat/char_stat"
require "./status/char_status"
require "./known_list/char_known_list"
require "./ai/l2_character_ai"
require "../holders/invul_skill_holder"
require "../time_stamp"
require "./tasks/character/*"
require "../../enums/zone_id"
require "../../enums/team"
require "../../enums/pc_cond_override"
require "../../enums/effect_flag"
require "../../enums/teleport_where_type"
require "../stats/calculator"
require "../stats/formulas"
require "../char_effect_list"
require "../skills/skill_channelized"
require "../skills/skill_channelizer"
require "./instance/l2_raid_boss_instance"

abstract class L2Character < L2Object
  include SkillsHolder

  MAX_HP_BAR_PX = 352.0

  @hp_update_inc_check = 0.0
  @hp_update_dec_check = 0.0
  @hp_update_interval  = 0.0
  @zones = Bytes.new(ZoneId.size)
  @zones_mutex = Mutex.new(:Reentrant)
  @zone_validate_counter = 4i8
  @teleport_lock = Mutex.new(:Reentrant)
  @invul_against_skills : IHash(Int32, InvulSkillHolder)?
  @reuse_time_stamp_items : IHash(Int32, TimeStamp)?
  @reuse_time_stamp_skills : IHash(Int32, TimeStamp)?
  @disabled_skills : IHash(Int32, Int64)?
  @trigger_skills : IHash(Int32, OptionsSkillHolder)?
  @all_skills_disabled : Bool = false
  @ai : L2CharacterAI?
  @exceptions = 0i64
  @move : MoveData?
  @skill_cast_2 : Scheduler::DelayedTask?
  @attack_by_list : ISet(L2Character)?

  getter title : String = ""
  getter cast_interrupt_time = 0i64
  getter skills : IHash(Int32, Skill) = Concurrent::Map(Int32, Skill).new
  getter abnormal_visual_effects = 0
  getter abnormal_visual_effects_special = 0
  getter abnormal_visual_effects_event = 0
  getter cast_interrupt_time = 0
  getter target : L2Object?
  getter calculators : Slice(Calculator?)
  getter(skill_channelizer) { SkillChannelizer.new(self) }
  getter(skill_channelized) { SkillChannelized.new }
  getter! stat : CharStat
  getter! status : CharStatus
  getter? running = false
  getter? core_ai_disabled = false
  setter paralyzed : Bool = false
  setter pending_revive : Bool = false
  setter skill_cast : Scheduler::DelayedTask?
  setter invul : Bool = false
  property attack_end_time : Int64 = 0i64
  property bow_attack_end_time : Int32 = 0
  property cross_bow_attack_end_time : Int64 = 0i64
  property debugger : L2Character?
  property last_skill_cast : Skill?
  property last_simultaneous_skill_cast : Skill?
  property team : Team = Team::NONE
  property summoner : L2Character?
  property! template : L2CharTemplate
  property? lethalable : Bool = true
  property? casting_now : Bool = false
  property? casting_simultaneously_now : Bool = false
  property? dead : Bool = false
  property? mortal : Bool = true
  property? overloaded : Bool = false
  property? teleporting : Bool = false
  property? immobilized : Bool = false
  property? no_rnd_walk : Bool = false
  property? flying : Bool = false
  property? show_summon_animation : Bool = false

  def initialize(template : L2CharTemplate)
    initialize(IdFactory.next, template)
  end

  def initialize(l2id : Int32, @template : L2CharTemplate)
    super(l2id)

    init_char_stat
    init_char_status

    if door?
      @calculators = Formulas.std_door_calculators
    elsif npc?
      @calculators = Formulas.npc_std_calculators
    else
      @calculators = Slice.new(Stats.size, nil.as(Calculator?))
    end

    self.invul = true
  end

  def instance_type : InstanceType
    InstanceType::L2Character
  end

  private def init_ai : L2CharacterAI
    L2CharacterAI.new(self)
  end

  def ai : L2CharacterAI
    @ai ||= init_ai
  end

  def ai? : Bool
    !!@ai
  end

  def ai=(new_ai : L2CharacterAI?)
    ai = @ai

    if ai.is_a?(L2AttackableAI) && ai != new_ai
      ai.stop_ai_task
    end

    @ai = new_ai
  end

  private def init_known_list
    @known_list = CharKnownList.new(self)
  end

  private def init_char_stat
    @stat = CharStat.new(self)
  end

  private def init_char_status
    @status = CharStatus.new(self)
  end

  private def init_char_status_update_values
    @hp_update_inc_check = max_hp.to_f
    @hp_update_interval = @hp_update_inc_check / MAX_HP_BAR_PX
    @hp_update_dec_check = @hp_update_inc_check - @hp_update_interval
  end

  def effect_list : CharEffectList
    @effect_list ||= CharEffectList.new(self)
  end

  def known_list : CharKnownList
    super.as(CharKnownList)
  end

  def world_region=(new_region : L2WorldRegion?)
    if old_region = world_region
      if new_region
        old_region.revalidate_zones(self)
      else
        old_region.remove_from_zones(self)
      end
    end

    super
  end

  def summon : L2Summon?
    # return nil
  end

  def has_summon? : Bool
    !!summon
  end

  def has_pet? : Bool
    smn = summon()
    !!smn && smn.pet?
  end

  def has_servitor? : Bool
    smn = summon()
    !!smn && smn.servitor?
  end

  def broadcast_packet(gsp : GameServerPacket)
    gsp.invisible = invisible?
    known_list.known_players.each_value &.send_packet(gsp)
  end

  def broadcast_packet(gsp : GameServerPacket, radius : Number)
    gsp.invisible = invisible?
    known_list.known_players.each_value do |pc|
      if inside_radius?(pc, radius, false, false)
        pc.send_packet(gsp)
      end
    end
  end

  def need_hp_update? : Bool
    current_hp = current_hp()
    max_hp = max_hp()

    return true if current_hp <= 1 || max_hp < MAX_HP_BAR_PX

    if current_hp < @hp_update_dec_check || (current_hp - @hp_update_dec_check).abs <= 1e-6 || current_hp > @hp_update_inc_check || (current_hp - @hp_update_inc_check).abs <= 1e-6
      if (current_hp - max_hp).abs <= 1e-6
        @hp_update_inc_check = current_hp + 1
        @hp_update_dec_check = current_hp - @hp_update_interval
      else
        double_multi = current_hp / @hp_update_interval

        if double_multi.infinite?
          warn { "L2Character#need_hp_update? double_multi is infinite. current_hp: #{current_hp}, @hp_update_interval: #{@hp_update_interval}." }
          return current_hp < max_hp # custom crappy fix
        end

        int_multi = double_multi.to_i

        @hp_update_dec_check = @hp_update_interval * (double_multi < int_multi ? int_multi - 1 : int_multi)
        @hp_update_inc_check = @hp_update_dec_check + @hp_update_interval
      end

      return true
    end

    false
  end

  def send_message(msg : String)
    # no-op
  end

  def action_failed
    acting_player.try &.send_packet(ActionFailed::STATIC_PACKET)
  end

  def on_decay
    decay_me
    world_region.try &.remove_from_zones(self)
  end

  def on_spawn
    super
    revalidate_zone(true)
  end

  def on_teleported
    @teleport_lock.synchronize do
      return unless teleporting?
      spawn_me(*xyz)
      self.teleporting = false
      OnCreatureTeleported.new(self).async(self)
    end
  end

  def delete_me : Bool
    self.debugger = nil

    if ai?
      ai.stop_ai_task
    end

    true
  end

  def detach_ai
    unless walker?
      self.ai = nil
    end
  end

  def attack_by_list : ISet(L2Character)
    @attack_by_list || sync do
      @attack_by_list ||= Concurrent::Set(L2Character).new
    end
  end

  def trigger_skills : IHash(Int32, OptionsSkillHolder)
    @trigger_skills || sync do
      @trigger_skills ||= Concurrent::Map(Int32, OptionsSkillHolder).new
    end
  end

  def invul_against_skills : IHash(Int32, InvulSkillHolder)
    @invul_against_skills || sync do
      @invul_against_skills ||= Concurrent::Map(Int32, InvulSkillHolder).new
    end
  end

  def add_skill(skill : Skill?) : Skill?
    old_skill = nil

    if skill
      old_skill = @skills[skill.id]?
      @skills[skill.id] = skill

      if old_skill
        remove_stats_owner(old_skill)

        if old_skill.passive?
          stop_skill_effects(false, old_skill.id)
        end
      end

      add_stat_funcs(skill.get_stat_funcs(nil, self))

      if skill.passive?
        skill.apply_effects(self, self, false, true, false, 0)
      end
    end

    old_skill
  end

  def remove_skill(skill : Skill?, cancel_effect : Bool) : Skill?
    if skill
      remove_skill(skill.id, cancel_effect)
    end
  end

  def remove_skill(id : Int32) : Skill?
    remove_skill(id, true)
  end

  def remove_skill(id : Int32, cancel_effect : Bool) : Skill?
    if old_skill = @skills.delete(id)
      debug { "L2Character#remove_skill: Removed #{old_skill}." }
      if last_skill_cast && casting_now?
        if old_skill.id == last_skill_cast.not_nil!.id
          abort_cast
        end
      end

      if last_simultaneous_skill_cast && casting_simultaneously_now?
        if old_skill.id == last_simultaneous_skill_cast.not_nil!.id
          abort_cast
        end
      end

      if cancel_effect || old_skill.toggle? || old_skill.passive?
        remove_stats_owner(old_skill)
        stop_skill_effects(false, old_skill.id)
      end
    end

    old_skill
  end

  def get_known_skill(id : Int) : Skill?
    @skills[id]?
  end

  def get_skill_level(id : Int32) : Int32
    get_known_skill(id).try &.level || -1
  end

  def add_trigger_skill(holder : OptionsSkillHolder)
    trigger_skills[holder.skill_id] = holder
  end

  def remove_trigger_skill(holder : OptionsSkillHolder)
    trigger_skills.delete(holder.skill_id)
  end

  def add_time_stamp_item(item : L2ItemInstance, reuse : Int64)
    add_time_stamp_item(item, reuse, -1)
  end

  def add_time_stamp_item(item : L2ItemInstance, reuse : Int64, time : Int64)
    unless temp = @reuse_time_stamp_items
      temp = sync do
        @reuse_time_stamp_items ||= Concurrent::Map(Int32, TimeStamp).new
      end
    end

    temp[item.l2id] = TimeStamp.new(item, reuse, time)
  end

  def get_item_remaining_reuse_time(item_l2id : Int32) : Int64
    sync do
      # if temp = @reuse_time_stamp_items
      #   if temp2 = temp[item_l2id]
      #     temp2.remaining
      #   else
      #     -1i64
      #   end
      # else
      #   -1i64
      # end

      @reuse_time_stamp_items.try &.[item_l2id]?.try &.remaining || -1i64
    end
  end

  def get_reuse_delay_on_group(group : Int32) : Int64
    if group > 0
      @reuse_time_stamp_items.try &.each_value do |ts|
        if ts.shared_reuse_group == group && ts.has_not_passed?
          return ts.remaining
        end
      end
    end

    -1i64
  end

  def item_reuse_time_stamps : IHash(Int32, TimeStamp)?
    @reuse_time_stamp_items
  end

  def add_time_stamp(skill : Skill, reuse : Int64)
    add_time_stamp(skill, reuse, -1)
  end

  def add_time_stamp(skill : Skill, reuse : Int64, time : Int64)
    unless temp = @reuse_time_stamp_skills
      sync do
        temp = @reuse_time_stamp_skills ||= Concurrent::Map(Int32, TimeStamp).new
      end
    end

    temp.not_nil![skill.hash] = TimeStamp.new(skill, reuse, time)
  end

  def skill_reuse_time_stamps : IHash(Int32, TimeStamp)?
    @reuse_time_stamp_skills
  end

  def remove_time_stamp(skill : Skill)
    sync { @reuse_time_stamp_skills.try &.delete(skill.hash) }
  end

  def reset_time_stamps
    sync { @reuse_time_stamp_skills.try &.clear }
  end

  def get_skill_remaining_reuse_time(hash : Int32) : Int64
    sync { @reuse_time_stamp_skills.try &.[hash]?.try &.remaining || -1i64 }
  end

  def has_skill_reuse?(hash : Int32) : Bool?
    sync do
      return false unless temp = @reuse_time_stamp_skills
      temp[hash]?.try &.has_not_passed? || false
    end
  end

  def get_skill_reuse_time_stamp(hash : Int32) : TimeStamp?
    sync do
      if temp = @reuse_time_stamp_skills
        temp[hash]?
      end
    end
  end

  def disable_skill(skill : Skill?, delay : Int64)
    return unless skill

    unless @disabled_skills
      sync { @disabled_skills ||= Concurrent::Map(Int32, Int64).new }
    end

    delay = delay > 0 ? Time.ms + delay : Int64::MAX
    @disabled_skills.not_nil![skill.hash] = delay
  end

  def enable_skill(skill : Skill?)
    if skill
      @disabled_skills.try &.delete(skill.hash)
    end
  end

  def reset_disabled_skills
    sync { @disabled_skills.try &.clear }
  end

  def skill_disabled?(skill : Skill?) : Bool
    !!skill && skill_disabled?(skill.hash)
  end

  def skill_disabled?(hash : Int32) : Bool
    if all_skills_disabled?
      return true
    end

    if all_skills_disabled?
      return true
    end

    unless temp = @disabled_skills
      return false
    end

    unless stamp = temp[hash]?
      return false
    end

    if stamp < Time.ms
      temp.delete(hash)
      return false
    end

    true
  end

  def disable_all_skills
    @all_skills_disabled = true
  end

  def enable_all_skills
    @all_skills_disabled = false
  end

  def can_revive? : Bool
    true
  end

  def can_revive=(val : Bool)
    # no-op
  end

  def pending_revive? : Bool
    dead? && @pending_revive
  end

  def do_revive(revive_power : Float64)
    do_revive
  end

  def do_revive
    return unless dead?

    if !teleporting?
      self.pending_revive = false
      self.dead = false

      if Config.respawn_restore_cp > 0 && current_cp < max_cp * Config.respawn_restore_cp
        status.current_cp = max_cp * Config.respawn_restore_cp
      end

      if Config.respawn_restore_hp > 0 && current_hp < max_hp * Config.respawn_restore_hp
        status.current_hp = max_hp * Config.respawn_restore_hp
      end

      if Config.respawn_restore_mp > 0 && current_mp < max_mp * Config.respawn_restore_mp
        status.current_mp = max_mp * Config.respawn_restore_mp
      end

      broadcast_packet(Revive.new(self))

      world_region.try &.on_revive(self)
    else
      self.pending_revive = true
    end
  end

  def on_forced_attack(pc : L2PcInstance)
    if inside_peace_zone?(pc)
      pc.send_packet(SystemMessageId::TARGET_IN_PEACEZONE)
      pc.action_failed
      return
    end

    if pc.in_olympiad_mode? && pc.target.try &.playable?
      target = pc.target.as?(L2PcInstance)

      if target.nil? || (target.in_olympiad_mode? && (!pc.olympiad_start? || pc.olympiad_game_id != target.olympiad_game_id))
        pc.action_failed
        return
      end
    end

    if target = pc.target
      if !target.can_be_attacked? && !pc.access_level.allow_peace_attack?
        pc.action_failed
        return
      end
    end

    if pc.confused?
      pc.action_failed
      return
    end

    unless GeoData.can_see_target?(pc, self)
      pc.send_packet(SystemMessageId::CANT_SEE_TARGET)
      pc.action_failed
      return
    end

    if pc.block_checker_arena != -1
      pc.action_failed
      return
    end

    pc.set_intention(AI::ATTACK, self)
  end

  def do_die(killer : L2Character?) : Bool
    if killer # custom
      evt = OnCreatureKill.new(killer, self)
      term = EventDispatcher.notify(evt, self, TerminateReturn)
      if term && term.terminate
        return false
      end
    end

    sync do
      if dead?
        return false
      end

      set_current_hp(0)
      self.dead = true
    end

    self.target = nil

    stop_move(nil)

    stop_hp_mp_regeneration

    stop_all_effects_except_those_that_last_through_death

    calculate_rewards(killer)

    broadcast_status_update

    if ai?
      notify_event(AI::DEAD)
    end

    world_region.try &.on_death(self)

    attack_by_list.try &.clear

    if channelized?
      skill_channelized.abort_channelization
    end

    true
  end

  def calculate_rewards(killer : L2Character?)
    # no-op
  end

  def add_attacker_to_attack_by_list(player : L2Character?)
    # no-op
  end

  def get_listeners(type : EventType) : Indexable(AbstractEventListener)
    object_listeners = super
    template_listeners = template.get_listeners(type)

    global_listeners = npc? && !monster? ?
    Containers::NPCS.get_listeners(type) : monster? ?
    Containers::MONSTERS.get_listeners(type) : player? ?
    Containers::PLAYERS.get_listeners(type) : [] of AbstractEventListener

    object_empty = object_listeners.empty?
    template_empty = template_listeners.empty?
    global_empty = global_listeners.empty?

    case
    when object_empty && template_empty && global_empty
      Slice(AbstractEventListener).empty
    when !object_empty && template_empty && global_empty
      object_listeners
    when !template_empty && object_empty && global_empty
      template_listeners
    when !global_empty && object_empty && template_empty
      global_listeners
    else
      deq_size = object_listeners.size + template_listeners.size
      deq_size += global_listeners.size
      ret = Deque(AbstractEventListener).new(deq_size)
      ret.concat(object_listeners)
      ret.concat(template_listeners)
      ret.concat(global_listeners)
      ret
    end
  end

  def gm? : Bool
    false
  end

  def in_duel? : Bool
    false
  end

  def duel_id : Int32
    0
  end

  def siege_state : Int8
    0i8
  end

  def siege_side : Int32
    0
  end

  def check_and_equip_arrows : Bool
    true
  end

  def check_and_equip_bolts : Bool
    true
  end

  def add_exp_and_sp(add_to_exp : Int64, add_to_sp : Int32)
    # no-op
  end

  def reduce_arrow_count(bolts : Bool)
    # no-op
  end

  def notify_quest_event_skill_finished(skill : Skill, target : L2Object?)
    # no-op
  end

  def behind?(target : L2Object?) : Bool
    return false unless target

    max_angle_diff = 60.0

    if target.character?
      angle_char = Util.calculate_angle_from(self, target)
      angle_target = Util.convert_heading_to_degree(target.heading)
      angle_diff = angle_char - angle_target

      if angle_diff <= -360 + max_angle_diff
        angle_diff += 360
      end

      if angle_diff >= 360 - max_angle_diff
        angle_diff -= 360
      end

      if angle_diff.abs <= max_angle_diff
        return true
      end
    end

    false
  end

  def behind_target? : Bool
    behind?(target)
  end

  def in_front_of?(target : L2Object?) : Bool
    return false unless target

    max_angle_diff = 60.0

    angle_target = Util.calculate_angle_from(target, self)
    angle_char = Util.convert_heading_to_degree(target.heading)
    angle_diff = angle_char - angle_target

    if angle_diff <= -360 + max_angle_diff
      angle_diff += 360
    end

    if angle_diff >= 360 - max_angle_diff
      angle_diff -= 360
    end

    angle_diff.abs <= max_angle_diff
  end

  def in_front_of_target? : Bool
    target = target()
    target.is_a?(L2Character) && in_front_of?(target)
  end

  def facing?(target : L2Object?, max_angle : Int32) : Bool
    return false unless target

    max_angle_diff = max_angle.fdiv(2)
    angle_target = Util.calculate_angle_from(self, target)
    angle_char = Util.convert_heading_to_degree(heading)
    angle_diff = angle_char - angle_target
    angle_diff += 360 if angle_diff <= -360 + max_angle_diff
    angle_diff -= 360 if angle_diff >= 360 - max_angle_diff
    angle_diff.abs <= max_angle_diff
  end

  def add_stat_func(function : AbstractFunction)
    sync do
      if @calculators == Formulas.npc_std_calculators
        @calculators = Formulas.npc_std_calculators.map do |calc|
          if calc
            Calculator.new(calc)
          end
        end
      end

      calc = @calculators[function.stat.to_i] ||= Calculator.new
      calc.add_func(function)
    end
  end

  def add_stat_funcs(functions : Enumerable(AbstractFunction))
    if !player? && known_list.known_players.empty?
      functions.each { |f| add_stat_func(f) }
    else
      modified_stats = functions.map do |f|
        add_stat_func(f)
        f.stat
      end

      broadcast_modified_stats(modified_stats)
    end
  end

  def remove_stat_func(function : AbstractFunction)
    stat = function.stat.to_i

    sync do
      return unless calc = @calculators[stat]
      calc.remove_func(function)

      if calc.empty?
        @calculators[stat] = nil
      end

      j = 0
      if npc?
        Stats.size.times do |i|
          j = i
          break unless @calculators[i] == Formulas.npc_std_calculators[i]
        end

        if j >= Stats.size
          @calculators = Formulas.npc_std_calculators
        end
      end
    end
  end

  def remove_stat_funcs(functions : Enumerable(AbstractFunction))
    if !player? && known_list.known_players.empty?
      functions.each { |f| remove_stat_func(f) }
    else
      modified_stats = functions.map do |f|
        remove_stat_func(f)
        f.stat
      end

      broadcast_modified_stats(modified_stats)
    end
  end

  def remove_stats_owner(owner : Object)
    modified_stats = nil

    sync do
      @calculators.each_with_index do |calc, i|
        next unless calc
        if modified_stats
          modified_stats.concat(calc.remove_owner(owner))
        else
          modified_stats = calc.remove_owner(owner)
        end

        if calc.empty?
          @calculators[i] = nil
        end
      end

      if npc?
        j = 0
        Stats.size.times do |i|
          j = i
          unless @calculators[i] == Formulas.npc_std_calculators[i]
            break
          end
        end

        if j >= Stats.size
          @calculators = Formulas.npc_std_calculators
        end
      end

      if modified_stats
        broadcast_modified_stats(modified_stats)
      end
    end
  end

  private def broadcast_modified_stats(stat : Stats)
    broadcast_modified_stats({stat})
  end

  private def broadcast_modified_stats(stats : Indexable(Stats))
    return if stats.empty?

    me = self
    if me.is_a?(L2Summon) && me.owner
      me.update_and_broadcast_status(1)
    end

    broadcast_full = false

    su = StatusUpdate.new(self)

    stats.each do |stat|
      if stat.power_attack_speed?
        su.add_atk_spd(p_atk_spd)
      elsif stat.magic_attack_speed?
        su.add_cast_spd(m_atk_spd)
      elsif stat.move_speed?
        broadcast_full = true
      end
    end


    if me.is_a?(L2PcInstance)
      if broadcast_full
        me.update_and_broadcast_status(2)
      else
        me.update_and_broadcast_status(1)
        if su.has_attributes?
          broadcast_packet(su)
        end
      end

      summon = summon()

      if summon && affected?(EffectFlag::SERVITOR_SHARE)
        summon.broadcast_status_update
      end
    elsif me.is_a?(L2Npc)
      if broadcast_full
        known_list.known_players.each_value do |pc|
          if visible_for?(pc)
            if run_speed == 0
              pc.send_packet(ServerObjectInfo.new(me, pc))
            else
              pc.send_packet(NpcInfo.new(me, pc))
            end
          end
        end
      elsif su.has_attributes?
        broadcast_packet(su)
      end
    elsif su.has_attributes?
      broadcast_packet(su)
    end
  end

  def broadcast_social_action(id : Int32)
    broadcast_packet(SocialAction.new(l2id, id))
  end

  def broadcast_status_update
    if status.status_listener.empty?# || !need_hp_update?
      return
    end

    su = StatusUpdate.hp(self)
    status.status_listener.each &.send_packet(su)
  end

  def in_category?(category : CategoryType) : Bool
    CategoryData.in_category?(category, id)
  end

  def hp_blocked? : Bool
    affected?(EffectFlag::BLOCK_HP)
  end

  def mp_blocked? : Bool
    affected?(EffectFlag::BLOCK_MP)
  end

  def buff_blocked? : Bool
    affected?(EffectFlag::BLOCK_BUFF)
  end

  def debuff_blocked? : Bool
    affected?(EffectFlag::BLOCK_DEBUFF)
  end

  def resurrection_blocked? : Bool
    affected?(EffectFlag::BLOCK_RESURRECTION)
  end

  def undead? : Bool
    false
  end

  def target=(object : L2Object?)
    unless object && object.visible?
      object = nil
    end

    if object && object != @target
      known_list.add_known_object(object)
      object.known_list.add_known_object(self)
    end

    @target = object
  end

  def running=(bool : Bool)
    return if @running == bool # appears to work better without this

    @running = bool

    if run_speed != 0
      broadcast_packet(ChangeMoveType.new(self))
    end

    case me = self
    when L2PcInstance
      me.broadcast_user_info
    when L2Summon
      me.broadcast_status_update
    when L2Npc
      known_list.known_players.each_value do |pc|
        if visible_for?(pc)
          if run_speed == 0
            op = ServerObjectInfo.new(me, pc)
          else
            op = NpcInfo.new(me, pc)
          end

          pc.send_packet(op)
        end
      end
    end
  end

  def set_running
    unless running?
      self.running = true
    end
  end

  def set_walking
    if running?
      self.running = false
    end
  end

  def do_cast(skill : Skill)
    begin_cast(skill, false)
  end

  def do_cast(sh : SkillHolder)
    begin_cast(sh.skill, false)
  end

  def do_cast(skill : Skill, target : L2Character?, targets : Array(L2Object)?)
    unless check_do_cast_conditions(skill)
      self.casting_now = false
      return
    end

    if skill.simultaneous_cast?
      do_simultaneous_cast(skill, target, targets)
      return
    end

    stop_effects_on_action

    begin_cast(skill, false, target, targets)
  end

  def do_simultaneous_cast(skill : Skill)
    begin_cast(skill, true)
  end

  def do_simultaneous_cast(sh : SkillHolder)
    begin_cast(sh.skill, true)
  end

  def do_simultaneous_cast(skill : Skill, target : L2Character?, targets : Array(L2Object)?)
    unless check_do_cast_conditions(skill)
      self.casting_simultaneously_now = false
      return
    end

    stop_effects_on_action

    begin_cast(skill, true, target, targets)
  end

  private def begin_cast(skill : Skill, simultaneously : Bool)
    unless check_do_cast_conditions(skill)
      if simultaneously
        self.casting_simultaneously_now = false
      else
        self.casting_now = false
      end

      if player?
        set_intention(AI::ACTIVE)
      end

      return
    end
    if skill.simultaneous_cast? && !simultaneously
      simultaneously = true
    end

    stop_effects_on_action

    target = nil
    targets = skill.get_target_list(self)
    do_it = false
    do_default = false

    case skill.target_type
    when .area_summon?
      target = summon()
    when .aura?, .aura_corpse_mob?, .front_aura?, .behind_aura?, .ground?, .aura_friendly?, .aura_undead_enemy?
      target = self
    when .self?, .pet?, .servitor?, .summon?, .owner_pet?, .party?, .clan?, .party_clan?, .command_channel?
      do_it = true
      do_default = true
    else
      do_default = true
    end
    if do_default
      if targets.empty?
        if simultaneously
          self.casting_simultaneously_now = false
        else
          self.casting_now = false
        end

        if player?
          action_failed
          set_intention(AI::ACTIVE)
        end

        return
      end

      if (skill.continuous? && !skill.debuff?) || skill.has_effect_type?(EffectType::CP, EffectType::HP)
        do_it = true
      end

      if do_it
        target = targets[0]
      else
        target = target()
      end
    end

    begin_cast(skill, simultaneously, target.as(L2Character?), targets)
  end

  private def begin_cast(skill : Skill, simultaneously : Bool, target : L2Character?, targets : Array(L2Object)?)
    if target.nil?
      if simultaneously
        self.casting_simultaneously_now = false
      else
        self.casting_now = false
      end

      if player?
        action_failed
        set_intention(AI::ACTIVE)
      end

      return
    end

    event = OnCreatureSkillUse.new(self, skill, simultaneously, target, targets)
    term = EventDispatcher.notify(event, self, TerminateReturn)
    if term && term.terminate
      if simultaneously
        self.casting_simultaneously_now = false
      else
        self.casting_now = false
      end

      if player?
        action_failed
        set_intention(AI::ACTIVE)
      end

      return
    end

    # L2J wants to unhardcode this and use event listeners
    if skill.has_effect_type?(EffectType::RESURRECTION)
      if resurrection_blocked? || target.resurrection_blocked?
        send_packet(SystemMessageId::REJECT_RESURRECTION)
        target.send_packet(SystemMessageId::REJECT_RESURRECTION)

        if simultaneously
          self.casting_simultaneously_now = false
        else
          self.casting_now = false
        end

        if player?
          set_intention(AI::ACTIVE)
          action_failed
        end

        return
      end
    end

    magic_id = skill.id

    skill_anim_time = Formulas.cast_time(self, skill)

    if casting_simultaneously_now? && simultaneously
      skill2, simultaneously2, target2, targets2 = skill, simultaneously, target, targets
      task = -> { begin_cast(skill2, simultaneously2, target2, targets2) }
      ThreadPoolManager.schedule_ai(task, 100)

      return
    end

    if simultaneously
      self.casting_simultaneously_now = true
      self.last_simultaneous_skill_cast = skill
    else
      self.casting_now = true
      @cast_interrupt_time = -2 + GameTimer.ticks + (skill_anim_time / GameTimer::MILLIS_IN_TICK).to_i
      self.last_skill_cast = skill
    end

    reuse_delay =
    case
    when skill.reuse_delay_locked? || skill.static?
      skill.reuse_delay
    when skill.magic?
      (skill.reuse_delay * calc_stat(Stats::MAGIC_REUSE_RATE)).to_i
    when skill.physical?
      (skill.reuse_delay * calc_stat(Stats::P_REUSE)).to_i
    else
      (skill.reuse_delay * calc_stat(Stats::DANCE_REUSE)).to_i
    end

    skill_mastery = Formulas.skill_mastery(self, skill)

    if reuse_delay > 30_000 && !skill_mastery
      add_time_stamp(skill, reuse_delay.to_i64)
    end

    init_mp_cons = stat.get_mp_consume1(skill)
    if init_mp_cons > 0
      status.reduce_mp(init_mp_cons.to_f64)
      if acting_player # custom check to not create a new packet for npcs
        send_packet(StatusUpdate.current_mp(self))
      end
    end

    if reuse_delay > 10
      if skill_mastery
        reuse_delay = 100
        acting_player.try &.send_packet(SystemMessageId::SKILL_READY_TO_USE_AGAIN)
      end

      disable_skill(skill, reuse_delay.to_i64)
    end

    if target != self
      self.heading = Util.calculate_heading_from(self, target)
      broadcast_packet(ExRotation.new(l2id, heading))
    end

    if playable?
      if skill.item_consume_id > 0
        unless destroy_item_by_item_id("Consume", skill.item_consume_id, skill.item_consume_count.to_i64, nil, true)
          acting_player.not_nil!.send_packet(SystemMessageId::NOT_ENOUGH_ITEMS)
          abort_cast
          return
        end
      end

      # reduce talisman mana on skill use
      if skill.reference_item_id > 0
        if ItemTable[skill.reference_item_id].body_part == L2Item::SLOT_DECO
          inventory.get_items_by_item_id(skill.reference_item_id).each do |item|
            if item.equipped?
              if item.mana < item.use_skill_dis_time
                abort_cast
                return
              end
              item.decrease_mana(false, item.use_skill_dis_time)
              break
            end
          end
        end
      end
    end

    msu = MagicSkillUse.new(
      self,
      target,
      skill.display_id,
      skill.display_level,
      skill_anim_time.to_i,
      reuse_delay
    )
    broadcast_packet(msu)

    if player? && !skill.abnormal_instant?
      case magic_id
      when 1312
        # fishing, done in L2PcInstance#start_fishing
      when 2046 # wolf collar
        send_packet(SystemMessageId::SUMMON_A_PET)
      else
        sm = SystemMessage.use_s1
        sm.add_skill_name(skill)
        send_packet(sm)
      end
    end

    if skill.has_effects?(EffectScope::START)
      skill.apply_effect_scope(
        EffectScope::START,
        BuffInfo.new(self, target, skill),
        true,
        false
      )
    end

    if skill.fly_type?
      task = FlyToLocationTask.new(self, target, FlyType::CHARGE)
      ThreadPoolManager.schedule_effect(task, 50)
    end

    mut = MagicUseTask.new(
      self,
      targets,
      skill,
      skill_anim_time.to_i,
      simultaneously
    )

    if skill_anim_time > 0
      if player? && !simultaneously
        send_packet(SetupGauge.blue(skill_anim_time.to_i))
      end

      if skill.channeling? && skill.channeling_skill_id > 0
        skill_channelizer.start_channeling(skill)
      # elsif skill.continuous?
        # This was added by L2J in order to fix some animation problem but it
        # makes the next queued buff to abort the previous animation.
        # UPDATE: confirmed that in L2J the same issue is present so it likely
        # should be removed there as well.
        # skill_anim_time -= 300
      end

      # custom (so that physical attack skills complete their animations)
      if skill.cool_time > 0
        skill_anim_time += (skill.cool_time / p_atk_spd * 333.0).clamp(50, 200)
      end

      if simultaneously
        if task = @skill_cast_2
          task.cancel
          @skill_cast_2 = nil
        end
        @skill_cast_2 = ThreadPoolManager.schedule_effect(mut, skill_anim_time.to_i - 400)
      else
        if task = @skill_cast
          task.cancel
          @skill_cast = nil
        end
        @skill_cast = ThreadPoolManager.schedule_effect(mut, skill_anim_time.to_i - 400)
      end
    else
      mut.skill_time = 0
      on_magic_launched_timer(mut)
    end
  end

  def on_magic_launched_timer(mut : MagicUseTask)
    skill = mut.skill
    targets = mut.targets

    unless skill && targets
      abort_cast
      return
    end

    if targets.empty?
      case skill.target_type
      when .aura?, .front_aura?, .behind_aura?, .aura_corpse_mob?,
           .aura_friendly?, .aura_undead_enemy?
        # do nothing
      else
        abort_cast
        return
      end
    end

    escape_range = 0

    if skill.effect_range > escape_range
      escape_range = skill.effect_range
    elsif skill.cast_range < 0 && skill.affect_range > 80
      escape_range = skill.affect_range
    end

    if targets.size > 0 && escape_range > 0
      skip_range = 0
      skip_los = 0
      skip_peace_zone = 0
      target_list = [] of L2Object

      targets.each do |target|
        if target.is_a?(L2Character)
          col_radius = template.collision_radius
          unless inside_radius?(*target.xyz, escape_range + col_radius, true, false)
            skip_range += 1
            next
          end
          # i think other party type and clan targets should be ignored too
          if (!skill.target_type.party? || !skill.has_effect_type?(EffectType::HP))
            if !GeoData.can_see_target?(self, target)
              skip_los += 1
              next
            end
          end

          if skill.bad?
            if player?
              if target.inside_peace_zone?(acting_player.not_nil!)
                skip_peace_zone += 1
                next
              end
            else
              if target.inside_peace_zone?(self, target)
                skip_peace_zone += 1
                next
              end
            end
          end

          target_list << target
        end
      end

      if target_list.empty?
        if player?
          if skip_range > 0
            send_packet(SystemMessageId::DIST_TOO_FAR_CASTING_STOPPED)
          elsif skip_los > 0
            send_packet(SystemMessageId::CANT_SEE_TARGET)
          elsif skip_peace_zone > 0
            send_packet(SystemMessageId::A_MALICIOUS_SKILL_CANNOT_BE_USED_IN_PEACE_ZONE)
          end
        end

        abort_cast
        return
      end

      mut.targets = target_list
    end

    if (mut.simultaneous? && !casting_simultaneously_now?) || (!mut.simultaneous? && !casting_now?) || (looks_dead? && !skill.static?)
      notify_event(AI::CANCEL)
      return
    end

    unless skill.toggle?
      msl = MagicSkillLaunched.new(
        self,
        skill.display_id,
        skill.display_level,
        targets
      )
      broadcast_packet(msl)
    end

    mut.phase = 2

    if mut.skill_time == 0
      on_magic_hit_timer(mut)
    else
      @skill_cast = ThreadPoolManager.schedule_effect(mut, 400)
    end
  end

  def on_magic_hit_timer(mut : MagicUseTask)
    skill = mut.skill
    targets = mut.targets

    unless skill && targets
      abort_cast
      return
    end

    targets.each do |tgt|
      if tgt.playable?
        if player? && tgt.is_a?(L2Summon)
          tgt.update_and_broadcast_status(1)
        end
      elsif playable? && tgt.is_a?(L2Attackable)
        effect_point = skill.effect_point
        if effect_point > 0
          tgt.reduce_hate(self, effect_point)
        elsif effect_point < 0
          tgt.add_damage_hate(self, 0, -effect_point)
        end
      end
    end

    recharge_shots(skill.use_soulshot?, skill.use_spiritshot?)

    su = StatusUpdate.new(self)
    send_su = false

    mp_consume2 = stat.get_mp_consume2(skill)

    if mp_consume2 > 0
      if mp_consume2 > current_mp
        send_packet(SystemMessageId::NOT_ENOUGH_MP)
        abort_cast
        return
      end

      status.reduce_mp(mp_consume2.to_f64)
      su.add_cur_mp(current_mp.to_i)
      send_su = true
    end

    if skill.hp_consume > 0
      consume_hp = skill.hp_consume

      if consume_hp > current_hp
        send_packet(SystemMessageId::NOT_ENOUGH_HP)
        abort_cast
        return
      end

      status.reduce_hp(consume_hp.to_f64, self, true)

      su.add_cur_hp(current_hp.to_i)
      send_su = true
    end

    if send_su && playable? # custom playable check. change it to not create the packet in the first place unless playable
      send_packet(su)
    end

    me = self
    if me.is_a?(L2PcInstance) && skill.charge_consume > 0
      me.decrease_charges(skill.charge_consume)
    end

    call_skill(mut.skill, mut.targets)

    if mut.skill_time > 0
      mut.count += 1
    end

    mut.phase = 3

    if mut.skill_time == 0
      on_magic_finalizer(mut)
    else
      if mut.simultaneous?
        @skill_cast_2 = ThreadPoolManager.schedule_effect(mut, 0)
      else
        @skill_cast = ThreadPoolManager.schedule_effect(mut, 0)
      end
    end
  end

  def on_magic_finalizer(mut : MagicUseTask)
    if mut.simultaneous?
      @skill_cast_2 = nil
      self.casting_simultaneously_now = false
      return
    end

    @skill_cast = nil
    @cast_interrupt_time = 0

    self.casting_now = false
    self.casting_simultaneously_now = false

    skill = mut.skill
    unless targets = mut.targets
      raise "MagicUseTask has no targets in L2Character#on_magic_finalizer"
    end
    target = targets[0]?

    if mut.count > 0
      recharge_shots(mut.skill.use_soulshot?, mut.skill.use_spiritshot?)
    end

    t = target()
    if skill.next_action_is_attack? && t.is_a?(L2Character) && t != self
      if target && t == target && target.can_be_attacked?
        ni = ai.next_intention
        if ni.nil? || !ni.intention.move_to?
          set_intention(AI::ATTACK, target)
        end
      end
    end

    if skill.bad? && !skill.target_type.unlockable?
      ai.client_start_auto_attack
    end

    notify_event(AI::FINISH_CASTING)

    notify_quest_event_skill_finished(skill, target)

    if player? && (pc = acting_player)
      qs = pc.queued_skill

      pc.set_current_skill(nil, false, false)

      if qs
        pc.set_queued_skill(nil, false, false)
        task = QueuedMagicUseTask.new(pc, qs.skill, qs.ctrl?, qs.shift?)
        ThreadPoolManager.execute_general(task)
      end
    end

    if channeling?
      skill_channelizer.stop_channeling
    end
  end

  def call_skill(skill : Skill, targets : Array(L2Object)?)
    unless targets
      raise "Nil targets given to L2Character#call_skill"
    end

    active_weapon = active_weapon_item

    if skill.toggle? && affected_by_skill?(skill.id)
      return
    end

    targets.each do |target|
      next unless target.is_a?(L2Character)

      if target.ai?
        targets_attack_target = target.ai.attack_target?
        targets_cast_target = target.ai.cast_target?
      end

      if !Config.raid_disable_curse && ((target.is_a?(L2RaidBossInstance) && target.give_raid_curse? && level > target.level + 8) ||
        (!skill.bad? && targets_attack_target.is_a?(L2RaidBossInstance) && targets_attack_target.give_raid_curse? && targets_attack_target.attack_by_list.includes?(target) && (level > (targets_attack_target.level + 8))) ||
        (!skill.bad? && targets_cast_target.is_a?(L2RaidBossInstance) && targets_cast_target.give_raid_curse? && targets_cast_target.attack_by_list.includes?(target) && (level > (targets_cast_target.level + 8))))

        if skill.magic?
          curse = CommonSkill::RAID_CURSE
        else
          curse = CommonSkill::RAID_CURSE2
        end

        if curse_skill = curse.skill?
          abort_attack
          abort_cast
          set_intention(AI::IDLE)
          curse_skill.apply_effects(target, self)
        end

        return
      end

      if skill.overhit? && target.is_a?(L2Attackable)
        target.overhit = true
      end

      unless skill.static?
        if active_weapon && !target.dead?
          active_weapon.cast_on_magic_skill(self, target, skill)
        end

        @trigger_skills.try &.each_value do |sh|
          if (skill.magic? && sh.skill_type.magic?) || (skill.physical? && sh.skill_type.attack?)
            if Rnd.rand(100) < sh.chance
              make_trigger_cast(sh.skill, target)
            end
          end
        end
      end
    end

    skill.activate_skill(self, targets)

    if player = acting_player
      targets.each do |target|
        next unless target.is_a?(L2Character)

        if skill.effect_point <= 0
          if target.playable? || target.trap?
            if target != self
              if target.player?
                target.ai.client_start_auto_attack
              elsif target.is_a?(L2Summon) && target.ai?
                target.owner.ai.client_start_auto_attack
              end
              if player.summon != target && !trap? && skill.bad?
                player.update_pvp_status(target)
              end
            end
          elsif target.is_a?(L2Attackable)
            case skill.id
            when 51, 511
              # Lure, Temptation
            else
              target.add_attacker_to_attack_by_list(self)
            end
          end

          if target.ai? && !skill.has_effect_type?(EffectType::HATE)
            target.notify_event(AI::ATTACKED, self)
          end
        else
          if target.is_a?(L2PcInstance)
            if !(target != self || target == player) && (target.pvp_flag > 0 || target.karma > 0)
              player.update_pvp_status
            end
          elsif target.attackable?
            player.update_pvp_status
          end
        end
      end

      player.known_list.known_objects.each_value do |mob|
        if mob.is_a?(L2Npc)
          if mob.inside_radius?(player, 1000, true, true)
            OnNpcSkillSee.new(mob, player, skill, targets, summon?).async(mob)
            if mob.is_a?(L2Attackable)
              effect_point = skill.effect_point

              if player.has_summon?
                if targets.size == 1 && targets.includes?(player.summon)
                  effect_point = 0
                end
              end

              if effect_point > 0
                if mob.ai? && mob.ai.intention.attack?
                  npc_target = mob.target
                  targets.each do |skill_target|
                    if npc_target == skill_target || mob == skill_target
                      original_caster = summon? ? summon : player
                      hate = ((effect_point * 150) / (mob.level + 7)).to_i64
                      mob.add_damage_hate(original_caster, 0, hate)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    if skill.bad? && !skill.has_effect_type?(EffectType::HATE)
      targets.each do |target|
        if target.is_a?(L2Character) && target.ai?
          target.notify_event(AI::ATTACKED, self)
        end
      end
    end
  end

  def make_trigger_cast(skill : Skill, target : L2Character)
    make_trigger_cast(skill, target, false)
  end

  def make_trigger_cast(skill : Skill, target : L2Character, ignore_target_type : Bool)
    return unless skill.check_condition(self, target, false)
    return if skill_disabled?(skill)

    if skill.reuse_delay > 0
      disable_skill(skill, skill.reuse_delay.to_i64)
    end

    if ignore_target_type
      targets = [target] of L2Object
    else
      targets = skill.get_target_list(self, false, target)
      return if targets.empty?
    end


    targets.each do |obj|
      if obj.is_a?(L2Character)
        target = obj
        break
      end
    end

    if Config.alt_validate_trigger_skills && playable? && (pc = acting_player)
      if target.is_a?(L2Playable)
        unless pc.check_pvp_skill(target, skill)
          return
        end
      end
    end

    msu = MagicSkillUse.new(self, target, skill.display_id, skill.display_level, 0, 0)
    broadcast_packet(msu)
    msl = MagicSkillLaunched.new(self, skill.display_id, skill.display_level, targets)
    broadcast_packet(msl)

    skill.activate_skill(self, targets)
  rescue e
    error e
  end

  def stop_transformation(remove_effects : Bool)
    if remove_effects
      effect_list.stop_skill_effects(false, AbnormalType::TRANSFORM)
    end

    pc = self

    if pc.is_a?(L2PcInstance)
      pc.untransform
    else
      notify_event(AI::THINK)
    end

    update_abnormal_effect
  end

  def check_do_cast_conditions(skill : Skill?) : Bool
    unless skill
      action_failed
      return false
    end

    if skill_disabled?(skill)
      action_failed
      return false
    end

    if skill.fly_type? && movement_disabled?
      action_failed
      return false
    end

    total_mp = stat.get_mp_consume1(skill) + stat.get_mp_consume2(skill)
    if current_mp < total_mp
      send_packet(SystemMessageId::NOT_ENOUGH_MP)
      action_failed
      return false
    end

    if current_hp <= skill.hp_consume
      send_packet(SystemMessageId::NOT_ENOUGH_HP)
      action_failed
      return false
    end

    unless skill.static?
      if skill.magic?
        if muted?
          action_failed
          return false
        end
      elsif physical_muted?
        action_failed
        return false
      end
    end

    if skill.channeling? && skill.channeling_skill_id > 0
      return false unless region = world_region
      can_cast = true
      me = self
      if skill.target_type.ground? && me.is_a?(L2PcInstance)
        wp = me.current_skill_world_position.not_nil!
        unless region.check_effect_range_inside_peace_zone(skill, *wp.xyz)
          can_cast = false
        end
      elsif !region.check_effect_range_inside_peace_zone(skill, *xyz)
        can_cast = false
      end

      unless can_cast
        sm = SystemMessage.s1_cannot_be_used
        sm.add_skill_name(skill)
        send_packet(sm)
        return false
      end
    end

    if wep = active_weapon_item
      if wep.use_weapon_skills_only? && !gm? && wep.has_skills?
        unless wep.skills.try &.any? { |sh| sh.skill_id == skill.id }
          acting_player.try &.send_packet(SystemMessageId::WEAPON_CAN_USE_ONLY_WEAPON_SKILL)
        end

        return false
      end
    end

    if skill.item_consume_id > 0 && inventory?
      req_items = inventory.get_item_by_item_id(skill.item_consume_id)

      if req_items.nil? || req_items.count < skill.item_consume_count
        if skill.has_effect_type?(EffectType::SUMMON)
          sm = SystemMessage.summoning_servitor_costs_s2_s1
          sm.add_item_name(skill.item_consume_id)
          sm.add_int(skill.item_consume_count)
          send_packet(sm)
        else
          send_packet(SystemMessageId::THERE_ARE_NOT_ENOUGH_NECESSARY_ITEMS_TO_USE_THE_SKILL)
        end

        return false
      end
    end

    true
  end

  def can_abort_cast? : Bool
    @cast_interrupt_time > GameTimer.ticks
  end

  def abort_cast
    if casting_now? || casting_simultaneously_now?
      if cast = @skill_cast
        cast.cancel
        @skill_cast = nil
      end

      if cast2 = @skill_cast_2
        cast2.cancel
        @skill_cast_2 = nil
      end

      if channeling?
        skill_channelizer.stop_channeling
      end

      if @all_skills_disabled
        enable_all_skills
      end

      self.casting_now = false
      self.casting_simultaneously_now = false

      @cast_interrupt_time = 0

      if player?
        notify_event(AI::FINISH_CASTING)
      end

      broadcast_packet(MagicSkillCancel.new(l2id))
      action_failed
    end
  end

  def abort_attack
    if attacking_now?
      action_failed
    end
  end

  def attacking_now? : Bool
    @attack_end_time > Time.ns
  end

  def title=(string : String?)
    if string
      @title = string.size > 21 ? string[0, 20] : string
    else
      @title = ""
    end
  end

  def academy_member? : Bool
    false
  end

  def pledge_type : Int32
    0
  end

  def clan_id : Int32
    0
  end

  def ally_id : Int32
    0
  end

  def on_event? : Bool
    false
  end

  def sweep_active? : Bool
    false
  end

  def invul? : Bool
    @invul || @teleporting
  end

  def access_level : AccessLevel
    raise "L2Character doesn't have access level."
  end

  def inventory : Inventory
    raise "L2Character doesn't have an inventory."
  end

  def inventory? : Inventory?
    # return nil
  end

  def destroy_item_by_item_id(process : String?, id : Int32, count : Int64, reference : L2Object?, send_msg : Bool) : Bool
    true
  end

  def destroy_item(process : String?, l2id : Int32, count : Int64, reference : L2Object?, send_msg : Bool) : Bool
    true
  end

  def add_invul_against(holder : SkillHolder)
    temp = invul_against_skills
    invul_holder = temp[holder.skill_id]?

    if invul_holder
      invul_holder.increase_instances
    else
      temp[holder.skill_id] = InvulSkillHolder.new(holder)
    end
  end

  def invul_against?(skill_id : Int32, skill_lvl : Int32) : Bool
    if temp = @invul_against_skills
      if holder = temp[skill_id]?
        if holder.skill_lvl < 1 || holder.skill_lvl == skill_lvl
          return true
        end
      end
    end

    false
  end

  def remove_invul_against(holder : SkillHolder)
    temp = invul_against_skills
    if invul_holder = temp[holder.skill_id]?
      if invul_holder.decrease_instances < 1
        temp.delete(holder.skill_id)
      end
    end
  end

  def level_mod : Float64
    (level + 89).fdiv(100)
  end

  def raid? : Bool
    false
  end

  def minion? : Bool
    false
  end

  def raid_minion? : Bool
    false
  end

  def looks_dead? : Bool
    dead?
  end

  def current_load : Int32
    0
  end

  def bonus_weight_penalty : Int32
    0
  end

  def update_pvp_flag(value : Int32)
    # no-op
  end

  def character? : Bool
    true
  end

  def max_load : Int32
    0
  end

  def set_teleporting(@teleporting : Bool)
  end

  def race : Race
    template.race
  end

  def calc_stat(*args) : Float64
    stat.calc_stat(*args)
  end

  def max_cp : Int32
    stat.max_cp
  end

  def max_hp : Int32
    stat.max_hp
  end

  def max_mp : Int32
    stat.max_mp
  end

  def physical_attack_range : Int32
    stat.physical_attack_range
  end

  def physical_attack_angle : Int32
    stat.physical_attack_angle
  end

  def movement_speed_multiplier : Float64
    stat.movement_speed_multiplier
  end

  def str : Int32
    stat.str
  end

  def dex : Int32
    stat.dex
  end

  def con : Int32
    stat.con
  end

  def int : Int32
    stat.int
  end

  def wit : Int32
    stat.wit
  end

  def men : Int32
    stat.men
  end

  def move_speed : Float64
    stat.move_speed.to_f64
  end

  def run_speed : Float64
    stat.run_speed
  end

  def walk_speed : Float64
    stat.walk_speed
  end

  def swim_run_speed : Float64
    stat.swim_run_speed
  end

  def swim_walk_speed : Float64
    stat.swim_walk_speed
  end

  def accuracy : Int32
    stat.accuracy
  end

  def attack_speed_multiplier : Float32
    stat.attack_speed_multiplier
  end

  def max_recoverable_cp : Int32
    stat.max_recoverable_cp
  end

  def max_recoverable_hp : Int32
    stat.max_recoverable_hp
  end

  def max_recoverable_mp : Int32
    stat.max_recoverable_mp
  end

  def p_atk_spd : Float64
    stat.p_atk_spd
  end

  def m_atk_spd : Int32
    stat.m_atk_spd
  end

  def shld_def : Int32
    stat.shld_def
  end

  def attack_element : Int8
    stat.attack_element
  end

  def get_attack_element_value(attribute_id : Int) : Int32
    stat.get_attack_element_value(attribute_id)
  end

  def get_defense_element_value(attribute_id : Int) : Int32
    stat.get_defense_element_value(attribute_id)
  end

  def get_critical_dmg(char : L2Character, value : Float64) : Float64
    stat.get_critical_dmg(char, value)
  end

  def get_critical_hit(target : L2Character?, skill : Skill?) : Int32
    stat.get_critical_hit(target, skill)
  end

  def critical_hit : Int32
    stat.get_critical_hit
  end

  def get_evasion_rate(target) : Int32
    stat.get_evasion_rate(target)
  end

  def get_magical_attack_range(skill) : Int32
    stat.get_magical_attack_range(skill)
  end

  def magical_attack_range : Int32
    stat.get_magical_attack_range
  end

  def get_m_atk(target : L2Character?, skill : Skill?) : Float64
    stat.get_m_atk(target, skill)
  end

  def get_m_critical_hit(target : L2Character?, skill : Skill?) : Int32
    stat.get_m_critical_hit(target, skill)
  end

  def get_m_def(target : L2Character?, skill : Skill?) : Float64
    stat.get_m_def(target, skill)
  end

  def get_m_reuse_rate(skill : Skill) : Float64
    stat.get_m_reuse_rate(skill)
  end

  def get_p_atk(target : L2Character?) : Float64
    stat.get_p_atk(target)
  end

  def get_p_def(target : L2Character?) : Float64
    stat.get_p_def(target)
  end

  def get_attack_trait(ttype : TraitType) : Float32
    stat.get_attack_trait(ttype)
  end

  def has_attack_trait?(ttype : TraitType) : Bool
    stat.has_attack_trait?(ttype)
  end

  def get_defense_trait(ttype : TraitType) : Float32
    stat.get_defense_trait(ttype)
  end

  def has_defense_trait?(ttype : TraitType) : Bool
    stat.has_defense_trait?(ttype)
  end

  def trait_invul?(ttype : TraitType) : Bool
    stat.trait_invul?(ttype)
  end

  def max_buff_count : Int32
    stat.max_buff_count
  end

  def current_cp : Float64
    status.current_cp
  end

  def current_hp : Float64
    status.current_hp
  end

  def current_mp : Float64
    status.current_mp
  end

  def hp_percent : Int32
    ((current_hp / max_hp) * 100.0).to_i
  end

  def mp_percent : Int32
    ((current_mp / max_mp) * 100.0).to_i
  end

  def add_status_listener(char : L2Character)
    status.add_status_listener(char)
  end

  def remove_status_listener(char : L2Character)
    status.remove_status_listener(char)
  end

  def set_current_cp(cp : Float64)
    set_current_cp(cp, true)
  end

  def set_current_cp(cp : Float64, broadcast : Bool)
    status.set_current_cp(cp, broadcast)
  end

  def current_cp=(cp : Float64)
    status.set_current_cp(cp)
  end

  def set_current_hp(hp : Float64)
    set_current_hp(hp, true)
  end

  def set_current_hp(hp : Float64, broadcast : Bool)
    status.set_current_hp(hp, broadcast)
  end

  def current_hp=(hp : Float64)
    status.set_current_hp(hp)
  end

  def set_current_mp(mp : Float64)
    set_current_mp(mp, true)
  end

  def set_current_mp(mp : Float64, broadcast : Bool)
    status.set_current_mp(mp, broadcast)
  end

  def current_mp=(mp : Float64)
    status.set_current_mp(mp)
  end

  def set_current_hp_mp(hp : Float64, mp : Float64)
    status.set_current_hp_mp(hp, mp)
  end

  def reduce_current_hp(value : Float64, attacker : L2Character?, skill : Skill?)
    reduce_current_hp(value, attacker, true, false, skill)
  end

  def reduce_current_hp(value : Float64, attacker : L2Character?, awake : Bool, dot : Bool, skill : Skill?)
    if Config.champion_enable && champion? && Config.champion_hp != 0
      status.reduce_hp(value / Config.champion_hp, attacker, awake, dot, false)
    else
      status.reduce_hp(value, attacker, awake, dot, false)
    end
  end

  def reduce_current_hp_by_dot(hp : Float64, attacker : L2Character?, skill : Skill)
    reduce_current_hp(hp, attacker, !skill.toggle?, true, skill)
  end

  def reduce_current_mp(mp : Float64)
    status.reduce_mp(mp)
  end

  def stop_hp_mp_regeneration
    status.stop_hp_mp_regeneration
  end

  def intention : AI::Intention
    ai.intention
  end

  def intention=(intention : AI::Intention)
    ai.set_intention(intention)
  end

  def set_intention(intention : AI::Intention, *args)
    ai.set_intention(intention, *args)
  end

  def notify_event(event : AI::Event, *args)
    ai.notify_event(event, *args)
  end

  def buff_count : Int32
    effect_list.buff_count
  end

  def dance_count : Int32
    effect_list.dance_count
  end

  def stop_skill_effects(removed : Bool, skill_id : Int32)
    effect_list.stop_skill_effects(removed, skill_id)
  end

  def stop_skill_effects(removed : Bool, skill : Skill)
    effect_list.stop_skill_effects(removed, skill)
  end

  def stop_all_effects
    effect_list.stop_all_effects
  end

  def stop_effects(effect_type : EffectType)
    effect_list.stop_effects(effect_type)
  end

  def stop_all_effects_except_those_that_last_through_death
    effect_list.stop_all_effects_except_those_that_last_through_death
  end

  def stop_effects_on_action
    effect_list.stop_effects_on_action
  end

  def stop_effects_on_damage(awake : Bool)
    effect_list.stop_effects_on_damage(awake)
  end

  def update_effect_icons
    update_effect_icons(false)
  end

  def update_effect_icons(party_only : Bool)
    # no-op
  end

  def start_fake_death
    me = self
    return unless me.is_a?(L2PcInstance)
    me.fake_death = true
    abort_attack
    abort_cast
    stop_move(nil)
    notify_event(AI::FAKE_DEATH)
    broadcast_packet(ChangeWaitType.new(self, ChangeWaitType::START_FAKE_DEATH))
  end

  def start_stunning
    abort_attack
    abort_cast
    stop_move(nil)
    notify_event(AI::STUNNED)
    unless summon?
      set_intention(AI::IDLE)
    end
    update_abnormal_effect
  end

  def start_paralyze
    abort_attack
    abort_cast
    stop_move(nil)
    notify_event(AI::PARALYZED)
  end

  def stop_stunning(remove_effects : Bool)
    if remove_effects
      stop_effects(EffectType::STUN)
    end

    unless player?
      notify_event(AI::THINK)
    end

    update_abnormal_effect
  end

  def start_physical_attack_muted
    abort_attack
  end

  def do_attack(target : L2Character?)
    return if target.nil? || attacking_disabled?

    term = OnCreatureAttack.new(self, target).notify(self)
    if term && term.terminate
      set_intention(AI::ACTIVE)
      action_failed
      return
    end

    term = OnCreatureAttacked.new(self, target).notify(target)
    if term && term.terminate
      set_intention(AI::ACTIVE)
      action_failed
      return
    end

    unless looks_dead?
      if (npc? && target.looks_dead?) || !known_list.knows_object?(target)
        set_intention(AI::ACTIVE)
        action_failed
        return
      elsif actor = acting_player
        if target.dead?
          set_intention(AI::ACTIVE)
          action_failed
          return
        end

        if actor.transformed? && (tf = actor.transformation) && !tf.can_attack?
          action_failed
          return
        end
      end
    end

    if wpn = active_weapon_item
      if !wpn.attack_weapon? && !gm?
        if wpn.item_type == WeaponType::FISHINGROD
          send_packet(SystemMessageId::CANNOT_ATTACK_WITH_FISHING_POLE)
        else
          send_packet(SystemMessageId::THAT_WEAPON_CANT_ATTACK)
        end

        action_failed
        return
      end
    end

    if actor = acting_player
      if actor.in_observer_mode?
        send_packet(SystemMessageId::OBSERVERS_CANNOT_PARTICIPATE)
        action_failed
        return
      elsif (target_actor = target.acting_player) && actor.siege_state > 0 &&
        inside_siege_zone? &&
        target_actor.siege_state == actor.siege_state &&
        target_actor != self &&
        target_actor.siege_side == actor.siege_side

        if TerritoryWarManager.tw_in_progress?
          send_packet(SystemMessageId::YOU_CANNOT_ATTACK_A_MEMBER_OF_THE_SAME_TERRITORY)
        else
          send_packet(SystemMessageId::FORCED_ATTACK_IS_IMPOSSIBLE_AGAINST_SIEGE_SIDE_TEMPORARY_ALLIED_MEMBERS)
        end

        action_failed
        return
      elsif target.inside_peace_zone?(actor)
        set_intention(AI::ACTIVE)
        action_failed
        return
      end
    elsif inside_peace_zone?(self, target)
      set_intention(AI::ACTIVE)
      action_failed
      return
    end

    stop_effects_on_action

    unless GeoData.can_see_target?(self, target)
      send_packet(SystemMessageId::CANT_SEE_TARGET)
      set_intention(AI::ACTIVE)
      action_failed
      return
    end

    target.known_list.add_known_object(self)
    weapon_item = active_weapon_item

    was_ss_charged = charged_shot?(ShotType::SOULSHOTS)
    time_atk = calculate_time_between_attacks
    time_to_hit = time_atk // 2

    ss_grade = weapon_item.try &.item_grade_s_plus.to_i || 0
    attack = Attack.new(self, target, was_ss_charged, ss_grade)
    self.heading = Util.calculate_heading_from(self, target)
    reuse = calculate_reuse_time(weapon_item)

    hitted = false

    case attack_type
    when WeaponType::BOW
      unless can_use_range_weapon?
        return
      end
      @attack_end_time = Time.ns + Time.ms_to_ns(time_to_hit + (reuse // 2))
      hitted = do_attack_hit_by_bow(attack, target, time_atk, reuse)
    when WeaponType::CROSSBOW
      unless can_use_range_weapon?
        return
      end
      @attack_end_time = Time.ns + Time.ms_to_ns(time_to_hit + (reuse // 2))
      hitted = do_attack_hit_by_crossbow(attack, target, time_atk, reuse)
    when WeaponType::POLE
      @attack_end_time = Time.ns + Time.ms_to_ns(time_atk)
      hitted = do_attack_hit_by_pole(attack, target, time_to_hit)
    when WeaponType::FIST
      @attack_end_time = Time.ns + Time.ms_to_ns(time_atk)
      if player?
        hitted = do_attack_hit_by_dual(attack, target, time_to_hit)
      else
        hitted = do_attack_hit_simple(attack, target, time_to_hit)
      end
    when WeaponType::DUAL, WeaponType::DUALFIST, WeaponType::DUALDAGGER
      @attack_end_time = Time.ns + Time.ms_to_ns(time_atk)
      hitted = do_attack_hit_by_dual(attack, target, time_to_hit)
    else
      @attack_end_time = Time.ns + Time.ms_to_ns(time_atk)
      hitted = do_attack_hit_simple(attack, target, time_to_hit)
    end

    if pc = acting_player
      AttackStances << pc
      if pc.summon != target
        pc.update_pvp_status(target)
      end
    end

    if !hitted
      abort_attack
    else
      set_charged_shot(ShotType::SOULSHOTS, false)

      if pc = acting_player
        if pc.cursed_weapon_equipped?
          unless target.invul?
            target.current_cp = 0
          end
        elsif pc.hero?
          if target.is_a?(L2PcInstance) && target.cursed_weapon_equipped?
            target.current_cp = 0
          end
        end
      end
    end

    if attack.has_hits?
      broadcast_packet(attack)
    end

    task = NotifyAITask.new(self, AI::READY_TO_ACT)
    ThreadPoolManager.schedule_ai(task, time_atk + reuse)
  end

  def attack_type : WeaponType
    active_weapon_item.try &.item_type || template.base_attack_type
  end

  def do_attack_hit_by_bow(attack : Attack, target : L2Character, s_atk : Int32, reuse : Int32) : Bool
    damage = 0
    shld = 0i8
    crit = false
    miss = Formulas.hit_miss(self, target)
    reduce_arrow_count(false)
    @move = nil

    unless miss
      shld = Formulas.shld_use(self, target)
      crit = Formulas.crit(self, target)
      damage = Formulas.phys_dam(self, target, shld, crit, attack.has_soulshot?).to_i
      damage *= (calculate_distance(target, true, false) / 4000) + 0.8
      damage = damage.to_i
    end

    if player?
      send_packet(SetupGauge.red(s_atk + reuse))
    end

    task = HitTask.new(self, target, damage, crit, miss, attack.has_soulshot?, shld)
    ThreadPoolManager.schedule_ai(task, s_atk)
    @bow_attack_end_time = ((s_atk + reuse) // GameTimer::MILLIS_IN_TICK) + GameTimer.ticks
    attack.add_hit(target, damage, miss, crit, shld)
    !miss
  end

  def do_attack_hit_by_crossbow(attack : Attack, target : L2Character, s_atk : Int32, reuse : Int32) : Bool
    damage = 0
    shld = 0i8
    crit = false
    miss = Formulas.hit_miss(self, target)
    reduce_arrow_count(true)
    @move = nil

    unless miss
      shld = Formulas.shld_use(self, target)
      crit = Formulas.crit(self, target)
      damage = Formulas.phys_dam(self, target, shld, crit, attack.has_soulshot?).to_i
      damage *= (calculate_distance(target, true, false) / 4000) + 0.8
      damage = damage.to_i
    end

    if player?
      send_packet(SystemMessageId::CROSSBOW_PREPARING_TO_FIRE)
      send_packet(SetupGauge.red(s_atk + reuse))
    end

    task = HitTask.new(self, target, damage, crit, miss, attack.has_soulshot?, shld)
    ThreadPoolManager.schedule_ai(task, s_atk)
    @bow_attack_end_time = ((s_atk + reuse) // GameTimer::MILLIS_IN_TICK) + GameTimer.ticks
    attack.add_hit(target, damage, miss, crit, shld)

    !miss
  end

  def do_attack_hit_by_dual(attack : Attack, target : L2Character, s_atk : Int32) : Bool
    damage1 = damage2 = 0
    shld1 = shld2 = 0i8
    crit1 = crit2 = false

    miss1 = Formulas.hit_miss(self, target)
    miss2 = Formulas.hit_miss(self, target)

    ss = attack.has_soulshot?

    unless miss1
      shld1 = Formulas.shld_use(self, target)
      crit1 = Formulas.crit(self, target)
      damage1 = Formulas.phys_dam(self, target, shld1, crit1, ss).to_i
      damage1 //= 2
    end

    unless miss2
      shld2 = Formulas.shld_use(self, target)
      crit2 = Formulas.crit(self, target)
      damage2 = Formulas.phys_dam(self, target, shld2, crit2, ss).to_i
      damage2 //= 2
    end

    hit1 = HitTask.new(self, target, damage1, crit1, miss1, ss, shld1)
    ThreadPoolManager.schedule_ai(hit1, s_atk / 2)
    hit2 = HitTask.new(self, target, damage2, crit2, miss2, ss, shld2)
    ThreadPoolManager.schedule_ai(hit2, s_atk)

    attack.add_hit(target, damage1, miss1, crit1, shld1)
    attack.add_hit(target, damage2, miss2, crit2, shld2)

    !miss1 || !miss2
  end

  def do_attack_hit_by_pole(attack : Attack, target : L2Character, s_atk : Int32) : Bool
    hitted = do_attack_hit_simple(attack, target, 100, s_atk)

    if affected?(EffectFlag::SINGLE_TARGET)
      return hitted
    end

    max_radius = physical_attack_range
    max_angle_diff = physical_attack_angle
    attack_random_count_max = calc_stat(Stats::ATTACK_COUNT_MAX)
    attack_percent = 85.0
    attack_count = 0
    z = z()
    me = self

    known_list.known_objects.each_value do |obj|
      next unless obj.is_a?(L2Character)
      next if obj == target
      next if me.is_a?(L2PetInstance) && me.owner == self
      next unless Util.in_range?(max_radius, self, obj, false)
      next if (obj.z - z).abs > 650
      next unless facing?(obj, max_angle_diff)
      next if attackable? && obj.player? && obj.attackable?
      next if me.is_a?(L2Attackable) && obj.attackable? && !me.chaos?

      unless obj.looks_dead?
        if obj == ai.attack_target? || obj.auto_attackable?(self)
          hitted |= do_attack_hit_simple(attack, obj, attack_percent, s_atk)
          attack_percent /= 1.15
          attack_count += 1
          break if attack_count > attack_random_count_max
        end
      end
    end

    hitted
  end

  def do_attack_hit_simple(attack : Attack, target : L2Character, s_atk : Int32) : Bool
    do_attack_hit_simple(attack, target, 100.0, s_atk)
  end

  def do_attack_hit_simple(attack : Attack, target : L2Character, attack_percent : Float64, s_atk : Int32) : Bool
    damage = 0
    shld = 0i8
    crit = false

    unless miss = Formulas.hit_miss(self, target)
      shld = Formulas.shld_use(self, target)
      crit = Formulas.crit(self, target)
      damage = Formulas.phys_dam(self, target, shld, crit, attack.has_soulshot?).to_i

      if attack_percent != 100
        damage = ((damage * attack_percent) / 100.0).to_i
      end
    end

    task = HitTask.new(self, target, damage, crit, miss, attack.has_soulshot?, shld)
    ThreadPoolManager.schedule_ai(task, s_atk)

    attack.add_hit(target, damage, miss, crit, shld)

    !miss
  end

  def on_hit_timer(target : L2Character?, damage : Int32, crit : Bool, miss : Bool, soulshot : Bool, shld : Int8)
    me = self
    if !target || looks_dead? || (me.is_a?(L2Npc) && me.event_mob?)
      notify_event(AI::CANCEL)
      return
    end

    if (npc? && target.looks_dead?) || target.dead? || (!known_list.knows_object?(target) && !door?)
      recharge_shots(true, false)
      notify_event(AI::CANCEL)
      action_failed
      return
    end

    if miss
      if target.ai?
        target.notify_event(AI::EVADED, self)
      end

      notify_attack_avoid(target, false)
    end

    send_damage_message(target, damage, false, crit, miss)

    if target.raid? && target.give_raid_curse? && !Config.raid_disable_curse
      if level > target.level + 8
        if skill = CommonSkill::RAID_CURSE2.skill?
          abort_attack
          abort_cast
          set_intention(AI::IDLE)
          skill.apply_effects(target, self)
        end

        damage = 0
      end
    end

    if target.is_a?(L2PcInstance)
      target.ai.client_start_auto_attack
    end

    if !miss && damage > 0
      weapon = active_weapon_item
      is_bow = false
      reflected_damage = 0
      if weapon
        w_type = weapon.item_type
        is_bow = w_type == WeaponType::BOW || w_type == WeaponType::CROSSBOW
      end

      if !is_bow && !target.invul?
        acting_player = acting_player()
        if !target.raid? || (acting_player.nil? || acting_player.level <= target.level + 8)
          reflect_percent = target.calc_stat(Stats::REFLECT_DAMAGE_PERCENT, 0)
          if reflect_percent > 0
            reflected_damage = (reflect_percent / 100 * damage).to_i32
            if reflected_damage > target.max_hp
              reflected_damage = target.max_hp
            end
          end
        end
      end

      target.reduce_current_hp(damage.to_f64, self, nil)
      target.notify_damage_received(damage, self, nil, crit, false, false)

      if reflected_damage > 0
        if target.playable?
          sm = SystemMessage.c1_done_s3_damage_to_c2
          sm.add_char_name(target)
          sm.add_char_name(self)
          sm.add_int(reflected_damage)
          target.send_packet(sm)
        end

        if summon?
          sm = SystemMessage.c1_received_damage_of_s3_from_c2
          sm.add_char_name(self)
          sm.add_char_name(target)
          sm.add_int(reflected_damage)
          send_packet(sm)
        end

        reduce_current_hp(reflected_damage.to_f64, target, true, false, nil)
        notify_damage_received(reflected_damage, target, nil, crit, false, true)
      end

      unless is_bow
        absorb_percent = calc_stat(Stats::ABSORB_DAMAGE_PERCENT, 0)
        if absorb_percent > 0
          max_can_absorb = (max_recoverable_hp - current_hp).to_i
          absorb_damage = ((absorb_percent.fdiv(100)) * damage).to_i
          if absorb_damage > max_can_absorb
            absorb_damage = max_can_absorb
          end

          if absorb_damage > 0
            self.current_hp += absorb_damage
          end
        end

        absorb_percent = calc_stat(Stats::ABSORB_MANA_DAMAGE_PERCENT, 0)
        if absorb_percent > 0
          max_can_absorb = (max_recoverable_mp - current_mp).to_i
          absorb_damage = ((absorb_percent.fdiv(100)) * damage).to_i
          if absorb_damage > max_can_absorb
            absorb_damage = max_can_absorb
          end

          if absorb_damage > 0
            self.current_mp += absorb_damage
          end
        end
      end

      if target.ai?
        target.notify_event(AI::ATTACKED, self)
      end

      ai.client_start_auto_attack

      if summon?
        as(L2Summon).owner.ai.client_start_auto_attack
      end

      if !target.raid? && Formulas.atk_break(target, damage.to_f)
        target.break_attack
        target.break_cast
      end

      @trigger_skills.try &.each_value do |sh|
        if sh.skill_type.attack? || ((sh.skill_type.critical?) && crit)
          if Rnd.rand(100) < sh.chance
            make_trigger_cast(sh.skill, target)
          end
        end
      end

      if crit && weapon
        weapon.cast_on_critical_skill(self, target)
      end
    end

    recharge_shots(true, false)
  end

  def can_use_range_weapon? : Bool
    return true if transformed?
    return false unless weapon = active_weapon_item
    return false unless weapon.ranged?

    if player?
      unless check_and_equip_arrows
        set_intention(AI::IDLE)
        action_failed
        if weapon.bow?
          send_packet(SystemMessageId::NOT_ENOUGH_ARROWS)
        else
          send_packet(SystemMessageId::NOT_ENOUGH_BOLTS)
        end
        return false
      end

      if @bow_attack_end_time <= GameTimer.ticks
        mp_consume = weapon.mp_consume
        reduced = weapon.reduced_mp_consume
        if reduced > 0 && Rnd.rand(100) < weapon.reduced_mp_consume_chance
          mp_consume = reduced
        end
        mp_consume = calc_stat(Stats::BOW_MP_CONSUME_RATE, mp_consume).to_i

        if current_mp < mp_consume
          task = NotifyAITask.new(self, AI::READY_TO_ACT)
          ThreadPoolManager.schedule_ai(task, 1000)
          send_packet(SystemMessageId::NOT_ENOUGH_MP)
          action_failed
          return false
        end

        if mp_consume > 0
          status.reduce_mp(mp_consume.to_f64)
        end

        @bow_attack_end_time = (5 * GameTimer::TICKS_PER_SECOND) + GameTimer.ticks
      else
        task = NotifyAITask.new(self, AI::READY_TO_ACT)
        ThreadPoolManager.schedule_ai(task, 1000)
        action_failed
        return false
      end
    elsif npc?
      if @bow_attack_end_time > GameTimer.ticks
        return false
      end
    end

    true
  end

  def calculate_time_between_attacks : Int32
    (500_000 / p_atk_spd).to_i
  end

  def calculate_reuse_time(weapon : L2Weapon?) : Int32
    if transformed?
      if attack_type.bow?
        return ((1500 * 333 * stat.get_weapon_reuse_modifier(nil)) / stat.p_atk_spd).to_i
      elsif attack_type.crossbow?
        return ((1200 * 333 * stat.get_weapon_reuse_modifier(nil)) / stat.p_atk_spd).to_i
      end
    end

    if weapon.nil? || weapon.reuse_delay == 0
      return 0
    end

    (weapon.reuse_delay * 333).fdiv(p_atk_spd).to_i
  end

  def channeling? : Bool
    return false unless temp = @skill_channelizer
    temp.channeling?
  end

  def channelized? : Bool
    return false unless temp = @skill_channelized
    temp.channelized?
  end

  def champion? : Bool
    false
  end

  def transformed? : Bool
    false
  end

  def transformation? : Transform?
    # return nil
  end

  def transformation : Transform
    transformation?.not_nil!
  end

  def all_skills : Enumerable(Skill)
    @skills.values_slice # !
  end

  def all_skills_disabled? : Bool
    @all_skills_disabled || stunned? || sleeping? || paralyzed?
  end

  def affected_by_skill?(skill_id : Int32) : Bool
    effect_list.affected_by_skill?(skill_id)
  end

  def affected?(flag : EffectFlag) : Bool
    effect_list.affected?(flag)
  end

  def stunned? : Bool
    affected?(EffectFlag::STUNNED)
  end

  def sleeping? : Bool
    affected?(EffectFlag::SLEEP)
  end

  def betrayed? : Bool
    affected?(EffectFlag::BETRAYED)
  end

  def afraid? : Bool
    affected?(EffectFlag::FEAR)
  end

  def paralyzed? : Bool
    @paralyzed || affected?(EffectFlag::PARALYZED)
  end

  def confused? : Bool
    affected?(EffectFlag::CONFUSED)
  end

  def rooted? : Bool
    affected?(EffectFlag::ROOTED)
  end

  def muted? : Bool
    affected?(EffectFlag::MUTED)
  end

  def physical_muted? : Bool
    affected?(EffectFlag::PHYSICAL_MUTED)
  end

  def physical_attack_muted? : Bool
    affected?(EffectFlag::PHYSICAL_ATTACK_MUTED)
  end

  def disarmed? : Bool
    affected?(EffectFlag::DISARMED)
  end

  def stop_fake_death(remove_effects : Bool)
    if remove_effects
      stop_effects(EffectType::FAKE_DEATH)
    end

    case me = self
    when L2PcInstance
      me.fake_death = false
      me.recent_fake_death = true
    end

    broadcast_packet(ChangeWaitType.new(self, ChangeWaitType::STOP_FAKE_DEATH))
    broadcast_packet(Revive.new(self))
  end

  def movement_disabled? : Bool
    stunned? || rooted? || sleeping? || overloaded? || paralyzed? ||
    immobilized? || looks_dead? || teleporting?
  end

  def can_revive? : Bool
    true
  end

  def can_revive=(val : Bool)
    # no-op
  end

  def out_of_control? : Bool
    confused? || afraid?
  end

  def attacking_disabled? : Bool
    flying? || stunned? || sleeping? || attacking_now? || looks_dead? ||
    paralyzed? || physical_attack_muted? || core_ai_disabled?
  end

  def disable_core_ai(@core_ai_disabled : Bool)
  end

  def give_raid_curse? : Bool
    true
  end

  def target_id : Int32
    @target.try &.l2id || 0
  end

  def has_abnormal_visual_effect?(ave : AbnormalVisualEffect) : Bool
    if ave.event?
      @abnormal_visual_effects_event & ave.mask == ave.mask
    elsif ave.special?
      @abnormal_visual_effects_special & ave.mask == ave.mask
    else
      @abnormal_visual_effects & ave.mask == ave.mask
    end
  end

  def start_abnormal_visual_effect(update : Bool, *aves : AbnormalVisualEffect)
    start_abnormal_visual_effect(update, aves)
  end

  def start_abnormal_visual_effect(update : Bool, aves : Enumerable(AbnormalVisualEffect))
    aves.each do |ave|
      if ave.event?
        @abnormal_visual_effects_event |= ave.mask
      elsif ave.special?
        @abnormal_visual_effects_special |= ave.mask
      else
        @abnormal_visual_effects |= ave.mask
      end
    end

    update_abnormal_effect if update
  end

  def stop_abnormal_visual_effect(update : Bool, *aves : AbnormalVisualEffect)
    stop_abnormal_visual_effect(update, aves)
  end

  def stop_abnormal_visual_effect(update : Bool, aves : Enumerable(AbnormalVisualEffect))
    aves.each do |ave|
      if ave.event?
        @abnormal_visual_effects_event &= ~ave.mask
      elsif ave.special?
        @abnormal_visual_effects_special &= ~ave.mask
      else
        @abnormal_visual_effects &= ~ave.mask
      end
    end

    update_abnormal_effect if update
  end

  def random_damage_multiplier : Float64
    if wp = active_weapon_item
      random = wp.random_damage.to_f64
    else
      random = 5 + Math.sqrt(level)
    end

    1.0 + (Rnd.rand(0.0 - random..random) / 100)
  end

  def break_attack
    if attacking_now?
      abort_attack

      if player?
        action_failed
      end
    end
  end

  def break_cast
    last_skill = last_skill_cast
    if casting_now? && can_abort_cast? && last_skill
      if last_skill.magic? || last_skill.static?
        abort_cast

        if player?
          send_packet(SystemMessageId::CASTING_INTERRUPTED)
        end
      end
    end
  end

  def force_is_casting(new_skill_cast_end_tick : Int32)
    self.casting_now = true
    @cast_interrupt_time = new_skill_cast_end_tick - 4
  end

  def send_damage_message(target, damage, mcrit, pcrit, miss)
    if miss && target.is_a?(L2PcInstance)
      sm = SystemMessage.c1_evaded_c2_attack
      sm.add_pc_name(target)
      sm.add_char_name(self)
      target.send_packet(sm)
    end
  end

  def notify_damage_received(damage, attacker, skill, crit, dot, reflect)
    e1 = OnCreatureDamageReceived.new(attacker, self, damage.to_f64, skill, crit, dot, reflect)
    e1.async(self)
    e2 = OnCreatureDamageDealt.new(attacker, self, damage.to_f64, skill, crit, dot, reflect)
    e2.async(attacker)
  end

  def notify_attack_avoid(target : L2Character, dot : Bool)
    OnCreatureAttackAvoid.new(self, target, dot).async(target)
  end

  def in_party? : Bool
    false
  end

  def party : L2Party?
    # return nil
  end

  def in_active_region? : Bool
    reg = world_region
    !!reg && reg.active?
  end

  def add_override_cond(*conds : PcCondOverride)
    conds.each { |cond| @exceptions |= cond.mask }
  end

  def remove_overrided_cond(*conds : PcCondOverride)
    conds.each { |cond| @exceptions &= ~cond.mask }
  end

  def can_override_cond?(cond : PcCondOverride) : Bool
    @exceptions & cond.mask == cond.mask
  end

  {% for cond in PcCondOverride.constants %}
    def override_{{cond.stringify.downcase.id}}? : Bool
      mask = PcCondOverride::{{cond}}.mask
      @exceptions & mask == mask
    end

    def override_{{cond.stringify.downcase.id}}=(val : Bool)
      mask = PcCondOverride::{{cond}}.mask
      val ? (@exceptions |= mask) : (@exceptions &= ~mask)
    end
  {% end %}

  def override_cond=(@exceptions : Int64)
  end

  def min_level : Int32
    1
  end

  abstract def level : Int32
  abstract def update_abnormal_effect
  abstract def active_weapon_instance : L2ItemInstance?
  abstract def active_weapon_item : L2Weapon?
  abstract def secondary_weapon_instance : L2ItemInstance?
  abstract def secondary_weapon_item : L2Item? # weapons, arrows...

  def inside_radius?(loc : Locatable, radius : Int32, check_z_axis : Bool, strict : Bool) : Bool
    inside_radius?(*loc.xyz, radius, check_z_axis, strict)
  end

  def inside_radius?(x : Int32, y : Int32, z : Int32, radius : Int32, check_z_axis : Bool, strict : Bool) : Bool
    dist = calculate_distance(x, y, z, check_z_axis, true)
    strict ? dist < radius.abs2 : dist <= radius.abs2
  end

  def revalidate_zone(force : Bool)
    return unless reg = world_region

    if force
      @zone_validate_counter = 4i8
    else
      @zone_validate_counter -= 1
      if @zone_validate_counter < 0
        @zone_validate_counter = 4i8
      else
        return
      end
    end

    reg.revalidate_zones(self)
  end

  def set_inside_zone(id : ZoneId, val : Bool)
    @zones_mutex.synchronize do
      if val
        @zones[id.to_i] += 1
      elsif @zones[id.to_i] > 0
        @zones[id.to_i] -= 1
      end
    end
  end

  def inside_zone?(id : ZoneId) : Bool
    case id
    when ZoneId::PVP
      if InstanceManager.get_instance(instance_id).try &.pvp_instance?
        return true
      end

      return @zones[ZoneId::PVP.to_i] > 0 && @zones[ZoneId::PEACE.to_i] == 0
    when ZoneId::PEACE
      if InstanceManager.get_instance(instance_id).try &.pvp_instance?
        return false
      end
    end

    @zones[id.to_i] > 0
  end

  {% for id in ZoneId.constants %}
    def inside_{{id.underscore.id}}_zone? : Bool
      inside_zone?(ZoneId::{{id}})
    end

    def inside_{{id.underscore.id}}_zone=(val : Bool)
      set_inside_zone(ZoneId::{{id}}, val)
    end
  {% end %}

  def inside_peace_zone?(attacker : L2PcInstance) : Bool
    inside_peace_zone?(attacker, self)
  end

  def inside_peace_zone?(attacker : L2Object, target : L2Object?) : Bool
    if attacker.is_a?(L2PcInstance)
      return false unless attacker.access_level.allow_peace_attack?
    end
    return false unless target
    return false unless target.playable? && attacker.playable?
    return false if InstanceManager.get_instance(instance_id).try &.pvp_instance?
    if TerritoryWarManager.player_with_ward_can_be_killed_in_peace_zone?
      if TerritoryWarManager.tw_in_progress?
        if target.is_a?(L2PcInstance) && target.combat_flag_equipped?
          return false
        end
      end
    end

    if Config.alt_game_karma_player_can_be_killed_in_peacezone
      pc_target = target.acting_player
      if pc_target && pc_target.karma > 0
        return false
      end
      pc_attacker = attacker.acting_player
      if pc_attacker && pc_attacker.karma > 0
        if pc_target && pc_target.pvp_flag > 0
          return false
        end
      end
    end

    target.inside_zone?(ZoneId::PEACE) || attacker.inside_zone?(ZoneId::PEACE)
  end

  def tele_to_location(x : Int32, y : Int32, z : Int32, heading : Int32, instance_id : Int32, random_offset : Int32)
    self.instance_id = instance_id

    if @pending_revive
      do_revive
    end

    stop_move(nil, false)
    abort_attack
    abort_cast

    self.teleporting = true
    self.target = nil

    set_intention(AI::ACTIVE)

    if Config.offset_on_teleport_enabled && random_offset > 0
      x += Rnd.rand(-random_offset..random_offset)
      y += Rnd.rand(-random_offset..random_offset)
    end

    z += 5

    broadcast_packet(TeleportToLocation.new(self, x, y, z, heading))

    decay_me

    set_xyz(x, y, z)

    if heading != 0
      self.heading = heading
    end

    me = self
    if !me.is_a?(L2PcInstance) || (me.client.try &.detached?)
      on_teleported
    end

    revalidate_zone(true)
  end

  def tele_to_location(x : Int32, y : Int32, z : Int32, heading : Int32, instance_id : Int32, random_offset : Bool)
    tele_to_location(x, y, z, heading, instance_id, random_offset ? Config.max_offset_on_teleport : 0)
  end

  def tele_to_location(x : Int32, y : Int32, z : Int32, heading : Int32, random_offset : Bool)
    tele_to_location(x, y, z, heading, -1, random_offset ? Config.max_offset_on_teleport : 0)
  end

  def tele_to_location(x : Int32, y : Int32, z : Int32, heading : Int32, instance_id : Int32)
    tele_to_location(x, y, z, heading, instance_id, 0)
  end

  def tele_to_location(x : Int32, y : Int32, z : Int32, heading : Int32)
    tele_to_location(x, y, z, heading, -1, 0)
  end

  def tele_to_location(x : Int32, y : Int32, z : Int32, random_offset : Bool)
    tele_to_location(x, y, z, 0, -1, random_offset ? Config.max_offset_on_teleport : 0)
  end

  def tele_to_location(x : Int32, y : Int32, z : Int32)
    tele_to_location(x, y, z, 0, -1, 0)
  end

  def tele_to_location(loc : Locatable, random_offset : Int32)
    tele_to_location(*loc.xyz, loc.heading, loc.instance_id, random_offset)
  end

  def tele_to_location(loc : Locatable, instance_id : Int32, random_offset : Int32)
    tele_to_location(*loc.xyz, loc.heading, instance_id, random_offset)
  end

  def tele_to_location(loc : Locatable, random_offset : Bool)
    tele_to_location(*loc.xyz, loc.heading, loc.instance_id, random_offset ? Config.max_offset_on_teleport : 0)
  end

  def tele_to_location(loc : Locatable)
    tele_to_location(*loc.xyz, loc.heading, loc.instance_id, 0)
  end

  def tele_to_location(where : TeleportWhereType)
    loc = MapRegionManager.get_tele_to_location(self, where)
    tele_to_location(loc, true)
  end

  def in_combat? : Bool
    ai? && (!!ai.attack_target? || ai.auto_attacking?)
  end

  private class MoveData
    property move_start_time : Int32 = 0
    property move_time_stamp : Int32 = 0
    property x_destination : Int32 = 0
    property y_destination : Int32 = 0
    property z_destination : Int32 = 0
    property x_accurate : Float64 = 0.0
    property y_accurate : Float64 = 0.0
    property z_accurate : Float64 = 0.0
    property heading : Int32 = 0
    property on_geodata_path_index : Int32 = 0
    property geo_path_accurate_tx : Int32 = 0
    property geo_path_accurate_ty : Int32 = 0
    property geo_path_gtx : Int32 = 0
    property geo_path_gty : Int32 = 0
    property! geo_path : Array(AbstractNodeLoc)?
    property? disregarding_geodata : Bool = false
  end

  def update_position : Bool
    unless m = @move
      return true
    end

    unless visible?
      @move = nil
      return true
    end

    if m.move_time_stamp == 0
      m.move_time_stamp = m.move_start_time
      m.x_accurate = x.to_f64
      m.y_accurate = y.to_f64
    end

    ticks = GameTimer.ticks

    if m.move_time_stamp == ticks
      return false
    end

    x_prev, y_prev, z_prev = x, y, z

    if Config.coord_synchronize == 1
      dx = m.x_destination - x_prev
      dy = m.y_destination - y_prev
    else
      dx = m.x_destination - m.x_accurate
      dy = m.y_destination - m.y_accurate
    end

    dx = dx.to_f
    dy = dy.to_f

    floating = flying? || inside_water_zone?

    if Config.coord_synchronize == 2 && !floating && !m.disregarding_geodata? && ticks % 10 == 0 && GeoData.has_geo?(x_prev, y_prev)
      geo_height = GeoData.get_spawn_height(x_prev, y_prev, z_prev)
      dz = m.z_destination - geo_height
      me = self
      if me.is_a?(L2PcInstance) && (me.client_z - geo_height).between?(200, 1500)
        dz = m.z_destination - z_prev
      elsif in_combat? && dz.abs > 200 && dx.abs2 + dy.abs2 < 40_000
        dz = m.z_destination - z_prev
      else
        z_prev = geo_height
      end
    else
      dz = m.z_destination - z_prev
    end
    dz = dz.to_f

    delta = dx.abs2 + dy.abs2

    if delta < 10_000 && dz.abs2 > 2_500 && !floating
      delta = Math.sqrt(delta)
    else
      delta = Math.sqrt(delta + dz.abs2)
    end

    dist_fraction = Float64::MAX

    if delta > 1
      dist_passed = move_speed.to_f64 * (ticks - m.move_time_stamp)
      dist_passed /= GameTimer::TICKS_PER_SECOND
      dist_fraction = dist_passed / delta
    end

    if dist_fraction > 1
      set_xyz(
        m.x_destination.to_i32,
        m.y_destination.to_i32,
        m.z_destination.to_i32
      )
    else
      m.x_accurate += dx * dist_fraction
      m.y_accurate += dy * dist_fraction

      set_xyz(
        m.x_accurate.to_i32,
        m.y_accurate.to_i32,
        (z_prev + ((dz * dist_fraction) + 0.5)).to_i32
      )
    end

    revalidate_zone(false)

    m.move_time_stamp = ticks

    if dist_fraction > 1
      task = -> do
        if Config.move_based_knownlist
          known_list.find_objects
        end

        notify_event(AI::ARRIVED)
      end
      ThreadPoolManager.execute_ai(task)

      return true
    end

    false
  end

  def moving? : Bool
    !!@move
  end

  def x_destination : Int32
    @move.try &.x_destination || x
  end

  def y_destination : Int32
    @move.try &.y_destination || y
  end

  def z_destination : Int32
    @move.try &.z_destination || z
  end

  def on_geodata_path? : Bool
    return false unless m = @move
    return false if m.on_geodata_path_index == -1
    return false if m.on_geodata_path_index == m.geo_path.size - 1
    true
  end

  def move_to_location(x : Int32, y : Int32, z : Int32, offset : Int32)
    speed = move_speed
    return if speed <= 0 || movement_disabled?
    cur_x, cur_y, cur_z = x(), y(), z()

    dx = (x - cur_x).to_f
    dy = (y - cur_y).to_f
    dz = (z - cur_z).to_f
    distance = Math.hypot(dx, dy)

    vertical_movement_only = flying? && distance == 0 && dz != 0
    if vertical_movement_only
      distance = dz.abs
    end

    if inside_water_zone? && distance > 700
      divider = 700.fdiv(distance)
      x = cur_x + (divider * dx).to_i
      y = cur_y + (divider * dy).to_i
      z = cur_z + (divider * dz).to_i
      dx = (x - cur_x).to_f
      dy = (y - cur_y).to_f
      dz = (z - cur_z).to_f
      distance = Math.hypot(dx, dy)
    end

    if offset > 0 || distance < 1
      offset -= dz.abs.to_i
      offset = 5 if offset < 5

      if distance < 1 || distance - offset <= 0
        notify_event(AI::ARRIVED)
        return
      end

      sin = dy / distance
      cos = dx / distance

      distance -= offset - 5

      x = cur_x + (distance * cos).to_i
      y = cur_y + (distance * sin).to_i
    else
      sin = dy / distance
      cos = dx / distance
    end

    m = MoveData.new
    m.on_geodata_path_index = -1
    m.disregarding_geodata = false

    if !flying? && (!inside_water_zone? || inside_siege_zone?)
      me = self
      in_vehicle = me.is_a?(L2PcInstance) && !!me.vehicle

      if in_vehicle
        m.disregarding_geodata = true
      end

      original_distance = distance
      original_x = x
      original_y = y
      original_z = z
      gtx = (original_x - L2World::MAP_MAX_X) >> 4
      gty = (original_y - L2World::MAP_MAX_Y) >> 4

      if Config.pathfinding > 0 && (!(me.is_a?(L2Attackable) && me.returning_to_spawn_point?)) || (player? && !(in_vehicle && distance > 1500)) || is_a?(L2RiftInvaderInstance)
        if (m2 = @move) && on_geodata_path?
          if gtx == m2.geo_path_gtx && gty == m2.geo_path_gty
            return
          end

          m2.on_geodata_path_index = -1
        end

        unless cur_x.between?(L2World::MAP_MIN_X, L2World::MAP_MAX_X)
          unless cur_y.between?(L2World::MAP_MIN_Y, L2World::MAP_MAX_Y)
            warn { "Outside of world area at #{cur_x} #{cur_y}." }
            set_intention(AI::IDLE)
            if me.is_a?(L2PcInstance)
              me.logout
            elsif summon?
              return
            else
              on_decay
            end

            return
          end
        end

        dst = GeoData.move_check(cur_x, cur_y, cur_z, x, y, z, instance_id)
        x, y, z = dst.xyz
        dx = (x - cur_x).to_f
        dy = (y - cur_y).to_f
        dz = (z - cur_z).to_f
        distance = vertical_movement_only ? Math.pow(dz, 2) : Math.hypot(dx, dy)
      end

      if Config.pathfinding > 0 && original_distance - distance > 30 && distance < 2000
        if (playable? && !in_vehicle) || minion? || in_combat? ||         (npc? && walker?) || is_a?(L2Decoy) # custom, force
          m.geo_path = PathFinding.find_path(cur_x, cur_y, cur_z, original_x, original_y, original_z, instance_id, playable?)
          if !m.geo_path? || m.geo_path.size < 0
            # debug "path not found." if !npc? || !known_list.known_players.empty?
            if player? || (!playable? && !minion? && (z - cur_z).abs > 140) || (me.is_a?(L2Summon) && !me.follow_status)
              set_intention(AI::IDLE)
              return
            end

            m.disregarding_geodata = true
            x = original_x
            y = original_y
            z = original_z
            distance = original_distance
          else
            m.on_geodata_path_index = 0
            m.geo_path_gtx = gtx
            m.geo_path_gty = gty
            m.geo_path_accurate_tx = original_x
            m.geo_path_accurate_ty = original_y

            tmp = m.geo_path[m.on_geodata_path_index]
            x, y, z = tmp.x, tmp.y, tmp.z

            if DoorData.check_if_doors_between(cur_x, cur_y, cur_z, x, y, z, instance_id)
              m.geo_path = nil
              set_intention(AI::IDLE)
              return
            end
            (m.geo_path.size - 1).times do |i|
              if DoorData.check_if_doors_between(m.geo_path[i], m.geo_path[i + 1], instance_id)
                m.geo_path = nil
                set_intention(AI::IDLE)
                return
              end
            end

            dx = (x - cur_x).to_f
            dy = (y - cur_y).to_f
            dz = (z - cur_z).to_f
            distance = vertical_movement_only ? Math.pow(dz, 2) : Math.hypot(dx, dy)
            sin = dy / distance
            cos = dx / distance
          end
        end
      end

      if distance < 1 && (Config.pathfinding > 0 || playable? || is_a?(L2RiftInvaderInstance) || afraid?)
        if me.is_a?(L2Summon)
          me.follow_status = false
        end

        set_intention(AI::IDLE)

        return
      end
    end

    if (flying? || inside_water_zone?) && !vertical_movement_only
      distance = Math.hypot(distance, dz)
    end

    ticks_to_move = 1 + ((GameTimer::TICKS_PER_SECOND * distance) / speed).to_i

    m.x_destination = x
    m.y_destination = y
    m.z_destination = z
    m.heading = 0

    unless vertical_movement_only
      self.heading = Util.calculate_heading_from(cos, sin)
    end

    m.move_start_time = GameTimer.ticks

    @move = m

    GameTimer.register(self)

    if ticks_to_move * GameTimer::MILLIS_IN_TICK > 3_000
      task = NotifyAITask.new(self, AI::ARRIVED_REVALIDATE)
      ThreadPoolManager.schedule_ai(task, 2000)
    end
  end

  def move_to_next_route_point : Bool
    unless on_geodata_path?
      @move = nil
      return false
    end

    speed = move_speed

    if speed <= 0 || movement_disabled?
      @move = nil
      return false
    end

    unless md = @move
      return false
    end

    m = MoveData.new

    m.on_geodata_path_index = md.on_geodata_path_index + 1
    m.geo_path = md.geo_path
    m.geo_path_gtx = md.geo_path_gtx
    m.geo_path_gty = md.geo_path_gty
    m.geo_path_accurate_tx = md.geo_path_accurate_tx
    m.geo_path_accurate_ty = md.geo_path_accurate_ty

    route_point = md.geo_path[m.on_geodata_path_index]

    if md.on_geodata_path_index == md.geo_path.size - 2
      m.x_destination = md.geo_path_accurate_tx
      m.y_destination = md.geo_path_accurate_ty
    else
      m.x_destination = route_point.x
      m.y_destination = route_point.y
    end
    m.z_destination = route_point.z

    x, y = x(), y()

    distance = Math.hypot(m.x_destination - x, m.y_destination - y)

    if distance != 0
      self.heading = Util.calculate_heading_from(x, y, m.x_destination, m.y_destination)
    end

    ticks_to_move = 1 + ((GameTimer::TICKS_PER_SECOND * distance) / speed).to_i

    m.heading = 0
    m.move_start_time = GameTimer.ticks

    @move = m

    GameTimer.register(self)

    if ticks_to_move * GameTimer::MILLIS_IN_TICK > 3000
      task = NotifyAITask.new(self, AI::ARRIVED_REVALIDATE)
      ThreadPoolManager.schedule_ai(task, 2000)
    end

    broadcast_packet(MoveToLocation.new(self))

    true
  end

  def stop_move(loc : Location?)
    stop_move(loc, false)
  end

  def stop_move(loc : Location?, update_known_objects : Bool)
    @move = nil

    if loc
      set_xyz(*loc.xyz)
      self.heading = loc.heading
      revalidate_zone(true)
    end

    broadcast_packet(StopMove.new(self))

    if Config.move_based_knownlist && update_known_objects
      known_list.find_objects
    end
  end

  def validate_movement_heading(heading : Int32) : Bool
    return true unless m = @move

    result = true
    if m.heading != heading
      result = m.heading == 0
      m.heading = heading
    end
    result
  end

  def debugger? : Bool
    !!@debugger
  end

  def send_debug_packet(gsp : GameServerPacket)
    @debugger.try &.send_packet(gsp)
  end

  def send_debug_message(& : -> String)
    @debugger.try &.send_message(yield)
  end

  def send_debug_message(msg : String)
    send_debug_message { msg }
  end

  def say(msg : NpcString | String)
    if player?
      cs = CreatureSay.new(l2id, Packets::Incoming::Say2::ALL, name, msg)
    else
      cs = CreatureSay.new(l2id, Packets::Incoming::Say2::NPC_ALL, name, msg)
    end

    broadcast_packet(cs)
  end

  def shout(msg : NpcString | String)
    if player?
      cs = CreatureSay.new(l2id, Packets::Incoming::Say2::SHOUT, name, msg)
    else
      cs = CreatureSay.new(l2id, Packets::Incoming::Say2::NPC_SHOUT, name, msg)
    end

    broadcast_packet(cs)
  end

  private def bad_coords
    decay_me
  end

  # custom methods

  def alive? : Bool
    !dead?
  end

  def max_cp! : self
    self.current_cp = max_cp.to_f64
    self
  end

  def max_hp! : self
    self.current_hp = max_hp.to_f64
    self
  end

  def max_mp! : self
    self.current_mp = max_mp.to_f64
    self
  end

  def heal! : self
    max_cp!.max_hp!.max_mp!
  end
end
