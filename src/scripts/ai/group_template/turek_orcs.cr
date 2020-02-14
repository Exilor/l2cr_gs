class Scripts::TurekOrcs < AbstractNpcAI
  # NPCs
  private MOBS = {
    20494, # Turek War Hound
    20495, # Turek Orc Warlord
    20497, # Turek Orc Skirmisher
    20498, # Turek Orc Supplier
    20499, # Turek Orc Footman
    20500  # Turek Orc Sentinel
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_attack_id(MOBS)
    add_event_received_id(MOBS)
    add_move_finished_id(MOBS)
  end

  def on_adv_event(event, npc, player)
    npc = npc.not_nil!
    if event.casecmp?("checkState") && npc.alive? && !npc.intention.attack?
      if npc.hp_percent > 70 && npc.variables.get_i32("state") == 2
        npc.variables["state"] = 3
        npc.as(L2Attackable).return_home
      else
        npc.variables.delete("state")
      end
    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon)
    if !npc.variables.has_key?("isHit")
      npc.variables["isHit"] = 1
    elsif npc.hp_percent < 50 && npc.hp_percent > 30 && attacker.current_hp > 25
      if npc.has_ai_value?("fleeX") && npc.has_ai_value?("fleeY")
        if npc.has_ai_value?("fleeZ") && npc.variables.get_i32("state") == 0
          if Rnd.rand(100) < 10
            # Say and flee
            broadcast_npc_say(npc, 0, NpcString.get(Rnd.rand(1000007..1000027)))
            npc.disable_core_ai(true) # to avoid attacking behaviour while fleeing
            npc.running = true
            npc.set_intention(AI::MOVE_TO, Location.new(npc.get_ai_value("fleeX"), npc.get_ai_value("fleeY"), npc.get_ai_value("fleeZ")))
            npc.variables["state"] = 1
            npc.variables["attacker"] = attacker.l2id
          end
        end
      end
    end

    super
  end

  def on_event_received(event_name, sender, receiver, reference)
    if event_name == "WARNING" && receiver.alive? && !receiver.intention.attack?
      if pc = reference.try &.acting_player
        if pc.alive?
          receiver.variables["state"] = 3
          receiver.running = true
          receiver.as(L2Attackable).add_damage_hate(pc, 0, 99999)
          receiver.set_intention(AI::ATTACK, pc)
        end
      end
    end

    super
  end

  def on_move_finished(npc)
    # NPC reaches flee point
    if npc.variables.get_i32("state") == 1
      if npc.x == npc.get_ai_value("fleeX") && npc.y == npc.get_ai_value("fleeY")
        npc.disable_core_ai(false)
        start_quest_timer("checkState", 15000, npc, nil)
        npc.variables["state"] = 2
        npc.broadcast_event("WARNING", 400, L2World.get_player(npc.variables.get_i32("attacker")))
      else
        npc.set_intention(AI::MOVE_TO, Location.new(npc.get_ai_value("fleeX"), npc.get_ai_value("fleeY"), npc.get_ai_value("fleeZ")))
      end
    elsif npc.variables.get_i32("state") == 3 && npc.stays_in_spawn_loc?
      npc.disable_core_ai(false)
      npc.variables.delete("state")
    end
  end
end
