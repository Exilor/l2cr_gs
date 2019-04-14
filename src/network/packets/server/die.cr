class Packets::Outgoing::Die < GameServerPacket
  @sweepable : Bool
  @access : AccessLevel?
  @clan : L2Clan?
  @jailed : Bool
  @can_teleport : Bool
  @jailed = false
  @static_res = false

  def initialize(@char : L2Character)
    if char.player?
      pc = char.acting_player
      @access = pc.access_level
      @clan = pc.clan?
      @jailed = pc.jailed?
    end

    @sweepable = char.sweep_active?
    @can_teleport = @char.can_revive? && !@char.pending_revive?
  end

  def write_impl
    c 0x00

    d @char.l2id
    d @can_teleport ? 1 : 0

    if @char.player?
      if true # !OlympiadManager.registered?(@char) && !@char.on_event?
        @static_res = @char.inventory.has_item_for_self_resurrection?
      end

      if @access.try &.allow_fixed_res?
        @static_res = true
      end
    end

    clan = @clan

    if @can_teleport && !@jailed && clan
      in_castle_defense = false
      in_fort_defense = false

      castle = CastleManager.get_castle(@char)
      fort = FortManager.get_fort(@char)
      hall = ClanHallSiegeManager.get_nearby_clan_hall(@char)
      if castle && castle.siege.in_progress?
        siege_clan = castle.siege.get_attacker_clan(clan)
        if siege_clan && castle.siege.defender?(clan)
          in_castle_defense = true
        end
      elsif fort && fort.siege.in_progress?
        siege_clan = fort.siege.get_attacker_clan(clan)
        if siege_clan && fort.siege.defender?(clan)
          in_fort_defense = true
        end
      end
      d clan.hideout_id > 0 ? 1 : 0
      d clan.castle_id > 0 || in_castle_defense ? 1 : 0
      if TerritoryWarManager.get_hq_for_clan(clan) || (siege_clan && !in_castle_defense && !in_fort_defense && !siege_clan.flag.empty?) || (hall && hall.siege.attacker?(clan))
        d 1
      else
        d 0
      end
      d @sweepable ? 1 : 0
      d @static_res ? 1 : 0
      d clan.fort_id > 0 || in_fort_defense ? 1 : 0
    else
      d 0
      d 0
      d 0
      d @sweepable ? 1 : 0
      d @static_res ? 1 : 0
      d 0
    end
  end
end
