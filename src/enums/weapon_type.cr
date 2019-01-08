require "../models/interfaces/item_type"
require "./trait_type"

class WeaponType < EnumClass
  include ItemType

  getter trait_type

  def initialize(@trait_type : TraitType)
    unless 0 <= to_i <= 16
      raise "weapon type with value #{to_i} outside of range (valid: 0..16)"
    end
  end

  add(SWORD,        TraitType::SWORD)
  add(BLUNT,        TraitType::BLUNT)
  add(DAGGER,       TraitType::DAGGER)
  add(BOW,          TraitType::BOW)
  add(POLE,         TraitType::POLE)
  add(NONE,         TraitType::NONE)
  add(DUAL,         TraitType::DUAL)
  add(ETC,          TraitType::ETC)
  add(FIST,         TraitType::FIST)
  add(DUALFIST,     TraitType::DUALFIST)
  add(FISHINGROD,   TraitType::NONE)
  add(RAPIER,       TraitType::RAPIER)
  add(ANCIENTSWORD, TraitType::ANCIENTSWORD)
  add(CROSSBOW,     TraitType::CROSSBOW)
  add(FLAG,         TraitType::NONE)
  add(OWNTHING,     TraitType::NONE)
  add(DUALDAGGER,   TraitType::DUALDAGGER)
end
