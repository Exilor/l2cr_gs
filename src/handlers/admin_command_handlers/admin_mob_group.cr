module AdminCommandHandler::AdminMobGroup
  extend self
  extend AdminCommandHandler
  include Packets::Outgoing

  def use_admin_command(command, pc)
    if command == "admin_mobmenu"
      show_main_page(pc, command)
      return true
    elsif command == "admin_mobgroup_list"
      show_group_list(pc)
    elsif command.starts_with?("admin_mobgroup_create")
      create_group(command, pc)
    elsif command.starts_with?("admin_mobgroup_delete", "admin_mobgroup_remove")
      remove_group(command, pc)
    elsif command.starts_with?("admin_mobgroup_spawn")
      spawn_group(command, pc)
    elsif command.starts_with?("admin_mobgroup_unspawn")
      unspawn_group(command, pc)
    elsif command.starts_with?("admin_mobgroup_kill")
      kill_group(command, pc)
    elsif command.starts_with?("admin_mobgroup_attackgrp")
      attack_group(command, pc)
    elsif command.starts_with?("admin_mobgroup_attack")
      if target = pc.target.as?(L2Character)
        attack(command, pc, target)
      end
    elsif command.starts_with?("admin_mobgroup_rnd")
      set_normal(command, pc)
    elsif command.starts_with?("admin_mobgroup_idle")
      idle(command, pc)
    elsif command.starts_with?("admin_mobgroup_return")
      return_to_char(command, pc)
    elsif command.starts_with?("admin_mobgroup_follow")
      follow(command, pc, pc)
    elsif command.starts_with?("admin_mobgroup_casting")
      set_casting(command, pc)
    elsif command.starts_with?("admin_mobgroup_nomove")
      no_move(command, pc)
    elsif command.starts_with?("admin_mobgroup_invul")
      invul(command, pc)
    elsif command.starts_with?("admin_mobgroup_teleport")
      teleport_group(command, pc)
    end

    show_main_page(pc, command)

    true
  end

  private def show_main_page(pc, command)
    filename = "mobgroup.htm"
    AdminHtml.show_admin_html(pc, filename)
  end

  private def return_to_char(command, pc)
    begin
      group_id = command.split[1].to_i
    rescue
      pc.send_message("Incorrect command arguments.")
      return
    end
    unless group = MobGroupTable.get_group(group_id)
      pc.send_message("Invalid group specified.")
      return
    end
    group.return_group(pc)
  end

  private def idle(command, pc)
    begin
      group_id = command.split[1].to_i
    rescue
      pc.send_message("Incorrect command arguments.")
      return
    end
    unless group = MobGroupTable.get_group(group_id)
      pc.send_message("Invalid group specified.")
      return
    end
    group.set_idle_mode
  end

  private def set_normal(command, pc)
    begin
      group_id = command.split[1].to_i
    rescue
      pc.send_message("Incorrect command arguments.")
      return
    end
    unless group = MobGroupTable.get_group(group_id)
      pc.send_message("Invalid group specified.")
      return
    end
    group.set_attack_random
  end

  private def attack(command, pc, target)
    begin
      group_id = command.split[1].to_i
    rescue
      pc.send_message("Incorrect command arguments.")
      return
    end
    unless group = MobGroupTable.get_group(group_id)
      pc.send_message("Invalid group specified.")
      return
    end
    group.attack_target = target
  end

  private def follow(command, pc, target)
    begin
      group_id = command.split[1].to_i
    rescue
      pc.send_message("Incorrect command arguments.")
      return
    end
    unless group = MobGroupTable.get_group(group_id)
      pc.send_message("Invalid group specified.")
      return
    end
    group.set_follow_mode(target)
  end

  private def create_group(command, pc)
    begin
      cmd_params = command.split

      group_id = cmd_params[1].to_i
      template_id = cmd_params[2].to_i
      mob_count = cmd_params[3].to_i
    rescue
      pc.send_message("Usage: #mobgroup_create <group> <npcid> <count>")
      return
    end

    if MobGroupTable.get_group(group_id)
      pc.send_message("Mob group #{group_id} already exists.")
      return
    end

    unless template = NpcData[template_id]?
      pc.send_message("Invalid NPC ID specified.")
      return
    end

    group = MobGroup.new(group_id, template, mob_count)
    MobGroupTable.add_group(group_id, group)

    pc.send_message("Mob group #{group_id} created.")
  end

  private def remove_group(command, pc)
    begin
      group_id = command.split[1].to_i
    rescue
      pc.send_message("Usage: #mobgroup_remove <group_id>")
      return
    end

    unless group = MobGroupTable.get_group(group_id)
      pc.send_message("Invalid group specified.")
      return
    end

    do_animation(pc)
    group.unspawn_group

    if MobGroupTable.remove_group(group_id)
      pc.send_message("Mob group #{group_id} unspawned and removed.")
    end
  end

  private def spawn_group(command, pc)
    topos = false
    posx = 0
    posy = 0
    posz = 0

    begin
      cmd_params = command.split
      group_id = cmd_params[1].to_i

      begin
        posx = cmd_params[2].to_i
        posy = cmd_params[3].to_i
        posz = cmd_params[4].to_i
        topos = true
      rescue
        # no position given
      end
    rescue
      pc.send_message("Usage: #mobgroup_spawn <group> [ x y z ]")
      return
    end

    unless group = MobGroupTable.get_group(group_id)
      pc.send_message("Invalid group specified.")
      return
    end

    do_animation(pc)

    if topos
      group.spawn_group(posx, posy, posz)
    else
      group.spawn_group(pc)
    end

    pc.send_message("Mob group #{group_id} spawned.")
  end

  private def unspawn_group(command, pc)
    begin
      group_id = command.split[1].to_i
    rescue
      pc.send_message("Usage: #mobgroup_unspawn <group_id>")
      return
    end

    unless group = MobGroupTable.get_group(group_id)
      pc.send_message("Invalid group specified.")
      return
    end

    do_animation(pc)
    group.unspawn_group

    pc.send_message("Mob group #{group_id} unspawned.")
  end

  private def kill_group(command, pc)
    begin
      group_id = command.split[1].to_i
    rescue
      pc.send_message("Usage: #mobgroup_kill <group_id>")
      return
    end

    unless group = MobGroupTable.get_group(group_id)
      pc.send_message("Invalid group specified.")
      return
    end

    do_animation(pc)
    group.kill_group(pc)
  end

  private def set_casting(command, pc)
    begin
      group_id = command.split[1].to_i
    rescue
      pc.send_message("Usage: #mobgroup_casting <group_id>")
      return
    end

    unless group = MobGroupTable.get_group(group_id)
      pc.send_message("Invalid group specified.")
      return
    end

    group.set_cast_mode
  end

  private def no_move(command, pc)
    begin
      group_id = command.split[1].to_i
      enabled = command.split[2]
    rescue
      pc.send_message("Usage: #mobgroup_nomove <group_id> <on|off>")
      return
    end

    unless group = MobGroupTable.get_group(group_id)
      pc.send_message("Invalid group specified.")
      return
    end

    if enabled.casecmp?("on") || enabled.casecmp?("true")
      group.no_move_mode = true
    elsif enabled.casecmp?("off") || enabled.casecmp?("false")
      group.no_move_mode = false
    else
      pc.send_message("Incorrect command arguments.")
    end
  end

  private def do_animation(pc)
    msu = MagicSkillUse.new(pc, 1008, 1, 4000, 0)
    Broadcast.to_self_and_known_players_in_radius(pc, msu, 1500)
    pc.send_packet(SetupGauge.blue(4000))
  end

  private def attack_group(command, pc)
    begin
      group_id = command.split[1].to_i
      other_group_id = command.split[2].to_i
    rescue
      pc.send_message("Usage: #mobgroup_attackgrp <group_id> <target_group_id>")
      return
    end

    unless group = MobGroupTable.get_group(group_id)
      pc.send_message("Invalid group specified.")
      return
    end

    unless other_group = MobGroupTable.get_group(other_group_id)
      pc.send_message("Incorrect target group.")
      return
    end

    group.attack_group = other_group
  end

  private def invul(command, pc)
    begin
      group_id = command.split[1].to_i
      enabled = command.split[2]
    rescue
      pc.send_message("Usage: #mobgroup_invul <group_id> <on|off>")
      return
    end

    unless group = MobGroupTable.get_group(group_id)
      pc.send_message("Invalid group specified.")
      return
    end

    if enabled.casecmp?("on") || enabled.casecmp?("true")
      group.invul = true
    elsif enabled.casecmp?("off") || enabled.casecmp?("false")
      group.invul = false
    else
      pc.send_message("Incorrect command arguments.")
    end
  end

  private def teleport_group(command, pc)
    begin
      group_id = command.split[1].to_i
      target_player_str = command.split[2]

      if target_player_str
        target_player = L2World.get_player(target_player_str)
      end

      target_player ||= pc
    rescue
      pc.send_message("Usage: #mobgroup_teleport <group_id> [playerName]")
      return
    end

    unless group = MobGroupTable.get_group(group_id)
      pc.send_message("Invalid group specified.")
      return
    end

    group.teleport_group(target_player)
  end

  private def show_group_list(pc)
    pc.send_message("======= <Mob Groups> =======")

    MobGroupTable.groups.each do |g|
      pc.send_message("#{g.group_id}: #{g.active_mob_count} alive out of #{g.max_mob_count} of NPC ID #{g.template.id} (#{g.status})")
    end

    pc.send_packet(SystemMessageId::FRIEND_LIST_FOOTER)
  end

  def commands
    {
      "admin_mobmenu",
      "admin_mobgroup_list",
      "admin_mobgroup_create",
      "admin_mobgroup_remove",
      "admin_mobgroup_delete",
      "admin_mobgroup_spawn",
      "admin_mobgroup_unspawn",
      "admin_mobgroup_kill",
      "admin_mobgroup_idle",
      "admin_mobgroup_attack",
      "admin_mobgroup_rnd",
      "admin_mobgroup_return",
      "admin_mobgroup_follow",
      "admin_mobgroup_casting",
      "admin_mobgroup_nomove",
      "admin_mobgroup_attackgrp",
      "admin_mobgroup_invul",
      "admin_mobgroup_teleport"
    }
  end
end
