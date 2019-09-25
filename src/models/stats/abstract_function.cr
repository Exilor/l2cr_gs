abstract class AbstractFunction
  alias OwnerType = L2Object | AbstractEffect | Skill |
    Elementals::ElementalStatBoni | Options

  getter stat, order, owner, value, apply_cond

  def initialize(@stat : Stats, @order : Int32 = 1, @owner : OwnerType? = nil, @value : Float64 = 0.0, @apply_cond : Condition? = nil)
  end

  abstract def calc(effector : L2Character, effected : L2Character, skill : Skill?, val : Float64)

  # Convenience method for subclasses.
  private def test(effector : L2Character, effected : L2Character?, skill : Skill?) : Bool
    return true unless cond = @apply_cond
    cond.test(effector, effected, skill)
  end

  def public_initialize(*args)
    initialize(*args)
  end
end

require "./formulas/*"
