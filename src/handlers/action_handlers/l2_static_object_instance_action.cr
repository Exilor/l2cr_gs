module ActionHandler::L2StaticObjectInstanceAction
  extend self
  extend ActionHandler

  def action(pc, target, interact) : Bool
    return false unless target.is_a?(L2StaticObjectInstance)

    if target.type < 0
      raise "StaticObject with invalid type #{target.type}."
    end

    if pc.target != target
      pc.target = target
    elsif interact
      if pc.inside_radius?(target, L2Npc::INTERACTION_DISTANCE, false, false)
        if target.type == 2
          if target.id == 24230101
            file_name = "data/html/signboards/tomb_of_crystalgolem.htm"
          else
            file_name = "data/html/signboards/pvp_signboard.htm"
          end
          html = NpcHtmlMessage.new(target.l2id)
          if content = HtmCache.get_htm(pc, file_name)
            html.html = content
          else
            html.html = "<html><body>Signboard is missing:<br>#{file_name}</body></html>"
          end

          pc.send_packet(html)
        elsif target.type == 0
          pc.send_packet(target.map.not_nil!)
        end
      else
        pc.set_intention(AI::INTERACT, target)
      end
    end

    true
  end

  def instance_type : InstanceType
    InstanceType::L2StaticObjectInstance
  end
end
