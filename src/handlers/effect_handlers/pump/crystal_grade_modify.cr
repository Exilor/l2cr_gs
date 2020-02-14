class EffectHandler::CrystalGradeModify < AbstractEffect
  @grade : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @grade = params.get_i32("grade", 0)
  end

  def can_start?(info : BuffInfo) : Bool
    info.effected.player?
  end

  def on_start(info)
    if pc = info.effected.acting_player
      pc.expertise_penalty_bonus = @grade
      pc.refresh_expertise_penalty
    end
  end

  def on_exit(info)
    if pc = info.effected.acting_player
      pc.expertise_penalty_bonus = 0
      pc.refresh_expertise_penalty
    end
  end
end
