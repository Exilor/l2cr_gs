require "./l2_item"
require "../../enums/weapon_type"

class L2Weapon < L2Item
  @skills_on_magic : SkillHolder?
  @skills_on_magic_condition : Condition?
  @skills_on_crit : SkillHolder?
  @skills_on_crit_condition : Condition?
  @enchant_4_skill : SkillHolder?

  getter random_damage : Int32
  getter soulshot_count : Int32
  getter spiritshot_count : Int32
  getter mp_consume : Int32
  getter base_attack_range : Int32
  getter base_attack_angle : Int32
  getter change_weapon_id : Int32
  getter item_type : WeaponType
  getter reduced_soulshot : Int32
  getter reduced_soulshot_chance : Int32
  getter reduced_mp_consume : Int32
  getter reduced_mp_consume_chance : Int32
  getter? magic_weapon : Bool
  getter? force_equip : Bool
  getter? attack_weapon : Bool
  getter? use_weapon_skills_only : Bool

  def initialize(set)
    super

    @item_type = set.get_enum("weapon_type", WeaponType, WeaponType::NONE)
    @type_1 = ItemType1::WEAPON_RING_EARRING_NECKLACE
    @type_2 = ItemType2::WEAPON
    @magic_weapon = set.get_bool("is_magic_weapon", false)
    @soulshot_count = set.get_i32("soulshots", 0)
    @spiritshot_count = set.get_i32("spiritshots", 0)
    @random_damage = set.get_i32("random_damage", 0)
    @mp_consume = set.get_i32("mp_consume", 0)
    @base_attack_range = set.get_i32("attack_range", 40)
    damage_range = set.get_string("damage_range", "").split(';')
    if damage_range.size > 1 && damage_range[3].num?
      @base_attack_angle = damage_range[3].to_i
    else
      @base_attack_angle = 120
    end
    rs = set.get_string("reduced_soulshot", "").split(',')
    @reduced_soulshot_chance = rs.size == 2 ? rs[0].to_i : 0
    @reduced_soulshot = rs.size == 2 ? rs[1].to_i : 0

    rm = set.get_string("reduced_mp_consume", "").split(',')
    @reduced_mp_consume_chance = rm.size == 2 ? rm[0].to_i : 0
    @reduced_mp_consume = rm.size == 2 ? rm[1].to_i : 0
    @change_weapon_id = set.get_i32("change_weaponId", 0)
    @force_equip = set.get_bool("isForceEquip", false)
    @attack_weapon = set.get_bool("isAttackWeapon", true)
    @use_weapon_skills_only = set.get_bool("useWeaponSkillsOnly", false)

    skill = set.get_string("enchant4_skill", nil)
    unless skill.nil? || skill.empty?
      info = skill.split('-')
      if info.size == 2
        id = info.first.to_i
        level = info.last.to_i
        if id > 0 && level > 0
          @enchant_4_skill = SkillHolder.new(id, level)
        end
      end
    end

    skill = set.get_string("onmagic_skill", nil)
    unless skill.nil? || skill.empty?
      info = skill.split('-')
      chance = set.get_i32("onmagic_chance", 100)
      if info.size == 2
        id = info.first.to_i
        level = info.last.to_i
        if id > 0 && level > 0 && chance > 0
          @skills_on_magic = SkillHolder.new(id, level)
          @skills_on_magic_condition = Condition::GameChance.new(chance)
        end
      end
    end

    skill = set.get_string("oncrit_skill", nil)
    unless skill.nil? || skill.empty?
      info = skill.split('-')
      chance = set.get_i32("oncrit_chance", 100)
      if info.size == 2
        id = info.first.to_i
        level = info.last.to_i
        if id > 0 && level > 0 && chance > 0
          @skills_on_crit = SkillHolder.new(id, level)
          @skills_on_crit_condition = Condition::GameChance.new(chance)
        end
      end
    end
  end

  def mask : UInt32
    @item_type.mask
  end

  def enchant_4_skill : Skill?
    @enchant_4_skill.try &.skill
  end

  def bow? : Bool
    @item_type.bow?
  end

  def crossbow? : Bool
    @item_type.crossbow?
  end

  def ranged? : Bool
    @item_type.bow? || @item_type.crossbow?
  end

  def cast_on_critical_skill(caster : L2Character, target : L2Character)
    return unless skill = @skills_on_crit.try &.skill

    if cond = @skills_on_crit_condition
      return unless cond.test(caster, target, skill)
    end

    return unless skill.check_condition(caster, target, false)

    skill.activate_skill(caster, target)
  end

  def cast_on_magic_skill(caster : L2Character, target : L2Character, trigger : Skill)
    return unless skill = @skills_on_magic.try &.skill

    return if trigger.bad? != skill.bad?

    return unless trigger.magic? && skill.magic?

    return if trigger.toggle?

    unless caster.ai.cast_target?
      warn "No cast target."
    end

    return if caster.ai.cast_target? != target

    if cond = @skills_on_magic_condition
      return unless cond.test(caster, target, skill)
    end

    return unless skill.check_condition(caster, target, false)

    if skill.bad?
      if Formulas.shld_use(caster, target, skill) == Formulas::SHIELD_DEFENSE_PERFECT_BLOCK
        return
      end
    end

    skill.activate_skill(caster, target)

    if caster.is_a?(L2PcInstance)
      targets = [target] of L2Object
      caster.known_list.known_objects.each_value do |npc|
        next unless npc.is_a?(L2Npc)
        next unless Util.in_range?(1000, npc, caster, false)
        evt = OnNpcSkillSee.new(npc, caster, skill, targets, false)
        evt.async(npc)
      end
    end

    if caster.player?
      sm = SystemMessage.s1_has_been_activated
      sm.add_skill_name(skill)
      caster.send_packet(sm)
    end
  end
end
