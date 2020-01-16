class Condition
  class PlayerCanSummon < Condition
    initializer val : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effected.try &.acting_player

      can_summon = true

      case
      when Config.restore_servitor_on_reconnect && SummonTable.servitors.has_key?(pc.l2id)
        pc.send_packet(SystemMessageId::SUMMON_ONLY_ONE)
        can_summon = false
      when Config.restore_pet_on_reconnect && SummonTable.pets.has_key?(pc.l2id)
        pc.send_packet(SystemMessageId::SUMMON_ONLY_ONE)
        can_summon = false
      when pc.has_summon?
        pc.send_packet(SystemMessageId::SUMMON_ONLY_ONE)
        can_summon = false
      when pc.mounted? || pc.flying_mounted?
        can_summon = false
      end

      @val == can_summon
    end
  end
end
