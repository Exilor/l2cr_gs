abstract class AbstractFunction
  private alias Owner = L2Object | AbstractEffect | Skill | Options |
    Elementals::ElementalStatBoni

  getter_initializer stat : Stats, order : Int32 = 1, owner : Owner? = nil,
    value : Float64 = 0.0, apply_cond : Condition? = nil

  abstract def calc(effector : L2Character, effected : L2Character?, skill : Skill?, val : Float64) : Float64

  private def test(effector : L2Character, effected : L2Character?, skill : Skill?) : Bool
    return true unless cond = @apply_cond
    cond.test(effector, effected, skill)
  end

  def public_initialize(*args)
    initialize(*args)
  end
end

require "./formulas/*"
