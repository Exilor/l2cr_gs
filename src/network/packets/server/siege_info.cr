class Packets::Outgoing::SiegeInfo < GameServerPacket
  @castle : Castle?
  @hall : ClanHall?

  initializer castle : Castle
  initializer hall : ClanHall

  def write_impl
    unless pc = client.active_char
      return
    end

    c 0xc9
    if castle = @castle
      d castle.residence_id
      owner_id = castle.owner_id
      d (owner_id == pc.clan_id && pc.clan_leader?) ? 1 : 0
      d owner_id
      if owner_id > 0
        if owner = ClanTable.get_clan(owner_id)
          s owner.name
          s owner.leader_name
          d owner.ally_id
          s owner.ally_name
        else
          warn "Nil owner for castle #{castle.name}."
        end
      else
        s ""
        s ""
        d 0
        s ""
      end

      d Time.ms / 1000

      if !castle.time_registration_over? && pc.clan_leader? && pc.clan_id == castle.owner_id
        cal = Calendar.new
        cal.ms = castle.siege_date.ms
        cal.minute = 0
        cal.second = 0
        d 0
        d Config.siege_hour_list.size
        Config.siege_hour_list.each do |hour|
          cal.hour = hour
          d cal.ms / 1000
        end
      else
        d castle.siege_date.ms / 1000
        d 0
      end
    elsif hall = @hall
      d hall.id
      owner_id = hall.owner_id
      d (owner_id == pc.clan_id && pc.clan_leader?) ? 1 : 0
      d owner_id
      if owner_id > 0
        if owner = ClanTable.get_clan(owner_id)
          s owner.name
          s owner.leader_name
          d owner.ally_id
          s owner.ally_name
        else
          warn "Nil owner for siegable hall #{hall.name}."
        end
      else
        s ""
        s ""
        d 0
        s ""
      end

      d Time.ms / 1000
      d ClanHallSiegeManager.get_siegable_hall!(hall.id).next_siege_time / 1000
      d 0
    else
      error "No castle and no hall."
    end
  end
end
