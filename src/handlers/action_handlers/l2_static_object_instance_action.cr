module ActionHandler::L2StaticObjectInstanceAction
  extend self
  extend ActionHandler

  def action(pc, target, interact) : Bool
    obj = target.as(L2StaticObjectInstance)

    if obj.type < 0
      warn "StaticObject with invalid type #{obj.type}."
    end

    if pc.target != obj
      pc.target = obj
    elsif interact
      if !pc.inside_radius?(obj, L2Npc::INTERACTION_DISTANCE, false, false)
        pc.set_intention(AI::INTERACT, obj)
      else
        if obj.type == 2
          if obj.id == 24230101
            file_name = "data/html/signboards/tomb_of_crystalgolem.htm"
          else
            file_name = "data/html/signboards/pvp_signboard.htm"
          end
          html = NpcHtmlMessage.new(obj.l2id)
          if content = HtmCache.get_htm(pc, file_name)
            html.html = content
          else
            html.html = "<html><body>Signboard is missing:<br>#{file_name}</body></html>"
          end

          pc.send_packet(html)
        elsif obj.type == 0
          pc.send_packet(obj.map)
        end
      end
    end

    true
  end

  def instance_type
    InstanceType::L2StaticObjectInstance
  end
end
