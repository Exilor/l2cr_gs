class Packets::Outgoing::SiegeAttackerList < GameServerPacket
  @castle : Castle?
  @hall : SiegableHall?

  initializer castle : Castle
  initializer hall : SiegableHall

  private def write_impl
    c 0xca

    if castle = @castle
      d castle.residence_id
      d 0
      d 1
      d 0

      size = castle.siege.attacker_clans.size
      if size > 0
        d size
        d size
        castle.siege.attacker_clans.each do |siege_clan|
          unless clan = ClanTable.get_clan(siege_clan.clan_id)
            next
          end

          d clan.id
          s clan.name
          s clan.leader_name
          d clan.crest_id
          d 0 # signed time (seconds) (not stored by L2J)
          d clan.ally_id
          s clan.ally_name
          s "" # ally leader name
          d clan.ally_crest_id
        end
      else
        q 0
      end
    elsif hall = @hall
      d hall.id
      d 0
      d 1
      d 0

      attackers = hall.siege.attacker_clans
      size = attackers.size
      if size > 0
        d size
        d size
        attackers.each do |siege_clan|
          unless clan = ClanTable.get_clan(siege_clan.clan_id)
            next
          end

          d clan.id
          s clan.name
          s clan.leader_name
          d clan.crest_id
          d 0 # signed time (seconds) (not stored by L2J)
          d clan.ally_id
          s clan.ally_name
          s "" # ally leader name
          d clan.ally_crest_id
        end
      else
        q 0
      end
    else
      raise "Nil @castle and @hall"
    end
  end
end
