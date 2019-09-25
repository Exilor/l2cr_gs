abstract class Packets::Outgoing::AbstractHtmlPacket < GameServerPacket
  VAR_PARAM_START_CHAR = '$'

  @disable_validation = false
  getter html : String?
  getter npc_l2id = 0

  def initialize(npc_l2id : Int32)
    if npc_l2id < 0
      raise ArgumentError.new("l2id can't be negative")
    end

    @npc_l2id = npc_l2id
  end

  def initialize(html : String)
    @npc_l2id = 0
    self.html = html
  end

  def initialize(npc_l2id : Int32, html : String)
    if npc_l2id < 0
      raise ArgumentError.new("l2id can't be negative")
    end

    @npc_l2id = npc_l2id
    self.html = html
  end

  def html=(html : String)
    if html.size > 17_200
      html = html[0, 17_200]
    end

    unless html.includes?("<html")
      warn "Html is too long. It would crash the client."
      html = "<html><body>#{html}</body></html>"
    end

    @html = html
  end

  def set_file(pc, path : String)
    unless content = HtmCache.get_htm(pc, path)
      self.html = "<html><body>My Text is missing:<br>#{path}</body></html>"
      return false
    end

    self.html = content
    true
  end

  def disable_validation
    @disable_validation = false
  end

  def []=(pattern : String, val)
    if html = @html
      unless html.includes?(pattern)
        warn "#{pattern.inspect} not found in this html:"
        warn html
      end
      @html = html.gsub(pattern, val.to_s)
    end
  end

  def run_impl
    if pc = active_char
      pc.clear_html_actions(scope)
      return if @disable_validation
      Util.build_html_action_cache(pc, scope, @npc_l2id, @html)
    end
  end

  abstract def scope : HtmlActionScope
end
