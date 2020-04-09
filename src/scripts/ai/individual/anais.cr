  class Scripts::Anais < AbstractNpcAI
    # NPCs
    private ANAIS = 25701
    private DIVINE_BURNER = 18915
    private GRAIL_WARD = 18929
    # Skill
    private DIVINE_NOVA = SkillHolder.new(6326)
    # Instances
    private DIVINE_BURNERS = Array(L2Npc).new(4)

    @next_target : L2PcInstance?
    @current : L2Npc?
    @pot = 0

    def initialize
      super(self.class.simple_name, "ai/individual")

      add_attack_id(ANAIS)
      add_spawn_id(DIVINE_BURNER)
      add_kill_id(GRAIL_WARD)
    end

    private def burner_on_attack(pot, anais)
      npc = DIVINE_BURNERS[pot]
      npc.display_effect = 1
      npc.running = false
      if pot < 4
        @current = npc
        check_around = get_quest_timer("CHECK", anais, nil)
        if check_around.nil? # || !check_around.active?
          start_quest_timer("CHECK", 3000, anais, nil)
        end
      else
        cancel_quest_timer("CHECK", anais, nil)
      end
    end

    def on_adv_event(event, npc, player)
      npc = npc.not_nil!

      case event
      when "CHECK"
        unless npc.attacking_now?
          cancel_quest_timer("CHECK", npc, nil)
        end
        if @current || @pot < 4
          players = npc.known_list.known_players.values
          target = players.sample?(random: Rnd)
          @next_target = target || npc.target.as?(L2PcInstance)
          b = DIVINE_BURNERS[@pot]
          @pot += 1
          b.display_effect = 1
          b.running = false
          ward = add_spawn(GRAIL_WARD, Location.new(*b.xyz), true, 0)
          ward.as(L2Attackable).add_damage_hate(@next_target, 0, 999)
          ward.running = true
          ward.set_intention(AI::ATTACK, @next_target, nil)
          start_quest_timer("GUARD_ATTACK", 1000, ward, @next_target, true)
          start_quest_timer("SUICIDE", 20000, ward, nil)
          ward.set_intention(AI::ATTACK, @next_target)
        end
      when "GUARD_ATTACK"
        if next_target = @next_target
          distance = npc.calculate_distance(next_target, false, false)
          if distance < 100
            npc.do_cast(DIVINE_NOVA)
          elsif distance > 2000
            npc.do_die(nil)
            cancel_quest_timer("GUARD_ATTACK", npc, player)
          end
        end
      when "SUICIDE"
        npc.do_cast(DIVINE_NOVA)
        cancel_quest_timer("GUARD_ATTACK", npc, @next_target)
        if current = @current
          current.display_effect = 2
          current.running = false
          @current = nil
        end
        npc.do_die(nil)
      else
        # [automatically added else]
      end


      super
    end

    def on_attack(npc, attacker, damage, is_summon)
      if @pot == 0
        burner_on_attack(0, npc)
      elsif npc.current_hp <= npc.max_recoverable_hp * 0.75 && @pot == 1
        burner_on_attack(1, npc)
      elsif npc.current_hp <= npc.max_recoverable_hp * 0.5 && @pot == 2
        burner_on_attack(2, npc)
      elsif npc.current_hp <= npc.max_recoverable_hp * 0.25 && @pot == 3
        burner_on_attack(3, npc)
      end

      super
    end

    def on_spawn(npc)
      DIVINE_BURNERS << npc
      super
    end

    def on_kill(npc, killer, is_summon)
      npc.do_cast(DIVINE_NOVA.skill)
      cancel_quest_timer("GUARD_ATTACK", npc, @next_target)
      cancel_quest_timer("CHECK", npc, nil)
      if current = @current
        current.display_effect = 2
        current.running = false
        @current = nil
      end

      super
    end
  end
