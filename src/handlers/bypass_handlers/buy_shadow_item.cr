module BypassHandler::BuyShadowItem
  extend self
  extend BypassHandler

  def use_bypass(command, pc, target)
    return false unless target.is_a?(L2MerchantInstance)

    html = NpcHtmlMessage.new(target.l2id)

    case pc.level
    when 0..39
      html.set_file(pc, "data/html/common/shadow_item-lowlevel.htm")
    when 40..45
      html.set_file(pc, "data/html/common/shadow_item_d.htm")
    when 46..51
      html.set_file(pc, "data/html/common/shadow_item_c.htm")
    else
      html.set_file(pc, "data/html/common/shadow_item_b.htm")
    end

    html["%objectId%"] = target.l2id
    pc.send_packet(html)

    true
  end

  def commands
    {"BuyShadowItem"}
  end
end
