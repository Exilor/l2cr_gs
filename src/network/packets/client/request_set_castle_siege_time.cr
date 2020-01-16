class Packets::Incoming::RequestSetCastleSiegeTime < GameClientPacket
  @castle_id = 0
  @time = 0i64

  private def read_impl
    @castle_id = d
    @time = 1000i64 * d
  end

  private def run_impl
    return unless pc = active_char
    castle = CastleManager.get_castle_by_id(@castle_id)
    if castle.nil?
      # do nothing
    elsif castle.owner_id > 0 && castle.owner_id != pc.clan_id
      # do nothing
    elsif !pc.clan_leader?
      # do nothing
    elsif !castle.time_registration_over?
      if siege_time_valid?(castle.siege_date.ms, @time)
        castle.siege_date.ms = @time
        castle.time_registration_over = true
        castle.siege.save_siege_date
        sm = SystemMessage.s1_announced_siege_time
        sm.add_castle_id(@castle_id)
        Broadcast.to_all_online_players(sm)
        pc.send_packet(SiegeInfo.new(castle))
      else
        warn { "#{pc.name} tried to set an invalid castle siege time (#{Time.from_ms(@time)})." }
      end
    else
      warn { "Error while #{pc.name} tried to change the date for castle #{castle.name}." }
    end
  end

  private def siege_time_valid?(siege_date, chosen_date)
    cal1 = Calendar.new
    cal1.ms = siege_date
    cal1.minute = 0
    cal1.second = 0

    cal2 = Calendar.new
    cal2.ms = chosen_date

    Config.siege_hour_list.each do |hour|
      cal1.hour = hour
      if calendar_equal?(cal1, cal2)
        return true
      end
    end

    false
  end

  private def calendar_equal?(cal1, cal2)
    return false unless cal1.year == cal2.year
    return false unless cal1.month == cal2.month
    return false unless cal1.day == cal2.day
    return false unless cal1.hour == cal2.hour
    return false unless cal1.minute == cal2.minute
    return false unless cal1.second == cal2.second
    true
  end
end
