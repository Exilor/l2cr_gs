require "../network/**"
require "./skills/buff_info"
require "../util/linked_list"

class CharEffectList
  include Packets::Outgoing
  include Synchronizable
  include Enumerable(BuffInfo)

  @effect_flags = 0
  @has_buffs_removed_on_action = false
  @has_buffs_removed_on_damage = false
  @has_debuffs_removed_on_damage = false
  @party_only = false
  @buffs : Interfaces::List(BuffInfo)?
  @debuffs : Interfaces::List(BuffInfo)?
  @dances : Interfaces::List(BuffInfo)?
  @passives : Interfaces::List(BuffInfo)?
  @toggles : Interfaces::List(BuffInfo)?
  @triggered : Interfaces::List(BuffInfo)?
  @blocked_buff_slots : Interfaces::Set(AbnormalType)?
  @hidden_buffs = Atomic(Int32).new(0)

  property short_buff : BuffInfo?

  initializer owner : L2Character

  def buffs : Interfaces::List(BuffInfo)
    @buffs || sync { @buffs ||= Concurrent::LinkedList(BuffInfo).new }
  end

  def debuffs : Interfaces::List(BuffInfo)
    @debuffs || sync { @debuffs ||= Concurrent::LinkedList(BuffInfo).new }
  end

  def dances : Interfaces::List(BuffInfo)
    @dances || sync { @dances ||= Concurrent::LinkedList(BuffInfo).new }
  end

  def passives : Interfaces::List(BuffInfo)
    @passives || sync { @passives ||= Concurrent::LinkedList(BuffInfo).new }
  end

  def toggles : Interfaces::List(BuffInfo)
    @toggles || sync { @toggles ||= Concurrent::LinkedList(BuffInfo).new }
  end

  def triggered : Interfaces::List(BuffInfo)
    @triggered || sync { @triggered ||= Concurrent::LinkedList(BuffInfo).new }
  end

  private def stacked_effects : Interfaces::Map(AbnormalType, BuffInfo)
    @stacked_effects || sync do
      @stacked_effects ||= Concurrent::Map(AbnormalType, BuffInfo).new
    end
  end

  def blocked_buff_slots : Interfaces::Set(AbnormalType)
    @blocked_buff_slots || sync do
      @blocked_buff_slots ||= Concurrent::Set(AbnormalType).new
    end
  end

  private def each_with_list(& : BuffInfo, Interfaces::List(BuffInfo) ->) : Nil
    @buffs.try     { |list| list.safe_each { |info| yield(info, list) } }
    @triggered.try { |list| list.safe_each { |info| yield(info, list) } }
    @dances.try    { |list| list.safe_each { |info| yield(info, list) } }
    @toggles.try   { |list| list.safe_each { |info| yield(info, list) } }
    @debuffs.try   { |list| list.safe_each { |info| yield(info, list) } }
  end

  def each(dances : Bool = true, & : BuffInfo ->) : Nil
    @buffs.try     &.each { |info| yield(info) }
    @triggered.try &.each { |info| yield(info) }
    @dances.try    &.each { |info| yield(info) } if dances
    @toggles.try   &.each { |info| yield(info) }
    @debuffs.try   &.each { |info| yield(info) }
  end

  def for_each(dances : Bool, & : BuffInfo -> Bool) : Nil
    update = false
    @buffs.try     &.each { |info| update |= yield(info) }
    @triggered.try &.each { |info| update |= yield(info) }
    @dances.try    &.each { |info| update |= yield(info) } if dances
    @toggles.try   &.each { |info| update |= yield(info) }
    @debuffs.try   &.each { |info| update |= yield(info) }
    update_effect_list(update)
  end

  def effects : Indexable(BuffInfo)
    return Slice(BuffInfo).empty if empty?

    ret = [] of BuffInfo
    ret.concat(buffs)     if has_buffs?
    ret.concat(triggered) if has_triggered?
    ret.concat(dances)    if has_dances?
    ret.concat(toggles)   if has_toggles?
    ret.concat(debuffs)   if has_debuffs?
    ret
  end

  def get_effect_list(skill : Skill) : Interfaces::List(BuffInfo)
    return passives  if skill.passive?
    return debuffs   if skill.debuff?
    return triggered if skill.trigger?
    return dances    if skill.dance?
    return toggles   if skill.toggle?
    buffs
  end

  def get_first_effect(type : EffectType) : BuffInfo?
    find &.effects.any? { |effect| effect.effect_type == type }
  end

  def get_buff_info_by_skill_id(id : Int32) : BuffInfo?
    find { |info| info.skill.id == id } ||
    @passives.try &.find { |info| info.skill.id == id }
  end

  def affected_by_skill?(id : Int32) : Bool
    !!get_buff_info_by_skill_id(id)
  end

  def get_buff_info_by_abnormal_type(type : AbnormalType)
    @stacked_effects.try &.[type]?
  end

  def add_blocked_buff_slots(slots : Enumerable(AbnormalType))
    blocked_buff_slots.concat(slots)
  end

  def remove_blocked_buff_slots(slots : Enumerable(AbnormalType))
    @blocked_buff_slots.try &.subtract(slots)
  end

  def short_buff_status_update(info : BuffInfo?)
    if @owner.player?
      @short_buff = info

      if info
        id = info.skill.id
        level = info.skill.level
        time = info.time
        @owner.send_packet(ShortBuffStatusUpdate.new(id, level, time))
      else
        @owner.send_packet(ShortBuffStatusUpdate::CLEAR)
      end
    end
  end

  private def stacks?(skill : Skill) : Bool
    type = skill.abnormal_type
    return false if type.none? || empty?
    get_effect_list(skill).any? { |info| info.skill.abnormal_type == type }
  end

  def buff_count : Int32
    return 0 unless buffs = @buffs
    buffs.size &- @hidden_buffs.get &- (@short_buff ? 1 : 0)
  end

  def dance_count : Int32
    @dances.try &.size || 0
  end

  def triggered_buff_count : Int32
    @triggered.try &.size || 0
  end

  def hidden_buffs_count : Int32
    @hidden_buffs.get
  end

  def stop_and_remove(info : BuffInfo)
    stop_and_remove(true, info, get_effect_list(info.skill))
  end

  def stop_and_remove(info : BuffInfo, effect_list)
    stop_and_remove(true, info, effect_list)
  end

  def stop_and_remove(removed : Bool, info : BuffInfo, effect_list)
    return unless effect_list

    effect_list.delete_first(info)
    info.stop_all_effects(removed)

    if !info.in_use?
      @hidden_buffs.sub(1)
    elsif temp = @stacked_effects
      temp.delete(info.skill.abnormal_type)
    end

    if info.skill.abnormal_instant? && has_buffs?
      effect_list.each do |buff|
        if buff.skill.abnormal_type == info.skill.abnormal_type
          unless buff.in_use?
            buff.in_use = true
            buff.add_stats
            if temp = @stacked_effects
              temp[buff.skill.abnormal_type] = buff
            end

            @hidden_buffs.sub(1)
            break
          end
        end
      end
    end

    unless removed
      info.skill.apply_effect_scope(EffectScope::STOP, info, true, false)
    end
  end

  def stop_all_effects
    stop_all_buffs(false, true)
    stop_all_dances(false)
    stop_all_toggles(false)
    stop_all_debuffs(false)

    @stacked_effects.try &.clear

    update_effect_list(true)
  end

  def stop_all_effects_except_those_that_last_through_death
    update = false

    each_with_list do |info, list|
      unless info.skill.stay_after_death?
        stop_and_remove(info, list)
        update = true
      end
    end

    update_effect_list(update)
  end

  def stop_all_effects_not_stay_on_subclass_change
    update = false

    each_with_list do |info, list|
      unless info.skill.stay_on_subclass_change?
        stop_and_remove(info, list)
        update = true
      end
    end

    update_effect_list(update)
  end

  def stop_all_buffs(update : Bool, stop_triggered : Bool)
    @buffs.try &.safe_each { |i| stop_and_remove(i, buffs) }

    if stop_triggered
      @triggered.try &.safe_each { |i| stop_and_remove(i, triggered) }
    end

    update_effect_list(update)
  end

  def stop_all_toggles(update : Bool = true)
    if has_toggles?
      toggles.safe_each { |i| stop_and_remove(i, toggles) }
      update_effect_list(update)
    end
  end

  def stop_all_dances(update : Bool = true)
    if has_dances?
      dances.safe_each { |i| stop_and_remove(i, dances) }
      update_effect_list(update)
    end
  end

  def stop_all_debuffs(update : Bool = true)
    if has_debuffs?
      debuffs.safe_each { |i| stop_and_remove(i, debuffs) }
      update_effect_list(update)
    end
  end

  def stop_effects(type : EffectType)
    update = false

    each_with_list do |info, list|
      info.effects.each do |effect|
        if effect.effect_type == type
          stop_and_remove(info, list)
          update = true
        end
      end
    end

    update_effect_list(update)
  end

  def stop_skill_effects(removed : Bool, id : Int32)
    get_buff_info_by_skill_id(id).try { |info| remove(removed, info) }
  end

  def stop_skill_effects(removed : Bool, skill : Skill)
    stop_skill_effects(removed, skill.id)
  end

  def stop_skill_effects(removed : Bool, type : AbnormalType) : Bool
    if effects = @stacked_effects
      if old = effects.delete(type)
        stop_skill_effects(removed, old.skill)
        return true
      end
    end

    false
  end

  def stop_effects_on_action
    return unless @has_buffs_removed_on_any_action

    update = false

    each_with_list do |info, list|
      if info.skill.removed_on_any_action_except_move?
        stop_and_remove(info, list)
        update = true
      end
    end

    update_effect_list(update)
  end

  def stop_effects_on_damage(awake : Bool)
    return unless awake

    update = false

    if @has_buffs_removed_on_damage
      @buffs.try &.safe_each do |info|
        if info.skill.removed_on_damage?
          stop_and_remove(info, @buffs)
        end
      end

      @triggered.try &.safe_each do |info|
        if info.skill.removed_on_damage?
          stop_and_remove(info, @triggered)
        end
      end

      @dances.try &.safe_each do |info|
        if info.skill.removed_on_damage?
          stop_and_remove(info, @dances)
        end
      end

      @toggles.try &.safe_each do |info|
        if info.skill.removed_on_damage?
          stop_and_remove(info, @toggles)
        end
      end

      update = true
    end

    if @has_debuffs_removed_on_damage
      debuffs.safe_each do |info|
        if info.skill.removed_on_damage?
          stop_and_remove(info, @debuffs)
        end
      end

      update = true
    end

    update_effect_list(update)
  end

  def empty? : Bool
    none?
  end

  def has_buffs? : Bool
    return false unless list = @buffs
    !list.empty?
  end

  def has_debuffs? : Bool
    return false unless list = @debuffs
    !list.empty?
  end

  def has_triggered? : Bool
    return false unless list = @triggered
    !list.empty?
  end

  def has_dances? : Bool
    return false unless list = @dances
    !list.empty?
  end

  def has_toggles? : Bool
    return false unless list = @toggles
    !list.empty?
  end

  def has_passives? : Bool
    return false unless list = @passives
    !list.empty?
  end

  def remove(removed : Bool, info : BuffInfo)
    stop_and_remove(removed, info, get_effect_list(info.skill))
    update_effect_list(true)
  end

  def add(info : BuffInfo)
    skill = info.skill

    if blocked_slots = @blocked_buff_slots
      if blocked_slots.includes?(skill.abnormal_type)
        return
      end
    end

    if skill.passive?
      unless skill.check_condition(info.effector, info.effected, false)
        return
      end

      passives = passives()
      passives.safe_each do |b|
        if b.skill.id == skill.id
          b.in_use = false
          b.remove_stats
          passives.delete_first(b)
        end
      end

      passives << info

      info.initialize_effects

      return
    end

    return if info.effected.dead? && info.effector != info.effected

    if skill.abnormal_type.none?
      stop_skill_effects(true, skill)
    else
      stacked_effects = stacked_effects()
      if stacked_effects.has_key?(skill.abnormal_type)
        stacked_info = stacked_effects[skill.abnormal_type]?

        if stacked_info && skill.abnormal_lvl >= stacked_info.skill.abnormal_lvl
          if skill.abnormal_instant?
            if stacked_info.skill.abnormal_instant?
              stop_skill_effects(true, skill.abnormal_type)
            end

            if stacked_info = stacked_effects[skill.abnormal_type]?
              stacked_info.in_use = false
              stacked_info.remove_stats
              @hidden_buffs.add(1)
            end
          else
            if stacked_info.skill.abnormal_instant?
              stop_skill_effects(true, skill.abnormal_type)
            end

            stop_skill_effects(true, skill.abnormal_type)
          end
        else
          return
        end
      end

      stacked_effects[skill.abnormal_type] = info
    end

    effects = get_effect_list(skill)

    if !skill.debuff? && !skill.toggle? && !skill.seven_signs? && !stacks?(skill)
      to_remove = -1

      if skill.dance?
        to_remove = dance_count &- Config.dances_max_amount
      elsif skill.trigger?
        to_remove = triggered_buff_count &- Config.triggered_buffs_max_amount
      elsif !skill.healing_potion_skill?
        to_remove = buff_count &- @owner.stat.max_buff_count
      end

      effects.safe_each do |info|
        if to_remove < 0
          break
        end

        unless info.in_use?
          next
        end


        if info.skill.abnormal_type.summon_condition?
          next
        end

        stop_and_remove(info, effects)

        to_remove &-= 1
      end
    end

    effects << info
    info.initialize_effects
    update_effect_list(true)
  end

  def update_effect_icons(party_only : Bool)
    if party_only
      @party_only = true
    end

    update_effect_list(true)
  end

  def update_effect_icons
    update_effect_flags

    return unless @owner.playable?

    asu = nil # AbnormalStatusUpdate
    ps  = nil # PartySpelled
    pss = nil # PartySpelled
    os  = nil # ExOlympiadSpelledInfo

    is_summon = false

    case owner = @owner
    when L2PcInstance
      if @party_only
        @party_only = false
      else
        asu = AbnormalStatusUpdate.new
      end

      if owner.in_party?
        ps = PartySpelled.new(owner)
      end

      if owner.in_olympiad_mode?
        if owner.olympiad_start?
          os = ExOlympiadSpelledInfo.new(owner)
        end
      end
    when L2Summon
      is_summon = true
      ps = PartySpelled.new(owner)
      pss = PartySpelled.new(owner)
    end

    @buffs.try &.each do |info|
      if info.skill.healing_potion_skill?
        short_buff_status_update(info)
      else
        add_icon(info, asu, ps, pss, os, is_summon)
      end
    end

    @triggered.try &.each { |i| add_icon(i, asu, ps, pss, os, is_summon) }
    @dances.try    &.each { |i| add_icon(i, asu, ps, pss, os, is_summon) }
    @toggles.try   &.each { |i| add_icon(i, asu, ps, pss, os, is_summon) }
    @debuffs.try   &.each { |i| add_icon(i, asu, ps, pss, os, is_summon) }

    @owner.send_packet(asu) if asu

    if ps
      case owner
      when L2Summon
        summon_owner = owner.owner
        if pss && (party = summon_owner.party)
          party.broadcast_to_party_members(summon_owner, pss)
        end
        summon_owner.send_packet(ps)
      when L2PcInstance
        if party = owner.party
          party.broadcast_packet(ps)
        end
      end
    end

    if os
      game_id = owner.acting_player.not_nil!.olympiad_game_id
      game = OlympiadGameManager.get_olympiad_task(game_id)
      if game && game.battle_started?
        game.zone.broadcast_packet_to_observers(os)
      end
    end
  end

  private def add_icon(info, asu, ps, pss, os, is_summon)
    return unless info && info.in_use?
    skill = info.skill

    if asu
      asu.add_skill(info)
    end

    if ps && (is_summon || !skill.toggle?)
      ps.add_skill(info)
    end

    if pss && (is_summon || !skill.toggle?)
      pss.add_skill(info)
    end

    if os
      os.add_skill(info)
    end
  end

  private def update_effect_list(update)
    return unless update
    update_effect_icons
    compute_effect_flags
  end

  private def update_effect_flags
    @buffs.try &.each do |info|
      if info.skill.removed_on_any_action_except_move?
        @has_buffs_removed_on_any_action = true
      end

      if info.skill.removed_on_damage?
        @has_buffs_removed_on_damage = true
      end
    end

    @triggered.try &.each do |info|
      if info.skill.removed_on_any_action_except_move?
        @has_buffs_removed_on_any_action = true
      end

      if info.skill.removed_on_damage?
        @has_buffs_removed_on_damage = true
      end
    end

    @toggles.try &.each do |info|
      if info.skill.removed_on_any_action_except_move?
        @has_buffs_removed_on_any_action = true
      end

      if info.skill.removed_on_damage?
        @has_buffs_removed_on_damage = true
      end
    end

    @debuffs.try &.each do |info|
      if info.skill.removed_on_damage?
        @has_debuffs_removed_on_damage = true
      end
    end
  end

  private def compute_effect_flags
    @effect_flags = reduce(0) do |flags, info|
      info.effects.reduce(flags) { |f, e| f | e.effect_flags }
    end
  end

  def affected?(flag : EffectFlag) : Bool
    @effect_flags & flag.mask != 0
  end

  def to_log(io : IO)
    io.print("CharEffectList(", @owner.name, ')')
  end
end
