require "./char_status"

class NpcStatus < CharStatus
  def reduce_hp(value : Float64, attacker : L2Character?, awake : Bool, dot : Bool, hp_consume : Bool)
    return if @active_char.dead?

    if attacker
      if pc = attacker.acting_player?
        if pc.in_duel?
          pc.duel_state = DuelState::INTERRUPTED
        end
      end

      active_char.add_attacker_to_attack_by_list(attacker)
    end

    super
  end

  def active_char : L2Npc
    super.as(L2Npc)
  end
end
