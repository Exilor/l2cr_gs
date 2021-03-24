module UserCommandHandler::Time
  extend self
  extend UserCommandHandler

  def use_user_command(id : Int32, pc : L2PcInstance) : Bool
    return false unless id == commands[0]

    t = GameTimer.time

    h = ((t // 60) % 24).to_s
    if (t % 60) < 10
      m = "0#{t % 60}"
    else
      m = (t % 60).to_s
    end

    if GameTimer.night?
      sm = Packets::Outgoing::SystemMessage.time_s1_s2_in_the_night
    else
      sm = Packets::Outgoing::SystemMessage.time_s1_s2_in_the_day
    end

    sm.add_string(h)
    sm.add_string(m)

    pc.send_packet(sm)

    if Config.display_server_time
      pc.send_message("Server time is #{::Time.now}")
    end

    true
  end

  def commands : Enumerable(Int32)
    {77}
  end
end
