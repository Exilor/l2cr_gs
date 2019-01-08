class Condition
  class PlayerCanTakeCastle < Condition
    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.as?(L2PcInstance)
      if pc.looks_dead? || pc.cursed_weapon_equipped? || !pc.clan_leader?
        return false
      end
      unless skill
        raise "No skill!"
      end

      castle = CastleManager.get_castle(pc)

      if castle.nil? || (castle.residence_id <= 0 || !castle.siege.in_progress? || castle.siege.get_attacker_clan?(pc.clan).nil?)
        sm = SystemMessage.s1_cannot_be_used
        sm.add_skill_name(skill)
        pc.send_packet(sm)
        return false
      elsif !castle.artefacts.includes?(effected)
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        return false
      elsif !Util.in_range?(skill.cast_range, pc, effected, true)
        pc.send_packet(SystemMessageId::DIST_TOO_FAR_CASTING_STOPPED)
        return false
      end

      castle.siege.announce_to_player(SystemMessageId::OPPONENT_STARTED_ENGRAVING, false)
      true
    end
  end
end
