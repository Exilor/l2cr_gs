module EffectHandler
  class Passive < AbstractEffect
    def can_start?(info : BuffInfo) : Bool
      info.effected.attackable?
    end

    def on_start(info)
      target = info.effected
      if target.is_a?(L2Attackable)
        target.abort_attack
        target.abort_cast
        target.disable_all_skills
        target.immobilized = true
      end
    end

    def on_exit(info)
      info.effected.enable_all_skills
      info.effected.immobilized = false
    end
  end
end
