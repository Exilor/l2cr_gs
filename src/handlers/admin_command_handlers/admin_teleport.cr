module AdminCommandHandler::AdminTeleport
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    case command
    when "admin_teleto"
      pc.tele_mode = 1
    when "admin_instant_move"
      pc.send_message("Instant move on. Click where you want to go.")
      pc.tele_mode = 1
    when "admin_teleto r"
      pc.tele_mode = 2
    when "admin_teleto end"
      pc.tele_mode = 0
    when "admin_warp"
      warp(pc)
    when "admin_show_moves"
      AdminHtml.show_admin_html(pc, "teleports.htm")
    when "admin_show_moves_other"
      AdminHtml.show_admin_html(pc, "tele/other.htm")
    when "admin_show_teleport"
      show_teleport_chat_window(pc)
    when "admin_recall_npc"
      recall_npc(pc)
    when "admin_teleport_to_character"
      teleport_to_character(pc, pc.target)
    when /\Aadmin_walk.*/
      val = command.from(11).split
      if val.size == 3 && val.all? &.number?
        x = val.shift.to_i
        y = val.shift.to_i
        z = val.shift.to_i
        pc.set_intention(AI::MOVE_TO, Location.new(x, y, z, 0))
      else
        warn { "Wrong coordinates: #{val}." }
      end
    when /\Aadmin_move_to.*/
      begin
        val = command.from(14)
        teleport_to(pc, val)
      rescue
        pc.send_message("Usage: //move_to <x> <y> <z>")
        AdminHtml.show_admin_html(pc, "teleports.htm")
      end
    when /\Aadmin_teleport_character.*/
      begin
        val = command.from(25)
        teleport_character(pc, val)
      rescue
        pc.send_message("Wrong coordinates or no coordinates given.")
        show_teleport_chat_window(pc)
      end
    when /\Aadmin_teleportto.*/
      target_name = command.from(17)
      begin
        player = L2World.get_player(target_name)
        teleport_to_character(pc, player)
      rescue
      end
    when /\Aadmin_recall.*/
      begin
        param = command.split
        if param.size != 2
          pc.send_message("Usage: //recall <playername>")
          return false
        end
        name = param[1]
        if player = L2World.get_player(name)
          teleport_character(player, pc.location, pc)
        else
          change_character_position(pc, name)
        end
      rescue
      end
    when /\Aadmin_tele.*/
      show_teleport_chat_window(pc)
    when /\Aadmin_go.*/
      int_val = 150
      x, y, z = pc.xyz
      begin
        val = command.from(8)
        st = val.split
        dir = st.shift
        unless st.empty?
          int_val = st.shift.to_i
        end
        case dir
        when "east"
          x += int_val
        when "west"
          x -= int_val
        when "north"
          y -= int_val
        when "south"
          y += int_val
        when "up"
          z += int_val
        when "down"
          z -= int_val
        end

        pc.tele_to_location(Location.new(x, y, z))
        show_teleport_window(pc)
      rescue
      end

    when /\Aadmin_sendhome.*/
      st = command.split
      st.shift
      if st.size > 1
        pc.send_message("Usage: //sendhome <playername>")
      elsif st.size == 1
        name = st.shift
        unless player = L2World.get_player(name)
          pc.send_packet(SystemMessageId::TARGET_IS_NOT_FOUND_IN_THE_GAME)
          return false
        end
        teleport_home(player)
      else
        if target = pc.target.as?(L2PcInstance)
          teleport_home(target)
        else
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        end
      end
    end

    true
  end

  private def teleport_home(pc)
    r = case pc.race
    when .elf?      then "elf_town"
    when .dark_elf? then "darkelf_town"
    when .orc?      then "orc_town"
    when .dwarf?    then "dwarf_town"
    when .kamael?   then "kamael_town"
    else "talking_island_town"
    end

    loc = MapRegionManager.get_map_region_by_name(r).spawn_loc
    pc.tele_to_location(loc, true)
    pc.instance_id = 0
    pc.in_7s_dungeon = false
  end

  private def teleport_to(pc, coords)
    x, y, z = coords.split.values_at(0, 1, 2).map &.to_i
    pc.intention = AI::IDLE
    pc.tele_to_location(x, y, z)

    pc.send_message("You have been teleported to #{coords}")
  rescue e
    warn e
    pc.send_message("Wrong or no coordinates given.")
  end

  private def show_teleport_window(pc)
    AdminHtml.show_admin_html(pc, "move.htm")
  end

  private def show_teleport_chat_window(pc)
    unless player = pc.target.as?(L2PcInstance)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    msg = <<-TEXT
      <html><title>Teleport Character</title>
      <body>The character you will teleport is #{player.name}.<br>
      Co-ordinate x<edit var="char_cord_x" width=110>
      Co-ordinate y<edit var="char_cord_y" width=110>
      Co-ordinate z<edit var="char_cord_z" width=110>
      <button value="Teleport" action="bypass -h admin_teleport_character $char_cord_x $char_cord_y $char_cord_z" width=60 height=15 back="L2UI_ct1.button_df" fore="L2UI_ct1.button_df">
      <button value="Teleport near you" action="bypass -h admin_teleport_character #{pc.x} #{pc.y} #{pc.z} width=115 height=15 back="L2UI_ct1.button_df" fore="L2UI_ct1.button_df">
      <center><button value="Back" action="bypass -h admin_current_player" width=40 height=15 back="L2UI_ct1.button_df" fore="L2UI_ct1.button_df"></center>
      </body></html>
    TEXT

    reply = NpcHtmlMessage.new
    reply.html = msg
    pc.send_packet(reply)
  end

  private def teleport_character(x1, x2, x3 = nil)
    if x2.is_a?(String)
      teleport_character1(x1, x2)
    else
      teleport_character2(x1, x2, x3)
    end
  end

  private def teleport_character1(pc, coords)
    unless player = pc.target.as?(L2PcInstance)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    if player == pc
      player.send_packet(SystemMessageId::CANNOT_USE_ON_YOURSELF)
    else
      x, y, z = coords.split.values_at(0, 1, 2).map &.to_i
      teleport_character2(player, Location.new(x, y, z), nil)
    end
  end

  private def teleport_character2(player, loc, pc)
    return unless player

    if player.jailed?
      pc.try &.send_message("#{player.name} is in jail.")
    else
      if pc && pc.instance_id >= 0
        player.instance_id = pc.instance_id
        pc.send_message("You have recalled #{player.name}.")
      else
        player.instance_id = 0
      end

      player.send_message("Admin is teleporting you.")
      player.intention = AI::IDLE
      player.tele_to_location(loc, true)
    end
  end

  private def teleport_to_character(pc, target)
    unless target && target.player?
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    if target == pc
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
    else
      pc.intention = AI::IDLE
      pc.tele_to_location(target, true)
      pc.send_message("You have teleported to character #{target.name}.")
    end
  end

  private def recall_npc(pc)
    obj = pc.target

    if obj.is_a?(L2Npc) && !obj.minion? && !obj.is_a?(L2RaidBossInstance) && !obj.is_a?(L2GrandBossInstance)
      target = obj.as(L2Npc)
      unless sp = target.spawn?
        pc.send_message("Incorrect monster spawn.")
        warn { "NPC #{target.l2id} has no spawn." }
        return
      end

      respawn_time = sp.respawn_delay // 1000

      target.delete_me
      sp.stop_respawn
      SpawnTable.delete_spawn(sp, true)

      begin
        sp = L2Spawn.new(target.template.id)
        if Config.save_gmspawn_on_custom
          sp.custom = true
        end

        sp.x, sp.y, sp.z = pc.xyz
        sp.amount = 1
        sp.heading = pc.heading
        sp.respawn_delay = respawn_time
        if pc.instance_id >= 0
          sp.instance_id = pc.instance_id
        else
          sp.instance_id = 0
        end
        SpawnTable.add_new_spawn(sp, true)
        sp.init

        pc.send_message("Created #{target.template.name} on #{target.l2id}.")

        debug { "Spawn at #{target.xyz}." }
        debug { "GM #{pc.name} (#{pc.l2id}) moved NPC #{target.l2id}." }
      rescue e
        warn e
        pc.send_message("Target is not in game.")
      end
    elsif target = obj.as?(L2RaidBossInstance)
      unless sp = target.spawn?
        pc.send_message("Incorrect raid spawn.")
        warn { "NPC ID #{target.id} has no spawn." }
        return
      end
      cur_hp = target.current_hp
      cur_mp = target.current_mp

      RaidBossSpawnManager.delete_spawn(sp, true)

      begin
        dat = L2Spawn.new(target.id)
        if Config.save_gmspawn_on_custom
          sp.custom = true
        end
        dat.x, dat.y, dat.z = pc.xyz
        dat.amount = 1
        dat.heading = pc.heading
        dat.respawn_min_delay = 43200
        dat.respawn_max_delay = 129600

        RaidBossSpawnManager.add_new_spawn(dat, 0, cur_hp, cur_mp, true)
      rescue e
        warn e
        pc.send_packet(SystemMessageId::TARGET_CANT_FOUND)
      end
    else
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
    end
  end

  private def change_character_position(pc, name)
    x, y, z = pc.xyz
    sql = "UPDATE characters SET x=?, y=?, z=? WHERE char_name=?"
    GameDB.exec(sql, x, y, z, name)
  rescue e
    error e
  end

  private def warp(pc)
    unless pc.moving?
      pc.send_message("You need to be moving in order to warp.")
      return
    end

    pc.set_xyz(pc.x_destination, pc.y_destination, pc.z_destination)
    pc.stop_move(nil)
    pc.broadcast_packet(ValidateLocation.new(pc))
    msu = MagicSkillUse.new(pc, pc, 628, 1, 1, 1)
    pc.broadcast_packet(msu)


    if smn = pc.summon
      msu = MagicSkillUse.new(smn, smn, 628, 1, 1, 1)
      smn.broadcast_packet(msu)
      smn.tele_to_location(*pc.xyz)
      smn.follow_owner
    end
  end

  def commands
    %w(
    admin_show_moves
    admin_show_moves_other
    admin_show_teleport
    admin_teleport_to_character
    admin_teleportto
    admin_move_to
    admin_teleport_character
    admin_recall
    admin_walk
    teleportto
    recall
    admin_recall_npc
    admin_gonorth
    admin_gosouth
    admin_goeast
    admin_gowest
    admin_goup
    admin_godown
    admin_tele
    admin_teleto
    admin_instant_move
    admin_sendhome
    admin_warp
    )
  end
end
