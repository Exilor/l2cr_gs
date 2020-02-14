require "../../../enums/race"

class Condition
  class PlayerRace < Condition
    @races : Slice(Race)

    def initialize(races)
      @races = races.sort.to_slice
    end

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.as?(L2PcInstance)
      @races.bincludes?(pc.race)
    end
  end
end
