module BypassHandler::Buy
  extend self
  extend BypassHandler

  def use_bypass(command : String, pc : L2PcInstance, target : L2Character?) : Bool
    return false unless target.is_a?(L2MerchantInstance)

    commands = command.split

    if commands.size < 2
      warn { "Too few commands. Original command: '#{command}'." }
      return false
    end

    unless commands[1].number?
      warn { "Invalid shop_id '#{commands[1]}' (commands: '#{commands}')." }
      return false
    end

    shop_id = commands[1].to_i

    target.show_buy_window(pc, shop_id)

    true
  end

  def commands : Enumerable(String)
    {"Buy"}
  end
end
