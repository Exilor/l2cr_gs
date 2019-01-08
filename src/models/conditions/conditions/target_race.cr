require "../../../enums/race"

class Condition
  class TargetRace < Condition
    initializer race: Race

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      !!effected && effected.race == @race
    end
  end
end
