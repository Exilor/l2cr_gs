require "./attackable_known_list"

class DefenderKnownList < AttackableKnownList
  def add_known_object(obj : L2Object) : Bool
    return false unless super

    me = active_char

    if ((fort = me.fort?) && fort.zone.active?) || ((castle = me.castle?) && castle.zone.active?) || ((hall = me.conquerable_hall) && hall.siege_zone.active?)
      if obj.playable?
        pc = obj.acting_player
      end

      siege_id = fort.try &.residence_id
      siege_id ||= castle.try &.residence_id
      siege_id ||= hall.try &.id || 0

      if pc && ((pc.siege_state == 2 && !pc.registered_on_this_siege_field?(siege_id)) || (pc.siege_state == 1 && !TerritoryWarManager.ally_field?(pc, siege_id)) || pc.siege_state == 0)
        if me.intention.idle?
          me.intention = AI::ACTIVE
        end
      end
    end

    true
  end

  def active_char : L2DefenderInstance
    super.as(L2DefenderInstance)
  end
end
