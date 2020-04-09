module BypassHandler::Loto
  extend self
  extend BypassHandler

  private TICKET = 4442

  def use_bypass(command, pc, target)
    unless target.is_a?(L2Npc)
      return false
    end

    val = 0

    begin
      val = command.from(5).to_i
    rescue e
      error e
    end

    if val == 0
      5.times do |i|
        pc.set_loto(i, 0)
      end
    end

    show_loto_window(pc, target, val)

    false
  end

  private def show_loto_window(pc, npc, val)
    npc_id = npc.id
    html = NpcHtmlMessage.new(npc.l2id)

    if val == 0 # first buy lottery ticket window
      filename = npc.get_html_path(npc_id, 1)
      html.set_file(pc, filename)
    elsif val.between?(1, 21) # 1-20 - buttons, 21 - second buy lottery ticket window
      unless Lottery.started?
        pc.send_packet(SystemMessageId::NO_LOTTERY_TICKETS_CURRENT_SOLD)
        return
      end

      unless Lottery.selling_tickets?
        pc.send_packet(SystemMessageId::NO_LOTTERY_TICKETS_AVAILABLE)
        return
      end

      filename = npc.get_html_path(npc_id, 5)
      html.set_file(pc, filename)

      count = 0
      found = 0
      5.times do |i|
        if pc.get_loto(i) == val
          pc.set_loto(i, 0)
          found = 1
        elsif pc.get_loto(i) > 0
          count += 1
        end
      end

      if count < 5 && found == 0 && val <= 20
        5.times do |i|
          if pc.get_loto(i) == 0
            pc.set_loto(i, val)
            break
          end
        end
      end

      count = 0
      5.times do |i|
        if pc.get_loto(i) > 0
          count += 1
          if pc.get_loto(i) < 10
            button = "0#{pc.get_loto(i)}"
          else
            button = pc.get_loto(i).to_s
          end
          search = "fore=\"L2UI.lottoNum#{button}\" back=\"L2UI.lottoNum#{button}a_check\""
          replacement = "fore=\"L2UI.lottoNum#{button}a_check\" back=\"L2UI.lottoNum#{button}\""
          html[search] = replacement
        end
      end

      if count == 5
        search = "0\">Return"
        replacement = "22\">Your lucky numbers have been selected above."
        html[search] = replacement
      end
    elsif val == 22 # selected ticket with 5 numbers
      unless Lottery.started?
        pc.send_packet(SystemMessageId::NO_LOTTERY_TICKETS_CURRENT_SOLD)
        return
      end

      unless Lottery.selling_tickets?
        pc.send_packet(SystemMessageId::NO_LOTTERY_TICKETS_AVAILABLE)
        return
      end

      price = Config.alt_lottery_ticket_price
      loto_number = Lottery.id
      enchant = 0
      type2 = 0

      5.times do |i|
        if pc.get_loto(i) == 0
          return
        end

        if pc.get_loto(i) < 17
          enchant += Math.pow(2, pc.get_loto(i) - 1).to_i
        else
          type2 += Math.pow(2, pc.get_loto(i) - 17).to_i
        end
      end

      if pc.adena < price
        sm = SystemMessage.you_not_enough_adena
        pc.send_packet(sm)
        return
      end

      unless pc.reduce_adena("Loto", price, npc, true)
        return
      end

      Lottery.increase_prize(price)

      sm = SystemMessage.earned_item_s1
      sm.add_item_name(TICKET)
      pc.send_packet(sm)

      item = L2ItemInstance.new(IdFactory.next, TICKET)
      item.count = 1
      item.custom_type_1 = loto_number
      item.enchant_level = enchant
      item.custom_type_2 = type2
      pc.inventory.add_item("Loto", item, pc, npc)

      iu = InventoryUpdate.new
      iu.add_item(item)
      adena = pc.inventory.adena_instance.not_nil!
      iu.add_modified_item(adena)
      pc.send_packet(iu)

      filename = npc.get_html_path(npc_id, 6)
      html.set_file(pc, filename)
    elsif val == 23 # current lottery jackpot
      filename = npc.get_html_path(npc_id, 3)
      html.set_file(pc, filename)
    elsif val == 24 # previous winning numbers/prize claim
      filename = npc.get_html_path(npc_id, 4)
      html.set_file(pc, filename)

      loto_number = Lottery.id
      message = ""
      pc.inventory.items.each do |item|
        if item.id == TICKET && item.custom_type_1 < loto_number
          message += "<a action=\"bypass -h npc_%objectId%_Loto #{item.l2id}\">#{item.custom_type_1} Event Number "
          numbers = Lottery.decode_numbers(item.enchant_level, item.custom_type_2)
          5.times do |i|
            message += "#{numbers[i]} "
          end
          check = Lottery.check_ticket(item)
          if check[0] > 0
            case check[0]
            when 1
              message += "- 1st Prize"
            when 2
              message += "- 2nd Prize"
            when 3
              message += "- 3rd Prize"
            when 4
              message += "- 4th Prize"
            else
              # [automatically added else]
            end


            message += " #{check[1]}a."
          end
          message += "</a><br>"
        end
      end

      if message.empty?
        message = "There has been no winning lottery ticket.<br>"
      end

      html["%result%"] = message
    elsif val == 25 # lottery instructions
      filename = npc.get_html_path(npc_id, 2)
      html.set_file(pc, filename)
    elsif val > 25 # check lottery ticket by item object id
      return unless item = pc.inventory.get_item_by_l2id(val)
      if item.id != TICKET || item.custom_type_1 >= Lottery.id
        return
      end

      check = Lottery.check_ticket(item)

      sm = SystemMessage.s1_disappeared
      sm.add_item_name(TICKET)
      pc.send_packet(sm)

      adena = check[1].to_i64
      if adena > 0
        pc.add_adena("Loto", adena, npc, true)
      end

      pc.destroy_item("Loto", item, npc, false)
      return
    end

    html["%objectId%"] = npc.l2id
    html["%race%"] = Lottery.id
    html["%adena%"] = Lottery.prize
    html["%ticket_price%"] = Config.alt_lottery_ticket_price
    html["%prize5%"] = Config.alt_lottery_5_number_rate * 100
    html["%prize4%"] = Config.alt_lottery_4_number_rate * 100
    html["%prize3%"] = Config.alt_lottery_3_number_rate * 100
    html["%prize2%"] = Config.alt_lottery_2_and_1_number_prize
    html["%enddate%"] = Lottery.end_date
    pc.send_packet(html)

    pc.action_failed
  end

  def commands
    {"Loto"}
  end
end
