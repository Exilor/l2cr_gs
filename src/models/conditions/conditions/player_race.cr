require "../../../enums/race"

class Condition
  class PlayerRace < Condition
    initializer races: Array(Race)

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.as?(L2PcInstance)
      @races.includes?(pc.race)
    end
  end
end
