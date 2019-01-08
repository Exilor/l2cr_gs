module SummonEffectsTable
  extend self
  extend Loggable

  private record SummonEffect, skill : Skill, effect_time : Int32

  # l2id -> (class_index -> (reference_skill -> skill.id))
  private SERVITOR_EFFECTS = Hash(Int32, Hash(Int32, Hash(Int32, Hash(Int32, SummonEffect)))).new do |h, k|
    h[k] = Hash(Int32, Hash(Int32, Hash(Int32, SummonEffect))).new do |h, k|
      h[k] = Hash(Int32, Hash(Int32, SummonEffect)).new do |h, k|
        h[k] = Hash(Int32, SummonEffect).new
      end
    end
  end

  private PET_EFFECTS = Hash(Int32, Hash(Int32, SummonEffect)).new do |h, k|
    h[k] = Hash(Int32, SummonEffect).new # Integer => SummonEffect
  end

  private def get_servitor_effects(pc) : Hash(Int32, Hash(Int32, SummonEffect))?
    if servitor_map = SERVITOR_EFFECTS[pc.l2id]?
      servitor_map[pc.class_index]?
    end
    # SERVITOR_EFFECTS.dig(pc.l2id, pc.class_index)
  end

  private def get_servitor_effects(pc, reference_skill : Int32) : Hash(Int32, SummonEffect)?
    if map = get_servitor_effects(pc)
      map[reference_skill]?
    end
  end

  private def contain_owner?(pc)
    return false unless temp = SERVITOR_EFFECTS[pc.l2id]?
    temp.has_key?(pc.class_index)
  end

  private def remove_effects(map : Hash(Int32, SummonEffect)?, skill_id)
    map.try &.delete(skill_id)
  end

  private def apply_effects(summon, map : Hash(Int32, SummonEffect)?)
    map.try &.each_value do |se|
      se.skill.apply_effects(summon, summon, false, se.effect_time)
    end
  end

  def contains_skill?(pc, reference_skill)
    if temp = get_servitor_effects(pc)
      temp.has_key?(reference_skill)
    else
      false
    end
  end

  def clear_servitor_effects(pc, reference_skill)
    get_servitor_effects(pc).try &.clear
  end

  def add_servitor_effect(pc, reference_skill, skill, effect_time)
    se = SummonEffect.new(skill, effect_time)
    SERVITOR_EFFECTS[pc.l2id][pc.class_index][reference_skill][skill.id] = se
  end

  def remove_servitor_effects(pc, reference_skill, skill_id)
    remove_effects(get_servitor_effects(pc, reference_skill), skill_id)
  end

  def apply_servitor_effects(servitor, pc, reference_skill)
    apply_effects(servitor, get_servitor_effects(pc, reference_skill))
  end

  def add_pet_effect(control_l2id, skill, effect_time)
    se = SummonEffect.new(skill, effect_time)
    PET_EFFECTS[control_l2id][skill.id] = se
  end

  def contains_pet_id?(control_l2id)
    PET_EFFECTS.has_key?(control_l2id)
  end

  def apply_pet_effects(pet, control_l2id)
    apply_effects(pet, PET_EFFECTS[control_l2id])
  end

  def clear_pet_effects(control_l2id)
    PET_EFFECTS[control_l2id]?.try &.clear
  end

  def remove_pet_effects(control_l2id, skill_id)
    remove_effects(PET_EFFECTS[control_l2id], skill_id)
  end
end
