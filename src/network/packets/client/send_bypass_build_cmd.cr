class Packets::Incoming::SendBypassBuildCMD < GameClientPacket
  no_action_request

  private GM_MESSAGE = 9
  private ANNOUNCEMENT = 10

  @command = ""

  private def read_impl
    @command = s.strip
  end

  private def run_impl
    return unless pc = active_char
    return unless run_custom_cmd(pc) == :proceed

    command = "admin_" + @command[/^(\S)+/]

    unless handler = AdminCommandHandler[command]
      if pc.gm?
        pc.send_message("The command #{command.from(6)} does not exist.")
      end

      return
    end

    unless AdminData.has_access?(command, pc.access_level)
      pc.send_message("You don't have the access right to use this command")
      warn { "#{pc} tried to use admin command #{command} without the proper access level." }
      return
    end

    if Config.gmaudit
      GMAudit.log("#{pc.name} [#{pc.l2id}]", @command, pc.target.try &.name || "no-target")
      debug { "#{pc} used command '#{command}'." }
    end

    handler.use_admin_command("admin_" + @command, pc)
  end

  private def run_custom_cmd(pc)
    case @command
    when "save"
      pc.store_me
    when "save_all"
      L2World.players.each &.store_me
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
    when "rush"
      rush
    when "skills"
      send_skill_info
    when /^get_ch\s\d+$/
      ClanHallManager.set_owner(args[0].to_i, pc.clan.not_nil!) if pc.clan
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
      send_packet(ClientSetTime::STATIC_PACKET)
    when /^milk\s\d+$/
      milk_target
    when "aspir"
      aspir(999999)
    when /^clan_level\s\d$/
      pc.clan.try &.level = args.first.to_i
    when /^uplift\s.*/
      uplift_target
    when "cancel"
      char_target.stop_all_effects
    when "cleanse"
      char_target.effect_list.stop_all_debuffs
    when "reuse"
      reset_skill_reuse
    when /^ivar\s\S+$/
      print_ivar
    when /^spawn2\s\d+$/
      spawn_npc
    when /^spawn2\s(\w\s?)+$/
      spawn_npc_by_name
    when /^goto_npc\s.+$/
      goto_npc
    when "interrupt"
      if target = pc.target.as?(L2Character)
        target.abort_cast
        target.abort_attack
      end
    when "recall_bots"
      L2World.players.each do |player|
        if player.name.starts_with?("bot") && player != pc
          player.tele_to_location(pc, true)
        end
      end
    when "bots_follow"
      pc.known_list.known_players.values_slice.each do |player|
        player.set_intention(AI::FOLLOW, pc)
      end
    when "bots_stop"
      pc.known_list.known_players.values_slice.each do |player|
        player.stop_move(nil)
        player.intention = AI::IDLE
      end
    when "bots_attack"
      pc.known_list.known_players.values_slice.each do |player|
        if target = pc.target.as?(L2Character)
          player.set_intention(AI::ATTACK, target)
        end
      end
    when "bots_come"
      pc.known_list.known_players.values_slice.each do |player|
        if target = pc.target.as?(L2Character)
          player.set_intention(AI::MOVE_TO, pc)
        end
      end
    when "champion"
      toggle_champ_target
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
      pc.party.try &.each { |m| m.tele_to_location(pc, true) if m != pc }
    when /start_quest\s\d+/
      id = args[0].to_i
      if q = QuestManager.get_quest(id)
        state = q.new_quest_state(pc)
        state.start_quest
        pc.send_message("Started quest '#{q.descr}'.")
      else
        pc.send_message("Quest with id #{id} not found.")
      end
    else
      return :proceed
    end

    nil
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

  private def rush
    if pc.moving?
      dst = Location.new(pc.x_destination, pc.y_destination, pc.z_destination)
      pc.broadcast_packet(FlyToLocation.new(pc, dst, FlyType::CHARGE))
      pc.set_xyz(pc.x_destination, pc.y_destination, pc.z_destination)
      pc.stop_move(nil)

      if summon = pc.summon
        summon.broadcast_packet(FlyToLocation.new(summon, dst, FlyType::CHARGE))
        summon.set_xyz(dst)
        summon.follow_owner
      end
    else
      pc.send_message("You need to be moving in order to rush.")
    end
  end

  private def milk_target
    pc = pc()
    unless target = pc.target.as?(L2Attackable)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end
    pc.target = nil
    times = args.first.to_i
    target.reduce_current_hp(target.max_hp - 1f64, pc, nil)
    case pc.class_id
    when .dwarven_fighter?, .scavenger?, .bounty_hunter?, .fortune_seeker?
      is_spoiler = true
    else
      # [automatically added else]
    end

    party = pc.party

    timer = Timer.new

    times.times do
      if is_spoiler
        target.spoiler_l2id = pc.l2id
      end

      target.do_die(pc)

      if is_spoiler
        target.take_sweep.try &.each do |item|
          if party
            party.distribute_item(pc, item, true, target)
          else
            pc.add_item("Admin milk", item, target, true)
          end
        end
      end

      target.do_revive
    end

    pc.send_message("Target milked #{times} times in #{timer} s.")
  end

  private def aspir(radius)
    pc = pc()
    radius = 1000 if radius == 0
    party = pc.party
    pc.known_list.known_objects.values_slice.each do |item|
      begin
        next unless item.is_a?(L2ItemInstance)
        if item.template.has_ex_immediate_effect? && item.etc_item?
          next
        end

        next unless Util.in_range?(radius, item, pc, true)
        old_region = item.world_region
        item.visible = false
        item.world_region = nil
        L2World.remove_visible_object(item, old_region)

        if item.id == Inventory::ADENA_ID && pc.inventory.adena_instance
          if party
            party.distribute_item(pc, item)
          else
            pc.add_adena("Pickup", item.count, nil, true)
            ItemTable.destroy_item("Pickup", item, pc, nil)
          end
        else
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

  private def reset_skill_reuse
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
      pc.send_message("No NPC with id #{npc_id} exists.")
      return
    end
    sp = L2Spawn.new(npc_id)
    sp.instance_id = pc.instance_id
    sp.heading = pc.heading
    sp.x, sp.y, sp.z = pc.xyz
    sp.stop_respawn

    sp.spawn_one(false)
  end

  private def spawn_npc_by_name
    name = args.join(' ')
    unless template = NpcData.templates.find &.name.casecmp?(name)
      pc.send_message("No NPC with name #{name} exists.")
      return
    end
    sp = L2Spawn.new(template.id)
    sp.instance_id = pc.instance_id
    sp.heading = pc.heading
    sp.x, sp.y, sp.z = pc.xyz
    sp.stop_respawn

    sp.spawn_one(false)
  end

  private def goto_npc
    name = args.join(' ')

    unless name.num?
      npc = L2World.objects.find do |obj|
        obj.as?(L2Npc).try &.name.try &.casecmp?(name)
      end
      unless npc
        name2 = name.downcase
        npc = L2World.objects.find do |obj|
          obj.as?(L2Npc).try &.name.try &.includes?(name2)
        end
      end
    end

    if npc.nil? && name.num?
      id = name.to_i
      npc = L2World.objects.find do |obj|
        obj.is_a?(L2Npc) && obj.id == id
      end
    end

    if npc
      pc.tele_to_location(npc)
    else
      pc.send_message("No npc with name or id '#{name}' was found.")
    end
  end

  private def follow_me
    if target = pc.target.as?(L2Character)
      target.running = true
      target.set_intention(AI::FOLLOW, pc)
    else
      pc.send_message("You don't have a target")
    end
  end

  private def stop
    if target = pc.target.as?(L2Character)
      target.running = false
      target.intention = AI::IDLE
    else
      pc.send_message("You don't have a target")
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
      if obj.is_a?(L2Npc) && (sp = obj.spawn?)
        obj.set_intention(AI::MOVE_TO, sp.location)
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
      pc.send_message("No class found for '#{id}'")
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
    pc.give_available_skills(true, true)

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
    else
      # [automatically added else]
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
    @command.split[1..-1]
  end
end
