module Lottery
  extend self
  include Loggable

  private SECOND = 1000i64
  private MINUTE = 60000i64

  private INSERT_LOTTERY = "INSERT INTO games(id, idnr, enddate, prize, newprize) VALUES (?, ?, ?, ?, ?)"
  private UPDATE_PRICE = "UPDATE games SET prize=?, newprize=? WHERE id = 1 AND idnr = ?"
  private UPDATE_LOTTERY = "UPDATE games SET finished=1, prize=?, newprize=?, number1=?, number2=?, prize1=?, prize2=?, prize3=? WHERE id=1 AND idnr=?"
  private SELECT_LAST_LOTTERY = "SELECT idnr, prize, newprize, enddate, finished FROM games WHERE id = 1 ORDER BY idnr DESC LIMIT 1"
  private SELECT_LOTTERY_ITEM = "SELECT enchant_level, custom_type2 FROM items WHERE item_id = 4442 AND custom_type1 = ?"
  private SELECT_LOTTERY_TICKET = "SELECT number1, number2, prize1, prize2, prize3 FROM games WHERE id = 1 and idnr = ?"


  class_getter id = 0
  class_getter prize = 0i64
  class_getter end_date = 0i64
  class_getter? selling_tickets = false
  class_getter? started = false

  def load
    @@id = 1
    @@prize = Config.alt_lottery_prize
    @@selling_tickets = false
    @@started = false
    @@end_date = Time.ms

    if Config.allow_lottery
      start_lottery_task
    end
  end

  def increase_prize(count : Int64)
    @@prize += count
    GameDB.exec(UPDATE_PRICE, prize, prize, id)
  rescue e
    error e
  end

  private def start_lottery_task
    GameDB.each(SELECT_LAST_LOTTERY) do |rs|
      begin
        @@id = rs.get_i32(:"idnr")

        if rs.get_i32(:"finished") == 1
          @@id &+= 1
          @@prize = rs.get_i64(:"newprize")
        else
          @@prize = rs.get_i64(:"prize")
          @@end_date = rs.get_i64(:"enddate")

          if @@end_date <= Time.ms &+ (2 &* MINUTE)
            finish_lottery_task
            return
          end

          if @@end_date > Time.ms
            @@started = true
            ThreadPoolManager.schedule_general(->finish_lottery_task, @@end_date &- Time.ms)

            if @@end_date > Time.ms &+ (12 &* MINUTE)
              @@selling_tickets = true
              ThreadPoolManager.schedule_general(->stop_selling_tickets_task, @@end_date &- Time.ms &- (10 &* MINUTE))
            end
            return
          end
        end
      rescue e
        error e
      end
    end

    debug { "Lottery: Starting ticket sale for lottery ##{id}." }
    @@selling_tickets = true
    @@started = true

    Broadcast.to_all_online_players("Lottery tickets are now available for Lucky Lottery ##{id}.")
    finish_time = Calendar.new
    finish_time.ms = @@end_date
    finish_time.minute = 0
    finish_time.second = 0

    if finish_time.day_of_week == Calendar::SUNDAY
      finish_time.hour = 19
      @@end_date = finish_time.ms + 604_800_000
    else
      finish_time.day_of_week = Calendar::SUNDAY
      finish_time.hour = 19
      @@end_date = finish_time.ms
    end

    ThreadPoolManager.schedule_general(->stop_selling_tickets_task, @@end_date &- Time.ms &- (10 &* MINUTE))
    ThreadPoolManager.schedule_general(->finish_lottery_task, @@end_date &- Time.ms)

    begin
      GameDB.exec(INSERT_LOTTERY, 1, id, end_date, prize, prize)
    rescue e
      error e
    end
  end

  private def stop_selling_tickets_task
    debug { "Lottery: Stopping ticket sale for lottery ##{id}." }
    @@selling_tickets = false
    sm = Packets::Outgoing::SystemMessage.lottery_ticket_sales_temp_suspended
    Broadcast.to_all_online_players(sm)
  end

  private def finish_lottery_task
    debug { "Lottery: Ending lottery ##{id}." }
    nums = Slice.new(5, 0)
    lucky_num = 0

    5.times do |i|
      found = true

      while found
        lucky_num = Rnd.rand(20) &+ 1
        found = false

        i.times do |j|
          if nums[j] == lucky_num
            found = true
          end
        end
      end

      nums[i] = lucky_num
    end

    debug { "Lottery: The lucky numbers are #{nums[0]}, #{nums[1]}, #{nums[2]}, #{nums[3]}, #{nums[4]}." }

    enchant = 0
    type2 = 0

    5.times do |i|
      if nums[i] < 17
        enchant += Math.pow(2, nums[i] &- 1).to_i
      else
        type2 += Math.pow(2, nums[i] &- 17).to_i
      end
    end

    debug { "Lottery: Encoded lucky numbers are #{enchant}, #{type2}." }

    count1 = 0
    count2 = 0
    count3 = 0
    count4 = 0

    begin
      GameDB.each(SELECT_LOTTERY_ITEM, id) do |rs|
        cur_enchant = rs.get_i32(:"enchant_level") & enchant
        curtype2 = rs.get_i32(:"custom_type2") & type2

        if cur_enchant == 0 && curtype2 == 0
          next
        end

        count = 0

        1.upto(16) do
          val = cur_enchant // 2

          if val != (cur_enchant / 2).round
            count &+= 1
          end

          val2 = curtype2 // 2

          if val2 != curtype2 // 2
            count &+= 1
          end

          cur_enchant = val
          curtype2 = val2
        end

        if count == 5
          count1 &+= 1
        elsif count == 4
          count2 &+= 1
        elsif count == 3
          count3 &+= 1
        elsif count > 0
          count4 &+= 1
        end
      end
    rescue e
      error e
    end

    prize4 = count4.to_i64 * Config.alt_lottery_2_and_1_number_prize
    prize1 = 0i64
    prize2 = 0i64
    prize3 = 0i64

    if count1 > 0
      prize1 = ((prize.to_i64 &- prize4) * Config.alt_lottery_5_number_rate).to_i64 // count1
    end

    if count2 > 0
      prize2 = ((prize.to_i64 &- prize4) * Config.alt_lottery_4_number_rate).to_i64 // count2
    end

    if count3 > 0
      prize3 = ((prize.to_i64 &- prize4) * Config.alt_lottery_3_number_rate).to_i64 // count3
    end

    if Config.debug
      debug "Lottery: #{count1} players with all FIVE numbers each win #{prize1}."
      debug "Lottery: #{count2} players with FOUR numbers each win #{prize2}."
      debug "Lottery: #{count3} players with THREE numbers each win #{prize3}."
      debug "Lottery: #{count4} players with ONE or TWO numbers each win #{prize4}."
    end

    newprize = prize.to_i64 &- (prize1 &+ prize2 &+ prize3 &+ prize4)

    debug { "Lottery: Jackpot for next lottery is #{newprize}." }

    if count1 > 0
      # There are winners.
      sm = Packets::Outgoing::SystemMessage.amount_for_winner_s1_is_s2_adena_we_have_s3_prize_winner
      sm.add_int(id)
      sm.add_long(prize)
      sm.add_long(count1)
      Broadcast.to_all_online_players(sm)
    else
      # There are no winners.
      sm = Packets::Outgoing::SystemMessage.amount_for_lottery_s1_is_s2_adena_no_winner
      sm.add_int(id)
      sm.add_long(prize)
      Broadcast.to_all_online_players(sm)
    end

    begin
      GameDB.exec(
        UPDATE_LOTTERY,
        prize,
        newprize,
        enchant,
        type2,
        prize1,
        prize2,
        prize3,
        id
      )
    rescue e
      error e
    end

    ThreadPoolManager.schedule_general(->start_lottery_task, MINUTE)
    @@id &+= 1

    @@started = false
  end

  def decode_numbers(enchant : Int32, type2 : Int32) : Slice(Int32)
    res = Slice.new(5, 0)
    id = 0
    nr = 1

    while enchant > 0
      val = enchant // 2
      if val != (enchant / 2).round
        res[id] = nr
        id &+= 1
      end
      enchant //= 2
      nr &+= 1
    end

    nr = 17

    while type2 > 0
      val = type2 // 2
      if val != type2 / 2
        res[id] = nr
        id &+= 1
      end
      type2 //= 2
      nr &+= 1
    end

    res
  end

  def check_ticket(item : L2ItemInstance) : Slice(Int64)
    check_ticket(item.custom_type_1, item.enchant_level, item.custom_type_2)
  end

  def check_ticket(id : Int32, enchant : Int32, type2 : Int32) : Slice(Int64)
    res = Slice.new(2, 0i64)
    begin
      GameDB.each(SELECT_LOTTERY_TICKET, id) do |rs|
        curenchant = rs.get_i32(:"number1") & enchant
        curtype2 = rs.get_i32(:"number2") & type2

        if curenchant == 0 && curtype2 == 0
          return res
        end

        count = 0

        1.upto(16) do
          val = curenchant // 2
          if val != (curenchant / 2).round
            count &+= 1
          end
          val2 = curtype2 // 2
          if val2 != curtype2 / 2
            count &+= 1
          end
          curenchant = val
          curtype2 = val2
        end

        case count
        when 0
          # do nothing
        when 5
          res[0] = 1
          res[1] = rs.get_i64(:"prize1")
        when 4
          res[0] = 2
          res[1] = rs.get_i64(:"prize2")
        when 3
          res[0] = 3
          res[1] = rs.get_i64(:"prize3")
        else
          res[0] = 4
          res[1] = Config.alt_lottery_2_and_1_number_prize
        end
      end
    rescue e
      error { "Error while checking lottery ticket ##{id}:" }
      error e
    end

    res
  end
end
