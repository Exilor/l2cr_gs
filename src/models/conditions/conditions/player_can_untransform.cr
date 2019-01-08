class Condition
  class PlayerCanUntransform < Condition
    initializer val: Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      can = true
      can = false unless pc = effector.acting_player?

      if pc
        if pc.looks_dead? || pc.cursed_weapon_equipped?
          can = false
        elsif (pc.transformed? || pc.in_stance?) && pc.flying_mounted? && !pc.inside_landing_zone?
          pc.send_packet(SystemMessageId::TOO_HIGH_TO_PERFORM_THIS_ACTION)
          can = false
        end
      end

      @val == can
    end
  end
end
