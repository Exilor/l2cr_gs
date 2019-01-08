require "./attackable_known_list"

class DefenderKnownList < AttackableKnownList
  def add_known_object(obj : L2Object) : Bool
    unless super
      return false
    end

    castle = active_char.castle?
    fort = active_char.fort?
    hall = active_char.conquerable_hall?

    if (fort && fort.zone.active?) || (castle && castle.zone.active?) || (hall && hall.siege_zone.active?)
      pc = nil
      if obj.playable?
        pc = obj.acting_player
      end

      siege_id = fort.try &.residence_id
      siege_id ||= castle.try &.residence_id
      siege_id ||= hall.try &.id || 0

      if pc && ((pc.siege_state == 2 && !pc.registered_on_this_siege_field?(siege_id)) || (pc.siege_state == 1 && !TerritoryWarManager.ally_field?(pc, siege_id)) || pc.siege_state == 0)
        if active_char.intention.idle?
          active_char.intention = AI::ACTIVE
        end
      end
    end

    true
  end

  def active_char
    super.as(L2DefenderInstance)
  end
end
