require "./race"
require "./class_type"
require "./class_level"

class PlayerClass < EnumClass
  getter race, type, level

  protected initializer race : Race, type : ClassType, level : ClassLevel

  add(HumanFighter,   Race::HUMAN, ClassType::Fighter, ClassLevel::First)
  add(Warrior,        Race::HUMAN, ClassType::Fighter, ClassLevel::Second)
  add(Gladiator,      Race::HUMAN, ClassType::Fighter, ClassLevel::Third)
  add(Warlord,        Race::HUMAN, ClassType::Fighter, ClassLevel::Third)
  add(HumanKnight,    Race::HUMAN, ClassType::Fighter, ClassLevel::Second)
  add(Paladin,        Race::HUMAN, ClassType::Fighter, ClassLevel::Third)
  add(DarkAvenger,    Race::HUMAN, ClassType::Fighter, ClassLevel::Third)
  add(Rogue,          Race::HUMAN, ClassType::Fighter, ClassLevel::Second)
  add(TreasureHunter, Race::HUMAN, ClassType::Fighter, ClassLevel::Third)
  add(Hawkeye,        Race::HUMAN, ClassType::Fighter, ClassLevel::Third)
  add(HumanMystic,    Race::HUMAN, ClassType::Mystic,  ClassLevel::First)
  add(HumanWizard,    Race::HUMAN, ClassType::Mystic,  ClassLevel::Second)
  add(Sorceror,       Race::HUMAN, ClassType::Mystic,  ClassLevel::Third)
  add(Necromancer,    Race::HUMAN, ClassType::Mystic,  ClassLevel::Third)
  add(Warlock,        Race::HUMAN, ClassType::Mystic,  ClassLevel::Third)
  add(Cleric,         Race::HUMAN, ClassType::Priest,  ClassLevel::Second)
  add(Bishop,         Race::HUMAN, ClassType::Priest,  ClassLevel::Third)
  add(Prophet,        Race::HUMAN, ClassType::Priest,  ClassLevel::Third)

  add(ElvenFighter,      Race::ELF, ClassType::Fighter, ClassLevel::First)
  add(ElvenKnight,       Race::ELF, ClassType::Fighter, ClassLevel::Second)
  add(TempleKnight,      Race::ELF, ClassType::Fighter, ClassLevel::Third)
  add(Swordsinger,       Race::ELF, ClassType::Fighter, ClassLevel::Third)
  add(ElvenScout,        Race::ELF, ClassType::Fighter, ClassLevel::Second)
  add(Plainswalker,      Race::ELF, ClassType::Fighter, ClassLevel::Third)
  add(SilverRanger,      Race::ELF, ClassType::Fighter, ClassLevel::Third)
  add(ElvenMystic,       Race::ELF, ClassType::Mystic,  ClassLevel::First)
  add(ElvenWizard,       Race::ELF, ClassType::Mystic,  ClassLevel::Second)
  add(Spellsinger,       Race::ELF, ClassType::Mystic,  ClassLevel::Third)
  add(ElementalSummoner, Race::ELF, ClassType::Mystic,  ClassLevel::Third)
  add(ElvenOracle,       Race::ELF, ClassType::Priest,  ClassLevel::Second)
  add(ElvenElder,        Race::ELF, ClassType::Priest,  ClassLevel::Third)

  add(DarkElvenFighter, Race::DARK_ELF, ClassType::Fighter, ClassLevel::First)
  add(PalusKnight,      Race::DARK_ELF, ClassType::Fighter, ClassLevel::Second)
  add(ShillienKnight,   Race::DARK_ELF, ClassType::Fighter, ClassLevel::Third)
  add(Bladedancer,      Race::DARK_ELF, ClassType::Fighter, ClassLevel::Third)
  add(Assassin,         Race::DARK_ELF, ClassType::Fighter, ClassLevel::Second)
  add(AbyssWalker,      Race::DARK_ELF, ClassType::Fighter, ClassLevel::Third)
  add(PhantomRanger,    Race::DARK_ELF, ClassType::Fighter, ClassLevel::Third)
  add(DarkElvenMystic,  Race::DARK_ELF, ClassType::Mystic,  ClassLevel::First)
  add(DarkElvenWizard,  Race::DARK_ELF, ClassType::Mystic,  ClassLevel::Second)
  add(Spellhowler,      Race::DARK_ELF, ClassType::Mystic,  ClassLevel::Third)
  add(PhantomSummoner,  Race::DARK_ELF, ClassType::Mystic,  ClassLevel::Third)
  add(ShillienOracle,   Race::DARK_ELF, ClassType::Priest,  ClassLevel::Second)
  add(ShillienElder,    Race::DARK_ELF, ClassType::Priest,  ClassLevel::Third)

  add(OrcFighter, Race::ORC, ClassType::Fighter, ClassLevel::First)
  add(OrcRaider,  Race::ORC, ClassType::Fighter, ClassLevel::Second)
  add(Destroyer,  Race::ORC, ClassType::Fighter, ClassLevel::Third)
  add(OrcMonk,    Race::ORC, ClassType::Fighter, ClassLevel::Second)
  add(Tyrant,     Race::ORC, ClassType::Fighter, ClassLevel::Third)
  add(OrcMystic,  Race::ORC, ClassType::Mystic,  ClassLevel::First)
  add(OrcShaman,  Race::ORC, ClassType::Mystic,  ClassLevel::Second)
  add(Overlord,   Race::ORC, ClassType::Mystic,  ClassLevel::Third)
  add(Warcryer,   Race::ORC, ClassType::Mystic,  ClassLevel::Third)

  add(DwarvenFighter,   Race::DWARF, ClassType::Fighter, ClassLevel::First)
  add(DwarvenScavenger, Race::DWARF, ClassType::Fighter, ClassLevel::Second)
  add(BountyHunter,     Race::DWARF, ClassType::Fighter, ClassLevel::Third)
  add(DwarvenArtisan,   Race::DWARF, ClassType::Fighter, ClassLevel::Second)
  add(Warsmith,         Race::DWARF, ClassType::Fighter, ClassLevel::Third)

  {% for i in 1..30 %}
    add(DUMMY_ENTRY_{{i}}, Race::NONE, ClassType::Fighter, ClassLevel::First)
  {% end %}

  add(Duelist,       Race::HUMAN, ClassType::Fighter, ClassLevel::Fourth)
  add(Dreadnought,   Race::HUMAN, ClassType::Fighter, ClassLevel::Fourth)
  add(PhoenixKnight, Race::HUMAN, ClassType::Fighter, ClassLevel::Fourth)
  add(HellKnight,    Race::HUMAN, ClassType::Fighter, ClassLevel::Fourth)
  add(Sagittarius,   Race::HUMAN, ClassType::Fighter, ClassLevel::Fourth)
  add(Adventurer,    Race::HUMAN, ClassType::Fighter, ClassLevel::Fourth)
  add(Archmage,      Race::HUMAN, ClassType::Mystic,  ClassLevel::Fourth)
  add(Soultaker,     Race::HUMAN, ClassType::Mystic,  ClassLevel::Fourth)
  add(ArcanaLord,    Race::HUMAN, ClassType::Mystic,  ClassLevel::Fourth)
  add(Cardinal,      Race::HUMAN, ClassType::Priest,  ClassLevel::Fourth)
  add(Hierophant,    Race::HUMAN, ClassType::Priest,  ClassLevel::Fourth)

  add(EvaTemplar,        Race::ELF, ClassType::Fighter, ClassLevel::Fourth)
  add(SwordMuse,         Race::ELF, ClassType::Fighter, ClassLevel::Fourth)
  add(WindRider,         Race::ELF, ClassType::Fighter, ClassLevel::Fourth)
  add(MoonlightSentinel, Race::ELF, ClassType::Fighter, ClassLevel::Fourth)
  add(MysticMuse,        Race::ELF, ClassType::Mystic,  ClassLevel::Fourth)
  add(ElementalMaster,   Race::ELF, ClassType::Mystic,  ClassLevel::Fourth)
  add(EvaSaint,          Race::ELF, ClassType::Priest,  ClassLevel::Fourth)

  add(ShillienTemplar, Race::DARK_ELF, ClassType::Fighter, ClassLevel::Fourth)
  add(SpectralDancer,  Race::DARK_ELF, ClassType::Fighter, ClassLevel::Fourth)
  add(GhostHunter,     Race::DARK_ELF, ClassType::Fighter, ClassLevel::Fourth)
  add(GhostSentinel,   Race::DARK_ELF, ClassType::Fighter, ClassLevel::Fourth)
  add(StormScreamer,   Race::DARK_ELF, ClassType::Mystic,  ClassLevel::Fourth)
  add(SpectralMaster,  Race::DARK_ELF, ClassType::Mystic,  ClassLevel::Fourth)
  add(ShillienSaint,   Race::DARK_ELF, ClassType::Priest,  ClassLevel::Fourth)

  add(Titan,          Race::ORC, ClassType::Fighter, ClassLevel::Fourth)
  add(GrandKhavatari, Race::ORC, ClassType::Fighter, ClassLevel::Fourth)
  add(Dominator,      Race::ORC, ClassType::Mystic,  ClassLevel::Fourth)
  add(Doomcryer,      Race::ORC, ClassType::Mystic,  ClassLevel::Fourth)

  add(FortuneSeeker, Race::DWARF, ClassType::Fighter, ClassLevel::Fourth)
  add(Maestro,       Race::DWARF, ClassType::Fighter, ClassLevel::Fourth)

  {% for i in 31..35 %}
    add(DUMMY_ENTRY_{{i}}, Race::NONE, ClassType::Fighter, ClassLevel::First)
  {% end %}

  add(MaleSoldier,       Race::KAMAEL, ClassType::Fighter, ClassLevel::First)
  add(FemaleSoldier,     Race::KAMAEL, ClassType::Fighter, ClassLevel::First)
  add(Trooper,           Race::KAMAEL, ClassType::Fighter, ClassLevel::Second)
  add(Warder,            Race::KAMAEL, ClassType::Fighter, ClassLevel::Second)
  add(Berserker,         Race::KAMAEL, ClassType::Fighter, ClassLevel::Third)
  add(MaleSoulbreaker,   Race::KAMAEL, ClassType::Fighter, ClassLevel::Third)
  add(FemaleSoulbreaker, Race::KAMAEL, ClassType::Fighter, ClassLevel::Third)
  add(Arbalester,        Race::KAMAEL, ClassType::Fighter, ClassLevel::Third)
  add(Doombringer,       Race::KAMAEL, ClassType::Fighter, ClassLevel::Fourth)
  add(MaleSoulhound,     Race::KAMAEL, ClassType::Fighter, ClassLevel::Fourth)
  add(FemaleSoulhound,   Race::KAMAEL, ClassType::Fighter, ClassLevel::Fourth)
  add(Trickster,         Race::KAMAEL, ClassType::Fighter, ClassLevel::Fourth)
  add(Inspector,         Race::KAMAEL, ClassType::Fighter, ClassLevel::Third)
  add(Judicator,         Race::KAMAEL, ClassType::Fighter, ClassLevel::Fourth)

  def of_type?(type : ClassType) : Bool
    @type == type
  end

  def of_level?(level : ClassLevel) : Bool
    @level == level
  end

  def of_race?(race : Race) : Bool
    @race == race
  end

  def self.get_set(race : Race?, level : ClassLevel) : Set(PlayerClass)
    set = Set(PlayerClass).new
    each do |pc|
      if race.nil? || pc.of_race?(race)
        if level.nil? || pc.of_level?(level)
          set << pc
        end
      end
    end
    set
  end

  private NEVER_SUBCLASSED = Set.new({Overlord, Warsmith})
  private MAIN_SUBCLASS_SET = get_set(nil, ClassLevel::Third) - NEVER_SUBCLASSED

  private SUBCLASS_SET_MAP = {
    DarkAvenger => Set.new({DarkAvenger, Paladin, TempleKnight, ShillienKnight}),
    Paladin => Set.new({DarkAvenger, Paladin, TempleKnight, ShillienKnight}),
    TempleKnight => Set.new({DarkAvenger, Paladin, TempleKnight, ShillienKnight}),
    ShillienKnight => Set.new({DarkAvenger, Paladin, TempleKnight, ShillienKnight}),

    TreasureHunter => Set.new({TreasureHunter, AbyssWalker, Plainswalker}),
    AbyssWalker => Set.new({TreasureHunter, AbyssWalker, Plainswalker}),
    Plainswalker => Set.new({TreasureHunter, AbyssWalker, Plainswalker}),

    Hawkeye => Set.new({Hawkeye, SilverRanger, PhantomRanger}),
    SilverRanger => Set.new({Hawkeye, SilverRanger, PhantomRanger}),
    PhantomRanger => Set.new({Hawkeye, SilverRanger, PhantomRanger}),

    Warlock => Set.new({Warlock, ElementalSummoner, PhantomSummoner}),
    ElementalSummoner => Set.new({Warlock, ElementalSummoner, PhantomSummoner}),
    PhantomSummoner => Set.new({Warlock, ElementalSummoner, PhantomSummoner}),

    Sorceror => Set.new({Sorceror, Spellsinger, Spellhowler}),
    Spellsinger => Set.new({Sorceror, Spellsinger, Spellhowler}),
    Spellhowler => Set.new({Sorceror, Spellsinger, Spellhowler})
  }

  private delegate get_set, to: PlayerClass

  def get_available_subclasses(pc : L2PcInstance) : Set(PlayerClass)?
    subclasses = nil

    if @level.third?
      race = pc.race
      if !race.kamael?
        subclasses = MAIN_SUBCLASS_SET.dup
        subclasses.delete(self)
        if race.elf?
          subclasses.subtract(get_set(Race::DARK_ELF, ClassLevel::Third))
        elsif race.dark_elf?
          subclasses.subtract(get_set(Race::ELF, ClassLevel::Third))
        end
        subclasses.subtract(get_set(Race::KAMAEL, ClassLevel::Third))
        if unavailable = SUBCLASS_SET_MAP[self]?
          subclasses.subtract(unavailable)
        end
      else
        subclasses = get_set(Race::KAMAEL, ClassLevel::Third)
        subclasses.delete(self)

        if Config.max_subclass <= 3
          if pc.appearance.sex
            subclasses.delete(FemaleSoulbreaker)
          else
            subclasses.delete(MaleSoulbreaker)
          end
        end
        tmp = pc.subclasses[2]?
        if tmp.nil? || tmp.level < 75
          subclasses.delete(Inspector)
        end
      end
    end

    subclasses
  end
end
