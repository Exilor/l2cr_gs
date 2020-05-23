require "../../models/entity/clan_hall/clan_hall_siege_engine"

class Scripts::DevastatedCastle < ClanHallSiegeEngine
  private GUSTAV = 35410
  private MIKHAIL = 35409
  private DIETRICH = 35408
  private DAMAGE_TO_GUSTAV = {} of Int32 => Int32

  @gustav_trigger_hp : Float64

  def initialize
    super(self.class.simple_name, "conquerablehalls", DEVASTATED_CASTLE)

    @gustav_trigger_hp = NpcData[GUSTAV].base_hp_max.to_f64 / 12

    add_kill_id(GUSTAV)
    add_spawn_id(MIKHAIL)
    add_spawn_id(DIETRICH)
    add_attack_id(GUSTAV)
  end

  def on_spawn(npc)
    if npc.id == MIKHAIL
      broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::GLORY_TO_ADEN_THE_KINGDOM_OF_THE_LION_GLORY_TO_SIR_GUSTAV_OUR_IMMORTAL_LORD)
    elsif npc.id == DIETRICH
      broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::SOLDIERS_OF_GUSTAV_GO_FORTH_AND_DESTROY_THE_INVADERS)
    end

    nil
  end

  def on_attack(npc, attacker, damage, is_summon)
    unless @hall.in_siege?
      return
    end

    sync do
      if (clan = attacker.clan) && attacker?(clan)
        id = clan.id
        if new_damage = DAMAGE_TO_GUSTAV[id]?
          new_damage += damage
          DAMAGE_TO_GUSTAV[id] = new_damage
        else
          DAMAGE_TO_GUSTAV[id] = damage
        end
      end

      if npc.current_hp < @gustav_trigger_hp && !npc.intention.cast?
        broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::THIS_IS_UNBELIEVABLE_HAVE_I_REALLY_BEEN_DEFEATED_I_SHALL_RETURN_AND_TAKE_YOUR_HEAD)
        npc.set_intention(AI::CAST, SkillData[4235, 1], npc)
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    unless @hall.in_siege?
      return
    end

    @mission_accomplished = true

    if npc.id == GUSTAV
      sync do
        cancel_siege_task
        end_siege
      end
    end

    super
  end

  def winner : L2Clan?
    counter = 0
    most_damaged = 0
    DAMAGE_TO_GUSTAV.each do |clan_id, damage|
      if damage > counter
        counter = damage
        most_damaged = clan_id
      end
    end

    ClanTable.get_clan(most_damaged)
  end
end
