class L2FortCommanderInstance < L2DefenderInstance
  property? can_talk : Bool = true

  def instance_type : InstanceType
    InstanceType::L2FortCommanderInstance
  end

  def auto_attackable?(attacker : L2Character) : Bool
    unless attacker.is_a?(L2PcInstance)
      return false
    end

    unless fort.residence_id > 0 && fort.siege.in_progress?
      return false
    end

    !fort.siege.defender?(attacker.clan)
  end

  def add_damage_hate(attacker : L2Character?, damage : Int32, aggro : Int64)
    return unless attacker

    unless attacker.is_a?(L2FortCommanderInstance)
      super
    end
  end

  def do_die(killer : L2Character?) : Bool
    return false unless super

    if fort.siege.in_progress?
      fort.siege.killed_commander(self)
    end

    true
  end

  def return_home
    return if inside_radius?(spawn, 200, false, false)

    debug "Returning home."

    self.returning_to_spawn_point = true
    clear_aggro_list

    if ai?
      ai.set_intention(AI::MOVE_TO, spawn.location)
    end
  end

  def add_damage(attacker : L2Character, damage : Int32, skill : Skill?)
    sp = spawn?

    if sp && can_talk?
      commanders = FortSiegeManager.get_commander_spawn_list(fort.residence_id)
      commanders.not_nil!.each do |sp2|
        if sp2.id == sp.id
          case sp2.message_id
          when 1
            npc_string = NpcString::ATTACKING_THE_ENEMYS_REINFORCEMENTS_IS_NECESSARY_TIME_TO_DIE
          when 2
            if attacker.is_a?(L2Summon)
              attacker = attacker.owner
            end
            npc_string = NpcString::EVERYONE_CONCENTRATE_YOUR_ATTACKS_ON_S1_SHOW_THE_ENEMY_YOUR_RESOLVE
          when 3
            npc_string = NpcString::SPIRIT_OF_FIRE_UNLEASH_YOUR_POWER_BURN_THE_ENEMY
          else
            # automatically added
          end


          if npc_string
            ns = NpcSay.new(l2id, Packets::Incoming::Say2::NPC_SHOUT, id, npc_string)
            if npc_string.param_count == 1
              ns.add_string_parameter(attacker.name)
            end

            broadcast_packet(ns)
            self.can_talk = false
            ThreadPoolManager.schedule_general(TalkTask.new(self), 10000)
          end
        end
      end
    end

    super
  end

  def has_random_animation? : Bool
    false
  end

  private struct TalkTask
    initializer commander : L2FortCommanderInstance

    def call
      @commander.can_talk = true
    end
  end
end