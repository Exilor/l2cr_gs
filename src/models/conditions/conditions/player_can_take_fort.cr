class Condition
  class PlayerCanTakeFort < self
    initializer val : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      unless pc = effector.as?(L2PcInstance)
        return !@val
      end

      can = true

      if pc.looks_dead? || pc.cursed_weapon_equipped? || !pc.clan_leader?
        can = false
      end

      fort = FortManager.get_fort(pc)
      if fort.nil? || (fort.residence_id <= 0 || !fort.siege.in_progress? || fort.siege.get_attacker_clan(pc.clan).nil?)
        sm = SystemMessage.s1_cannot_be_used
        sm.add_skill_name(skill.not_nil!)
        pc.send_packet(sm)
        can = false
      elsif fort.flag_pole != effected
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      elsif !Util.in_range?(200, pc, effected, true)
        pc.send_packet(SystemMessageId::DIST_TOO_FAR_CASTING_STOPPED)
        can = false
      end

      @val == can
    end
  end
end
