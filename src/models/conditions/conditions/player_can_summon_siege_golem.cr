class Condition
  class PlayerCanSummonSiegeGolem < Condition
    initializer val : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      unless pc = effector.as?(L2PcInstance)
        return !@val
      end

      can = true

      if pc.looks_dead? || pc.cursed_weapon_equipped? || pc.clan.nil?
        can = false
      end

      castle = CastleManager.get_castle(pc)
      fort = FortManager.get_fort(pc)

      unless castle || fort
        can = false
      end

      if (fort && fort.residence_id == 0) || (castle && castle.residence_id == 0)
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        can = false
      elsif (castle && !castle.siege.in_progress?) || (fort && !fort.siege.in_progress?)
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        can = false
      elsif pc.clan_id != 0 && ((castle && (castle.siege.get_attacker_clan(pc.clan_id).nil?)) || (fort && (fort.siege.get_attacker_clan(pc.clan_id).nil?)))
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        can = false
      elsif SevenSigns.instance.check_summon_conditions(pc)
        can = false
      end

      @val == can
    end
  end
end
