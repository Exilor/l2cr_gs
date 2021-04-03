require "../../../enums/race"

class Condition
  class PlayerRace < self
    def initialize(races : Enumerable(Race))
      @races = EnumSet(Race).new
      races.each { |race| @races << race }
    end

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.as?(L2PcInstance)
      @races.includes?(pc.race)
    end
  end
end
