class Condition
  class PlayerCanCreateBase < Condition
    initializer val : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      unless effector && effector.player? && (pc = effector.acting_player)
        return !@val
      end

      unless skill
        raise "No skill for PlayerCanCreateBase"
      end

      can = true

      if pc.looks_dead? || pc.cursed_weapon_equipped? || pc.clan.nil?
        can = false
      end

      clan = pc.clan.not_nil!

      castle = CastleManager.get_castle(pc)
      fort = FortManager.get_fort(pc)

      if castle && fort
        sm = SystemMessage.s1_cannot_be_used
        sm.add_skill_name(skill)
        pc.send_packet(sm)
        can = false
      elsif (castle && !castle.siege.in_progress?) || (fort && !fort.siege.in_progress?)
        sm = SystemMessage.s1_cannot_be_used
        sm.add_skill_name(skill)
        pc.send_packet(sm)
        can = false
      elsif (castle && castle.siege.get_attacker_clan(clan).nil?) || (fort && fort.siege.get_attacker_clan(clan).nil?)
        sm = SystemMessage.s1_cannot_be_used
        sm.add_skill_name(skill)
        pc.send_packet(sm)
        can = false
      elsif !pc.clan_leader?
        sm = SystemMessage.s1_cannot_be_used
        sm.add_skill_name(skill)
        pc.send_packet(sm)
        can = false
      elsif (castle && castle.siege.get_attacker_clan(clan).not_nil!.num_flags >= SiegeManager.flag_max_count) || (fort && fort.siege.get_attacker_clan(clan).not_nil!.num_flags >= FortSiegeManager.flag_max_count)
        sm = SystemMessage.s1_cannot_be_used
        sm.add_skill_name(skill)
        pc.send_packet(sm)
        can = false
      elsif !pc.inside_hq_zone?
        pc.send_packet(SystemMessageId::NOT_SET_UP_BASE_HERE)
        can = false
      end

      @val == can
    end
  end
end
