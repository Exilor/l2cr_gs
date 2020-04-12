require "./l2_character"
require "./stat/npc_stat"
require "./status/npc_status"
require "./known_list/npc_known_list"
require "../l2_spawn"
require "../variables/npc_variables"
require "../../instance_managers/walking_manager"
require "../../instance_managers/town_manager"
require "../../task_managers/decay_task_manager"
require "./instance/l2_clan_hall_manager_instance"
require "./instance/l2_doormen_instance"

class L2Npc < L2Character
  INTERACTION_DISTANCE = 150
  RANDOM_ITEM_DROP_LIMIT = 70
  private MINIMUM_SOCIAL_INTERVAL = 6000

  @in_town = false
  @castle_index = -2
  @fort_index = -2
  @last_social_broadcast = 0i64
  @soulshot_amount = 0
  @spiritshot_amount = 0
  @shots_mask = 0
  @current_l_hand_id : Int32
  @current_r_hand_id : Int32
  @current_enchant : Int32
  @current_collision_height : Float64
  @current_collision_radius : Float64

  getter display_effect = 0
  setter auto_attackable : Bool = false
  property busy_message : String = ""
  property killing_blow_weapon : Int32 = 0
  property! summoned_npcs : IHash(Int32, L2Npc)?
  property! spawn : L2Spawn?
  property? busy : Bool = false
  property? random_animation_enabled : Bool = true
  property? talking : Bool = true
  property? decayed : Bool = false
  property? event_mob : Bool = false

  def initialize(template : L2NpcTemplate)
    super

    @current_l_hand_id = template.l_hand_id
    @current_r_hand_id = template.r_hand_id
    if Config.enable_random_enchant_effect
      @current_enchant = rand(4..21)
    else
      @current_enchant = template.weapon_enchant
    end
    @current_collision_height = template.f_collision_height
    @current_collision_radius = template.f_collision_radius
    self.flying = template.flying?

    template.skills.each_value do |skill|
      add_skill(skill)
    end

    init_char_status_update_values
  end

  def initialize(npc_id : Int32)
    initialize(NpcData[npc_id])
  end

  def instance_type : InstanceType
    InstanceType::L2Npc
  end

  def template : L2NpcTemplate
    super.as(L2NpcTemplate)
  end

  def id : Int32
    template.id
  end

  def name : String
    template.name
  end

  def show_name? : Bool
    template.show_name?
  end

  def targetable? : Bool
    template.targetable?
  end

  def can_move? : Bool
    template.can_move?
  end

  def ai_type : AIType
    template.ai_type
  end

  def dodge : Int32
    template.dodge
  end

  def chaos? : Bool
    template.chaos?
  end

  def level : Int32
    template.level.to_i32
  end

  ##############################################################################

  private def init_known_list
    @known_list = NpcKnownList.new(self)
  end

  def known_list : NpcKnownList
    super.as(NpcKnownList)
  end

  private def init_char_stat
    @stat = NpcStat.new(self)
  end

  private def init_char_status
    @status = NpcStatus.new(self)
  end

  ##############################################################################

  def auto_attackable?(char : L2Character) : Bool
    @auto_attackable
  end

  def send_info(pc : L2PcInstance)
    if visible_for?(pc)
      if Config.check_known && pc.gm?
        pc.send_message("Added NPC #{name}")
      end

      if run_speed == 0
        pc.send_packet(ServerObjectInfo.new(self, pc))
      else
        pc.send_packet(NpcInfo.new(self, pc))
      end
    end
  end

  def collision_height : Float64
    @current_collision_height
  end

  def collision_radius : Float64
    @current_collision_radius
  end

  def right_hand_item : Int32
    @current_r_hand_id
  end

  def left_hand_item : Int32
    @current_l_hand_id
  end

  def warehouse? : Bool
    false
  end

  def can_target?(pc : L2PcInstance) : Bool
    if pc.out_of_control?
      pc.action_failed
      return false
    elsif pc.locked_target? && pc.locked_target? != self
      pc.send_packet(SystemMessageId::FAILED_CHANGE_TARGET)
      pc.action_failed
      return false
    end

    true
  end

  def can_interact?(pc : L2PcInstance) : Bool
    return false if pc.casting_now? || pc.casting_simultaneously_now?
    return false if pc.dead? || pc.fake_death? || pc.sitting?
    return false unless pc.private_store_type.none?
    return false unless inside_radius?(pc, INTERACTION_DISTANCE, true, false)
    return false if pc.instance_id != instance_id && pc.instance_id != -1
    return false if @busy
    true
  end

  def in_town? : Bool
    if @castle_index < 0
      castle?
    end

    @in_town
  end

  def castle? : Castle?
    if @castle_index < 0
      if town = TownManager.get_town(*xyz)
        @castle_index = CastleManager.get_castle_index(town.tax_by_id)
      end

      if @castle_index < 0
        @castle_index = CastleManager.find_nearest_castle_index(self)
      else
        @in_town = true
      end
    end

    if @castle_index < 0
      return
    end

    CastleManager.castles[@castle_index]
  end

  def castle : Castle
    unless castle = castle?
      raise "No castle found for #{self}"
    end

    castle
  end

  def get_castle(max_dst : Int64) : Castle?
    idx = CastleManager.find_nearest_castle_index(self, max_dst)
    if idx < 0
      return
    end

    CastleManager.castles[idx]
  end

  def fort? : Fort?
    if @fort_index < 0
      if fort = FortManager.get_fort(*xyz)
        @fort_index = FortManager.get_fort_index(fort.residence_id)
      end

      if @fort_index < 0
        @fort_index = FortManager.find_nearest_fort_index(self)
      end
    end

    if @fort_index < 0
      return
    end

    FortManager.forts[@fort_index]
  end

  def fort : Fort
    unless fort = fort?
      raise "No fort found for #{self}"
    end

    fort
  end

  def get_fort(max_dst : Int64) : Fort?
    idx = FortManager.find_nearest_fort_index(self, max_dst)
    if idx < 0
      return
    end

    FortManager.forts[idx]
  end

  def my_lord?(pc : L2PcInstance) : Bool
    if (clan = pc.clan) && pc.clan_leader?
      castle_id = castle?.try &.residence_id || -1
      fort_id = fort?.try &.residence_id || -1
      return clan.castle_id == castle_id || clan.fort_id == fort_id
    end

    false
  end

  def conquerable_hall : SiegableHall?
    ClanHallSiegeManager.get_nearby_clan_hall(x, y, 10000)
  end

  def on_bypass_feedback(pc : L2PcInstance, command : String)
    # debug "L2Npc#on_bypass_feedback(#{pc}, #{command.inspect})"
    if busy? && busy_message.size > 0
      pc.action_failed
      html = NpcHtmlMessage.new(l2id)
      html.set_file(pc, "data/html/npcbusy.htm")
      html["%busymessage%"] = busy_message
      html["%npcname%"] = name
      html["%playername%"] = pc.name
      pc.send_packet(html)
    else
      if handler = BypassHandler[command]
        debug { "#{handler} will handle #{command.inspect}." }
        handler.use_bypass(command, pc, self)
      else
        warn { "Unknown NPC bypass #{command.inspect}." }
        if pc.gm?
          pc.send_message("Unknown NPC bypass #{command.inspect} (Npc id: #{id}).")
        end
      end
    end
  end

  def show_chat_window(pc : L2PcInstance)
    show_chat_window(pc, 0)
  end

  def show_chat_window(pc : L2PcInstance, file_name : String)
    html = NpcHtmlMessage.new(l2id)
    html.set_file(pc, file_name)
    html["%objectId%"] = l2id
    pc.send_packet(html)
    pc.action_failed
  end

  def show_chat_window(pc : L2PcInstance, val : Int32)
    unless talking?
      pc.action_failed
      return
    end
    if pc.cursed_weapon_equipped? && (!pc.target.is_a?(L2ClanHallManagerInstance) || !pc.target.is_a?(L2DoormenInstance))
      pc.target = pc
      return
    end

    if pc.karma > 0
      if !Config.alt_game_karma_player_can_shop && is_a?(L2MerchantInstance)
        if show_pk_deny_chat_window(pc, "merchant")
          return
        end
      elsif !Config.alt_game_karma_player_can_use_gk && is_a?(L2TeleporterInstance)
        if show_pk_deny_chat_window(pc, "teleporter")
          return
        end
      elsif !Config.alt_game_karma_player_can_use_warehouse && is_a?(L2WarehouseInstance)
        if show_pk_deny_chat_window(pc, "warehouse")
          return
        end
      end
    end

    return if template.type?("L2Auctioneer") && val == 0

    npc_id = template.id

    file_name = SevenSigns::SEVEN_SIGNS_HTML_PATH
    seal_avarice_owner = SevenSigns.get_seal_owner(SevenSigns::SEAL_AVARICE)
    seal_gnosis_owner = SevenSigns.get_seal_owner(SevenSigns::SEAL_GNOSIS)
    player_cabal = SevenSigns.get_player_cabal(pc.l2id)
    comp_winner = SevenSigns.cabal_highest_score

    case npc_id
    when 31127..31131
      file_name += "festival/dawn_guide.htm"
    when 31137..31141
      file_name += "festival/dusk_guide.htm"
    when 31092 # Black Marketeer of Mammon
      file_name += "blkmrkt_1.htm"
    when 31113 # Merchant of Mammon
      if Config.alt_strict_sevensigns
        case comp_winner
        when SevenSigns::CABAL_DAWN
          if player_cabal != comp_winner || player_cabal != seal_avarice_owner
            pc.send_packet(SystemMessageId::CAN_BE_USED_BY_DAWN)
            pc.action_failed
            return
          end
        when SevenSigns::CABAL_DUSK
          if player_cabal != comp_winner || player_cabal != seal_avarice_owner
            pc.send_packet(SystemMessageId::CAN_BE_USED_BY_DUSK)
            pc.action_failed
            return
          end
        else
          pc.send_packet(SystemMessageId::SSQ_COMPETITION_UNDERWAY)
          return
        end
      end

      file_name += "mammmerch_1.htm"
    when 31126 # Blacksmith of Mammon
      if Config.alt_strict_sevensigns
        case comp_winner
        when SevenSigns::CABAL_DAWN
          if player_cabal != comp_winner || player_cabal != seal_gnosis_owner
            pc.send_packet(SystemMessageId::CAN_BE_USED_BY_DAWN)
            pc.action_failed
            return
          end
        when SevenSigns::CABAL_DUSK
          if player_cabal != comp_winner || player_cabal != seal_gnosis_owner
            pc.send_packet(SystemMessageId::CAN_BE_USED_BY_DUSK)
            pc.action_failed
            return
          end
        else
          pc.send_packet(SystemMessageId::SSQ_COMPETITION_UNDERWAY)
          return
        end
      end

      file_name += "mammblack_1.htm"
    when 31132..31136, 31142..31146 # Festival Witches
      file_name += "festival/festival_witch.htm"
    when 31688
      if pc.noble?
        file_name = Olympiad::OLYMPIAD_HTML_PATH + "noble_main.htm"
      else
        file_name = get_html_path(npc_id, val)
      end
    when 31690, 31769..31772
      if pc.hero? || pc.noble?
        file_name = Olympiad::OLYMPIAD_HTML_PATH + "noble_main.htm"
      else
        file_name = get_html_path(npc_id, val)
      end
    when 36402
      if pc.olympiad_buff_count > 0
        if pc.olympiad_buff_count == Config.alt_oly_max_buffs
          file_name = Olympiad::OLYMPIAD_HTML_PATH + "olympiad_buffs.htm"
        else
          file_name = Olympiad::OLYMPIAD_HTML_PATH + "olympiad_5buffs.htm"
        end
      else
        file_name = Olympiad::OLYMPIAD_HTML_PATH + "olympiad_nobuffs.htm"
      end
    when 30298 # Blacksmith Pinter
      if pc.academy_member?
        file_name = get_html_path(npc_id, 1)
      else
        file_name = get_html_path(npc_id, val)
      end
    else
      if npc_id.between?(31865, 31918)
        if val == 0
          file_name += "rift/GuardianOfBorder.htm"
        else
          file_name += "rift/GuardianOfBorder-#{val}.htm"
        end
      elsif npc_id.between?(31093, 31094) || npc_id.between?(31172, 31201) || npc_id.between?(31239, 31254)
        return
      else
        file_name = get_html_path(npc_id, val)
      end
    end

    html = NpcHtmlMessage.new(l2id)
    html.set_file(pc, file_name)

    if is_a?(L2MerchantInstance)
      if Config.list_pet_rent_npc.includes?(npc_id)
        html["_Quest"] = "_RentPet\">Rent Pet</a><br><a action=\"bypass -h " \
          "npc_%objectId%_Quest"
      end
    end

    html["%objectId%"] = l2id
    html["%festivalMins%"] = SevenSignsFestival.time_to_next_festival_str

    pc.send_packet(html)
    pc.action_failed
  end

  def show_pk_deny_chat_window(pc : L2PcInstance, type : String)
    if html = HtmCache.get_htm(pc, "data/html/#{type}/#{id}-pk.htm")
      insert_l2id_and_show_chat_window(pc, html)
      pc.action_failed
      true
    else
      warn { "L2Npc#show_pk_deny_chat_window: #{type}/#{id}-pk not found." }
      false
    end
  end

  def insert_l2id_and_show_chat_window(pc : L2PcInstance, content : String)
    content = content.gsub("%objectId%") { l2id }
    pc.send_packet(NpcHtmlMessage.new(l2id, content))
  end

  def get_html_path(npc_id : Int32, val : Int32)
    if val == 0
      temp = "data/html/default/#{npc_id}.htm"
    else
      temp = "data/html/default/#{npc_id}-#{val}.htm"
    end

    if !Config.lazy_cache
      if HtmCache.includes?(temp)
        return temp
      else
        warn { "L2Npc#get_html_path(#{npc_id}, #{val}) HtmCache can't find \"#{temp}\"." }
      end
    else
      if HtmCache.loadable?(temp)
        return temp
      else
        warn { "L2Npc#get_html_path(#{npc_id}, #{val}) is not loadable." }
      end
    end

    "data/html/npcdefault.htm"
  end

  def exp_reward : Int64
    (level.to_i64.abs2 * template.exp_rate * Config.rate_xp).to_i64
  end

  def sp_reward : Int32
    (template.sp * Config.rate_sp).to_i32
  end

  def do_die(killer : L2Character?) : Bool
    return false unless super

    @current_l_hand_id = template.l_hand_id
    @current_r_hand_id = template.r_hand_id
    @current_enchant = template.weapon_enchant
    @current_collision_height = template.f_collision_height
    @current_collision_radius = template.f_collision_radius

    @killing_blow_weapon = killer.try &.active_weapon_item.try &.id || 0
    DecayTaskManager.add(self)

    true
  end

  def end_decay_task
    unless decayed?
      DecayTaskManager.cancel(self)
      on_decay
    end
  end

  def on_spawn
    super

    # works:
    @soulshot_amount = template.parameters.get_i32("SoulShot", 0)
    @spiritshot_amount = template.parameters.get_i32("SpiritShot", 0)
    # doesn't work:
    # @soulshot_amount = template.soulshot
    # @spiritshot_amount = template.spiritshot

    @killing_blow_weapon = 0

    if teleporting?
      OnNpcTeleport.new(self).async(self)
    else
      OnNpcSpawn.new(self).async(self)
    end

    unless teleporting?
      WalkingManager.on_spawn(self)
    end
  end

  def on_decay
    return if decayed?
    @decayed = true

    super

    @spawn.try &.decrease_count(self)

    WalkingManager.on_death(self)

    summoner = summoner()

    if summoner.is_a?(L2Npc)
      summoner.remove_summoned_npc(l2id)
    end
  end

  def delete_me : Bool
    begin
      on_decay
    rescue e
      error e
    end

    if channelized?
      skill_channelized.abort_channelization
    end

    if old_region = world_region
      old_region.remove_from_zones(self)
    end

    begin
      known_list.remove_all_known_objects
    rescue e
      error e
    end

    L2World.remove_object(self)

    super
  end

  def mob? : Bool # L2J wants to delete this
    false
  end

  def l_hand_id=(@current_l_hand_id : Int32)
    update_abnormal_effect
  end

  def r_hand_id=(@current_r_hand_id : Int32)
    update_abnormal_effect
  end

  def set_hand_id(@current_l_hand_id : Int32, @current_r_hand_id : Int32)
    update_abnormal_effect
  end

  def enchant=(@current_enchant : Int32)
    update_abnormal_effect
  end

  def enchant_effect : Int32
    @current_enchant
  end

  def collision_height=(@current_collision_height : Float64)
  end

  def collision_radius=(@current_collision_radius : Float64)
  end

  def schedule_despawn(delay : Int64)
    task = -> { delete_me unless decayed? }
    ThreadPoolManager.schedule_general(task, delay)
    self
  end

  def team=(team : Team)
    super
    broadcast_info
  end

  def notify_quest_event_skill_finished(skill : Skill, target : L2Object?)
    if target.is_a?(L2Playable) && (pc = target.acting_player)
      OnNpcSkillFinished.new(self, pc, skill).async(self)
    end
  end

  def movement_disabled? : Bool
    super || !can_move? || ai_type.corpse?
  end

  def display_effect=(val : Int32)
    if val != @display_effect
      @display_effect = val
      broadcast_packet(ExChangeNpcState.new(l2id, val))
    end
  end

  def color_effect : Int32
    0
  end

  def npc? : Bool
    true
  end

  def walker? : Bool
    WalkingManager.registered?(self)
  end

  def charged_shot?(shot : ShotType) : Bool
    @shots_mask & shot.mask == shot.mask
  end

  def set_charged_shot(shot : ShotType, charged : Bool)
    if charged
      @shots_mask |= shot.mask
    else
      @shots_mask &= ~shot.mask
    end
  end

  def recharge_shots(physical : Bool, magical : Bool)
    if @soulshot_amount > 0 || @spiritshot_amount > 0
      if physical
        if @soulshot_amount == 0 || Rnd.rand(100) > soulshot_chance
          return
        end

        @soulshot_amount -= 1
        packet = MagicSkillUse.new(self, self, 2154, 1, 0, 0)
        Broadcast.to_self_and_known_players_in_radius(self, packet, 600)
        set_charged_shot(ShotType::SOULSHOTS, true)
      end

      if magical
        if @spiritshot_amount == 0 || Rnd.rand(100) > spiritshot_chance
          return
        end

        @spiritshot_amount -= 1
        packet = MagicSkillUse.new(self, self, 2061, 1, 0, 0)
        Broadcast.to_self_and_known_players_in_radius(self, packet, 600)
        set_charged_shot(ShotType::SPIRITSHOTS, true)
      end
    end
  end

  def get_point_in_range(min : Int32, max : Int32) : Location
    if max == 0 || max < min
      return Location.new(x(), y(), z)
    end

    radius = Rnd.rand(min..max)
    angle = Rnd.rand * 2 * Math::PI


    x = x() + (radius * Math.cos(angle))
    y = y() + (radius * Math.sin(angle))
    Location.new(x.to_i32, y.to_i32, z)
  end

  def drop_item(pc : L2PcInstance, item : ItemHolder) : L2ItemInstance?
    drop_item(pc, item.id, item.count)
  end

  def drop_item(pc : L2PcInstance, item_id : Int32, count : Int64) : L2ItemInstance?
    item = nil

    count.times do |i|
      new_x = x + Rnd.rand((RANDOM_ITEM_DROP_LIMIT * 2) + 1) - RANDOM_ITEM_DROP_LIMIT
      new_y = y + Rnd.rand((RANDOM_ITEM_DROP_LIMIT * 2) + 1) - RANDOM_ITEM_DROP_LIMIT
      new_z = z + 20

      unless ItemTable[item_id]?
        warn { "Item #{item_id} doesn't exist." }
        return
      end

      unless item = ItemTable.create_item("Loot", item_id, count, pc, self)
        return
      end

      if pc
        item.drop_protection.protect(pc)
      end

      item.drop_me(self, new_x, new_y, new_z)

      unless Config.list_protected_items.includes?(item_id)
        herb = item.template.has_ex_immediate_effect?
        if (Config.autodestroy_item_after > 0 && !herb) || (Config.herb_auto_destroy_time > 0 && herb)
          ItemsAutoDestroy.add_item(item)
        end
      end

      item.protected = false

      # If stackable, end loop as entire count is included in 1 instance of item
      if item.stackable? || !Config.multiple_item_drop
        break
      end
    end

    item
  end

  def visible_for?(pc : L2PcInstance) : Bool
    if has_listener?(EventType::ON_NPC_CAN_BE_SEEN)
      evt = OnNpcCanBeSeen.new(self, pc)
      if term = EventDispatcher.notify(evt, self)
        return term.terminate
      end
    end

    super
  end

  def summoned_npcs : Enumerable(L2Npc)
    @summoned_npcs.try &.local_each_value || Slice(L2Npc).empty
  end

  def add_summoned_npc(npc : L2Npc)
    temp = @summoned_npcs || sync do
      @summoned_npcs ||= Concurrent::Map(Int32, L2Npc).new
    end
    temp[npc.l2id] = npc
    npc.summoner = self
  end

  def remove_summoned_npc(id : Int32)
    @summoned_npcs.try &.delete(id)
  end

  def get_summoned_npcs(id : Int32) : L2Npc?
    @summoned_npcs.try &.[id]?
  end

  def summoned_npc_count : Int32
    @summoned_npcs.try &.size || 0
  end

  def reset_summoned_npcs
    @summoned_npcs.try &.clear
  end

  def on_random_animation(id : Int32)
    now = Time.ms
    if now - @last_social_broadcast > MINIMUM_SOCIAL_INTERVAL
      @last_social_broadcast = now
      broadcast_packet(SocialAction.new(l2id, id.to_i))
    end
  end

  def start_random_animation_timer
    return unless has_random_animation?

    min = mob? ? Config.min_monster_animation : Config.min_npc_animation
    max = mob? ? Config.max_monster_animation : Config.max_npc_animation

    delay = Rnd.rand(min..max) * 1000

    task = RandomAnimationTask.new(self)
    ThreadPoolManager.schedule_general(task, delay)
  end

  def has_random_animation? : Bool
    Config.max_npc_animation > 0 &&
    @random_animation_enabled &&
    !ai_type.corpse?
  end

  def aggressive? : Bool
    false
  end

  def in_my_clan?(npc : L2Npc) : Bool
    template.clan?(npc.template.clans)
  end

  def undead? : Bool
    template.race.undead?
  end

  def update_abnormal_effect
    known_list.known_players.each_value do |pc|
      next unless visible_for?(pc)

      if run_speed == 0
        pc.send_packet(ServerObjectInfo.new(self, pc))
      else
        pc.send_packet(NpcInfo.new(self, pc))
      end
    end
  end

  def aggro_range : Int32
    if has_ai_value?("aggroRange")
      get_ai_value("aggroRange")
    else
      template.aggro_range
    end
  end

  def get_ai_value(name : String) : Int32
    if has_ai_value?(name)
      return NpcPersonalAIData.get_ai_value(spawn.name.not_nil!, name).not_nil!
    end

    -1
  end

  def has_ai_value?(param_name : String) : Bool
    return false unless sp = @spawn
    return false unless sp_name = sp.name
    NpcPersonalAIData.has_ai_value?(sp_name, param_name)
  end

  def in_my_spawn_group?(npc : L2Npc) : Bool
    return false unless sp = spawn?
    !npc.spawn?.nil? && !sp.name.nil? && sp.name == npc.spawn.name
  end

  def stays_in_spawn_loc? : Bool
    return false unless sp = spawn?
    sp.get_x(self) == x && sp.get_y(self) == y
  end

  def has_skill_chance? : Bool
    min = template.min_skill_chance
    max = template.max_skill_chance
    Rnd.rand(100) < Rnd.rand(min..max)
  end

  private struct RandomAnimationTask
    initializer npc : L2Npc

    def call
      if @npc.mob?
        return unless @npc.intention.active?
      else
        return unless @npc.in_active_region?
      end

      unless @npc.dead? || @npc.stunned? || @npc.sleeping? || @npc.paralyzed?
        @npc.on_random_animation(rand(2..3))
      end

      @npc.start_random_animation_timer
    end
  end

  def soulshot_chance : Int32
    template.soulshot_chance
  end

  def spiritshot_chance : Int32
    template.spiritshot_chance
  end

  def show_no_teach_html(pc : L2PcInstance)
    npc_id = id
    html = ""
    if is_a? L2WarehouseInstance
      html = HtmCache.get_htm("data/html/warehouse/#{npc_id}-noteach.htm")
    elsif is_a? L2TrainerInstance
      html = HtmCache.get_htm("data/html/trainer/#{npc_id}-noteach.htm")
      html ||= HtmCache.get_htm("scripts/ai/npc/Trainers/HealerTrainer/#{npc_id}-noteach.html")
    end

    no_teach_msg = NpcHtmlMessage.new(l2id)
    if html
      no_teach_msg.html = html
      no_teach_msg["%objectId%"] = l2id
    else
      no_teach_msg.html = "<html><body>I cannot teach you any skills.<br>You must find your current class teachers.</body></html>"
    end

    pc.send_packet(no_teach_msg)
  end

  def long_range_skills : Indexable(Skill)
    template.get_ai_skills(AISkillScope::LONG_RANGE)
  end

  def short_range_skills : Indexable(Skill)
    template.get_ai_skills(AISkillScope::SHORT_RANGE)
  end

  def broadcast_event(event_name : String, radius : Int32, reference : L2Object?)
    L2World.get_visible_objects(self, radius) do |obj|
      if obj.is_a?(L2Npc) && obj.has_listener?(EventType::ON_NPC_EVENT_RECEIVED)
        OnNpcEventReceived.new(event_name, self, obj, reference).async(obj)
      end
    end
  end

  def send_script_event(event_name : String, receiver : L2Object, reference : L2Object?)
    evt = OnNpcEventReceived.new(event_name, self, receiver, reference)
    evt.async(receiver)
  end

  def variables : NpcVariables
    get_script(NpcVariables) || add_script(NpcVariables.new)
  end

  def has_variables? : Bool
    !!get_script(NpcVariables)
  end

  def script_value : Int32
    variables.get_i32("SCRIPT_VAL")
  end

  def script_value=(val : Int32)
    variables["SCRIPT_VAL"] = val
  end

  def script_value?(val : Int32) : Bool
    variables.get_i32("SCRIPT_VAL") == val
  end

  def active_weapon_instance : L2ItemInstance?
    # return nil
  end

  def active_weapon_item : L2Weapon?
    weapon_id = template.r_hand_id
    return if weapon_id < 1

    ItemTable[weapon_id].as?(L2Weapon)
  end

  def secondary_weapon_instance : L2ItemInstance?
    # return nil
  end

  def secondary_weapon_item : L2Weapon?
    weapon_id = template.l_hand_id
    return if weapon_id < 1

    ItemTable[weapon_id].as?(L2Weapon)
  end
end
