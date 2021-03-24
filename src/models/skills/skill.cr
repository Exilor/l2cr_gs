require "../l2_extractable_product_item"
require "../l2_extractable_skill"
require "../../enums/skill_operate_type"
require "../../enums/abnormal_visual_effect"
require "../../enums/target_type"
require "../../enums/effect_type"
require "../../enums/attribute_type"
require "../../enums/fly_type"
require "../../enums/mount_type"
require "../../enums/common_skill"
require "../../enums/affect_scope"
require "../../data/xml/skill_trees_data"
require "../../network/packets/server/system_message"

class Skill
  enum SkillType : UInt8
    PHYSICAL
    MAGIC
    STATIC
    DANCE
    TRIGGER
  end

  private EMPTY_TARGET_LIST = [] of L2Object

  @effect_lists = EnumMap(EffectScope, Array(AbstractEffect)).new
  @extractable_items : L2ExtractableSkill?
  @operate_type : SkillOperateType
  @skill_type : SkillType
  @pre_condition : Array(Condition)?
  @item_pre_condition : Array(Condition)?
  @func_templates : Array(FuncTemplate)?
  @effect_types : EnumSet(EffectType)?

  getter id : Int32
  getter level : Int32
  getter display_id : Int32
  getter display_level : Int32
  getter name : String
  getter trait_type : TraitType
  getter mp_consume1 : Int32
  getter mp_consume2 : Int32
  getter mp_per_channeling : Int32
  getter affect_scope : AffectScope
  getter hp_consume : Int32
  getter item_consume_count : Int32
  getter item_consume_id : Int32
  getter cast_range : Int32
  getter cool_time : Int32
  getter effect_range : Int32
  getter abnormal_lvl : Int32
  getter abnormal_type : AbnormalType
  getter abnormal_time : Int32
  getter hit_time : Int32
  getter hit_cancel_time : Int32
  getter abnormal_visual_effects = Slice(AbnormalVisualEffect).empty
  getter abnormal_visual_effects_special = Slice(AbnormalVisualEffect).empty
  getter abnormal_visual_effects_event = Slice(AbnormalVisualEffect).empty
  getter hash : Int32
  getter reuse_delay : Int32
  getter lvl_bonus_rate : Int32
  getter icon : String
  getter target_type : TargetType
  getter magic_level : Int32
  getter activate_rate : Int32
  getter min_chance : Int32
  getter max_chance : Int32
  getter affect_range : Int32
  getter affect_object : AffectObject
  getter attribute_type : AttributeType
  getter attribute_power : Int32
  getter basic_property : BaseStats
  getter min_pledge_class : Int32
  getter charge_consume : Int32
  getter max_soul_consume_count : Int32
  getter effect_point : Int32
  getter ride_state : EnumSet(MountType)?
  getter channeling_skill_id : Int32
  getter channeling_tick_initial_delay : Int32
  getter channeling_tick_interval : Int32
  getter? reuse_delay_locked : Bool
  getter? stay_after_death : Bool
  getter? stay_on_subclass_change : Bool
  getter? recovery_herb : Bool
  getter? next_action_is_attack : Bool
  getter? blocked_in_olympiad : Bool
  getter? dmg_directly_to_hp : Bool
  getter? overhit : Bool
  getter? debuff : Bool
  getter? abnormal_instant : Bool
  getter? suicide_attack : Bool
  getter? irreplaceable_buff : Bool
  getter? excluded_from_check : Bool
  getter? simultaneous_cast : Bool
  property reference_item_id : Int32 = 0

  def initialize(set : StatsSet)
    @id = set.get_i32("skill_id")
    @level = set.get_i32("level")
    @hash = SkillData.get_skill_hash(@id, @level)
    @display_id = set.get_i32("displayId", @id)
    @display_level = set.get_i32("displayLevel", @level)
    @name = set.get_string("name", "")
    @operate_type = set.get_enum("operateType", SkillOperateType)
    @skill_type = SkillType[set.get_i32("isMagic", 0)]
    @trait_type = set.get_enum("trait", TraitType, TraitType::NONE)
    @reuse_delay_locked = set.get_bool("reuseDelayLocked", false)
    @mp_consume1 = set.get_i32("mpConsume1", 0)
    @mp_consume2 = set.get_i32("mpConsume2", 0)
    @mp_per_channeling = set.get_i32("mpPerChanneling", @mp_consume2)
    @hp_consume = set.get_i32("hpConsume", 0)
    @item_consume_count = set.get_i32("itemConsumeCount", 0)
    @item_consume_id = set.get_i32("itemConsumeId", 0)
    @cast_range = set.get_i32("castRange", -1)
    @effect_range = set.get_i32("effectRange", -1)
    @abnormal_lvl = set.get_i32("abnormalLvl", 0)
    @abnormal_type = set.get_enum("abnormalType", AbnormalType, AbnormalType::NONE)

    abnormal_time = set.get_i32("abnormalTime", 0)

    if Config.enable_modify_skill_duration
      if time = Config.skill_duration_list[@id]?
        if @level < 100 || @level > 140
          abnormal_time = time
        elsif @level < 140
          abnormal_time += time
        end
      end
    end

    @abnormal_time = abnormal_time
    @abnormal_instant = set.get_bool("abnormalInstant", false)

    parse_abnormal_visual_effect(set.get_string("abnormalVisualEffect", nil))

    @stay_after_death = set.get_bool("stayAfterDeath", false)
    @stay_on_subclass_change = set.get_bool("stayOnSubclassChange", true)
    @hit_time = set.get_i32("hitTime", 0)
    @hit_cancel_time = set.get_i32("hitCancelTime", 0)
    @cool_time = set.get_i32("coolTime", 0)
    @debuff = set.get_bool("isDebuff", false)
    @recovery_herb = set.get_bool("isRecoveryHerb", false)

    if Config.enable_modify_skill_reuse && (tmp = Config.skill_reuse_list[@id]?)
      @reuse_delay = tmp
    else
      @reuse_delay = set.get_i32("reuseDelay", 0)
    end

    @affect_object = set.get_enum("affectObject", AffectObject, AffectObject::ALL)
    @affect_range = set.get_i32("affectRange", 0)

    tmp = set.get_string("rideState", nil)
    if tmp && !tmp.empty?
      ride_state = EnumSet(MountType).new
      tmp.split(';') { |s| ride_state << MountType.parse(s) }
      @ride_state = ride_state
    end

    if tmp = set.get_string("affectLimit", nil)
      begin
        v1, v2 = tmp.split('-')
      rescue e
        raise "Invalid affectLimit value '#{tmp}' for skill id #{@id}"
      end
      @affect_limit = {v1.to_i, v2.to_i}
    else
      @affect_limit = {0, 0}
    end

    @target_type = set.get_enum("targetType", TargetType, TargetType::SELF)
    @affect_scope = set.get_enum("affectScope", AffectScope, AffectScope::NONE)
    @magic_level = set.get_i32("magicLvl", 0)
    @lvl_bonus_rate = set.get_i32("lvlBonusRate", 0)
    @activate_rate = set.get_i32("activateRate", -1)
    @min_chance = set.get_i32("minChance", Config.min_abnormal_state_success_rate)
    @max_chance = set.get_i32("maxChance", Config.max_abnormal_state_success_rate)
    @next_action_is_attack = set.get_bool("nextActionAttack", false)
    @blocked_in_olympiad = set.get_bool("blockedInOlympiad", false)
    @attribute_type = set.get_enum("attributeType", AttributeType, AttributeType::NONE)
    @attribute_power = set.get_i32("attributePower", 0)
    @basic_property = set.get_enum("basicProperty", BaseStats, BaseStats::NONE)
    @overhit = set.get_bool("overHit", false)
    @suicide_attack = set.get_bool("isSuicideAttack", false)
    @min_pledge_class = set.get_i32("minPledgeClass", 0)
    @charge_consume = set.get_i32("chargeConsume", 0)
    @max_soul_consume_count = set.get_i32("soulMaxConsumeCount", 0)
    @dmg_directly_to_hp = set.get_bool("dmgDirectlyToHp", false)
    @effect_point = set.get_i32("effectPoint", 0)
    @irreplaceable_buff = set.get_bool("irreplaceableBuff", false)
    @excluded_from_check = set.get_bool("excludedFromCheck", false)
    @simultaneous_cast = set.get_bool("simultaneousCast", false)
    @icon = set.get_string("icon", "icon.skill0000")
    @channeling_skill_id = set.get_i32("channelingSkillId", 0)
    @channeling_tick_interval = set.get_i32("channelingTickInterval", 2) * 1000
    @channeling_tick_initial_delay = set.get_i32("channelingTickInitialDelay", @channeling_tick_interval / 1000) * 1000

    if tmp = set.get_string("capsuled_items_skill", nil)
      if tmp.empty?
        raise "Empty capsuled items."
      end
      @extractable_items = parse_extractable_skill(@id, @level, tmp)
    end
  end

  delegate physical?, magic?, static?, dance?, trigger?, to: @skill_type
  delegate fly_type?, active?, passive?, toggle?, self_continuous?, channeling?,
    to: @operate_type

  def aoe? : Bool
    @target_type.area? || @target_type.aura? || @target_type.behind_area? ||
      @target_type.behind_aura? || @target_type.front_area? ||
      @target_type.front_aura?
  end

  def damage? : Bool
    has_effect_type?(
      EffectType::MAGICAL_ATTACK,
      EffectType::HP_DRAIN,
      EffectType::PHYSICAL_ATTACK
    )
  end

  def can_be_stolen? : Bool
    !passive? && !toggle? && !debuff? && !hero_skill? && !gm_skill? &&
      !(static? && id != CommonSkill::CARAVANS_SECRET_MEDICINE.id) &&
      !irreplaceable_buff? && id != CommonSkill::SERVITOR_SHARE.id
  end

  def has_abnormal_visual_effects? : Bool
    !@abnormal_visual_effects.empty?
  end

  def has_abnormal_visual_effects_special? : Bool
    !@abnormal_visual_effects_special.empty?
  end

  def has_abnormal_visual_effects_event? : Bool
    !@abnormal_visual_effects_event.empty?
  end

  def affect_limit : Int32
    lim1 = @affect_limit[1]
    lim1 == 0 ? Int32::MAX : @affect_limit[0] &+ Rnd.rand(lim1)
  end

  def continuous? : Bool
    @operate_type.continuous? || self_continuous?
  end

  def transformation? : Bool
    @abnormal_type.transform?
  end

  def use_soulshot? : Bool
    has_effect_type?(EffectType::PHYSICAL_ATTACK)
  end

  def use_spiritshot? : Bool
    magic?
  end

  def use_fish_shot? : Bool
    has_effect_type?(EffectType::FISHING)
  end

  def healing_potion_skill? : Bool
    @abnormal_type.hp_recover?
  end

  def bad? : Bool
    @effect_point < 0 && !@target_type.self?
  end

  def check_condition(char : L2Character, object : L2Object?, item_or_weapon : Bool) : Bool
    if char.override_skill_conditions? && !Config.gm_skill_restriction
      return true
    end

    if char.is_a?(L2PcInstance) && !can_be_used_while_riding?(char)
      sm = Packets::Outgoing::SystemMessage.s1_cannot_be_used
      sm.add_skill_name(@id)
      char.send_packet(sm)
      return false
    end

    conditions = item_or_weapon ? @item_pre_condition : @pre_condition

    if conditions.nil? || conditions.empty?
      return true
    end

    target = object.as?(L2Character)

    conditions.each do |cond|
      unless cond.test(char, target, self)
        msg = cond.message
        msg_id = cond.message_id
        if msg_id != 0
          sm = Packets::Outgoing::SystemMessage[msg_id]
          if cond.add_name?
            sm.add_skill_name(@id)
          end
          char.send_packet(sm)
        elsif msg
          char.send_message(msg)
        end

        return false
      end
    end

    true
  end

  def can_be_used_while_riding?(pc : L2PcInstance) : Bool
    return true unless temp = @ride_state
    temp.includes?(pc.mount_type)
  end

  def get_target_list(char : L2Character, only_first : Bool) : Array(L2Object)
    target = char.target.as?(L2Character)
    get_target_list(char, only_first, target)
  end

  def get_target_list(char : L2Character, only_first : Bool, target : L2Character?) : Array(L2Object)
    if handler = TargetHandler[target_type]
      return handler.get_target_list(self, char, only_first, target)
    end

    char.send_message("Target type of skill is not currently handled.")

    EMPTY_TARGET_LIST
  end

  def get_target_list(char : L2Character) : Array(L2Object)
    get_target_list(char, false)
  end

  def get_first_of_target_list(char : L2Character) : L2Object?
    get_target_list(char, true).first?
  end

  def offensive_aoe_check(caster : L2Character, target : L2Character, source_in_arena : Bool) : Bool
    return false if target.dead? || target == caster

    player = caster.acting_player
    target_player = target.acting_player

    if player
      if target_player
        if target_player == caster || target_player == player
          return false
        end

        return false if target_player.in_observer_mode?

        if bad?
          if player.siege_state > 0 && player.inside_siege_zone?
            if player.siege_state == target_player.siege_state
              if player.siege_side == target_player.siege_side
                return false
              end
            end
          end

          if target.inside_peace_zone?
            return false
          end
        end

        if (party1 = player.party) && (party2 = target_player.party)
          if party1 == party2
            return false
          end

          if (cc1 = party1.command_channel) && (cc2 = party2.command_channel)
            if cc1 == cc2
              return false
            end
          end
        end

        unless TvTEvent.check_for_tvt_skill(player, target_player, self)
          return false
        end

        if !source_in_arena && !target_player.inside_pvp_zone?
          unless target_player.inside_siege_zone?
            if player.ally_id != 0 && player.ally_id == target_player.ally_id
              return false
            end

            if player.clan_id != 0 && player.clan_id == target_player.clan_id
              return false
            end

            unless player.check_pvp_skill(target_player, self)
              return false
            end
          end
        end
      end
    else
      if target_player.nil? && target.is_a?(L2Attackable)
        if caster.is_a?(L2Attackable)
          return false
        end
      end
    end

    unless GeoData.can_see_target?(caster, target)
      return false
    end

    true
  end

  def get_stat_funcs(effect : AbstractEffect?, player : L2Character) : Indexable(AbstractFunction)
    unless templates = @func_templates
      return Slice(AbstractFunction).empty
    end

    unless player.is_a?(L2Playable | L2Attackable)
      return Slice(AbstractFunction).empty
    end

    if templates.empty?
      return Slice(AbstractFunction).empty
    end

    ary = [] of AbstractFunction
    templates.each do |t|
      if f = t.get_func(player, nil, self, self)
        ary << f
      end
    end
    ary
  end

  def has_effect_type?(*types : EffectType) : Bool
    return false unless temp = @effect_types
    types.any? { |t| temp.includes?(t) }
  end

  def attach(cond : Condition?, item_or_weapon : Bool)
    return unless cond

    if item_or_weapon
      (@item_pre_condition ||= [] of Condition) << cond
    else
      (@pre_condition ||= [] of Condition) << cond
    end
  end

  def add_effect(scope : EffectScope, effect : AbstractEffect)
    unless effect.effect_type.none?
      (@effect_types ||= EnumSet(EffectType).new) << effect.effect_type
    end

    (@effect_lists[scope] ||= [] of AbstractEffect) << effect
  end

  def activate_skill(caster : L2Character, *targets : L2Object) # custom
    activate_skill(caster, targets)
  end

  def activate_skill(caster : L2Character, targets : Enumerable(L2Object))
    activate_skill(caster, nil, targets)
  end

  def activate_skill(cubic : L2CubicInstance, *targets : L2Object) # custom
    activate_skill(cubic, targets)
  end

  def activate_skill(cubic : L2CubicInstance, targets : Enumerable(L2Object))
    activate_skill(cubic.owner, cubic, targets)
  end

  private def activate_skill(caster : L2Character, cubic : L2CubicInstance?, targets : Enumerable(L2Object))
    case @id
    when 5852, 5853
      return unless block = targets.first?.as?(L2BlockInstance)
      return unless pc = caster.as?(L2PcInstance)
      arena = pc.block_checker_arena
      if arena != -1
        unless holder = HandysBlockCheckerManager.get_holder(arena)
          return
        end

        team = holder.get_player_team(pc)
        color = block.color_effect
        if (team == 0 && color == 0) || (team == 1 && color == 0x53)
          block.change_color(pc, holder, team)
        end
      end
    else
      targets.each do |target|
        target = target.as(L2Character)
        if Formulas.buff_debuff_reflection(target, self)
          apply_effects(target, caster, false, 0)

          info = BuffInfo.new(caster, target, self)
          apply_effect_scope(EffectScope::GENERAL, info, true, false)

          if caster.playable? && target.attackable?
            pvx_scope = EffectScope::PVE
          elsif caster.playable? && target.playable?
            pvx_scope = EffectScope::PVP
          end

          apply_effect_scope(pvx_scope, info, true, false)

          apply_effect_scope(EffectScope::CHANNELING, info, true, false)
        else
          apply_effects(caster, target)
        end
      end
    end

    if has_effects?(EffectScope::SELF)
      if caster.affected_by_skill?(id)
        caster.stop_skill_effects(true, id)
      end

      apply_effects(caster, caster, true, false, true, 0)
    end

    if use_spiritshot?
      if caster.charged_shot?(ShotType::BLESSED_SPIRITSHOTS)
        caster.set_charged_shot(ShotType::BLESSED_SPIRITSHOTS, false)
      else
        caster.set_charged_shot(ShotType::SPIRITSHOTS, false)
      end
    elsif use_soulshot?
      caster.set_charged_shot(ShotType::SOULSHOTS, false)
    end

    if suicide_attack?
      caster.do_die(caster)
    end
  end

  def apply_effects(effector : L2Character, effected : L2Character)
    apply_effects(effector, effected, false, false, true, 0)
  end

  def apply_effects(effector : L2Character, effected : L2Character, instant : Bool, abnormal_time : Int32)
    apply_effects(effector, effected, false, false, instant, abnormal_time)
  end

  def apply_effects(effector : L2Character, effected : L2Character, this : Bool, passive : Bool, instant : Bool, abnormal_time)
    if effector != effected && bad?
      if effected.invul?
        return
      end

      if effector.gm? && !effector.access_level.can_give_damage?
        return
      end
    end

    if debuff?
      if effected.debuff_blocked?
        return
      end
    else
      if effected.buff_blocked? && !bad?
        return
      end
    end

    if effected.invul_against?(id, level)
      effected.send_debug_message { "Skill #{to_s} has been ignored (invul against)" }
      return
    end

    add_continuous_effects = !passive && (@operate_type.toggle? || (@operate_type.continuous? && Formulas.effect_success(effector, effected, self)))

    if !this && !passive
      info = BuffInfo.new(effector, effected, self)

      if (pc = effector.as?(L2PcInstance)) && max_soul_consume_count > 0
        info.charges = pc.decrease_souls(max_soul_consume_count)
      end

      if add_continuous_effects && abnormal_time > 0
        info.abnormal_time = abnormal_time
      end

      apply_effect_scope(EffectScope::GENERAL, info, instant, add_continuous_effects)

      if effector.playable? && effected.attackable?
        pvx_scope = EffectScope::PVE
      elsif effector.playable? && effected.playable?
        pvx_scope = EffectScope::PVP
      end

      apply_effect_scope(pvx_scope, info, instant, add_continuous_effects)

      apply_effect_scope(EffectScope::CHANNELING, info, instant, add_continuous_effects)

      if add_continuous_effects
        effected.effect_list.add(info)
      end

      if effected.player? && (smn = effected.summon.as?(L2ServitorInstance))
        if !transformation? && !abnormal_type.summon_condition?
          if (add_continuous_effects && continuous? && !debuff?) || recovery_herb?
            apply_effects(effector, smn, recovery_herb?, 0)
          end
        end
      end
    end

    if this
      add_continuous_effects = !passive && (@operate_type.toggle? || ((@operate_type.continuous? || @operate_type.self_continuous?) && Formulas.effect_success(effector, effector, self)))
      info = BuffInfo.new(effector, effector, self)
      if add_continuous_effects && abnormal_time > 0
        info.abnormal_time = abnormal_time
      end

      apply_effect_scope(EffectScope::SELF, info, instant, add_continuous_effects)

      if add_continuous_effects && has_effect_type?(EffectType::BUFF)
        info.effector.effect_list.add(info)
      end

      if add_continuous_effects && info.effected.player? && !debuff?
        if id != CommonSkill::SERVITOR_SHARE.id && continuous?
          if smn = info.effected.summon.as?(L2ServitorInstance)
            apply_effects(effector, smn, false, 0)
          end
        end
      end
    end

    if passive
      info = BuffInfo.new(effector, effected, self)
      apply_effect_scope(EffectScope::PASSIVE, info, false, true)
      effector.effect_list.add(info)
    end
  end

  def apply_effect_scope(scope : EffectScope?, info : BuffInfo, apply_instant_effects : Bool, add_continuous_effects : Bool)
    return unless scope && (effects = @effect_lists[scope]?)

    effects.each do |effect|
      if effect.instant?
        if apply_instant_effects && effect.calc_success(info)
          effect.on_start(info)
        end
      elsif add_continuous_effects
        if effect.can_start?(info)
          info.add_effect(effect)
        end
      end
    end
  end

  def has_effects?(scope : EffectScope) : Bool
    return false unless effects = @effect_lists[scope]?
    !effects.empty?
  end

  def extractable_skill : L2ExtractableSkill?
    @extractable_items
  end

  def removed_on_any_action_except_move? : Bool
    @abnormal_type.invincibility? || @abnormal_type.hide?
  end

  def removed_on_damage? : Bool
    @abnormal_type.sleep? ||
      @abnormal_type.force_meditation? ||
      @abnormal_type.hide?
  end

  def hero_skill? : Bool
    SkillTreesData.hero_skill?(@id, @level)
  end

  def gm_skill? : Bool
    SkillTreesData.gm_skill?(@id, @level)
  end

  def clan_skill? : Bool
    SkillTreesData.clan_skill?(@id, @level)
  end

  def seven_signs? : Bool
    @id.between?(4361, 4366)
  end

  def to_s(io : IO)
    io.print(name, " Lv ", level)
  end

  def inspect(io : IO)
    to_s(io)
  end

  private def parse_abnormal_visual_effect(string)
    return if string.nil? || string.empty?

    aves_event = nil
    aves_special = nil
    aves = nil

    string.split(';') do |ave2|
      ave = AbnormalVisualEffect.parse(ave2)
      if ave.event?
        (aves_event ||= [] of AbnormalVisualEffect) << ave
      elsif ave.special?
        (aves_special ||= [] of AbnormalVisualEffect) << ave
      else
        (aves ||= [] of AbnormalVisualEffect) << ave
      end
    end

    if aves_event
      @abnormal_visual_effects_event = aves_event.to_slice
    end

    if aves_special
      @abnormal_visual_effects_special = aves_special.to_slice
    end

    if aves
      @abnormal_visual_effects = aves.to_slice
    end
  end

  private def parse_extractable_skill(skill_id, skill_lvl, values)
    products = [] of L2ExtractableProductItem

    values.split(';') do |prod_list|
      prod_data = prod_list.split(',')
      if prod_data.size < 3
        raise "Wrong size for extractable skill info: #{prod_data.size} (id: #{id})"
      end
      length = prod_data.size &- 1
      items = [] of ItemHolder
      (0...length).step(2) do |j|
        prod_id = prod_data[j].to_i
        quantity = prod_data[j &+ 1].to_i64
        if prod_id <= 0 || quantity <= 0
          raise "Wrong product item id or quantity for extractable skill (id: #{id})"
        end
        items << ItemHolder.new(prod_id, quantity)
      end
      chance = prod_data[length].to_f
      products << L2ExtractableProductItem.new(items.to_slice, chance)
    end

    if products.empty?
      raise "Empty extractable skill (id: #{id})"
    end

    L2ExtractableSkill.new(products)
  end
end
