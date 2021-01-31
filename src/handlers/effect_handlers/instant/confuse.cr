class EffectHandler::Confuse < AbstractEffect
  @chance : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @chance = params.get_i32("chance", 100)
  end

  def calc_success(info : BuffInfo) : Bool
    Formulas.probability(@chance.to_f, info.effector, info.effected, info.skill)
  end

  def effect_flags
    EffectFlag::CONFUSED.mask
  end

  def instant? : Bool
    true
  end

  def on_exit(info : BuffInfo)
    unless info.effected.player?
      info.effected.notify_event(AI::THINK)
    end
  end
  # L2AttackableAI expects this to set @attack_target to the new target
  def on_start(info : BuffInfo)
    target = info.effected
    target.notify_event(AI::CONFUSED)

    target_list = [] of L2Character

    target.known_list.each_object do |obj|
      if (target.monster? && obj.attackable?) || obj.character?
        if obj != target
          target_list << obj.as(L2Character)
        end
      end
    end

    unless target_list.empty?
      new_target = target_list.sample(random: Rnd)
      target.target = new_target
      target.set_intention(AI::ATTACK, new_target)
    end
  end
end
