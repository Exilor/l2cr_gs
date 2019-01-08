# class L2BodyguardInstance < L2Attackable
#   property! pc : L2PcInstance?

#   @follow_task : Runnable::PeriodicTask?
#   @defend_task : Runnable::PeriodicTask?

#   def instance_type
#     InstanceType::L2GuardInstance
#   end

#   def on_spawn
#     ThreadPoolManager.schedule_ai_at_fixed_rate(->defend_task, 1000, 100)
#     # self.no_rnd_walk = true
#     super
#   end

#   def do_die(killer : L2Character?) : Bool
#     return false unless super
#     @defend_task.try &.cancel
#     true
#   end

#   private def defend_task
#     return unless intention.active? || intention.idle?
#     return unless pc = pc?
#     return unless pc && pc.world_region?

#     unless inside_radius?(pc, 400, true, false) && !intention.move_to?
#       ai.move_to_pawn(pc, 100)
#       return
#     end

#     set_intention(AI::ACTIVE)

#     candidates = [] of L2Character

#     L2World.get_visible_objects(pc, 1500) do |obj|
#       case obj
#       when L2Attackable
#         next if obj.dead?

#         if info = obj.aggro_list.find { |ch, _| ch.l2id == pc.l2id}
#           candidates << obj
#         elsif obj.aggressive? && obj.aggro_range >= pc.calculate_distance(obj, true, false)
#           candidates << obj
#         end
#       when L2Playable
#       end
#     end

#     unless candidates.empty?
#       target = candidates.sample
#       known_list.add_known_object(target)
#       add_damage_hate(target, 0, 1i64)
#       self.target = target
#       set_intention(AI::ATTACK, target)
#     end
#   end
# end

class L2BodyguardAI < L2AttackableAI
  private def auto_attack_condition(target : L2Character?) : Bool
    return false unless target

    me = active_char.as(L2BodyguardInstance)
    return false unless pc = me.pc?
    return false if target == pc

    if target.ai?
      if target.ai.@attack_target == pc || target.ai.@cast_target == pc
        return true
      end
    end

    if target.is_a?(L2MonsterInstance)
      if target.aggressive?
        if target.aggro_range >= pc.calculate_distance(target, true, false)
          return true
        end
      end
    end

    super
  end

  private def think_active
    super

    me = active_char.as(L2BodyguardInstance)
    return unless pc = me.pc?
    unless intention.attack? || intention.move_to?
      unless me.inside_radius?(pc, 345, true, false)
        move_to_pawn(pc, 100)
      end
    end
  end
end


class L2BodyguardInstance < L2Attackable
  property! pc : L2PcInstance?

  @follow_task : Runnable::PeriodicTask?
  @defend_task : Runnable::PeriodicTask?

  def instance_type
    InstanceType::L2GuardInstance
  end

  def init_ai
    L2BodyguardAI.new(self)
  end

  def on_spawn
    super
  end

  def do_die(killer : L2Character?) : Bool
    return false unless super
    true
  end

  def aggressive?
    true
  end

  # private def defend_task
  #   return unless intention.active? || intention.idle?
  #   return unless pc = pc?
  #   return unless pc && pc.world_region?

  #   unless inside_radius?(pc, 400, true, false) && !intention.move_to?
  #     ai.move_to_pawn(pc, 100)
  #     return
  #   end

  #   set_intention(AI::ACTIVE)

  #   candidates = [] of L2Character

  #   L2World.get_visible_objects(pc, 1500) do |obj|
  #     case obj
  #     when L2Attackable
  #       next if obj.dead?

  #       if info = obj.aggro_list.find { |ch, _| ch.l2id == pc.l2id}
  #         candidates << obj
  #       elsif obj.aggressive? && obj.aggro_range >= pc.calculate_distance(obj, true, false)
  #         candidates << obj
  #       end
  #     when L2Playable
  #     end
  #   end

  #   unless candidates.empty?
  #     target = candidates.sample
  #     known_list.add_known_object(target)
  #     add_damage_hate(target, 0, 1i64)
  #     self.target = target
  #     set_intention(AI::ATTACK, target)
  #   end
  # end
end
