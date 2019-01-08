require "./playable_status"

class SummonStatus < PlayableStatus
  def reduce_hp(value : Float64, attacker : L2Character?)
    reduce_hp(value, attacker, true, false, false)
  end

  def reduce_hp(value : Float64, attacker : L2Character?, awake : Bool, dot : Bool, hp_consume : Bool)
    sum = active_char
    return unless attacker && sum.alive?

    pc = attacker.acting_player?

    if pc && (sum.owner?.nil? || sum.owner.duel_id != pc.duel_id)
      pc.duel_state = DuelState::INTERRUPTED
    end

    caster = sum.transferring_damage_to

    if party = sum.owner.party?
      if caster && Util.in_range?(1000, sum, caster, true) && caster.alive?
        if party.members.includes?(caster)
          t_dmg = sum.calc_stat(Stats::TRANSFER_DAMAGE_TO_PLAYER, 0).to_i
          t_dmg = (value.to_i * t_dmg) / 100
          t_dmg = Math.min(caster.current_hp - 1, t_dmg).to_i
          if t_dmg > 0
            in_range = party.members.count do |m|
              Util.in_range?(1000, m, caster, false) && m != caster
            end
            if attacker.playable? && caster.current_cp > 0
              if caster.current_cp > t_dmg
                caster.status.reduce_cp(t_dmg)
              else
                t_dmg = (t_dmg - caster.current_cp).to_i
                caster.status.reduce_cp(caster.current_cp.to_i)
              end
            end

            if in_range > 0
              caster.reduce_current_hp(t_dmg.fdiv(in_range), attacker, nil)
              value -= t_dmg
            end
          end
        end
      end
    elsif caster && caster == sum.owner
      if Util.in_range?(1000, sum, caster, true) && caster.alive?
        t_dmg = sum.calc_stat(Stats::TRANSFER_DAMAGE_TO_PLAYER, 0)
        t_dmg = (value * t_dmg) / 100
        t_dmg = Math.min(caster.current_hp - 1, t_dmg)
        if t_dmg > 0
          if attacker.playable? && caster.current_cp > 0
            if caster.current_cp > t_dmg
              caster.status.reduce_cp(t_dmg.to_i)
            else
              t_dmg = (t_dmg - caster.current_cp).to_i
              caster.status.reduce_cp caster.current_cp.to_i
            end
          end

          caster.reduce_current_hp(t_dmg.to_f, attacker, nil)
          value -= t_dmg
        end
      end
    end

    super
  end

  def active_char
    super.as(L2Summon)
  end
end
