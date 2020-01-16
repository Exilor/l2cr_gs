class Packets::Outgoing::SiegeDefenderList < GameServerPacket
  initializer castle : Castle

  private def write_impl
    c 0xcb

    d @castle.residence_id
    d 0
    d 1
    d 0

    size = @castle.siege.defender_clans.size + @castle.siege.defender_waiting_clans.size

    if size <= 0
      q 0
      return
    end

    d size
    d size

    @castle.siege.defender_clans.each do |sc|
      unless clan = ClanTable.get_clan(sc.clan_id)
        next
      end

      d clan.id
      s clan.name
      s clan.leader_name
      d clan.crest_id
      d 0 # signed time (seconds) (not stored by L2J)
      case sc.type
      when .owner?
        d 1
      when .defender_pending?
        d 2
      when .defender?
        d 3
      else
        d 0
      end
      d clan.ally_id
      s clan.ally_name
      s "" # ally leader name
      d clan.ally_crest_id
    end

    @castle.siege.defender_waiting_clans.each do |sc|
      clan = ClanTable.get_clan(sc.clan_id).not_nil!
      d clan.id
      s clan.name
      s clan.leader_name
      d clan.crest_id
      d 0
      d 2
      d clan.ally_id
      s clan.ally_name
      s ""
      d clan.ally_crest_id
    end
  end
end
