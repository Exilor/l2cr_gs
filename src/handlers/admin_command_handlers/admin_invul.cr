module AdminCommandHandler::AdminInvul
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command == "admin_invul"
      handle_invul(pc)
      AdminHtml.show_admin_html(pc, "gm_menu.htm")
    end
    if command == "admin_setinvul"
      target = pc.target
      if target.is_a?(L2PcInstance)
        handle_invul(target)
      end
    end

    true
  end

  private def handle_invul(pc)
    if pc.invul?
      pc.invul = false
      text = "#{pc} is now mortal"
      debug { "GM removed invul mode from player #{pc}(#{pc.l2id})" }
    else
      pc.invul = true
      text = "#{pc} is now invulnerable"
      debug { "GM activated invul mode for player #{pc}(#{pc.l2id})" }
    end
    pc.send_message(text)
  end

  def commands
    {
      "admin_invul",
      "admin_setinvul"
    }
  end
end
