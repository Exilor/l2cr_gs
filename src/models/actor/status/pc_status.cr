require "./playable_status"

class PcStatus < PlayableStatus
  include Packets::Outgoing

  getter current_cp = 0.0

  def reduce_cp(value : Int32)
    cp = current_cp
    self.current_cp = cp > value ? (cp - value).to_f : 0.0
  end

  def reduce_hp(value : Float64, attacker : L2Character?)
    reduce_hp(value, attacker, true, false, false, false)
  end

  def reduce_hp(value : Float64, attacker : L2Character?, awake : Bool, dot : Bool, hp_consume : Bool)
    reduce_hp(value, attacker, awake, dot, hp_consume, false)
  end

  def reduce_hp(value : Float64, attacker : L2Character?, awake : Bool, dot : Bool, hp_consume : Bool, ignore_cp : Bool)
    pc = active_char
    return if pc.dead?

    if Config.offline_mode_no_damage && pc.client? && pc.client.detached? && ((Config.offline_trade_enable && (pc.private_store_type.sell? || pc.private_store_type.buy?)) || (Config.offline_craft_enable && (pc.in_craft_mode? || pc.private_store_type.manufacture?)))
      return
    end

    return if (pc.invul? || pc.hp_blocked?) && !(dot || hp_consume)

    unless hp_consume
      pc.stop_effects_on_damage awake
      if pc.in_craft_mode? || pc.in_store_mode?
        pc.private_store_type = PrivateStoreType::NONE
        pc.stand_up
        pc.broadcast_user_info
      elsif pc.sitting?
        pc.stand_up
      end

      unless dot
        if pc.stunned? && Rnd.rand(10).zero?
          pc.stop_stunning(true)
        end
      end
    end

    full_value = value.to_i
    t_dmg = mp_dam = 0

    if attacker && attacker != pc
      attacker_player = attacker.acting_player?
      if attacker.is_a?(L2PcInstance)
        return if attacker.gm? && !attacker.access_level.can_give_damage?
        if pc.in_duel?
          return if pc.duel_state.dead? || pc.duel_state.winner?
          if attacker.duel_id != pc.duel_id
            pc.duel_state = DuelState::INTERRUPTED
          end
        end
      end

      if summon = pc.summon
        if pc.has_servitor? && Util.in_range?(1000, pc, summon, true)
          t_dmg = pc.calc_stat(Stats::TRANSFER_DAMAGE_PERCENT, 0).to_i
          t_dmg = (value.to_i * t_dmg) / 100
          t_dmg = Math.min(summon.current_hp - 1, t_dmg).to_i
          if t_dmg > 0
            summon.reduce_current_hp(t_dmg.to_f, attacker, nil)
            value -= t_dmg
            full_value = value.to_i
          end
        end
      end

      mp_dam = (value * pc.calc_stat(Stats::MANA_SHIELD_PERCENT, 0) / 100).to_i
      if mp_dam > 0
        mp_dam = (value - mp_dam).to_i
        if mp_dam > pc.current_mp
          pc.send_packet(SystemMessageId::MP_BECAME_0_ARCANE_SHIELD_DISAPPEARING)
          pc.stop_skill_effects(true, 1556)
          value = mp_dam - pc.current_mp
          pc.current_mp = 0f64
        else
          pc.reduce_current_mp(mp_dam.to_f64)
          sm = SystemMessage.arcane_shield_decreased_your_mp_by_s1_instead_of_hp
          sm.add_int(mp_dam)
          pc.send_packet(sm)
          return
        end
      end

      if (caster = pc.transferring_damage_to) && (party = pc.party?)
        if Util.in_range?(1000, pc, caster, true) && caster.alive?
          if pc != caster && party.members.includes?(caster)
            t_dmg = value.to_i * pc.calc_stat(Stats::TRANSFER_DAMAGE_TO_PLAYER, 0).to_i
            t_dmg /= 100
            t_dmg = Math.min(caster.current_hp - 1, t_dmg).to_i

            if t_dmg > 0
              members_in_range = party.members.count do |m|
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

              if members_in_range > 0
                caster.reduce_current_hp(t_dmg.to_f / members_in_range, attacker, nil)
                value -= t_dmg
                full_value = value.to_i
              end
            end
          end
        end
      end

      if !ignore_cp && attacker.is_a?(L2Playable)
        if current_cp() >= value
          set_current_cp(current_cp() - value)
          value = 0
        else
          value -= current_cp()
          set_current_cp(0f64, false)
        end
      end

      if full_value > 0 && !dot
        sm = SystemMessage.c1_received_damage_of_s3_from_c2
        sm.add_string(pc.name)
        sm.add_char_name(attacker)
        sm.add_int(full_value)
        pc.send_packet(sm)
        if t_dmg > 0 && attacker_player
          sm = SystemMessage.given_s1_damage_to_your_target_and_s2_damage_to_servitor
          sm.add_int(full_value)
          sm.add_int(t_dmg)
          attacker_player.send_packet(sm)
        end
      end
    end

    if value > 0
      value = current_hp() - value
      if value <= 0
        if pc.in_duel?
          pc.disable_all_skills
          stop_hp_mp_regeneration
          if attacker
            attacker.intention = AI::ACTIVE
            attacker.action_failed
            attacker.target = nil
            attacker.abort_attack
          end
          DuelManager.on_player_defeat(pc)
          value = 1
        else
          value = 0
        end
      end

      set_current_hp(value.to_f64)
    end

    if pc.current_hp < 0.5 && !hp_consume
      pc.abort_attack
      pc.abort_cast
      if pc.in_olympiad_mode?
        stop_hp_mp_regeneration
        pc.dead = true
        pc.pending_revive = true
        if summon = pc.summon
          summon.intention = AI::IDLE
        end

        return
      end
      pc.do_die attacker
    end
  end

  def set_current_cp(new_cp : Float64)
    set_current_cp(new_cp, true)
  end

  def set_current_cp(new_cp : Float64, broadcast : Bool)
    pc = active_char

    current_cp = current_cp().to_i
    max_cp = pc.stat.max_cp

    sync do
      return if pc.dead?
      new_cp = 0 if new_cp < 0

      if new_cp >= max_cp
        @current_cp = max_cp.to_f
        @flags_regen_active &= ~REGEN_FLAG_CP

        if @flags_regen_active == 0
          stop_hp_mp_regeneration
        end
      else
        @current_cp = new_cp.to_f
        @flags_regen_active |= REGEN_FLAG_CP
        start_hp_mp_regeneration
      end
    end

    if current_cp != @current_cp && broadcast
      pc.broadcast_status_update
    end
  end

  def do_regeneration
    pc = active_char
    stat = pc.stat

    if current_cp < stat.max_recoverable_cp
      set_current_cp(current_cp + Formulas.cp_regen(pc), false)
    end

    if current_hp < stat.max_recoverable_hp
      set_current_hp(current_hp + Formulas.hp_regen(pc), false)
    end

    if current_mp < stat.max_recoverable_mp
      set_current_mp(current_mp + Formulas.mp_regen(pc), false)
    end

    pc.broadcast_status_update
  end

  def active_char
    super.as(L2PcInstance)
  end
end
