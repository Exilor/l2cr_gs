class Condition
  class PlayerCanTransform < self
    initializer val : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      can = true

      pc = effector.acting_player

      case pc
      when nil
        can = false
      when .looks_dead?, .cursed_weapon_equipped?
        can = false
      when .sitting?
        pc.send_packet(SystemMessageId::CANNOT_TRANSFORM_WHILE_SITTING)
        can = false
      when .transformed?, .in_stance?
        pc.send_packet(SystemMessageId::YOU_ALREADY_POLYMORPHED_AND_CANNOT_POLYMORPH_AGAIN)
        can = false
      when .in_water?
        pc.send_packet(SystemMessageId::YOU_CANNOT_POLYMORPH_INTO_THE_DESIRED_FORM_IN_WATER)
        can = false
      when .flying_mounted?, .mounted?
        pc.send_packet(SystemMessageId::YOU_CANNOT_POLYMORPH_WHILE_RIDING_A_PET)
        can = false
      end

      @val == can
    end
  end
end
