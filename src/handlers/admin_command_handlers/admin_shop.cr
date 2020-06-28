module AdminCommandHandler::AdminShop
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    case command
    when /\Aadmin_buy.*/
      begin
        handle_buy_request(pc, command.from(10))
      rescue
        pc.send_message("Please specify buy list.")
      end
    when "admin_gmshop"
      AdminHtml.show_admin_html(pc, "gmshops.htm")
    end


    true
  end

  private def handle_buy_request(pc, command)
    val = command.number? ? command.to_i : -1

    if buy_list = BuyListData.get_buy_list(val)
      pc.send_packet(BuyList.new(buy_list, pc.adena, 0))
      pc.send_packet(ExBuySellList.new(pc, false))
    else
      warn { "No buy list with id #{val}." }
    end
  end

  def commands
    %w(admin_buy admin_gmshop)
  end
end
