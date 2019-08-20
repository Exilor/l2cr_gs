module ActionShiftHandler::L2NpcActionShift
  extend self
  extend ActionShiftHandler

  def action(pc, target, interact) : Bool
    if pc.gm?
      target = target.as(L2Npc)
      pc.target = target

      html = NpcHtmlMessage.new
      html.set_file(pc, "data/html/admin/npcinfo.htm")

      html["%objid%"] = target.l2id
			html["%class%"] = target.class.simple_name
			html["%race%"] = target.template.race.to_s
			html["%id%"] = target.template.id
			html["%lvl%"] = target.template.level
			html["%name%"] = target.template.name
			html["%tmplid%"] = target.template.id
			html["%aggro%"] = target.as?(L2Attackable).try &.aggro_range || 0
			html["%hp%"] = target.current_hp.to_i
			html["%hpmax%"] = target.max_hp
			html["%mp%"] = target.current_mp.to_i
			html["%mpmax%"] = target.max_mp

			html["%patk%"] = target.get_p_atk(nil).to_i
			html["%matk%"] = target.get_m_atk(nil, nil).to_i
			html["%pdef%"] = target.get_p_def(nil).to_i
			html["%mdef%"] = target.get_m_def(nil, nil).to_i
			html["%accu%"] = target.accuracy
			html["%evas%"] = target.get_evasion_rate(nil)
			html["%crit%"] = target.get_critical_hit(nil, nil)
			html["%rspd%"] = target.run_speed.to_i
			html["%aspd%"] = target.p_atk_spd
			html["%cspd%"] = target.m_atk_spd
			html["%atkType%"] = target.template.base_attack_type
			html["%atkRng%"] = target.template.base_attack_range
			html["%str%"] = target.str
			html["%dex%"] = target.dex
			html["%con%"] = target.con
			html["%int%"] = target.int
			html["%wit%"] = target.int
			html["%men%"] = target.men
			html["%loc%"] = "#{target.x} #{target.y} #{target.z}"
			html["%heading%"] = target.heading
			html["%collision_radius%"] = target.template.f_collision_radius
			html["%collision_height%"] = target.template.f_collision_height
			html["%dist%"] = pc.calculate_distance(target, true, false).to_i

      aattr = target.attack_element
      html["%ele_atk%"] = Elementals.get_element_name(aattr)
			html["%ele_atk_value%"] = target.get_attack_element_value(aattr)
			html["%ele_dfire%"] = target.get_defense_element_value(Elementals::FIRE)
			html["%ele_dwater%"] = target.get_defense_element_value(Elementals::WATER)
			html["%ele_dwind%"] = target.get_defense_element_value(Elementals::WIND)
			html["%ele_dearth%"] = target.get_defense_element_value(Elementals::EARTH)
			html["%ele_dholy%"] = target.get_defense_element_value(Elementals::HOLY)
			html["%ele_ddark%"] = target.get_defense_element_value(Elementals::DARK)

      if sp = target.spawn?
        html["%territory%"] = sp.spawn_territory.try &.name || "None"
        if sp.territory_based?
          html["%spawntype%"] = "Random"
          loc = sp.get_location(target)
          html["%spawn%"] = "#{loc.x} #{loc.y} #{loc.z}"
        else
          html["%spawntype%"] = "Fixed"
          html["%spawn%"] = "#{sp.x} #{sp.y} #{sp.z}"
        end

        html["%loc2d%"] = target.calculate_distance(sp.get_location(target), false, false).to_i
        html["%loc3d%"] = target.calculate_distance(sp.get_location(target), true, false).to_i
        if sp.respawn_min_delay == 0
          html["%resp%"] = "None"
        elsif sp.respawn_random?
          html["%resp%"] = "#{sp.respawn_min_delay // 1000}-#{sp.respawn_max_delay // 1000} sec"
        else
          html["%resp%"] = "#{sp.respawn_min_delay // 1000} sec"
        end
      else
        html["%territory%"] = "<font color=FF0000>--</font>"
				html["%spawntype%"] = "<font color=FF0000>--</font>"
				html["%spawn%"] = "<font color=FF0000>null</font>"
				html["%loc2d%"] = "<font color=FF0000>--</font>"
				html["%loc3d%"] = "<font color=FF0000>--</font>"
				html["%resp%"] = "<font color=FF0000>--</font>"
      end

      if target.ai?
        clans = target.template.clans
        ignore_clan_npc_ids = target.template.ignore_clan_npc_ids
        clans_string = clans.try &.join(", ") || ""
        ignore_clan_npc_ids_string = ignore_clan_npc_ids.try &.join(", ") || ""
        html["%ai_intention%"] = "<tr><td><table width=270 border=0 bgcolor=131210><tr><td width=100><font color=FFAA00>Intention:</font></td><td align=right width=170>#{target.intention}</td></tr></table></td></tr>"
				html["%ai%"] = "<tr><td><table width=270 border=0><tr><td width=100><font color=FFAA00>AI</font></td><td align=right width=170>#{target.ai.class}</td></tr></table></td></tr>"
				html["%ai_type%"] = "<tr><td><table width=270 border=0 bgcolor=131210><tr><td width=100><font color=FFAA00>AIType</font></td><td align=right width=170>#{target.ai_type}</td></tr></table></td></tr>"
				html["%ai_clan%"] = "<tr><td><table width=270 border=0><tr><td width=100><font color=FFAA00>Clan & Range:</font></td><td align=right width=170>#{clans_string} #{target.template.clan_help_range}</td></tr></table></td></tr>"
				html["%ai_enemy_clan%"] = "<tr><td><table width=270 border=0 bgcolor=131210><tr><td width=100><font color=FFAA00>Ignore & Range:</font></td><td align=right width=170>#{ignore_clan_npc_ids_string} #{target.template.aggro_range}</td></tr></table></td></tr>"
      else
        html["%ai_intention%"] = ""
				html["%ai%"] = ""
				html["%ai_type%"] = ""
				html["%ai_clan%"] = ""
				html["%ai_enemy_clan%"] = ""
      end

      pc.send_packet(html)
    elsif Config.alt_game_viewnpc
      return false unless target.npc?
      pc.target = target
      handler_class = BypassHandler["NpcViewMod"].class
      if handler_class.responds_to?(:send_npc_view)
        handler_class.send_npc_view(pc, target)
      else
        warn "No handler found for NpcViewMod."
      end
    end

    true
  end

  def instance_type : InstanceType
    InstanceType::L2Npc
  end
end
