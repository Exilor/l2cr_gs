module AdminCommandHandler::AdminReload
  extend self
  extend AdminCommandHandler

  private RELOAD_USAGE = "Usage: #reload <config|access|npc|quest [quest_id|quest_name]|walker|htm[l] [file|directory]|multisell|buylist|teleport|skill|item|door|effect|handler|enchant|creationpoint>"

  def use_admin_command(command, pc)
    st = command.split
    actual_command = st.shift
    if actual_command.casecmp?("admin_reload")
      if st.empty?
        AdminHtml.show_admin_html(pc, "reload.htm")
        pc.send_message(RELOAD_USAGE)
        return true
      end

      type = st.shift
      case type.casecmp
      when "config"
        Config.load
        AdminData.broadcast_message_to_gms(pc.name + ": Reloaded Config.")
      when "access"
        AdminData.load
        AdminData.broadcast_message_to_gms(pc.name + ": Reloaded Access.")
      when "npc"
        NpcData.load
        AdminData.broadcast_message_to_gms(pc.name + ": Reloaded Npcs.")
      when "quest"
        pc.send_message("Reloading quests is not supported.")
        return true
      when "walker"
        WalkingManager.load
        pc.send_message("All walkers have been reloaded")
        AdminData.broadcast_message_to_gms(pc.name + ": Reloaded Walkers.")
      when "htm", "html"
        if !st.empty?
          path = "#{Config.datapack_root}/data/html/#{st.shift}"
          if File.exists?(path)
            html = File.read(path)
            HtmCache.reload(html)
            AdminData.broadcast_message_to_gms("#{pc.name}: Reloaded Htm File: #{File.basename(path)}.")
          else
            pc.send_message("File or Directory #{path} does not exist.")
          end
        else
          HtmCache.reload
          pc.send_message("Cache[HTML]: #{HtmCache.memory_usage} megabytes on #{HtmCache.loaded_files} files loaded")
          AdminData.broadcast_message_to_gms(pc.name + ": Reloaded Htms.")
        end
      when "multisell"
        MultisellData.load
        AdminData.broadcast_message_to_gms(pc.name + ": Reloaded Multisells.")
      when "buylist"
        BuyListData.load
        AdminData.broadcast_message_to_gms(pc.name + ": Reloaded Buylists.")
      when "teleport"
        TeleportLocationTable.load
        AdminData.broadcast_message_to_gms(pc.name + ": Reloaded Teleports.")
      when "skill"
        SkillData.reload
        AdminData.broadcast_message_to_gms(pc.name + ": Reloaded Skills.")
      when "item"
        ItemTable.reload
        AdminData.broadcast_message_to_gms(pc.name + ": Reloaded Items.")
      when "door"
        DoorData.load
        AdminData.broadcast_message_to_gms(pc.name + ": Reloaded Doors.")
      when "zone"
        ZoneManager.reload
        AdminData.broadcast_message_to_gms(pc.name + ": Reloaded Zones.")
      when "cw"
        CursedWeaponsManager.reload
        AdminData.broadcast_message_to_gms(pc.name + ": Reloaded Cursed Weapons.")
      when "crest"
        CrestTable.load
        AdminData.broadcast_message_to_gms(pc.name + ": Reloaded Crests.")
      when "effect"
        pc.send_message("Reloading effects is not supported.")
        return true
      when "handler"
        pc.send_message("Reloading handlers is not supported.")
        return true
      when "enchant"
        EnchantItemGroupsData.load
        EnchantItemData.load
        AdminData.broadcast_message_to_gms(pc.name + ": Reloaded item enchanting data.")
      when "transform"
        TransformData.load
        AdminData.broadcast_message_to_gms(pc.name + ": Reloaded transform data.")
      when "creationpoint"
        PlayerCreationPointData.load
        AdminData.broadcast_message_to_gms(pc.name + ": Reloaded creation points data.")
      else
        pc.send_message(RELOAD_USAGE)
        return true
      end

      pc.send_message("WARNING: There are several known issues regarding this feature. Reloading server data during runtime is STRONGLY NOT RECOMMENDED for live servers, just for developing environments.")
    end

    true
  end

  def commands
    {"admin_reload"}
  end
end
