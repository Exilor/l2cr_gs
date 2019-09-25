module CommunityBoardHandler
  extend self
  extend Loggable

  private HANDLERS = {} of String => IParseBoardHandler
  private BYPASSES = Hash(Int32, String).new

  def load
    {% for const in @type.constants %}
      const = {{const.id}}
      if const.is_a?(IParseBoardHandler)
        register(const)
      end
    {% end %}
  end

  def [](cmd : String) : IParseBoardHandler?
    HANDLERS.each_value do |cb|
      cb.commands.each do |command|
        if cmd.downcase.starts_with?(command.downcase)
          return cb
        end
      end
    end

    nil
  end

  def register(handler : IParseBoardHandler)
    handler.commands.each do |cmd|
      HANDLERS[cmd.downcase] = handler
    end
  end

  def community_board_command?(cmd : String)
    !!self[cmd]
  end

  def handle_parse_command(command : String, pc : L2PcInstance)
    return unless pc

    unless Config.enable_community_board
      pc.send_packet(SystemMessageId::CB_OFFLINE)
      return
    end

    unless cb = self[command]
      warn { "No handler found for command #{command.inspect}" }
      return
    end

    cb.parse_command(command, pc)
  end

  def handle_write_command(pc : L2PcInstance, url : String, arg1 : String, arg2 : String, arg3 : String, arg4 : String, arg5 : String)
    unless Config.enable_community_board
      pc.send_packet(SystemMessageId::CB_OFFLINE)
      return
    end

    case url
    when "Topic"
      cmd = "_bbstop"
    when "Post"
      cmd = "_bbspos"
    when "Region"
      cmd = "_bbsloc"
    when "Notice"
      cmd = "_bbsclan"
    else
      separate_and_send("<html><body><br><br><center>The command: #{url} is not implemented yet.</center><br><br></body></html>", pc)
      return
    end

    unless cb = self[cmd]
      debug "No handler found for command #{cmd.inspect}"
      return
    end

    unless cb.responds_to?(:write_community_board_command)
      warn { "#{cb} doesn't implement #write_community_board_command" }
      return
    end

    cb.write_community_board_command(pc, arg1, arg2, arg3, arg4, arg5)
  end

  def add_bypass(pc : L2PcInstance, title : String, bypass : String)
    BYPASSES[pc.l2id] = "#{title}&#{bypass}"
  end

  def remove_bypass(pc)
    BYPASSES.delete(pc.l2id)
  end

  def separate_and_send(html : String, pc : L2PcInstance)
    Util.send_cb_html(pc, html)
  end

  module IParseBoardHandler
    include Loggable

    # abstract def parse_command(cmd : String, pc : L2PcInstance) : Bool
    # abstract def commands : Enumerable(String)
  end
end

require "./community_board_handlers/*"
