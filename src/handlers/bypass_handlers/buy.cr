module BypassHandler::Buy
  extend self
  extend BypassHandler

  def use_bypass(command, pc, target)
    return false unless target.is_a?(L2MerchantInstance)

    commands = command.split

    if commands.size < 2
      warn { "Too few commands. Original command: '#{command}'." }
      return false
    end

    unless commands[1].num?
      warn { "Invalid shop_id '#{commands[1]}' (commands: '#{commands}')." }
      return false
    end

    shop_id = commands[1].to_i

    target.show_buy_window(pc, shop_id)

    true
  end

  def commands
    {"Buy"}
  end
end
