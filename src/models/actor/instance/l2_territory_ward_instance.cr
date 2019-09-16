class L2TerritoryWardInstance < L2Attackable
  def initialize(template : L2NpcTemplate)
    super
    disable_core_ai(true)
  end

  def auto_attackable?(attacker : L2Character) : Bool
    if invul?
      return false
    end

    if !castle? || !castle.zone.active?
      return false
    end

    unless pc = attacker.acting_player?
      return false
    end

    if pc.siege_side == 0
      return false
    end

    if TerritoryWarManager.ally_field?(pc, castle.residence_id)
      return false
    end

    true
  end

  def has_random_animation? : Bool
    false
  end

  def on_spawn
    super

    unless castle?
      warn "#{self.class} spawned outside a castle zone."
    end
  end

  def reduce_current_hp(value : Float64, attacker : L2Character?, awake : Bool, dot : Bool, skill : Skill?)
    if skill || !TerritoryWarManager.tw_in_progress?
      return
    end

    unless attacker
      return
    end

    unless pc = attacker.acting_player?
      return
    end

    if pc.combat_flag_equipped?
      return
    end

    if pc.siege_side == 0
      return
    end

    unless castle = castle?
      return
    end

    if TerritoryWarManager.ally_field?(pc, castle.residence_id)
      return
    end

    super
  end

  def reduce_current_hp_by_dot(hp : Float64, attacker : L2Character?, skill : Skill)
    # no-op
  end

  def do_die(killer : L2Character?) : Bool
    if !super || castle?.nil? || !TerritoryWarManager.tw_in_progress?
      return false
    end

    if killer.is_a?(L2PcInstance)
      if killer.siege_side > 0 && !killer.combat_flag_equipped?
        killer.add_item("Pickup", id - 23012, 1, nil, false)
      else
        TerritoryWarManager.get_territory_ward!(id - 23012).spawn_me
      end

      sm = SystemMessage.the_s1_ward_has_been_destroyed_c2_has_the_ward
      sm.add_string(name.gsub(" Ward", ""))
      sm.add_pc_name(killer)
      TerritoryWarManager.announce_to_participants(sm, 0, 0)
    else
      TerritoryWarManager.get_territory_ward!(id - 36491).spawn_me
    end

    decay_me
    true
  end

  def on_forced_attack(pc : L2PcInstance)
    on_action(pc)
  end

  def on_action(pc : L2PcInstance, interact : Bool)
    unless can_target?(pc)
      return
    end

    if pc.target != self
      pc.target = self
    elsif interact
      if auto_attackable?(pc) && (pc.z - z).abs < 100
        pc.set_intention(AI::ATTACK, self)
      else
        pc.action_failed
      end
    end
  end
end
