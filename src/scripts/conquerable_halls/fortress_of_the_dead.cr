class Scripts::FortressOfTheDead < ClanHallSiegeEngine
  private LIDIA = 35629
  private ALFRED = 35630
  private GISELLE = 35631
  private DAMAGE_TO_LIDIA = {} of Int32 => Int32

  def initialize
    super(self.class.simple_name, "conquerablehalls", FORTRESS_OF_DEAD)

    add_kill_id(LIDIA)
    add_kill_id(ALFRED)
    add_kill_id(GISELLE)

    add_spawn_id(LIDIA)
    add_spawn_id(ALFRED)
    add_spawn_id(GISELLE)

    add_attack_id(LIDIA)
  end

  def on_spawn(npc)
    if npc.id == LIDIA
      broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::HMM_THOSE_WHO_ARE_NOT_OF_THE_BLOODLINE_ARE_COMING_THIS_WAY_TO_TAKE_OVER_THE_CASTLE_HUMPH_THE_BITTER_GRUDGES_OF_THE_DEAD_YOU_MUST_NOT_MAKE_LIGHT_OF_THEIR_POWER)
    elsif npc.id == ALFRED
      broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::HEH_HEH_I_SEE_THAT_THE_FEAST_HAS_BEGUN_BE_WARY_THE_CURSE_OF_THE_HELLMANN_FAMILY_HAS_POISONED_THIS_LAND)
    elsif npc.id == GISELLE
      broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::ARISE_MY_FAITHFUL_SERVANTS_YOU_MY_PEOPLE_WHO_HAVE_INHERITED_THE_BLOOD_IT_IS_THE_CALLING_OF_MY_DAUGHTER_THE_FEAST_OF_BLOOD_WILL_NOW_BEGIN)
    end

    nil
  end

  def on_attack(npc, attacker, damage, is_summon)
    unless @hall.in_siege?
      return
    end

    sync do
      clan = attacker.clan
      if clan && attacker?(clan)
        id = clan.id
        if id > 0 && (new_damage = DAMAGE_TO_LIDIA[id]?)
          new_damage += damage
          DAMAGE_TO_LIDIA[id] = new_damage
        else
          DAMAGE_TO_LIDIA[id] = damage
        end
      end
    end

    nil
  end

  def on_kill(npc, killer, is_summon)
    unless @hall.in_siege?
      return
    end

    npc_id = npc.id

    if npc_id == ALFRED || npc_id == GISELLE
      broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::AARGH_IF_I_DIE_THEN_THE_MAGIC_FORCE_FIELD_OF_BLOOD_WILL)
    end

    if npc_id == LIDIA
      broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::GRARR_FOR_THE_NEXT_2_MINUTES_OR_SO_THE_GAME_ARENA_ARE_WILL_BE_CLEANED_THROW_ANY_ITEMS_YOU_DONT_NEED_TO_THE_FLOOR_NOW)
      @mission_accomplished = true
      sync do
        cancel_siege_task
        end_siege
      end
    end

    nil
  end

  def winner : L2Clan?
    counter = 0
    most_damaged = 0
    DAMAGE_TO_LIDIA.each do |key, value|
      damage = value
      if damage > counter
        counter = damage
        most_damaged = key
      end
    end

    ClanTable.get_clan(most_damaged)
  end

  def start_siege
    # Siege must start at night
    hours_left = (GameTimer.time // 60) % 24

    if hours_left < 0 || hours_left > 6
      cancel_siege_task
      time = (24 - hours_left).to_i64 * 10 * 60000
      @siege_task = ThreadPoolManager.schedule_general(->siege_starts_task, time)
    else
      super
    end
  end
end
