class Condition
  class PlayerCanCreateOutpost < self
    initializer val : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      unless pc = effector.as?(L2PcInstance)
        return !@val
      end

      can = true

      if pc.looks_dead? || pc.cursed_weapon_equipped? || pc.clan.nil?
        can = false
      end

      clan = pc.clan.not_nil!

      castle = CastleManager.get_castle(pc)
      fort = FortManager.get_fort(pc)

      unless castle && fort
        can = false
      end

      if (fort && fort.residence_id == 0) || (castle && castle.residence_id == 0)
        pc.send_message("You must be on fort or castle ground to construct an outpost or flag.")
        can = false
      elsif (fort && fort.zone.active?) || (castle && castle.zone.active?)
        pc.send_message("You can only construct an outpost or flag on siege field.")
        can = false
      elsif !pc.clan_leader?
        pc.send_message("You must be a clan leader to construct an outpost or flag.")
        can = false
      elsif TerritoryWarManager.get_hq_for_clan(clan)
        pc.send_packet(SystemMessageId::NOT_ANOTHER_HEADQUARTERS)
        can = false
      elsif TerritoryWarManager.get_flag_for_clan(clan)
        pc.send_packet(SystemMessageId::A_FLAG_IS_ALREADY_BEING_DISPLAYED_ANOTHER_FLAG_CANNOT_BE_DISPLAYED)
        can = false
      elsif !pc.inside_hq_zone?
        pc.send_packet(SystemMessageId::NOT_SET_UP_BASE_HERE)
        can = false
      end

      @val == can
    end
  end
end
