require "../known_list/defender_known_list"
require "../ai/l2_fort_siege_guard_ai"
require "../ai/l2_siege_guard_ai"
require "../ai/l2_special_siege_guard_ai"

class L2DefenderInstance < L2Attackable
  @castle : Castle?
  @fort : Fort?
  @hall : SiegableHall?

  def instance_type : InstanceType
    InstanceType::L2DefenderInstance
  end

  private def init_known_list
    @known_list = DefenderKnownList.new(self)
  end

  def has_random_animation? : Bool
    false
  end

  private def init_ai
    if conquerable_hall.nil? && get_castle(10_000).nil?
      L2FortSiegeGuardAI.new(self)
    elsif get_castle(10_000)
      L2SiegeGuardAI.new(self)
    else
      L2SpecialSiegeGuardAI.new(self)
    end
  end

  def auto_attackable?(attacker : L2Character) : Bool
    unless attacker.is_a?(L2Playable)
      return false
    end

    pc = attacker.acting_player

    fort = @fort
    castle = @castle
    hall = @hall

    if (fort && fort.zone.active?) || (castle && castle.zone.active?) || (hall && hall.siege_zone.active?)
      siege_id = fort.try &.residence_id
      siege_id ||= castle.try &.residence_id
      siege_id ||= hall.try &.id || 0

      if pc && ((pc.siege_state == 2 && !pc.registered_on_this_siege_field?(siege_id)) || (pc.siege_state == 1 && !TerritoryWarManager.ally_field?(pc, siege_id)) || pc.siege_state == 0)
        return true
      end
    end

    false
  end

  def return_home
    if walk_speed <= 0
      return
    end

    unless sp = spawn?
      return
    end

    unless inside_radius?(sp, 40, false, false)
      debug "Moving home."

      self.returning_to_spawn_point = true
      clear_aggro_list

      if ai?
        set_intention(AI::MOVE_TO, sp.location)
      end
    end
  end

  def on_spawn
    super

    @fort = FortManager.get_fort(*xyz)
    @castle = CastleManager.get_castle(*xyz)
    @hall = conquerable_hall
    unless @fort || @castle || @hall
      error { "Spawned outside of fortress, castle or siegable hall (at #{x} #{y} #{z})." }
    end
  end

  def on_action(pc : L2PcInstance, interact : Bool)
    unless can_target?(pc)
      pc.action_failed
      return
    end

    if self != pc.target
      pc.target = self
    elsif interact
      if auto_attackable?(pc) && !looks_dead? && (pc.z - z).abs < 600
        pc.set_intention(AI::ATTACK, self)
      end

      if !auto_attackable?(pc) && !can_interact?(pc)
        pc.set_intention(AI::INTERACT, self)
      end
    end

    pc.action_failed
  end

  def add_damage_hate(attacker : L2Character?, damage : Int, aggro : Int)
    return unless attacker

    unless attacker.is_a?(L2DefenderInstance)
      if damage == 0 && aggro <= 1 && attacker.is_a?(L2Playable)
        fort, castle, hall = @fort, @castle, @hall

        if (fort && fort.zone.active?) || (castle && castle.zone.active?) || (hall && hall.siege_zone.active?)
          pc = attacker.acting_player
          siege_id = fort.try &.residence_id
          siege_id ||= castle.try &.residence_id
          siege_id ||= hall.try &.id || 0

          if pc && ((pc.siege_state == 2 && pc.registered_on_this_siege_field?(siege_id)) || (pc.siege_state == 1 && TerritoryWarManager.ally_field?(pc, siege_id)) || pc.siege_state == 0)
            return
          end
        end
      end

      super
    end
  end
end
