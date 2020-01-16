require "../models/interfaces/item_type"
require "./trait_type"

class WeaponType < EnumClass
  include ItemType

  getter trait_type

  protected initializer trait_type : TraitType

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
