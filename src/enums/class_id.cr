require "./race"

class ClassId < EnumClass
  getter race : Race
  getter! parent : self
  getter? mage_class, summoner

  protected def initialize(parent = nil, race = nil, mage_class = false, summoner = false)
    @parent     = parent
    @race       = race       || parent.try &.race || Race::NONE
    @mage_class = mage_class || !!parent && parent.mage_class?
    @summoner   = summoner   || !!parent && parent.summoner?
  end

  def level : Int32
    (parent = @parent) ? parent.level &+ 1 : 0
  end

  def child_of?(other : self) : Bool
    return false unless parent = @parent
    parent == other || parent.child_of?(other)
  end

  def equals_or_child_of?(other : self) : Bool
    same?(other) || child_of?(other)
  end

  add(FIGHTER, race: Race::HUMAN)
  add(WARRIOR, parent: FIGHTER)
  add(GLADIATOR, parent: WARRIOR)
  add(WARLORD, parent: WARRIOR)
  add(KNIGHT, parent: FIGHTER)
  add(PALADIN, parent: KNIGHT)
  add(DARK_AVENGER, parent: KNIGHT)
  add(ROGUE, parent: FIGHTER)
  add(TREASURE_HUNTER, parent: ROGUE)
  add(HAWKEYE, parent: ROGUE)

  add(MAGE, race: Race::HUMAN, mage_class: true)
  add(WIZARD, parent: MAGE)
  add(SORCEROR, parent: WIZARD)
  add(NECROMANCER, parent: WIZARD)
  add(WARLOCK, parent: WIZARD, summoner: true)
  add(CLERIC, parent: MAGE)
  add(BISHOP, parent: CLERIC)
  add(PROPHET, parent: CLERIC)


  add(ELVEN_FIGHTER, race: Race::ELF)
  add(ELVEN_KNIGHT, parent: ELVEN_FIGHTER)
  add(TEMPLE_KNIGHT, parent: ELVEN_KNIGHT)
  add(SWORD_SINGER, parent: ELVEN_KNIGHT)
  add(ELVEN_SCOUT, parent: ELVEN_FIGHTER)
  add(PLAINS_WALKER, parent: ELVEN_SCOUT)
  add(SILVER_RANGER, parent: ELVEN_SCOUT)

  add(ELVEN_MAGE, race: Race::ELF, mage_class: true)
  add(ELVEN_WIZARD, parent: ELVEN_MAGE)
  add(SPELLSINGER, parent: ELVEN_WIZARD)
  add(ELEMENTAL_SUMMONER, parent: ELVEN_WIZARD, summoner: true)
  add(ORACLE, parent: ELVEN_MAGE)
  add(ELDER, parent: ORACLE)


  add(DARK_FIGHTER, race: Race::DARK_ELF)
  add(PALUS_KNIGHT, parent: DARK_FIGHTER)
  add(SHILLIEN_KNIGHT, parent: PALUS_KNIGHT)
  add(BLADEDANCER, parent: PALUS_KNIGHT)
  add(ASSASSIN, parent: DARK_FIGHTER)
  add(ABYSS_WALKER, parent: ASSASSIN)
  add(PHANTOM_RANGER, parent: ASSASSIN)

  add(DARK_MAGE, race: Race::DARK_ELF, mage_class: true)
  add(DARK_WIZARD, parent: DARK_MAGE)
  add(SPELLHOWLER, parent: DARK_WIZARD)
  add(PHANTOM_SUMMONER, parent: DARK_WIZARD, summoner: true)
  add(SHILLIEN_ORACLE, parent: DARK_MAGE)
  add(SHILLIEN_ELDER, parent: SHILLIEN_ORACLE)


  add(ORC_FIGHTER, race: Race::ORC)
  add(ORC_RAIDER, parent: ORC_FIGHTER)
  add(DESTROYER, parent: ORC_RAIDER)
  add(ORC_MONK, parent: ORC_FIGHTER)
  add(TYRANT, parent: ORC_MONK)

  add(ORC_MAGE, race: Race::ORC, mage_class: true)
  add(ORC_SHAMAN, parent: ORC_MAGE)
  add(OVERLORD, parent: ORC_SHAMAN)
  add(WARCRYER, parent: ORC_SHAMAN)


  add(DWARVEN_FIGHTER, race: Race::DWARF)
  add(SCAVENGER, parent: DWARVEN_FIGHTER)
  add(BOUNTY_HUNTER, parent: SCAVENGER)
  add(ARTISAN, parent: DWARVEN_FIGHTER)
  add(WARSMITH, parent: ARTISAN)


  {% for i in 0..29 %}
    add(DUMMY_ENTRY_{{i}})
  {% end %}


  add(DUELIST, parent: GLADIATOR)
  add(DREADNOUGHT, parent: WARLORD)
  add(PHOENIX_KNIGHT, parent: PALADIN)
  add(HELL_KNIGHT, parent: DARK_AVENGER)
  add(SAGITTARIUS, parent: HAWKEYE)
  add(ADVENTURER, parent: TREASURE_HUNTER)
  add(ARCHMAGE, parent: SORCEROR)
  add(SOULTAKER, parent: NECROMANCER)
  add(ARCANA_LORD, parent: WARLOCK)
  add(CARDINAL, parent: BISHOP)
  add(HIEROPHANT, parent: PROPHET)

  add(EVA_TEMPLAR, parent: TEMPLE_KNIGHT)
  add(SWORD_MUSE, parent: SWORD_SINGER)
  add(WIND_RIDER, parent: PLAINS_WALKER)
  add(MOONLIGHT_SENTINEL, parent: SILVER_RANGER)
  add(MYSTIC_MUSE, parent: SPELLSINGER)
  add(ELEMENTAL_MASTER, parent: ELEMENTAL_SUMMONER)
  add(EVA_SAINT, parent: ELDER)

  add(SHILLIEN_TEMPLAR, parent: SHILLIEN_KNIGHT)
  add(SPECTRAL_DANCER, parent: BLADEDANCER)
  add(GHOST_HUNTER, parent: ABYSS_WALKER)
  add(GHOST_SENTINEL, parent: PHANTOM_RANGER)
  add(STORM_SCREAMER, parent: SPELLHOWLER)
  add(SPECTRAL_MASTER, parent: PHANTOM_SUMMONER)
  add(SHILLIEN_SAINT, parent: SHILLIEN_ELDER)

  add(TITAN, parent: DESTROYER)
  add(GRAND_KHAVATARI, parent: TYRANT)
  add(DOMINATOR, parent: OVERLORD)
  add(DOOMCRYER, parent: WARCRYER)

  add(FORTUNE_SEEKER, parent: BOUNTY_HUNTER)
  add(MAESTRO, parent: WARSMITH)


  {% for i in 30..33 %}
    add(DUMMY_ENTRY_{{i}})
  {% end %}


  add(MALE_SOLDIER, race: Race::KAMAEL)
  add(FEMALE_SOLDIER, race: Race::KAMAEL)
  add(TROOPER, parent: MALE_SOLDIER)
  add(WARDER, parent: FEMALE_SOLDIER)
  add(BERSERKER, parent: TROOPER)
  add(MALE_SOULBREAKER, parent: TROOPER)
  add(FEMALE_SOULBREAKER, parent: WARDER)
  add(ARBALESTER, parent: WARDER)
  add(DOOMBRINGER, parent: BERSERKER)
  add(MALE_SOULHOUND, parent: MALE_SOULBREAKER)
  add(FEMALE_SOULHOUND, parent: FEMALE_SOULBREAKER)
  add(TRICKSTER, parent: ARBALESTER)
  add(INSPECTOR, parent: WARDER)
  add(JUDICATOR, parent: INSPECTOR)
end
