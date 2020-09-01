class TaskBirthday < Task
  private SELECT_PENDING_BIRTHDAY_GIFTS = "SELECT charId, char_name, createDate, (YEAR(NOW()) - YEAR(createDate)) AS age FROM characters WHERE (YEAR(NOW()) - YEAR(createDate) > 0) AND ((DATE_ADD(createDate, INTERVAL (YEAR(NOW()) - YEAR(createDate)) YEAR)) BETWEEN FROM_UNIXTIME(?) AND NOW())"

  def init
    super
    TaskManager.add_unique_task(name, TaskType::GLOBAL_TASK, "1", "06:30:00", "")
  end

  def name : String
    "birthday"
  end

  def on_time_elapsed(task : ExecutedTask)
    gift_count = give_birthday_gifts(task.last_activation)
    info { "#{gift_count} gifts sent." }
  end

  private def give_birthday_gifts(last_activation : Int64) : Int32
    gift_count = 0

    begin
      time = Time.s_to_ms(last_activation)
      GameDB.each(SELECT_PENDING_BIRTHDAY_GIFTS, time) do |rs|
        name = rs.get_string(:"char_name")
        age = rs.get_i32(:"age")
        id = rs.get_i32(:"charId")

        text = Config.alt_birthday_mail_text
        text = text.gsub("$c1", name)
        text = text.gsub("$s1", age.to_s)

        msg = Message.new(id, Config.alt_birthday_mail_text, text, Message::SendBySystem::ALEGRIA)
        msg.create_attachments.not_nil!.add_item("Birthday", Config.alt_birthday_gift, 1, nil, nil)
        MailManager.send_message(msg)
        gift_count &+= 1
      end
    rescue e
      error e
    end

    gift_count
  end
end
