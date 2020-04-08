require "../../../enums/class_id"

class Scripts::DragonValley < AbstractNpcAI
  # NPC
  private DRAKOS_ASSASSIN = 22823
  private SUMMON_NPC = {
    22824, # Drakos Guardian
    22862  # Drakos Hunter
  }
  private SPAWN_ANIMATION = {
    22826, # Scorpion Bones
    22823, # Drakos Assassin
    22828  # Parasitic Leech

  }
  private SPOIL_REACT_MONSTER = {
    22822, # Drakos Warrior
    22823, # Drakos Assassin
    22824, # Drakos Guardian
    22825, # Giant Scorpion Bones
    22826, # Scorpion Bones
    22827, # Batwing Drake
    22828, # Parasitic Leech
    22829, # Emerald Drake
    22830, # Gem Dragon
    22831, # Dragon Tracker of the Valley
    22832, # Dragon Scout of the Valley
    22833, # Sand Drake Tracker
    22834, # Dust Dragon Tracker
    22860, # Hungry Parasitic Leech
    22861, # Hard Scorpion Bones
    22862  # Drakos Hunter
  }
  # Items
  private GREATER_HERB_OF_MANA = 8604
  private SUPERIOR_HERB_OF_MANA = 8605
  # Skills
  private MORALE_BOOST1 = SkillHolder.new(6885)
  private MORALE_BOOST2 = SkillHolder.new(6885, 2)
  private MORALE_BOOST3 = SkillHolder.new(6885, 3)
  # Misc
  private MIN_DISTANCE = 1500
  private MIN_MEMBERS = 3
  private MIN_LVL = 80
  private CLASS_LVL = 3
  private CLASS_POINTS = EnumMap {
    ClassId::ADVENTURER => 0.2,
    ClassId::ARCANA_LORD => 1.5,
    ClassId::ARCHMAGE => 0.3,
    ClassId::CARDINAL => -0.6,
    ClassId::DOMINATOR => 0.2,
    ClassId::DOOMBRINGER => 0.2,
    ClassId::DOOMCRYER => 0.1,
    ClassId::DREADNOUGHT => 0.7,
    ClassId::DUELIST => 0.2,
    ClassId::ELEMENTAL_MASTER => 1.4,
    ClassId::EVA_SAINT => -0.6,
    ClassId::EVA_TEMPLAR => 0.8,
    ClassId::FEMALE_SOULHOUND => 0.4,
    ClassId::FORTUNE_SEEKER => 0.9,
    ClassId::GHOST_HUNTER => 0.2,
    ClassId::GHOST_SENTINEL => 0.2,
    ClassId::GRAND_KHAVATARI => 0.2,
    ClassId::HELL_KNIGHT => 0.6,
    ClassId::HIEROPHANT => 0.0,
    ClassId::JUDICATOR => 0.1,
    ClassId::MOONLIGHT_SENTINEL => 0.2,
    ClassId::MAESTRO => 0.7,
    ClassId::MALE_SOULHOUND => 0.4,
    ClassId::MYSTIC_MUSE => 0.3,
    ClassId::PHOENIX_KNIGHT => 0.6,
    ClassId::SAGITTARIUS => 0.2,
    ClassId::SHILLIEN_SAINT => -0.6,
    ClassId::SHILLIEN_TEMPLAR => 0.8,
    ClassId::SOULTAKER => 0.3,
    ClassId::SPECTRAL_DANCER => 0.4,
    ClassId::SPECTRAL_MASTER => 1.4,
    ClassId::STORM_SCREAMER => 0.3,
    ClassId::SWORD_MUSE => 0.4,
    ClassId::TITAN => 0.3,
    ClassId::TRICKSTER => 0.5,
    ClassId::WIND_RIDER => 0.2
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_attack_id(SUMMON_NPC)
    add_kill_id(SPOIL_REACT_MONSTER)
    add_spawn_id(SPOIL_REACT_MONSTER)
  end

  def on_attack(npc, attacker, damage, is_summon)
    if npc.current_hp < npc.max_hp / 2 && Rnd.rand(100) < 5 && npc.script_value?(0)
      npc.script_value = 1
      Rnd.rand(3..5).times do |i|
        playable = (is_summon ? attacker.summon : attacker) || attacker
        minion = add_spawn(DRAKOS_ASSASSIN, npc.x, npc.y, npc.z + 10, npc.heading, true, 0, true)
        add_attack_desire(minion, playable)
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    if npc.as(L2Attackable).spoiled?
      npc.drop_item(killer, Rnd.rand(GREATER_HERB_OF_MANA..SUPERIOR_HERB_OF_MANA), 1)
      manage_morale_boost(killer, npc)
    end

    super
  end

  def on_spawn(npc)
    if SPAWN_ANIMATION.includes?(npc.id)
      npc.show_summon_animation = true
    end

    super
  end

  private def manage_morale_boost(pc, npc)
    points = 0.0
    morale_boost_lv = 0

    party = pc.party
    if party && party.size >= MIN_MEMBERS && npc
      party.members.each do |member|
        if member.level >= MIN_LVL && member.class_id.level >= CLASS_LVL
          if npc.calculate_distance(member, true, false) < MIN_DISTANCE
            points += CLASS_POINTS[member.class_id]
          end
        end
      end

      if points >= 3
        morale_boost_lv = 3
      elsif points >= 2
        morale_boost_lv = 2
      elsif points >= 1
        morale_boost_lv = 1
      end

      party.members.each do |member|
        if npc.calculate_distance(member, true, false) < MIN_DISTANCE
          case morale_boost_lv
          when 1
            MORALE_BOOST1.skill.apply_effects(member, member)
          when 2
            MORALE_BOOST2.skill.apply_effects(member, member)
          when 3
            MORALE_BOOST3.skill.apply_effects(member, member)
          else
            # automatically added
          end

        end
      end
    end
  end
end