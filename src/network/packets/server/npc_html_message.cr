require "./abstract_html_packet"

class Packets::Outgoing::NpcHtmlMessage < Packets::Outgoing::AbstractHtmlPacket
  def initialize
    @item_id = 0
  end

  def initialize(npc_l2id : Int32)
    super
    @item_id = 0
  end

  def initialize(html : String)
    super
    @item_id = 0
  end

  def initialize(npc_l2id : Int32, html : String)
    super
    @item_id = 0
  end

  def initialize(npc_l2id : Int32, item_id : Int32)
    super(npc_l2id)

    if item_id < 0
      raise ArgumentError.new("item_id can't be negative")
    end

    @item_id = item_id
  end

  def initialize(npc_l2id : Int32, item_id : Int32, html : String)
    super(npc_l2id, html)

    if item_id < 0
      raise ArgumentError.new("item_id can't be negative")
    end

    @item_id = item_id
  end

  def scope : HtmlActionScope
    @item_id == 0 ? HtmlActionScope::NPC_HTML : HtmlActionScope::NPC_ITEM_HTML
  end

  private def write_impl
    c 0x19

    d @npc_l2id
    s @html
    d @item_id
  end
end
