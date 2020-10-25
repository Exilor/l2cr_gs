module ChatHandler::ChatShout
  extend self
  extend ChatHandler

  def handle_chat(type, pc, target, text)
    if pc.chat_banned? && Config.ban_chat_channels.includes?(type)
      pc.send_packet(SystemMessageId::CHATTING_IS_CURRENTLY_PROHIBITED)
      return
    end

    cs = Packets::Outgoing::CreatureSay.new(pc.l2id, type, pc.name, text)
    default = Config.default_global_chat
    if default.casecmp?("on") || (default.casecmp?("gm") && pc.override_chat_conditions?)
      region = MapRegionManager.get_map_region_loc_id(pc)
      L2World.players.each do |player|
        if region == MapRegionManager.get_map_region_loc_id(player)
          unless BlockList.blocked?(player, pc)
            player.send_packet(cs)
          end
        end
      end
    elsif default.casecmp?("global")
      if !pc.override_chat_conditions? && !pc.flood_protectors.global_chat.try_perform_action("global chat")
        pc.send_message("Do not spam the shout channel.")
        return
      end

      L2World.players.each do |player|
        unless BlockList.blocked?(player, pc)
          player.send_packet(cs)
        end
      end
    end
  end

  def chat_type_list
    {1}
  end
end
