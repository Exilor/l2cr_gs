class Packets::Incoming::SendBypassBuildCMD < GameClientPacket
  no_action_request

  GM_MESSAGE = 9
  ANNOUNCEMENT = 10

  @command = ""

  def read_impl
    @command = s.strip
  end

  def run_impl
    return unless pc = active_char
    return unless run_custom_cmd(pc) == :proceed

    debug command = "admin_#{@command[/^(\S)+/]}"
    handler = AdminCommandHandler[command]
    unless handler
      if pc.gm?
        pc.send_message "The command #{command.from(6)} does not exist."
      end
      return
    end

    unless AdminData.has_access?(command, pc.access_level)
      pc.send_message("You don't have the access right to use this command!")
      warn "#{pc} tried to use admin command #{command} without the proper access level."
      return
    end

    if Config.gmaudit
      GMAudit.log(pc.name + " [#{pc.l2id}]", @command, pc.target.try &.name || "no-target")
      debug "#{pc} used command #{command.inspect}."
    end

    handler.use_admin_command("admin_#{@command}", pc)
  end

  private def run_custom_cmd(pc)
    case @command
    when "weapon"
      puts "Paperdoll size: #{pc.inventory.@paperdoll.size}"
    when "test"
      L2Cr.test(pc)
    when "zones"
      debug pc.world_region?.try &.zones.map &.name
    when "gc"
      GC.collect
    when "abort"
      pc.abort_cast
    when "save"
      pc.store_me
    when /^add_sp\s\d+$/
      pc.add_sp(args[0].to_i)
      send_packet(UserInfo.new(pc))
    when "save_items"
      ItemsOnGroundManager.save_in_db
    when /^hp\s\d+/
      set_hp
    when /^mp\s\d+/
      set_mp
    when /^cp\s\d+/
      set_cp
    when "warp"
      warp
    when "skills"
      send_skill_info
    when "weight"
      pc.refresh_overloaded
    when /^day_mobs$/
      DayNightSpawnManager.change_mode(0)
    when /^night_mobs$/
      DayNightSpawnManager.change_mode(1)
    when "vit"
      vit = Math.min(Config.starting_vitality_points, PcStat::MAX_VITALITY_POINTS)
      pc.set_vitality_points(vit, true)
    when "learn_all"
      pc_target.reward_skills(true)
    when /^get_ch\s\d+$/
      ClanHallManager.set_owner(args[0].to_i, pc.clan) if pc.clan?
    when "forget_all"
      pc_target.all_skills.each { |skill| pc_target.remove_skill(skill) }
      pc.send_skill_list
    when "destroy_items"
      pc.target.as?(L2PcInstance).try &.inventory.destroy_all_items("GM", pc, nil)
      pc.send_packet(ItemList.new(pc, false)) if pc == pc.target
    when "sunrise"
      send_packet(SunRise::STATIC_PACKET)
    when "sunset"
      send_packet(SunSet::STATIC_PACKET)
    when "realtime"
      send_packet(ClientSetTime.new(time: Time.now.to_s("%H:%M"), speed: 1))
    when "gametime"
      send_packet(ClientSetTime.new)
    when /^milk\s\d+$/
      milk_target
    when "aspir"
      aspir(999999)
    when /^clan_level\s\d$/
      pc.clan?.try &.level = args.first.to_i
    when /^shutdown\s\d+/
      Shutdown.start_shutdown(pc, args[0].to_i, false)
    when "shutdown"
      Shutdown.start_shutdown(pc, 0, false)
    when /^restart\s\d+/
      Shutdown.start_shutdown(pc, args[0].to_i, true)
    when "restart"
      Shutdown.start_shutdown(pc, 0, true)
    when /^level\s\d+/
      set_level
    when /^class\s.*/
      set_class
    when /^uplift\s.*/
      uplift_target
    when "cancel"
      char_target.stop_all_effects
    when "cleanse"
      char_target.effect_list.stop_all_debuffs
    when "kill_all"
      L2World.objects.each &.as?(L2Attackable).try { |m| m.do_die(pc) unless m.raid? || m.raid_minion? }
    when "drop_all"
      L2World.objects.each &.as?(L2Attackable).try { |m| m.do_die(pc) unless m.raid? || m.raid_minion? }
    when "reuse"
      reuse
    when /^learn\s\d+(\s\d+)?$/
      learn_skill
    when /^ivar\s\S+$/
      print_ivar
    when /^spawn\s\d+$/
      spawn_npc
    when /^spawn\s(\w\s?)+$/
      spawn_npc_by_name
    when /^goto\s\S+$/
      name = @command[/(\S)+\z/]
      if player = L2World.get_player(name)
        pc.tele_to_location(player)
      else
        pc.send_message("Player #{name.inspect} not found.")
      end
    when /^goto_npc\s.+$/
      goto_npc
    when /^recall\s\S+/
      recall_by_name


    when "recall_bots"
      L2World.players.each do |player|
        if player != pc
          player.tele_to_location(pc, true)
        end
      end
    when "bots_follow"
      pc.known_list.known_players.values.each do |player|
        player.set_intention(AI::FOLLOW, pc)
      end
    when "bots_stop"
      pc.known_list.known_players.values.each do |player|
        player.stop_move
        player.intention = AI::IDLE
      end
    when "bots_attack"
      pc.known_list.known_players.values.each do |player|
        if target = pc.target.as?(L2Character)
          player.set_intention(AI::ATTACK, target)
        end
      end
    when "bots_come"
      pc.known_list.known_players.values.each do |player|
        if target = pc.target.as?(L2Character)
          player.set_intention(AI::MOVE_TO, pc)
        end
      end
    when "players"
      pc.send_message("#{L2World.players.size} online players.")


    when "champion"
      toggle_champ_target
    when "delete"
      pc.target.as?(L2Npc).try { |n| n.delete_me; n.spawn?.try &.stop_respawn }
    when "follow_me"
      follow_me
    when "stop"
      stop
    when "go_back"
      go_back
    when "all_go_back"
      all_go_back
    when "all_follow_me"
      all_follow_me
    when /^summon(\s\d+)?/
      summon_npc
    when "attack"
      attack_my_target
    when "recall_party"
      pc.party?.try &.each { |m| m.tele_to_location(pc, true) if m != pc }
    when "invul"
      if pc.invul?
        pc.send_message("Invulnerability disabled.")
      else
        pc.send_message("Invulnerability enabled.")
      end
      pc.invul = !pc.invul?
    when "open"
      pc.target.as?(L2DoorInstance).try &.open_me
    when "close"
      pc.target.as?(L2DoorInstance).try &.close_me
    when /hb\s\d/
      set_hellbound_level
    when "hb"
      pc.send_message("Level: #{HellboundEngine.level}")
      pc.send_message("Trust: #{HellboundEngine.trust}")
    else
      return :proceed
    end

    nil
  end

  private def set_hellbound_level
    level = args.first.to_i
    HellboundEngine.level = level
  end

  private def set_hp
    char_target.current_hp = args[0].to_f64
  end

  private def set_mp
    char_target.current_mp = args[0].to_f64
  end

  private def set_cp
    char_target.current_cp = args[0].to_f64
  end

  private def res_target
    char_target.do_revive(100.0)
  end

  private def warp
    unless pc.moving?
      pc.send_message("You need to be moving in order to warp.")
      return
    end

    pc.set_xyz(pc.x_destination, pc.y_destination, pc.z_destination)
    pc.stop_move
    pc.broadcast_packet(ValidateLocation.new(pc))
    msu = MagicSkillUse.new(pc, pc, 628, 1, 1, 1)
    pc.broadcast_packet(msu)


    if summon = pc.summon
      msu = MagicSkillUse.new(summon, summon, 628, 1, 1, 1)
      summon.broadcast_packet(msu)
      summon.tele_to_location(*pc.xyz)
      summon.follow_owner
    end
  end

  private def milk_target
    return unless target = pc.target.as?(L2Attackable)
    pc.target = nil
    times = args.first.to_i
    target.reduce_current_hp(target.max_hp - 1f64, pc, nil)
    case pc.class_id
    when .dwarven_fighter?, .scavenger?, .bounty_hunter?, .fortune_seeker?
      is_spoiler = true
    end
    timer = Timer.new

    times.times do
      if is_spoiler
        target.spoiler_l2id = pc.l2id
      end

      target.do_die(pc)

      if is_spoiler
        target.take_sweep.try &.each do |item|
          if pc.in_party?
            pc.party.distribute_item(pc, item, true, target)
          else
            pc.add_item("Admin milk", item, target, true)
          end
        end
      end

      target.do_revive
    end

    pc.send_message("Target milked #{times} times in #{timer.result} s.")
  end

  private def aspir(radius)
    return unless pc = active_char
    radius = 1000 if radius == 0
    party = pc.party?
    pc.known_list.known_objects.values.each do |item|
      begin
        next unless item.is_a?(L2ItemInstance)
        if item.template.has_ex_immediate_effect? && item.etc_item?
          next
        end
        # debug "Util.in_range?(#{radius}, #{item}, #{pc}, #{true}) #{Util.in_range?(radius, item, pc, true)}"
        next unless Util.in_range?(radius, item, pc, true)
        old_region = item.world_region?
        item.visible = false
        item.world_region = nil
        L2World.remove_visible_object(item, old_region)

        if item.id == Inventory::ADENA_ID && pc.inventory.adena_instance?
          # debug "Adding #{item.count} adena"
          if party
            party.distribute_item(pc, item)
          else
            pc.add_adena("Pickup", item.count, nil, true)
            ItemTable.destroy_item("Pickup", item, pc, nil)
          end
        else
          # debug "Adding #{item}"
          if party
            party.distribute_item(pc, item)
          else
            pc.add_item("Pickup", item, nil, true)
          end
        end

        ItemsOnGroundManager.remove_object(item)
      rescue e
        error e
      end
    end
  end

  private def set_level
    target = pc_target#(char_target.as?(L2Playable) || pc_target)
    level = args[0].to_i
    old_level = target.level
    target.level = level
    target.exp = ExperienceData.get_exp_for_level(Math.min(level, target.max_exp_level))
    target.on_level_change(level > old_level)
    target.broadcast_info
  end

  private def set_class
    pc = active_char.not_nil!
    id = args.last {""}.upcase
    class_id = ClassId.parse?(id) || (ClassId[id.to_i]? if id.num?)
    if class_id && !class_id.to_s.includes?("DUMMY")
      target = pc_target
      target.class_template = class_id.to_i
      target.base_class = class_id.to_i
      target.broadcast_user_info
      target.send_message("You class is now #{class_id}.")
    else
      pc.send_message("No class found for #{id.inspect}")
      html = String.build do |io|
        io.puts "<html><title>Class names</title><body>"
        ClassId.each do |id|
          io.puts "#{id}<br1>" unless id.to_s.includes?("DUMMY")
        end
        io.puts "</body></html>"
      end
      msg = NpcHtmlMessage.new(html)
      pc.send_packet(msg)
    end
  end

  private def reuse
    pc_target.skill_reuse_time_stamps.try &.clear
    pc_target.@disabled_skills.try &.clear
    pc_target.send_packet(SkillCoolTime.new(pc_target))
  end

  private def char_target
    pc = active_char.not_nil!
    pc.target.as?(L2Character) || pc
  end

  private def pc_target
    char_target.as?(L2PcInstance) || active_char.not_nil!
  end

  private def learn_skill
    return unless pc = active_char
    if args.size == 1
      lvl = 1
    else
      lvl = args.last.to_i
    end

    id = args.first.to_i
    if skill = SkillData[id, lvl]?
      pc.add_skill(skill, false)
      pc.send_skill_list
      pc.send_message("You learnt #{skill}")
    else
      pc.send_message("No skill exists with ID #{id} and level #{lvl}.")
    end
  end

  private def print_ivar
    name = args.first
    {% for ivar in L2PcInstance.instance_vars %}
      if name.casecmp?({{ivar.stringify}})
        debug pc.@{{ivar.id}}.inspect
        return
      end
    {% end %}
  end

  private def spawn_npc
    npc_id = args.last.to_i
    unless NpcData[npc_id]?
      pc.send_message "No NPC with ID #{npc_id} exists."
      return
    end
    spawn = L2Spawn.new(npc_id)
    spawn.instance_id = pc.instance_id
    spawn.heading = pc.heading
    spawn.x, spawn.y, spawn.z = pc.xyz
    spawn.stop_respawn

    spawn.spawn_one(false)
  end

  private def spawn_npc_by_name
    name = args.join(' ')
    unless template = NpcData.templates.find &.name.casecmp?(name)
      pc.send_message "No NPC with name #{name} exists."
      return
    end
    spawn = L2Spawn.new(template.id)
    spawn.instance_id = pc.instance_id
    spawn.heading = pc.heading
    spawn.x, spawn.y, spawn.z = pc.xyz
    spawn.stop_respawn

    spawn.spawn_one(false)
  end

  private def goto_npc
    name = args.join(' ')
    npc = L2World.objects.find do |obj|
      obj.as?(L2Npc).try &.name.try &.casecmp?(name)
    end
    name2 = name.downcase
    npc ||= L2World.objects.find do |obj|
      obj.as?(L2Npc).try &.name.try &.includes?(name2)
    end
    if npc
      pc.tele_to_location(npc)
    else
      pc.send_message("No npc called #{name.inspect} was found.")
    end
  end

  private def recall_by_name
    if target = L2World.get_player(args.first)
      target.tele_to_location(pc)
    else
      pc.send_message("#{args.first} not found.")
    end
  end

  private def follow_me
    if target = pc.target.as?(L2Character)
      target.running = true
      target.set_intention(AI::FOLLOW, pc)
    else
      send_message("You don't have a target")
    end
  end

  private def stop
    if target = pc.target.as?(L2Character)
      target.running = false
      target.intention = AI::IDLE
    else
      send_message("You don't have a target")
    end
  end

  private def go_back
    if target = pc.target
      if target.is_a?(L2Npc)
        target.set_intention(AI::MOVE_TO, target.spawn.location)
      end
    end
  end

  private def all_go_back
    pc.known_list.each_character do |obj|
      if obj.is_a?(L2Npc)
        obj.set_intention(AI::MOVE_TO, obj.spawn.location)
      end
    end
  end

  private def all_follow_me
    pc.known_list.each_character do |obj|
      obj.running = true
      obj.set_intention(AI::FOLLOW, pc)
    end
  end

  private def toggle_champ_target
    target = pc.try &.target
    if target.is_a?(L2MonsterInstance)
      target.champion = !target.champion?
      target.send_info(pc)
    end
  end

  private def summon_npc
    id = args.first?.try &.to_i
    id ||= pc.target.as?(L2Npc).try &.id
    return unless id
    return unless template = NpcData[id]?
    summon = L2ServitorInstance.new(template, pc)
    pc.pet = summon.heal!
    summon.name = template.name

    if t = pc.target.as?(L2Npc)
      summon.set_xyz_invisible(*t.xyz)
    end

    summon.spawn_me
    msu = MagicSkillUse.new(summon, summon, 5456, 1, 1, 1)
    summon.broadcast_packet(msu)
    summon.@life_task.try &.cancel
    summon.set_running
  end

  private def attack_my_target
    return unless target = pc.target.as?(L2Character)

    pc.known_list.each_character do |char|
      next unless char.is_a?(L2Attackable)
      next if char == target

      char.known_list.add_known_object(target)

      info = char.aggro_list[target] ||= AggroInfo.new(target)
      info.add_hate(9999999)
      char.target = target
      char.set_intention(AI::ATTACK, target)
    end
  end

  private def uplift_target
    return unless pc = active_char
    return unless target = pc.target.as?(L2PcInstance)
    id = args.first {""}

    class_id = ClassId.parse?(id) || (ClassId[id.to_i]? if id.num?)
    if class_id && !class_id.to_s.includes?("DUMMY")
      if class_id.level == 3
        do_uplift_target(target, class_id)
      else
        pc.send_message("ClassId #{class_id} is not a 3rd class.")
      end
    else
      pc.send_message("No class found for #{id.inspect}")
      html = String.build do |io|
        io.puts "<html><title>Class names</title><body>"
        ClassId.each do |id|
          io.puts "#{id}<br1>" unless id.to_s.includes?("DUMMY")
        end
        io.puts "</body></html>"
      end
      msg = NpcHtmlMessage.new(html)
      pc.send_packet(msg)
    end
  end

  private def do_uplift_target(pc, class_id)
    # max level
    old_level = pc.level
    pc.level = 85
    pc.exp = ExperienceData.get_exp_for_level(Math.min(85, pc.max_exp_level))
    pc.on_level_change(85 > old_level)

    # set class
    pc.class_template = class_id.to_i
    pc.base_class = class_id.to_i

    # learn all skills
    pc.all_skills.each { |skill| pc.remove_skill(skill) }
    pc.reward_skills(true)

    # top level equipment
    items = [
      pc.inventory.add_item("GM", 15717, 2, pc, nil), # Elegia Ring x2
      pc.inventory.add_item("GM", 15718, 2, pc, nil), # Elegia Earring x2
      pc.inventory.add_item("GM", 15719, 1, pc, nil), # Elegia Necklace
      pc.inventory.add_item("GM", 10210, 1, pc, nil), # Enhanced Mithril Bracelet
      pc.inventory.add_item("GM", 15312, 1, pc, nil), # Dawn's Bracelet
      pc.inventory.add_item("GM", 14929, 1, pc, nil), # Top-grade Magic Rune Clip Mithril Belt
      pc.inventory.add_item("GM", 9588, 1, pc, nil)   # Striped Mithril Shirt
    ]

    case class_id
    when ClassId::DUELIST
      add_heavy_armor(pc, items)
      items << pc.inventory.add_item("GM", 16158, 1, pc, nil) # Eternal Dual Core Sword
    when ClassId::DREADNOUGHT
      add_heavy_armor(pc, items)
      items << pc.inventory.add_item("GM", 15889, 1, pc, nil) # Demitelum
    when ClassId::PHOENIX_KNIGHT
      add_heavy_armor(pc, items)
      items << pc.inventory.add_item("GM", 15587, 1, pc, nil) # Elegia Shield
      items << pc.inventory.add_item("GM", 15872, 1, pc, nil) # Eternal Core Sword
    when ClassId::HELL_KNIGHT
      add_heavy_armor(pc, items)
      items << pc.inventory.add_item("GM", 15587, 1, pc, nil) # Elegia Shield
      items << pc.inventory.add_item("GM", 15872, 1, pc, nil) # Eternal Core Sword
    when ClassId::SAGITTARIUS
      add_light_armor(pc, items)
      items << pc.inventory.add_item("GM", 15903, 1, pc, nil) # Recurve Thorne Bow
      items << pc.inventory.add_item("GM", 1345, 2000, pc, nil) # Shining Arrow
    when ClassId::ADVENTURER
      add_light_armor(pc, items)
      items << pc.inventory.add_item("GM", 16156, 1, pc, nil) # Mamba Edge Dual Daggers
    when ClassId::ARCHMAGE
      add_robe(pc, items)
      items << pc.inventory.add_item("GM", 15896, 1, pc, nil) # Cyclic Cane
    when ClassId::SOULTAKER
      add_robe(pc, items)
      items << pc.inventory.add_item("GM", 15896, 1, pc, nil) # Cyclic Cane
    when ClassId::ARCANA_LORD
      add_light_armor(pc, items)
      items << pc.inventory.add_item("GM", 15877, 1, pc, nil) # Eversor Mace
      items << pc.inventory.add_item("GM", 15587, 1, pc, nil) # Elegia Shield
    when ClassId::CARDINAL
      add_robe(pc, items)
      items << pc.inventory.add_item("GM", 15892, 1, pc, nil) # Sacredium
      items << pc.inventory.add_item("GM", 15588, 1, pc, nil) # Elegia Sigil
    when ClassId::HIEROPHANT
      add_heavy_armor(pc, items)
      items << pc.inventory.add_item("GM", 15903, 1, pc, nil) # Recurve Thorne Bow
      items << pc.inventory.add_item("GM", 1345, 2000, pc, nil) # Shining Arrow
    when ClassId::EVA_TEMPLAR
      add_heavy_armor(pc, items)
      items << pc.inventory.add_item("GM", 15587, 1, pc, nil) # Elegia Shield
      items << pc.inventory.add_item("GM", 15872, 1, pc, nil) # Eternal Core Sword
    when ClassId::SWORD_MUSE
      add_heavy_armor(pc, items)
      items << pc.inventory.add_item("GM", 15587, 1, pc, nil) # Elegia Shield
      items << pc.inventory.add_item("GM", 15872, 1, pc, nil) # Eternal Core Sword
    when ClassId::WIND_RIDER
      add_light_armor(pc, items)
      items << pc.inventory.add_item("GM", 16156, 1, pc, nil) # Mamba Edge Dual Daggers
    when ClassId::MOONLIGHT_SENTINEL
      add_light_armor(pc, items)
      items << pc.inventory.add_item("GM", 15903, 1, pc, nil) # Recurve Thorne Bow
      items << pc.inventory.add_item("GM", 1345, 2000, pc, nil) # Shining Arrow
    when ClassId::MYSTIC_MUSE
      add_robe(pc, items)
      items << pc.inventory.add_item("GM", 15892, 1, pc, nil) # Sacredium
      items << pc.inventory.add_item("GM", 15588, 1, pc, nil) # Elegia Sigil
    when ClassId::ELEMENTAL_MASTER
      add_robe(pc, items)
      items << pc.inventory.add_item("GM", 15896, 1, pc, nil) # Cyclic Cane
    when ClassId::EVA_SAINT
      add_robe(pc, items)
      items << pc.inventory.add_item("GM", 15892, 1, pc, nil) # Sacredium
      items << pc.inventory.add_item("GM", 15588, 1, pc, nil) # Elegia Sigil
    when ClassId::SHILLIEN_TEMPLAR
      add_heavy_armor(pc, items)
      items << pc.inventory.add_item("GM", 15587, 1, pc, nil) # Elegia Shield
      items << pc.inventory.add_item("GM", 15872, 1, pc, nil) # Eternal Core Sword
    when ClassId::SPECTRAL_DANCER
      add_heavy_armor(pc, items)
      items << pc.inventory.add_item("GM", 16158, 1, pc, nil) # Eternal Dual Core Sword
    when ClassId::GHOST_HUNTER
      add_light_armor(pc, items)
      items << pc.inventory.add_item("GM", 16156, 1, pc, nil) # Mamba Edge Dual Daggers
    when ClassId::GHOST_SENTINEL
      add_light_armor(pc, items)
      items << pc.inventory.add_item("GM", 15903, 1, pc, nil) # Recurve Thorne Bow
      items << pc.inventory.add_item("GM", 1345, 2000, pc, nil) # Shining Arrow
    when ClassId::STORM_SCREAMER
      add_robe(pc, items)
      items << pc.inventory.add_item("GM", 15896, 1, pc, nil) # Cyclic Cane
    when ClassId::SPECTRAL_MASTER
      add_robe(pc, items)
      items << pc.inventory.add_item("GM", 15896, 1, pc, nil) # Cyclic Cane
    when ClassId::SHILLIEN_SAINT
      add_robe(pc, items)
      items << pc.inventory.add_item("GM", 15892, 1, pc, nil) # Sacredium
      items << pc.inventory.add_item("GM", 15588, 1, pc, nil) # Elegia Sigil
    when ClassId::TITAN
      add_heavy_armor(pc, items)
      items << pc.inventory.add_item("GM", 15881, 1, pc, nil) # Contristo Hammer
    when ClassId::GRAND_KHAVATARI
      add_light_armor(pc, items)
      items << pc.inventory.add_item("GM", 15887, 1, pc, nil) # Jade Claw
    when ClassId::DOMINATOR
      add_robe(pc, items)
      items << pc.inventory.add_item("GM", 15892, 1, pc, nil) # Sacredium
      items << pc.inventory.add_item("GM", 15588, 1, pc, nil) # Elegia Sigil
    when ClassId::DOOMCRYER
      add_heavy_armor(pc, items)
      items << pc.inventory.add_item("GM", 15877, 1, pc, nil) # Eversor Mace
      items << pc.inventory.add_item("GM", 15587, 1, pc, nil) # Elegia Shield
    when ClassId::FORTUNE_SEEKER
      add_heavy_armor(pc, items)
      items << pc.inventory.add_item("GM", 16156, 1, pc, nil) # Mamba Edge Dual Daggers
    when ClassId::MAESTRO
      add_heavy_armor(pc, items)
      items << pc.inventory.add_item("GM", 15881, 1, pc, nil) # Contristo Hammer
    when ClassId::MALE_SOULHOUND, ClassId::FEMALE_SOULHOUND, ClassId::JUDICATOR
      add_light_armor(pc, items)
      items << pc.inventory.add_item("GM", 15905, 1, pc, nil) # Heavenstare Rapier
    when ClassId::TRICKSTER
      add_light_armor(pc, items)
      items << pc.inventory.add_item("GM", 15912, 1, pc, nil) # Thorne Crossbow
      items << pc.inventory.add_item("GM", 9637, 2000, pc, nil) # Shining Arrow
    when ClassId::DOOMBRINGER
      add_light_armor(pc, items)
      items << pc.inventory.add_item("GM", 15907, 1, pc, nil) # Pyseal Blade
    end

    items << pc.inventory.add_item("GM", 21720, 1, pc, nil) # Soul Cloak of Freya

    items.each do |item|
      pc.inventory.equip_item(item) if item
    end

    pc.inventory.items.each do |item|
      if item.weapon? || item.armor?
        item.enchant_level = 8
      end

      if item.item_id == 15717 || item.item_id == 15718
        unless item.equipped?
          pc.inventory.equip_item(item)
        end
      end
    end

    pc.broadcast_user_info

    old_target = pc.target
    pc.target = pc
    pc.broadcast_packet(MagicSkillUse.new(pc, 5103, 1, 1000, 0))
    pc.target = old_target
  end

  private def add_heavy_armor(pc, items)
    items2 = {
      pc.inventory.add_item("GM", 15575, 1, pc, nil), # Elegia Breastplate
      pc.inventory.add_item("GM", 15578, 1, pc, nil), # Elegia Gaiters
      pc.inventory.add_item("GM", 15572, 1, pc, nil), # Elegia Helmet
      pc.inventory.add_item("GM", 15581, 1, pc, nil), # Elegia Gauntlet
      pc.inventory.add_item("GM", 15584, 1, pc, nil)  # Elegia Boots
    }
    items.concat(items2)
  end

  private def add_light_armor(pc, items)
    items2 = {
      pc.inventory.add_item("GM", 15576, 1, pc, nil), # Elegia Leather Breastplate
      pc.inventory.add_item("GM", 15579, 1, pc, nil), # Elegia Leather Legging
      pc.inventory.add_item("GM", 15573, 1, pc, nil), # Elegia Leather Helmet
      pc.inventory.add_item("GM", 15582, 1, pc, nil), # Elegia Leather Gloves
      pc.inventory.add_item("GM", 15585, 1, pc, nil)  # Elegia Leather Boots
    }
    items.concat(items2)
  end

  private def add_robe(pc, items)
    items2 = {
      pc.inventory.add_item("GM", 15577, 1, pc, nil), # Elegia Tunic
      pc.inventory.add_item("GM", 15580, 1, pc, nil), # Elegia Stockings
      pc.inventory.add_item("GM", 15574, 1, pc, nil), # Elegia Circlet
      pc.inventory.add_item("GM", 15583, 1, pc, nil), # Elegia Gloves
      pc.inventory.add_item("GM", 15586, 1, pc, nil)  # Elegia Shoes
    }
    items.concat(items2)
  end

  private def send_skill_info
    return unless pc = active_char
    unless target = pc.target.as?(L2Npc)
      target = pc.target.as?(L2PcInstance) || pc
      p target.skills
      return
    end

    html = String.build do |io|
      io.puts "<html><title>AI skill list</title><body>"
      AISkillScope.each do |scope|
        skills = target.template.get_ai_skills(scope).join(", ")
        io.puts "#{scope}: #{skills}<br1>"
      end
      io.puts "</body></html>"
    end
    msg = NpcHtmlMessage.new(html)
    pc.send_packet(msg)
  end

  private def pc
    active_char.not_nil!
  end

  private def args
    @command.split(' ')[1..-1]
  end
end
