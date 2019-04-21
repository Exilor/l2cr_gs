require "./l2_playable"
require "./ai/l2_summon_ai"
require "./known_list/summon_known_list"
require "./stat/summon_stat"
require "./status/summon_status"

abstract class L2Summon < L2Playable
  private PASSIVE_SUMMONS = {
    12564, 12621, 14702, 14703, 14704, 14705, 14706, 14707, 14708, 14709, 14710,
    14711, 14712, 14713, 14714, 14715, 14716, 14717, 14718, 14719, 14720, 14721,
    14722, 14723, 14724, 14725, 14726, 14727, 14728, 14729, 14730, 14731, 14732,
    14733, 14734, 14735, 14736
  }

  @shots_mask = 0
  @previous_follow_status = true
  getter follow_status = true # L2R: @follow
  getter attack_range = 36
  getter? restore_summon = true
  property! owner : L2PcInstance

  def initialize(template : L2NpcTemplate, @owner : L2PcInstance)
    super(template)

    self.instance_id = owner.instance_id
    self.show_summon_animation = true
    ai
    x = owner.x + Rnd.rand(-100..100)
    y = owner.y + Rnd.rand(-100..100)
    set_xyz_invisible(x, y, owner.z)

    template.skills.each_value do |skill|
      add_skill(skill)
    end

    Formulas.add_funcs_to_new_summon(self)
  end

  def acting_player?
    owner?
  end

  def acting_player
    owner
  end

  def init_known_list
    @known_list = SummonKnownList.new(self)
  end

  def init_stat
    @stat = SummonStat.new(self)
  end

  def init_status
    @status = SummonStatus.new(self)
  end

  def init_ai
    L2SummonAI.new(self)
  end

  def template
    super.as(L2NpcTemplate)
  end

  def instance_type : InstanceType
    InstanceType::L2Summon
  end

  def id : Int32
    template.id
  end

  def karma : Int32
    owner.karma
  end

  def pvp_flag : Int8
    owner.pvp_flag
  end

  def send_packet(gsp)
    owner?.try &.send_packet(gsp)
  end

  def broadcast_packet(gsp)
    if owner?
      gsp.invisible = owner.invisible?
    end

    super
  end

  def broadcast_packet(gsp, radius : Int)
    if owner?
      gsp.invisible = owner.invisible?
    end

    super
  end

  def party? : L2Party?
    owner?.try &.party?
  end

  def in_party? : Bool
    return false unless owner = owner?
    owner.in_party?
  end

  def on_spawn
    super

    if Config.summon_store_skill_cooltime && !teleporting?
      restore_effects
    end

    self.follow_status = true
    update_and_broadcast_status(0)
    rc = RelationChanged.new(self, owner.get_relation(owner), false)
    send_packet(rc)
    owner.known_list.each_player(800) do |pc|
      relation = owner.get_relation(pc)
      rc = RelationChanged.new(self, relation, auto_attackable?(pc))
      pc.send_packet(rc)
    end
    if party = owner.party?
      party.broadcast_to_party_members(owner, ExPartyPetWindowAdd.new(self))
    end
    self.show_summon_animation = false
    @restore_summon = false
    OnPlayerSummonSpawn.new(self).async(self)
  end

  def update_abnormal_effect
    known_list.known_players.each_value do |pc|
      pc.send_packet(SummonInfo.new(self, pc, 1))
    end
  end

  def control_l2id : Int32
    0
  end

  def soulshots_per_hit : Int32
    Math.max(template.soulshot, 1)
  end

  def spiritshots_per_hit : Int32
    Math.max(template.spiritshot, 1)
  end

  def follow_status=(val : Bool)
    @follow_status = val

     if val
      set_intention(AI::FOLLOW, owner)
    else
      set_intention(AI::IDLE)
    end
  end

  def follow_owner
    self.follow_status = true
  end

  def broadcast_status_update
    super
    update_and_broadcast_status(1)
  end

  def update_and_broadcast_status(val : Int32)
    return unless owner?
    send_packet(PetInfo.new(self, val))
    send_packet(PetStatusUpdate.new(self))
    broadcast_npc_info(val) if visible?
    if party = owner.party?
      party.broadcast_to_party_members(owner, ExPartyPetWindowUpdate.new(self))
    end
    update_effect_icons(true)
  end

  def broadcast_npc_info(val : Int32)
    known_list.known_players.each_value do |pc|
      unless pc == owner
        pc.send_packet(SummonInfo.new(self, pc, val))
      end
    end
  end

  def delete_me(owner : L2PcInstance?)
    if owner
      owner.send_packet(PetDelete.new(summon_type, l2id))
      if party = owner.party?
        party.broadcast_to_party_members(owner, ExPartyPetWindowDelete.new(self))
      end
      owner.active_shots.each do |item_id|
        handler = ItemTable[item_id].as(L2EtcItem).handler_name
        if handler.try &.includes?("Beast")
          owner.disable_auto_shot(item_id)
        end
      end
    end

    inventory?.try &.destroy_all_items("pet deleted", owner, self)
    decay_me
    known_list.remove_all_known_objects
    owner?.try &.pet = nil

    super()
  end

  def unsummon(owner : L2PcInstance?)
    if visible? && alive?
      ai.stop_follow

      if owner
        owner.send_packet(PetDelete.new(summon_type, l2id))
        if party = owner.party?
          party.broadcast_to_party_members(owner, ExPartyPetWindowDelete.new(self))
        end
        if inventory? && inventory.size > 0
          owner().has_pet_items = true
          send_packet(SystemMessageId::ITEMS_IN_PET_INVENTORY)
        else
          owner().has_pet_items = false
        end
      end

      abort_attack
      abort_cast
      store_me
      store_effect(true)
      owner.try &.pet = nil
      ai.stop_ai_task if ai?
      stop_all_effects
      old_region = world_region?
      decay_me
      old_region.try &.remove_from_zones(self)
      known_list.remove_all_known_objects
      self.target = nil
      if owner
        owner.active_shots.each do |item_id|
          handler = ItemTable[item_id].as(L2EtcItem).handler_name
          if handler.try &.includes?("Beast")
            owner.disable_auto_shot(item_id)
          end
        end
      end
    end
  end

  def stop_all_effects
    super
    update_and_broadcast_status(1)
  end

  def stop_all_effects_except_those_that_last_through_death
    super
    update_and_broadcast_status(1)
  end

  def auto_attackable?(attacker : L2Character) : Bool
    !!owner? && owner.auto_attackable?(attacker)
  end

  def mountable? : Bool
    false
  end

  def exp_for_this_level
    return 0 if level >= Config.max_pet_level + 1
    ExperienceData.get_exp_for_level(level)
  end

  def exp_for_next_level
    return 0 if level >= Config.max_pet_level
    ExperienceData.get_exp_for_level(level + 1)
  end

  def team : Team
    owner?.try &.team || Team::NONE
  end

  def do_die(killer : L2Character?) : Bool
    if noblesse_blessing_affected?
      stop_effects(L2EffectType::NOBLESSE_BLESSING)
      store_effect(true)
    else
      store_effect(false)
    end

    return false unless super(killer)

    if owner = owner?
      known_list.each_character do |mob|
        if mob.is_a?(L2Attackable) && mob.alive?
          if info = mob.aggro_list[self]?
            mob.add_damage_hate(owner, info.damage, info.hate)
          end
        end
      end
    end

    DecayTaskManager.add(self)
    true
  end

  def do_die(killer : L2Character?, decayed : Bool) : Bool
    return false unless super(killer)
    DecayTaskManager.add(self) unless decayed
    true
  end

  def on_decay
    delete_me(@owner)
  end

  def stop_decay
    DecayTaskManager.cancel(self)
  end

  def active_weapon_item? : L2Weapon?
    # return nil
  end

  def inventory? : PetInventory?
    # return nil
  end

  def active_weapon_instance? : L2ItemInstance?
    # return nil
  end

  def secondary_weapon_instance? : L2ItemInstance?
    # return nil
  end

  def secondary_weapon_item? : L2Weapon?
    # return nil
  end

  def restore_summon=(val : Bool)
    # no-op
  end

  def invul? : Bool
    super || owner.spawn_protected?
  end

  def use_magic(skill : Skill?, force : Bool, dont_move : Bool) : Bool
    return false unless skill
    return false if dead?
    return false unless owner?
    return false if skill.passive?
    return false if casting_now?

    owner.set_current_pet_skill(skill, force, dont_move)

    case skill.target_type
    when .owner_pet?
      target = owner
    when .party?, .aura?, .front_aura?, .behind_aura?, .self?,
         .aura_corpse_mob?, .command_channel?, .aura_undead_enemy?
      target = self
    else
      target = skill.get_first_of_target_list(self)
    end

    unless target
      send_packet(SystemMessageId::TARGET_CANT_FOUND)
      return false
    end

    if skill_disabled?(skill)
      send_packet(SystemMessageId::PET_SKILL_CANNOT_BE_USED_RECHARCHING)
      return false
    end

    if current_mp < stat.get_mp_consume1(skill) + stat.get_mp_consume2(skill)
      send_packet(SystemMessageId::NOT_ENOUGH_MP)
      return false
    end

    if current_hp <= skill.hp_consume
      send_packet(SystemMessageId::NOT_ENOUGH_HP)
      return false
    end

    if self != target && skill.physical? && Config.pathfinding > 0
      unless PathFinding.find_path(x, y, z, *target.xyz, instance_id, true)
        send_packet(SystemMessageId::CANT_SEE_TARGET)
        return false
      end
    end

    if skill.bad?
      return false if @owner == target

      if inside_peace_zone?(self, target) && !owner.access_level.allow_peace_attack?
        send_packet(SystemMessageId::TARGET_IN_PEACEZONE)
        return false
      end

      if owner.in_olympiad_mode? && !owner.olympiad_start?
        action_failed
        return false
      end

      if target.acting_player? && owner.siege_state > 0 && owner.inside_siege_zone?
        if target.acting_player.siege_state == owner.siege_state
          if target.acting_player != owner
            if target.acting_player.siege_side == owner.siege_side
              if TerritoryWarManager.tw_in_progress?
                send_packet(SystemMessageId::YOU_CANNOT_ATTACK_A_MEMBER_OF_THE_SAME_TERRITORY)
              else
                send_packet(SystemMessageId::FORCED_ATTACK_IS_IMPOSSIBLE_AGAINST_SIEGE_SIDE_TEMPORARY_ALLIED_MEMBERS)
              end

              action_failed
              return false
            end
          end
        end
      end

      if target.door?
        unless target.auto_attackable?(owner)
          return false
        end
      else
        if !target.can_be_attacked? && !owner.access_level.allow_peace_attack?
          return false
        end

        if !target.auto_attackable?(self) && !force && !target.npc? && !skill.target_type.aura? && !skill.target_type.front_aura? && !skill.target_type.behind_aura? && !skill.target_type.clan? && !skill.target_type.party? && !skill.target_type.self?
          return false
        end
      end
    end

    set_intention(AI::CAST, skill, target)

    true
  end

  def send_damage_message(target, damage, mcrit, pcrit, miss)
    return if miss

    if target != owner
      if pcrit || mcrit
        if servitor?
          send_packet(SystemMessageId::CRITICAL_HIT_BY_SUMMONED_MOB)
        else
          send_packet(SystemMessageId::CRITICAL_HIT_BY_PET)
        end
      end

      if owner.in_olympiad_mode? && target.is_a?(L2PcInstance)
        if target.in_olympiad_mode?
          if target.olympiad_game_id == owner.olympiad_game_id
            OlympiadGameManager.notify_competitor_damage(owner, damage.to_i)
          end
        end
      end

      if target.invul? && !target.is_a?(L2NpcInstance)
        send_packet(SystemMessageId::ATTACK_WAS_BLOCKED)
      else
        sm = SystemMessage.c1_done_s3_damage_to_c2
        sm.add_npc_name(self)
        sm.add_char_name(target)
        sm.add_int(damage)
        send_packet(sm)
      end
    end
  end

  def reduce_current_hp(damage : Float64, attacker : L2Character?, skill : Skill?)
    super

    if owner? && attacker
      sm = SystemMessage.c1_received_damage_of_s3_from_c2
      sm.add_npc_name(self)
      sm.add_char_name(attacker)
      sm.add_int(damage.to_i32)
      send_packet(sm)
    end
  end

  def do_cast(skill)
    pc = acting_player
    unless pc.check_pvp_skill(target, skill)
      unless pc.access_level.allow_peace_attack?
        pc.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
        pc.action_failed
        return
      end
    end

    super
  end

  def in_combat? : Bool
    owner.in_combat?
  end

  def immobilized=(bool)
    super

    if bool
      @previous_follow_status = follow_status
      if @previous_follow_status
        self.follow_status = false
      end
    else
      self.follow_status = @previous_follow_status
    end
  end

  def hungry? : Bool
    false
  end

  def weapon : Int32
    0
  end

  def armor : Int32
    0
  end

  def send_info(pc : L2PcInstance)
    if pc == owner
      pc.send_packet(PetInfo.new(self, 0))
      update_effect_icons(true)
      if pet?
        pc.send_packet(PetItemList.new(inventory.items))
      end
    else
      pc.send_packet(SummonInfo.new(self, pc, 0))
    end
  end

  def on_teleported
    super
    send_packet(TeleportToLocation.new(self, *xyz, heading))
  end

  def undead? : Bool
    template.race.undead?
  end

  def switch_mode
    # no-op
  end

  def cancel_action
    unless movement_disabled?
      set_intention(AI::ACTIVE)
    end
  end

  def do_attack
    # debug "L2Summon#do_attack"
    if target = owner?.try &.target
      self.target = target
      set_intention(AI::ATTACK, target)
    end
  end

  def can_attack?(ctrl : Bool) : Bool
    return false unless target = owner?.try &.target
    return false if self == target || owner == target

    npc_id = id

    if PASSIVE_SUMMONS.includes?(npc_id)
      action_failed
      return false
    end

    if betrayed?
      send_packet(SystemMessageId::PET_REFUSING_ORDER)
      action_failed
      return false
    end

    if attacking_disabled?
      return false unless attacking_now?
      set_intention(AI::ATTACK, target)
    end

    if pet? && level - owner.level > 20
      send_packet(SystemMessageId::PET_TOO_HIGH_TO_CONTROL)
      action_failed
      return false
    end

    if owner.in_olympiad_mode? && !owner.olympiad_start?
      action_failed
      return false
    end

    if target.acting_player? && owner.siege_state > 0 && owner.inside_siege_zone?
      if target.acting_player.siege_side == owner.siege_side
        if TerritoryWarManager.tw_in_progress?
          send_packet(SystemMessageId::YOU_CANNOT_ATTACK_A_MEMBER_OF_THE_SAME_TERRITORY)
        else
          send_packet(SystemMessageId::FORCED_ATTACK_IS_IMPOSSIBLE_AGAINST_SIEGE_SIDE_TEMPORARY_ALLIED_MEMBERS)
        end

        action_failed
        return false
      end
    end

    unless owner.access_level.allow_peace_attack?
      if owner.inside_peace_zone?(self, target)
        send_packet(SystemMessageId::TARGET_IN_PEACEZONE)
        return false
      end
    end

    if locked_target?
      send_packet(SystemMessageId::FAILED_CHANGE_TARGET)
      return false
    end

    if !target.auto_attackable?(owner) && !ctrl && !target.npc?
      self.follow_status = false
      set_intention(AI::FOLLOW, target)
      send_packet(SystemMessageId::INCORRECT_TARGET)
      return false
    end

    if target.door? && !template.race.siege_weapon?
      return false
    end

    true
  end

  def summon? : Bool
    true
  end

  def summon : L2Summon
    self
  end

  def charged_shot?(type : ShotType)
    @shots_mask & type.mask == type.mask
  end

  def set_charged_shot(type : ShotType, charged : Bool)
    charged ? (@shots_mask |= type.mask) : (@shots_mask &= ~type.mask)
  end

  def uncharge_all_shots
    @shots_mask = 0
  end

  def recharge_shots(physical : Bool, magic : Bool)
    return if owner.active_shots.empty?

    owner.active_shots.each do |item_id|
      if item = owner.inventory.get_item_by_item_id(item_id)
        if magic && item.template.default_action.summon_spiritshot?
          ItemHandler[item.etc_item].try &.use_item(owner, item, false)
        end

        if physical && item.template.default_action.summon_soulshot?
          ItemHandler[item.etc_item].try &.use_item(owner, item, false)
        end
      else
        owner.remove_auto_shot(item_id)
      end
    end
  end

  def clan_id : Int32
    owner?.try &.clan_id || 0
  end

  def ally_id : Int32
    owner?.try &.ally_id || 0
  end

  def form_id : Int32
    # form_id = 0
    # npc_id = id()

    # if npc_id == 16_041 || npc_id == 16_042
    #   if level() > 69
    #     form_id = 3
    #   elsif level() > 64
    #     form_id = 2
    #   elsif level() > 59
    #     form_id = 1
    # elsif npc_id == 16_025 || npc_id == 16_037
    #   if level() > 69
    #     form_id = 3
    #   elsif level() > 64
    #     form_id = 2
    #   elsif level() > 59
    #     form_id = 1
    # end
    id = id()
    level = level()
    if id == 16_041 || id == 16_042 || id == 16_025 || id == 16_037
      return 3 if level > 69
      return 2 if level > 64
      return 1 if level > 59
    end

    0
  end

  def to_s(io : IO)
    if @owner && @name
      io << "#{owner.name}'s #{name.inspect}"
    else
      super
    end
  end

  abstract def summon_type : Int32
end
