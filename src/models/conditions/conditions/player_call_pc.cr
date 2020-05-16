class Condition
  class PlayerCallPc < Condition
    initializer val : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      can_call_player = false
      pc = effector.acting_player

      case
      when pc.nil?
        # do nothing
      when pc.in_olympiad_mode?
        pc.send_packet(SystemMessageId::YOU_MAY_NOT_SUMMON_FROM_YOUR_CURRENT_LOCATION)
      when pc.in_observer_mode?
        # do nothing
      when !TvTEvent.on_escape_use(pc.l2id)
        pc.send_packet(SystemMessageId::YOUR_TARGET_IS_IN_AN_AREA_WHICH_BLOCKS_SUMMONING)
      when pc.inside_no_summon_friend_zone? || pc.inside_jail_zone? || pc.flying_mounted?
        pc.send_packet(SystemMessageId::YOUR_TARGET_IS_IN_AN_AREA_WHICH_BLOCKS_SUMMONING)
      else
        can_call_player = true
      end

      @val == can_call_player
    end
  end
end
