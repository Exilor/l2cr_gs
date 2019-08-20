class Scripts::MonumentOfHeroes < AbstractNpcAI
  # NPCs
  private MONUMENTS = {
    31690,
    31769,
    31770,
    31771,
    31772
  }
  # Items
  private WINGS_OF_DESTINY_CIRCLET = 6842
  private WEAPONS = {
    6611, # Infinity Blade
    6612, # Infinity Cleaver
    6613, # Infinity Axe
    6614, # Infinity Rod
    6615, # Infinity Crusher
    6616, # Infinity Scepter
    6617, # Infinity Stinger
    6618, # Infinity Fang
    6619, # Infinity Bow
    6620, # Infinity Wing
    6621, # Infinity Spear
    9388, # Infinity Rapier
    9389, # Infinity Sword
    9390  # Infinity Shooter
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(MONUMENTS)
    add_talk_id(MONUMENTS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    case event
    when "HeroWeapon"
      if pc.hero?
        if has_at_least_one_quest_item?(pc, WEAPONS)
          return "already_have_weapon.htm"
        else
          return "weapon_list.htm"
        end
      end
      return "no_hero_weapon.htm"
    when "HeroCirclet"
      if pc.hero?
        if has_quest_items?(pc, WINGS_OF_DESTINY_CIRCLET)
          return "already_have_circlet.htm"
        else
          give_items(pc, WINGS_OF_DESTINY_CIRCLET, 1)
        end
      else
        return "no_hero_circlet.htm"
      end
    else
      weapon_id = event.to_i
      if WEAPONS.includes?(weapon_id)
        give_items(pc, weapon_id, 1)
      end
    end

    super
  end
end
