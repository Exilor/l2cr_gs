class Packets::Outgoing::TutorialShowHtml < Packets::Outgoing::AbstractHtmlPacket
  def initialize(npc_l2id : Int32, html : String)
    super
  end

  def initialize(html : String)
    super
  end

  def write_impl
    c 0xa6
    s @html
  end

  def scope
    HtmlActionScope::TUTORIAL_HTML
  end
end
