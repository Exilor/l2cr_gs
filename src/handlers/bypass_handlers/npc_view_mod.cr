require "../../util/html_util"

module BypassHandler::NpcViewMod
  extend self
  extend BypassHandler

  private DROP_LIST_ITEMS_PER_PAGE = 10

  def use_bypass(command, pc, target)
    st = command.split
    st.shift

    if st.empty?
      warn "Bypass[NpcViewMod] used without enough parameters."
      return false
    end

    actual_command = st.shift
    case actual_command.downcase
    when "view"
      if !st.empty?
        begin
          target = L2World.find_object(st.shift.to_i)
        rescue e
          warn e
          return false
        end
      else
        target = pc.target
      end

      unless npc = target.as?(L2Npc)
        return false
      end

      NpcViewMod.send_npc_view(pc, npc)
    when "droplist"
      if st.size < 2
        warn "Bypass[NpcViewMod] used without enough parameters."
        return false
      end

      dls_str = st.shift
      begin
        scope = DropListScope.parse(dls_str)
        target = L2World.find_object(st.shift.to_i)
        unless npc = target.as?(L2Npc)
          return false
        end
        page = st.empty? ? 0 : st.shift.to_i
        send_npc_drop_list(pc, npc, scope, page)
      rescue e
        warn "Bypass[NpcViewMod] unknown drop list scope: #{dls_str}"
        warn e
        return false
      end
    else
      # automatically added
    end


    true
  end

  def send_npc_view(pc, npc)
    html = NpcHtmlMessage.new
    html.set_file(pc, "data/html/mods/NpcView/Info.htm")
    html["%name%"] = npc.name
    html["%hpGauge%"] = HtmlUtil.get_hp_gauge(250, npc.current_hp.to_i64, npc.max_hp.to_i64, false)
    html["%mpGauge%"] = HtmlUtil.get_mp_gauge(250, npc.current_mp.to_i64, npc.max_mp.to_i64, false)

    sp = npc.spawn?
    if sp.nil? || sp.respawn_min_delay == 0
      html["%respawn%"] = "None"
    else
      unit = "seconds"
      min_respawn_delay = sp.respawn_min_delay // 1000
      max_respawn_delay = sp.respawn_max_delay // 1000

      if sp.respawn_random?
        html["%respawn%"] = "#{min_respawn_delay} #{max_respawn_delay} #{unit}"
      else
        html["%respawn%"] = "#{min_respawn_delay} #{unit}"
      end
    end

    html["%atktype%"] = npc.attack_type.to_s.capitalize
    html["%atkrange%"] = npc.stat.physical_attack_range

    html["%patk%"] = npc.get_p_atk(pc).to_i
    html["%pdef%"] = npc.get_p_def(pc).to_i

    html["%matk%"] = npc.get_m_atk(pc, nil).to_i
    html["%mdef%"] = npc.get_m_def(pc, nil).to_i

    html["%atkspd%"] = npc.p_atk_spd
    html["%castspd%"] = npc.m_atk_spd

    html["%critrate%"] = npc.stat.get_critical_hit(pc, nil)
    html["%evasion%"] = npc.get_evasion_rate(pc)

    html["%accuracy%"] = npc.stat.accuracy
    html["%speed%"] = npc.stat.move_speed.to_i

    html["%attributeatktype%"] = Elementals.get_element_name(npc.stat.attack_element)
    html["%attributeatkvalue%"] = npc.stat.get_attack_element_value(npc.stat.attack_element)
    html["%attributefire%"] = npc.stat.get_defense_element_value(Elementals::FIRE)
    html["%attributewater%"] = npc.stat.get_defense_element_value(Elementals::WATER)
    html["%attributewind%"] = npc.stat.get_defense_element_value(Elementals::WIND)
    html["%attributeearth%"] = npc.stat.get_defense_element_value(Elementals::EARTH)
    html["%attributedark%"] = npc.stat.get_defense_element_value(Elementals::DARK)
    html["%attributeholy%"] = npc.stat.get_defense_element_value(Elementals::HOLY)

    html["%dropListButtons%"] = get_drop_list_buttons(npc)

    pc.send_packet(html)
  end

  def get_drop_list_buttons(npc) : String
    String.build do |io|
      lists = npc.template.drop_lists
      if lists && !lists.empty? && (lists.has_key?(DropListScope::DEATH) || lists.has_key?(DropListScope::CORPSE))
        io << "<table width=275 cellpadding=0 cellspacing=0><tr>"
        if lists.has_key?(DropListScope::DEATH)
          io << "<td align=center><button value=\"Show Drop\" width=100 height=25 action=\"bypass NpcViewMod dropList DEATH "
          io << npc.l2id
          io << "\" back=\"L2UI_CT1.Button_DF_Calculator_Down\" fore=\"L2UI_CT1.Button_DF_Calculator\"></td>"
        end

        if lists.has_key?(DropListScope::CORPSE)
          io << "<td align=center><button value=\"Show Spoil\" width=100 height=25 action=\"bypass NpcViewMod dropList CORPSE "
          io << npc.l2id
          io << "\" back=\"L2UI_CT1.Button_DF_Calculator_Down\" fore=\"L2UI_CT1.Button_DF_Calculator\"></td>"
        end
        io << "</tr></table>"
      end
    end
  end

  private struct DecimalFormat
    initializer pattern : String

    # TODO
    def format(n)
      n.to_s
    end
  end

  def send_npc_drop_list(pc, npc, scope, page)
    drop_list = npc.template.get_drop_list(scope)
    if drop_list.nil? || drop_list.empty?
      return
    end

    pages = drop_list.size // DROP_LIST_ITEMS_PER_PAGE
    if DROP_LIST_ITEMS_PER_PAGE * pages < drop_list.size
      pages += 1
    end

    pages_str = String.build do |io|
      if pages > 1
        io << "<table><tr>"
        pages.times do |i|
          io << "<td align=center><button value=\""
          io << i.succ
          io << "\" width=20 height=20 action=\"bypass NpcViewMod dropList "
          io << scope
          io << ' '
          io << npc.l2id
          io << ' '
          io << i
          io << "\" back=\"L2UI_CT1.Button_DF_Calculator_Down\" fore=\"L2UI_CT1.Button_DF_Calculator\"></td>"
        end
        io << "</tr></table>"
      end
    end

    if page >= pages
      page = pages - 1
    end

    # start = page > 0 ? page * DROP_LIST_ITEMS_PER_PAGE : 0

    _end = (page * DROP_LIST_ITEMS_PER_PAGE) + DROP_LIST_ITEMS_PER_PAGE
    if _end > drop_list.size
      _end = drop_list.size
    end

    amount_format = DecimalFormat.new("#,###")
    chance_format = DecimalFormat.new("0.00##")

    left_height = 0
    right_height = 0
    left_sb = String::Builder.new
    right_sb = String::Builder.new
    _end.times do |i|
      sb = String::Builder.new

      height = 64
      drop_item = drop_list[i]?
      if drop_item.is_a?(GeneralDropItem)
        add_general_drop_item(pc, npc, amount_format, chance_format, sb, drop_item)
      elsif drop_item.is_a?(GroupedGeneralDropItem)
        ggdi = drop_item
        if ggdi.items.size == 1
          gdi = ggdi.items[0]
          add_general_drop_item(pc, npc, amount_format, chance_format, sb, GeneralDropItem.new(gdi.item_id, gdi.min, gdi.max, (gdi.chance * ggdi.chance) // 100, gdi.amount_strategy, gdi.chance_strategy, ggdi.precise_strategy, ggdi.killer_chance_modifier_strategy, gdi.drop_calculation_strategy))
        else
          normalized = ggdi.normalize_me(npc, pc)
          sb << "<table width=332 cellpadding=2 cellspacing=0 background=\"L2UI_CT1.Windows.Windows_DF_TooltipBG\"><tr><td width=32 valign=top><img src=\"L2UI_CT1.ICON_DF_premiumItem\" width=32 height=32></td><td fixwidth=300 align=center><font name=\"ScreenMessageSmall\" color=\"CD9000\">One from group</font></td></tr><tr><td width=32></td><td width=300><table width=295 cellpadding=0 cellspacing=0><tr><td width=48 align=right valign=top><font color=\"LEVEL\">Chance:</font></td><td width=247 align=center>"
          sb << chance_format.format(Math.min(normalized.chance, 100))
          sb << "%</td></tr></table><br>"

          normalized.items.each do |gdi|
            item = ItemTable[gdi.item_id]
            sb << "<table width=291 cellpadding=2 cellspacing=0 background=\"L2UI_CT1.Windows.Windows_DF_TooltipBG\"><tr><td width=32 valign=top>"
            unless icon = item.icon # or if it's empty?
              icon = "icon.etc_question_mark_i00"
            end
            sb << "<img src=\""
            sb << icon
            sb << "\" width=32 height=32></td><td fixwidth=259 align=center><font name=\"hs9\" color=\"CD9000\">"
            sb << item.name
            sb << "</font></td></tr><tr><td width=32></td><td width=259><table width=253 cellpadding=0 cellspacing=0><tr><td width=48 align=right valign=top><font color=\"LEVEL\">Amount:</font></td><td width=205 align=center>"
            minmax = get_precise_min_max(normalized.chance, gdi.get_min(npc), gdi.get_max(npc), gdi.precise_calculated?)
            min = minmax.min
            max = minmax.max
            if min == max
              sb << amount_format.format(min)
            else
              sb << amount_format.format(min)
              sb << " - "
              sb << amount_format.format(max)
            end

            sb << "</td></tr><tr><td width=48 align=right valign=top><font color=\"LEVEL\">Chance:</font></td><td width=205 align=center>"
            sb << chance_format.format(Math.min(gdi.chance, 100))
            sb << "%</td></tr></table></td></tr><tr><td width=32></td><td width=259>&nbsp;</td></tr></table>"

            height += 64
          end

          sb << "</td></tr><tr><td width=32></td><td width=300>&nbsp;</td></tr></table>"
        end
      end

      if left_height >= right_height + height
        right_sb << sb.to_s
        right_height += height
      else
        left_sb << sb.to_s
        left_height += height
      end
    end

    body_sb = String::Builder.new
    body_sb << "<table><tr><td>"
    body_sb << left_sb.to_s
    body_sb << "</td><td>"
    body_sb << right_sb.to_s
    body_sb << "</td></tr></table>"

    unless html = HtmCache.get_htm(pc, "data/html/mods/NpcView/DropList.htm")
      warn "The file data/html/mods/NpcView/DropList.htm could not be found."
      return
    end
    html = html.gsub("%name%", npc.name)
    html = html.gsub("%dropListButtons%", get_drop_list_buttons(npc))
    html = html.gsub("%pages%", pages_str)
    html = html.gsub("%items%", body_sb.to_s)
    Util.send_cb_html(pc, html)
  end

  private def add_general_drop_item(pc, npc, amount_format, chance_format, sb, drop_item)
    item = ItemTable[drop_item.item_id]
    sb << "<table width=332 cellpadding=2 cellspacing=0 background=\"L2UI_CT1.Windows.Windows_DF_TooltipBG\"><tr><td width=32 valign=top><img src=\""
    if icon = item.icon
      sb << icon
    end
    sb << "\" width=32 height=32></td><td fixwidth=300 align=center><font name=\"hs9\" color=\"CD9000\">"
    sb << item.name
    sb << "</font></td></tr><tr><td width=32></td><td width=300><table width=295 cellpadding=0 cellspacing=0><tr><td width=48 align=right valign=top><font color=\"LEVEL\">Amount:</font></td><td width=247 align=center>"
    min_max = get_precise_min_max(drop_item.get_chance(npc, pc), drop_item.get_min(npc), drop_item.get_max(npc), drop_item.precise_calculated?)

    min = min_max.min
    max = min_max.max
    if min == max
      sb << amount_format.format(min)
    else
      sb << amount_format.format(min)
      sb << " - "
      sb << amount_format.format(max)
    end

    sb << "</td></tr><tr><td width=48 align=right valign=top><font color=\"LEVEL\">Chance:</font></td><td width=247 align=center>"
    sb << chance_format.format(Math.min(drop_item.get_chance(npc, pc), 100))
    sb << "%</td></tr></table></td></tr><tr><td width=32></td><td width=300>&nbsp;</td></tr></table>"
  end

  private record MinMax, min : Int64, max : Int64

  private def get_precise_min_max(chance, min, max, is_precise)
    if !is_precise || chance <= 100
      return MinMax.new(min, max)
    end

    mult = (chance // 100).to_i64
    MinMax.new(mult * min, chance % 100 > 0 ? (mult + 1) * max : mult * max)
  end

  def commands
    {"NpcViewMod"}
  end
end