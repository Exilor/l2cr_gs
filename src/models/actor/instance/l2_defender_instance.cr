require "../known_list/defender_known_list"

class L2DefenderInstance < L2Attackable
  @castle : Castle?
  @fort : Fort?
  @hall : SiegableHall?

  def instance_type : InstanceType
    InstanceType::L2DefenderInstance
  end

  def init_known_list
    @known_list = DefenderKnownList.new(self)
  end

  def has_random_animation? : Bool
    false
  end

  # TODO: L2FortSiegeGuardAI, L2SiegeGuardAI, L2SpecialSiegeGuardAI

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
      if Config.debug
        debug "#{l2id} moving home."
      end

      self.returning_to_spawn_point = true
      clear_aggro_list

      if ai?
        set_intention(AI::MOVE_TO, sp.location)
      end
    end
  end

  def on_action(pc : L2PcInstance, interact : Bool)
    unless can_target?(pc)
      pc.action_failed
      return
    end

    if self != pc.target
      if Config.debug
        debug "New target selected: #{l2id}."
      end

      pc.target = self
    elsif interact
      if auto_attackable?(pc) && !looks_dead?
        if (pc.z - z).abs < 600
          pc.set_intention(AI::ATTACK, self)
        end
      end

      unless auto_attackable?(pc)
        unless can_interact?(pc)
          pc.set_intention(AI::INTERACT, self)
        end
      end
    end

    pc.action_failed
  end

  def add_damage_hate(attacker : L2Character?, damage : Int, aggro : Int)
    return unless attacker

    unless attacker.is_a?(L2DefenderInstance)
      if damage == 0 && aggro <= 1 && attacker.is_a?(L2Playable)
        fort, castle, hall = @fort, @castle, @hall

        pc = attacker.acting_player?

        siege_id = fort.try &.residence_id
        siege_id ||= castle.try &.residence_id
        siege_id ||= hall.try &.id || 0

        if pc && ((pc.siege_state == 2 && !pc.registered_on_this_siege_field?(siege_id)) || (pc.siege_state == 1 && !TerritoryWarManager.ally_field?(pc, siege_id)) || pc.siege_state == 0)
          return true
        end
      end

      super
    end
  end
end
