class Packets::Outgoing::NpcQuestHtmlMessage < Packets::Outgoing::AbstractHtmlPacket
  def initialize(l2id : Int32, @quest_id : Int32)
    super(l2id)
  end

  private def write_impl
    c 0xfe
    h 0x8d

    d @npc_l2id
    s @html
    d @quest_id
  end

  def scope : HtmlActionScope
    HtmlActionScope::NPC_QUEST_HTML
  end
end
