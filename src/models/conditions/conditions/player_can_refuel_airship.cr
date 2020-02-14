class Condition
  class PlayerCanRefuelAirship < Condition
    initializer val : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.acting_player
      return false unless airship = pc.airship
      return false unless airship.is_a?(L2ControllableAirShipInstance)
      return false if airship.fuel + @val > airship.max_fuel
      true
    end
  end
end
