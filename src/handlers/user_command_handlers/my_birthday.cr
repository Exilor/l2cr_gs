module UserCommandHandler::MyBirthday
  extend self
  extend UserCommandHandler

  def use_user_command(id, pc)
    unless id == commands[0]
      return false
    end

    date = pc.create_date

    sm = Packets::Outgoing::SystemMessage.c1_birthday_is_s3_s4_s2
    sm.add_pc_name(pc)
    sm.add_string(date.year.to_s)
    sm.add_string((date.month + 1).to_s)
    sm.add_string(date.day.to_s)

    pc.send_packet(sm)

    true
  end

  def commands
    {126}
  end
end
