require "../l2_playable"
require "./l2_servitor_instance"
require "./l2_decoy_instance"
require "./l2_trap_instance"
require "./l2_tamed_beast_instance"
require "./l2_cubic_instance"
require "./l2_guard_instance"
require "./l2_control_tower_instance"
require "../l2_vehicle"
require "../../subclass"
require "../../shortcuts"
require "../../macro_list"
require "../../block_list"
require "../../l2_radar"
require "../../teleport_bookmark"
require "../../l2_manufacture_item"
require "../../l2_premium_item"
require "../../party_match_waiting_list"
require "../../fishing/l2_fishing"
require "../../variables/player_variables"
require "../../variables/account_variables"
require "../../entity/duel"
require "../stat/pc_stat"
require "../status/pc_status"
require "../known_list/pc_known_list"
require "../ai/l2_player_ai"
require "../transform"
require "../../item_containers/pc_inventory"
require "../../item_containers/pc_refund"
require "../../item_containers/pc_warehouse"
require "../../item_containers/pc_freight"
require "../../items/l2_henna"
require "../../../enums/duel_state"
require "../../../enums/mount_type"
require "../../../enums/private_store_type"
require "../../../enums/party_distribution_type"
require "../../../enums/clan_privilege"
require "../../../enums/html_action_scope"
require "../../holders/skill_use_holder"
require "../../holders/player_event_holder"
require "../../calendar"
require "../../l2_request"
require "../../interfaces/event_listener"
require "../../../util/enum_bitmask"
require "../../../instance_managers/duel_manager"
require "../../l2_party"
require "../../l2_clan"
require "../../l2_contact_list"
require "../../trade_list"
require "../../../recipe_controller"
require "../tasks/player/*"
require "../../quests/quest_state"
require "../../entity/l2_event"

class L2PcInstance < L2Playable
  extend Loggable

  ID_NONE = -1
  REQUEST_TIMEOUT = 15
  private FALLING_VALIDATION_DELAY = 10_000
  private COND_OVERRIDE_KEY = "cond_override"

  @reco_bonus_task : TaskScheduler::DelayedTask?
  @reco_give_task : TaskScheduler::PeriodicTask?
  @subclass_lock = MyMutex.new
  @cur_weight_penalty = 0
  @last_compass_zone = 0
  @charges = Atomic(Int32).new(0)
  @souls = 0
  @silence_mode_excluded : Array(Int32)?
  @arrow_item : L2ItemInstance?
  @bolt_item : L2ItemInstance?
  @request_expire_time = 0i64
  @protect_end_time = 0i64
  @teleport_protect_end_time = 0i64
  @recent_fake_death_end_time = 0i64
  @last_html_action_origin_l2id = 0
  @html_action_origin_l2ids = Slice(Int32).new(HtmlActionScope.size)
  @html_action_caches = Slice(Array(String)).new(HtmlActionScope.size) { [] of String }
  @revive_requested = 0
  @revive_power = 0.0
  @revive_recovery = 0
  @cp_update_inc_check = 0.0
  @cp_update_dec_check = 0.0
  @cp_update_interval  = 0.0
  @mp_update_inc_check = 0.0
  @mp_update_dec_check = 0.0
  @mp_update_interval  = 0.0
  @falling_timestamp = 0i64
  @last_item_auction_info_request = 0i64
  @custom_skills : Interfaces::Map(Int32, Skill)?
  @action_mask = 0
  @can_feed = false
  @offline_shop_start = 0
  @in_duel = false
  @exchange_refusal = false
  @revive_pet = false
  @quests = Concurrent::Map(String, QuestState).new
  @water_task : TaskScheduler::PeriodicTask?
  @transform_skills : Interfaces::Map(Int32, Skill)?
  @vitality_task : TaskScheduler::PeriodicTask?
  @teleport_watchdog : TaskScheduler::DelayedTask?
  @soul_task : TaskScheduler::DelayedTask?
  @charge_task : TaskScheduler::DelayedTask?
  @task_warn_user_take_break : TaskScheduler::PeriodicTask?
  @pvp_reg_task : TaskScheduler::PeriodicTask?
  @notify_quest_of_death : Interfaces::Set(QuestState)?
  @dwarven_recipe_book = Concurrent::Map(Int32, L2RecipeList).new
  @common_recipe_book = Concurrent::Map(Int32, L2RecipeList).new
  @tamed_beasts : Interfaces::Set(L2TamedBeastInstance)?
  @warehouse : PcWarehouse?
  @snoop_listener = Concurrent::Set(L2PcInstance).new(1)
  @snooped_player = Concurrent::Set(L2PcInstance).new(1)
  @fish : L2Fish?
  @task_for_fish : TaskScheduler::PeriodicTask?
  @friends : Interfaces::Set(Int32)?
  @level_data : L2PetLevelData?
  @mount_feed_task : TaskScheduler::PeriodicTask?
  @dismount_task : TaskScheduler::DelayedTask?
  @rent_pet_task : TaskScheduler::PeriodicTask?
  @fame_task : TaskScheduler::PeriodicTask?
  @manufacture_items : Interfaces::Map(Int32, L2ManufactureItem)?
  @access_level : AccessLevel?
  @html_prefix : String?
  @sell_list : TradeList?
  @buy_list : TradeList?
  @loto = Slice(Int32).new(5)
  @race = Slice(Int32).new(2)
  @forum_mail : Forum?
  @forum_memo : Forum?

  getter henna_str = 0
  getter henna_dex = 0
  getter henna_con = 0
  getter henna_int = 0
  getter henna_wit = 0
  getter henna_men = 0
  getter appearance : PcAppearance
  getter event_listeners = Concurrent::Deque(EventListener).new
  getter online_time = 0i64
  getter online_begin_time = 0i64
  getter karma : Int32 = 0
  getter pvp_kills = 0
  getter pk_kills = 0
  getter fame = 0
  getter bookmark_slot = 0
  getter duel_id = 0
  getter mount_type = MountType::NONE
  getter mount_npc_id = 0
  getter mount_level = 0
  getter last_location = Location.new(0, 0, 0) # L2J: _lastLoc
  getter last_server_position = Location.new(0, 0, 0)
  getter recom_have = 0
  getter recom_left = 0
  getter private_store_type = PrivateStoreType::NONE
  getter store_name = ""
  getter clan_id = 0
  getter pledge_class = 0
  getter account_chars = {} of Int32 => String # L2J: _chars
  getter expertise_armor_penalty  = 0
  getter expertise_weapon_penalty = 0
  getter active_enchant_item_id = ID_NONE
  getter cubics = Concurrent::Map(Int32, L2CubicInstance).new
  getter active_shots = Concurrent::Set(Int32).new(1)
  getter soulshot_lock = MyMutex.new
  getter fish_x = 0
  getter fish_y = 0
  getter fish_z = 0
  getter multi_social_target = 0
  getter multi_social_action = 0
  getter not_move_until = 0i64
  getter engage_id = 0
  getter vehicle : L2Vehicle?
  getter current_skill : SkillUseHolder?
  getter current_pet_skill : SkillUseHolder?
  getter premium_item_list = Concurrent::Map(Int32, L2PremiumItem).new # L2J: _premiumItems
  getter fish_combat : L2Fishing?
  getter current_feed = 0
  getter account_name
  getter lang : String?
  getter tp_bookmarks = Concurrent::Map(Int32, TeleportBookmark).new
  getter(contact_list) { L2ContactList.new(self) }
  getter(subclasses) { Concurrent::Map(Int32, Subclass).new }
  getter(radar) { L2Radar.new(self) }
  getter(inventory) { PcInventory.new(self) }
  getter(freight) { PcFreight.new(self) }
  getter(refund) { PcRefund.new(self) }
  getter(request) { L2Request.new(self) }
  getter(block_list) { BlockList.new(self) }
  getter(shortcuts) { Shortcuts.new(self) }
  getter(macros) { MacroList.new(self) }
  getter clan : L2Clan?
  getter transformation : Transform?
  getter! ui_settings : UIKeysSettings
  getter? online = false
  getter? in_observer_mode = false # L2J: _observerMode
  getter? noble = false
  getter? hero = false
  getter? message_refusal = false
  getter? silence_mode = false
  getter? inventory_disabled = false
  getter? engage_request = false
  setter uptime : Int64 = 0i64
  setter can_revive : Bool = true
  setter active_requester : L2PcInstance?
  setter learning_class : ClassId?
  property original_cp_hp_mp : {Float64, Float64, Float64}?
  property base_class : Int32 = 0
  property create_date : Calendar = Calendar.new
  property delete_timer : Int64 = 0i64
  property last_access : Int64 = 0i64
  property newbie : Int32 = 0
  property active_class : Int32 = 0
  property class_index : Int32 = 0
  property exp_before_death : Int64 = 0i64
  property pvp_flag : Int8 = 0i8
  property siege_state : Int8 = 0i8
  property siege_side : Int32 = 0
  property olympiad_game_id : Int32 = -1
  property olympiad_side : Int32 = -1
  property olympiad_buff_count : Int32 = 0
  property duel_state : DuelState = DuelState::NO_DUEL
  property mount_l2id : Int32 = 0
  property tele_mode : Int32 = 0
  property offline_start_time : Int64 = 0i64 # L2J: _offlineShopStart
  property last_folk_npc : L2Npc?
  property last_quest_npc_l2id : Int32 = 0 # L2J: _questNpcObject
  property henna : Slice(L2Henna?) = Slice(L2Henna?).new(3)
  property agathion_id : Int32 = 0
  property party_room : Int32 = 0
  property apprentice : Int32 = 0
  property sponsor : Int32 = 0
  property clan_join_expiry_time : Int64 = 0i64
  property clan_create_expiry_time : Int64 = 0i64
  property power_grade : Int32 = 0
  property pledge_type : Int32 = 0
  property lvl_joined_academy : Int32 = 0
  property wants_peace : Int32 = 0
  property death_penalty_buff_level : Int32 = 0
  property party_distribution_type : PartyDistributionType = PartyDistributionType::FINDERS_KEEPERS # nil in L2J
  property expertise_penalty_bonus : Int32 = 0
  property active_enchant_support_item_id : Int32 = ID_NONE
  property active_enchant_attr_item_id : Int32 = ID_NONE
  property active_enchant_timestamp : Int64 = 0i64
  property block_checker_arena : Int8 = -1i8
  property cursed_weapon_equipped_id : Int32 = 0
  property client_x : Int32 = 0
  property client_y : Int32 = 0
  property client_z : Int32 = 0
  property client_heading : Int32 = 0
  property movie_id : Int32 = 0
  property pvp_flag_lasts : Int64 = 0i64
  property partner_id : Int32 = 0
  property couple_id : Int32 = 0
  property last_petition_gm_name : String?
  property summon : L2Summon?
  property decoy : L2Decoy?
  property trap : L2TrapInstance?
  property queued_skill : SkillUseHolder?
  property current_skill_world_position : Location?
  property active_trade_list : TradeList?
  property admin_confirm_cmd : String?
  property active_warehouse : ItemContainer?
  property multisell : Multisell::PreparedListContainer?
  property clan_privileges : EnumBitmask(ClanPrivilege) = EnumBitmask(ClanPrivilege).new
  property control_item_id : Int32 = 0
  property fists_weapon_item : L2Weapon?
  property client : GameClient?
  property party : L2Party?
  property in_vehicle_position : Location?
  property servitor_share : EnumMap(Stats, Float64)?
  property lure : L2ItemInstance?
  property event_status : PlayerEventHolder?
  property? sitting : Bool = false
  property? reco_two_hours_given : Bool = false
  property? enchanting : Bool = false
  property? in_crystallize : Bool = false
  property? in_craft_mode : Bool = false
  property? in_siege : Bool = false
  property? in_hideout_siege : Bool = false
  property? in_7s_dungeon : Bool = false
  property? minimap_allowed : Bool = false
  property? diet_mode : Bool = false
  property? trade_refusal : Bool = false
  property? fake_death : Bool = false
  property? married : Bool = false
  property? marry_request : Bool = false
  property? marry_accepted : Bool = false
  property? combat_flag_equipped : Bool = false # L2J: _combatFlagEquippedId
  property? fishing : Bool = false
  property? in_olympiad_mode : Bool = false
  property? olympiad_start : Bool = false
  property? charm_of_courage : Bool = false
  property? has_pet_items : Bool = false # L2J: _petItems, havePetInvItems()

  def initialize(l2id : Int32, class_id : Int32, @account_name : String, @appearance : PcAppearance)
    super(l2id, PlayerTemplateData[class_id])

    @appearance.owner = self

    ai # initializes AI

    start_vitality_task

    Formulas.add_funcs_to_new_player(self)

    init_char_status_update_values
    init_pc_status_update_values
  end

  def initialize(class_id : Int32, account : String, app : PcAppearance)
    initialize(IdFactory.next, class_id, account, app)
  end

  def instance_type : InstanceType
    InstanceType::L2PcInstance
  end

  def inventory? : PcInventory?
    @inventory
  end

  def flying_mounted? : Bool
    return false unless transformed?
    return false unless transformation = transformation()
    transformation.flying?
  end

  def self.create(class_id : Int32, account : String, name : String, app : PcAppearance) : L2PcInstance?
    pc = new(class_id, account, app)
    pc.name = name
    pc.base_class = pc.class_id
    pc.newbie = 1
    pc.recom_left = 20
    pc if GameDB.player.insert(pc)
  end

  def self.load(l2id : Int32) : L2PcInstance?
    unless pc = GameDB.player.load(l2id)
      return
    end

    GameDB.player.load_characters(pc)

    pc.inventory.restore
    pc.freight.restore

    unless Config.warehouse_cache
      pc.warehouse
    end

    GameDB.skill.load(pc)
    pc.macros.restore_me
    pc.shortcuts.restore_me
    GameDB.henna.load(pc)
    GameDB.teleport_bookmark.load(pc)
    GameDB.recipe_book.load(pc, true)

    if Config.store_recipe_shoplist
      GameDB.recipe_shop_list.load(pc)
    end

    GameDB.premium_item.load(pc)
    GameDB.item.load_pet_inventory(pc)
    pc.reward_skills
    GameDB.item_reuse.load(pc)
    if Config.store_skill_cooltime
      pc.restore_effects
    end
    if pc.current_hp < 0.5
      pc.dead = true
      pc.stop_hp_mp_regeneration
    end
    pc.pet = L2World.get_pet(pc.l2id)
    if smn = pc.summon
      smn.owner = pc
    end
    pc.refresh_overloaded
    pc.refresh_expertise_penalty
    GameDB.friend.load(pc)

    if Config.store_ui_settings
      pc.restore_ui_settings
    end

    if pc.gm?
      mask = pc.variables.get_i64(COND_OVERRIDE_KEY, PcCondOverride.mask)
      pc.override_cond = mask
    end

    pc
  rescue e
    error e
    nil
  end

  def delete_me
    clean_up
    store_me

    super
  end

  def clean_up
    sync do
      OnPlayerLogout.new(self).async(self)

      begin
        ZoneManager.get_zones(self) do |zone|
          zone.on_player_logout_inside(self)
        end
      rescue e
        error e
      end

      begin
        unless online?
          error "L2PcInstance#clean_up: #online? should have returned true"
        end
        set_online_status(false, true)
      rescue e
        error e
      end

      if Config.enable_block_checker_event && block_checker_arena != -1
        begin
          HandysBlockCheckerManager.on_disconnect(self)
        rescue e
          error e
        end
      end

      begin
        @online = false
        abort_attack
        abort_cast
        stop_move(nil)
        self.debugger = nil
      rescue e
        error e
      end

      begin
        if item = inventory.get_item_by_item_id(9819)
          if fort = FortManager.get_fort(self)
            FortSiegeManager.drop_combat_flag(self, fort.residence_id)
          else
            slot = inventory.get_slot_from_item(item)
            inventory.unequip_item_in_body_slot(slot)
            destroy_item("CombatFlag", item, nil, true)
          end
        elsif combat_flag_equipped?
          TerritoryWarManager.drop_combat_flag(self, false, false)
        end
      rescue e
        error e
      end

      begin
        PartyMatchWaitingList.remove_player(self)
        if @party_room != 0
          PartyMatchRoomList.get_room(@party_room).try &.delete_member(self)
        end
      rescue e
        error e
      end

      if flying?
        begin
          remove_skill(SkillData[4289, 1])
        rescue e
          error e
        end
      end

      begin
        store_recommendations
      rescue e
        error e
      end

      begin
        stop_all_timers
      rescue e
        error e
      end

      begin
        self.teleporting = false
      rescue e
        error e
      end

      begin
        RecipeController.request_make_item_abort(self)
      rescue e
        error e
      end

      begin
        self.target = nil
      rescue e
        error e
      end

      if channelized?
        skill_channelized.abort_channelization
      end

      effect_list.stop_all_toggles

      world_region.try &.remove_from_zones(self)

      begin
        decay_me
      rescue e
        error e
      end

      if in_party?
        begin
          leave_party
        rescue e
          error e
        end
      end

      if OlympiadManager.registered?(self) || olympiad_game_id != -1
        OlympiadManager.remove_disconnected_competitor(self)
      end

      if summon = @summon
        begin
          summon.restore_summon = true
          summon.unsummon(self)

          @summon.try &.broadcast_npc_info(0)
        rescue e
          error e
        end
      end

      if clan = clan()
        begin
          if mem = clan.get_clan_member(l2id)
            mem.player_instance = nil
          end
        rescue e
          error e
        end
      end

      if active_requester
        self.active_requester = nil
        cancel_active_trade
      end

      if gm?
        begin
          AdminData.delete_gm(self)
        rescue e
          error e
        end
      end

      begin
        if in_observer_mode?
          set_location_invisible(@last_location)
        end

        vehicle.try &.oust_player(self)
      rescue e
        error e
      end

      begin
        iid = instance_id
        if iid != 0 && !Config.restore_player_instance
          if inst = InstanceManager.get_instance(iid)
            inst.remove_player(l2id)
            if loc = inst.exit_loc
              x = loc.x + Rnd.rand(-30..30)
              y = loc.y + Rnd.rand(-30..30)
              set_xyz_invisible(x, y, loc.z)
              if smn = summon
                smn.tele_to_location(loc, true)
                smn.instance_id = 0
              end
            end
          end
        end
      rescue e
        error e
      end

      begin
        TvTEvent.on_logout(self)
      rescue e
        error e
      end

      begin
        inventory.delete_me
      rescue e
        error e
      end

      begin
        clear_warehouse
      rescue e
        error e
      end

      if Config.warehouse_cache
        WarehouseCache.delete(self)
      end

      begin
        freight.delete_me
      rescue e
        error e
      end

      begin
        clear_refund
      rescue e
        error e
      end

      if cursed_weapon_equipped?
        begin
          CursedWeaponsManager.get_cursed_weapon(@cursed_weapon_equipped_id).not_nil!.player = nil
        rescue e
          error e
        end
      end

      begin
        known_list.remove_all_known_objects
      rescue e
        error e
      end

      if clan_id > 0 && (clan = clan())
        lu = PledgeShowMemberListUpdate.new(self)
        clan.broadcast_to_other_online_members(lu, self)
      end

      @snooped_player.each &.remove_snooper(self)
      @snoop_listener.each &.remove_snooped(self)

      L2World.remove_object(self)
      L2World.remove_from_all_players(self)

      begin
        notify_friends
        block_list.player_logout
      rescue e
        error e
      end
    end
  end

  def store_me
    store(true)
  end

  def store(store_active_effects : Bool)
    sync do
      # GameDB.transaction do
        GameDB.player.store_char_base(self)
        GameDB.subclass.update(self)
        store_effect(store_active_effects)
        GameDB.item_reuse.insert(self)
        if Config.store_recipe_shoplist
          GameDB.recipe_shop_list.delete(self)
          GameDB.recipe_shop_list.insert(self)
        end
        if Config.store_ui_settings
          store_ui_settings
        end
        SevenSigns.instance.save_seven_signs_data(l2id)
        get_script(PlayerVariables).try &.store_me
        get_script(AccountVariables).try &.store_me
      # end
    end
  end

  def store_effect(store : Bool)
    unless Config.store_skill_cooltime
      return
    end

    # GameDB.transaction do
      GameDB.player_skill_save.delete(self)
      GameDB.player_skill_save.insert(self, store)
    # end
  end

  def restore_effects
    # GameDB.transaction do
      GameDB.player_skill_save.load(self)
      GameDB.player_skill_save.delete(self)
    # end
  end

  def restore_ui_settings
    @ui_settings = UIKeysSettings.new(l2id)
  end

  private def store_ui_settings
    if tmp = @ui_settings
      unless tmp.saved?
        tmp.save_in_db
      end
    end
  end

  def acting_player : L2PcInstance
    self
  end

  private def init_pc_status_update_values
    max_cp = max_cp().to_f
    max_mp = max_mp().to_f
    @cp_update_interval  = max_cp / MAX_BAR_PX
    @cp_update_inc_check = max_cp
    @cp_update_dec_check = max_cp - @cp_update_interval
    @mp_update_interval  = max_mp / MAX_BAR_PX
    @mp_update_inc_check = max_mp
    @mp_update_dec_check = max_mp - @mp_update_interval
  end

  private def init_ai : L2CharacterAI
    L2PlayerAI.new(self)
  end

  private def init_known_list
    @known_list = PcKnownList.new(self)
  end

  def known_list : PcKnownList
    super.as(PcKnownList)
  end

  private def init_char_stat
    @stat = PcStat.new(self)
  end

  def stat : PcStat
    super.as(PcStat)
  end

  private def init_char_status
    @status = PcStatus.new(self)
  end

  def status : PcStatus
    super.as(PcStatus)
  end

  def template : L2PcTemplate
    super.as(L2PcTemplate)
  end

  def name : String
    super.not_nil!
  end

  def name=(value : String)
    super

    if Config.cache_char_names
      CharNameTable.add_name(self)
    end
  end

  def manufacture_items
    @manufacture_items || sync do
      @manufacture_items ||= Concurrent::Map(Int32, L2ManufactureItem).new
    end
  end

  def race : Race
    if subclass_active?
      return PlayerTemplateData[@base_class].race
    end

    template.race
  end

  def class_id : ClassId
    template.class_id
  end

  def id : Int32
    template.class_id.to_i
  end

  def class_id=(id : Int32)
    # unless @subclass_lock.lock?
    #   return
    # end

    begin
      if lvl_joined_academy != 0 && @clan && PlayerClass[id].level.third?
        clan = clan().not_nil!
        if lvl_joined_academy <= 16
          clan.add_reputation_score(Config.join_academy_max_rep_score, true)
        elsif lvl_joined_academy >= 39
          clan.add_reputation_score(Config.join_academy_min_rep_score, true)
        else
          score = Config.join_academy_max_rep_score
          score -= (lvl_joined_academy - 16) * 20
          clan.add_reputation_score(score, true)
        end
      end

      @lvl_joined_academy = 0

      if subclass_active?
        subclasses[@class_index].class_id = id
      end

      self.target = self
      broadcast_packet(MagicSkillUse.new(self, 5103, 1, 1000, 0))
      self.class_template = id
      if class_id.level == 3
        send_packet(SystemMessageId::THIRD_CLASS_TRANSFER)
      else
        send_packet(SystemMessageId::CLASS_TRANSFER)
      end
      if party = party()
        party.broadcast_packet(PartySmallWindowUpdate.new(self))
      end
      clan.try &.broadcast_to_online_members(PledgeShowMemberListUpdate.new(self))
      reward_skills
      if !override_skill_conditions? && Config.decrease_skill_level
        check_player_skills
      end
    # ensure
      # @subclass_lock.unlock
    end
  end

  def class_template=(class_id : Int32)
    @active_class = class_id

    unless template = PlayerTemplateData[class_id]
      raise "Missing template for ClassId #{class_id}."
    end

    self.template = template

    OnPlayerProfessionChange.new(self, template, subclass_active?).async(self)
  end

  def base_class=(class_id : ClassId)
    @base_class = class_id.to_i
  end

  def recom_left=(val : Int32)
    @recom_left = val.clamp(0, 255)
  end

  def inc_recom_have
    if @recom_have < 255
      @recom_have &+= 1
    end
  end

  def recom_have=(value : Int32)
    @recom_have = value & 0xff
  end

  def dec_recom_left
    if @recom_left > 0
      @recom_left &-= 1
    end
  end

  def recom_bonus_time : Int32
    if task = @reco_bonus_task
      time = Time.ms_to_s(task.delay)
      return Math.max(time.to_i, 0)
    end

    0
  end

  def recom_bonus_type : Int32
    0
  end

  def in_party_match_room? : Bool
    @party_room > 0
  end

  def do_auto_loot(target : L2Attackable, item_id : Int32, item_count : Int64)
    if (party = party()) && !ItemTable[item_id].has_ex_immediate_effect?
      party.distribute_item(self, item_id, item_count, false, target)
    elsif item_id == Inventory::ADENA_ID
      add_adena("Loot", item_count, target, true)
    else
      add_item("Loot", item_id, item_count, target, true)
    end
  end

  def do_auto_loot(target : L2Attackable, item : ItemHolder)
    do_auto_loot(target, item.id, item.count)
  end

  def in_party? : Bool
    !!@party
  end

  def join_party(party : L2Party?)
    if party
      @party = party
      party.add_party_member(self)
    end
  end

  def leave_party
    if party = party()
      party.remove_party_member(self, L2Party::MessageType::Disconnected)
      @party = nil
    end
  end

  def give_recom(pc : L2PcInstance)
    pc.inc_recom_have
    dec_recom_left
  end

  def send_packet(gsp : GameServerPacket)
    @client.try &.send_packet(gsp)
  end

  def send_packet(id : SystemMessageId)
    sm = SystemMessage[id]
    send_packet(sm)
  end

  def send_message(msg : String)
    send_packet(SystemMessage.from_string(msg))
  end

  def send_html(html : String)
    send_packet(NpcHtmlMessage.new(html))
  end

  def broadcast_packet(gsp : GameServerPacket)
    unless gsp.is_a?(CharInfo)
      send_packet(gsp)
    end

    gsp.invisible = invisible?

    known_list.each_player do |pc|
      unless visible_for?(pc)
        next
      end

      pc.send_packet(gsp)

      if gsp.is_a?(CharInfo)
        relation = get_relation(pc)
        old_relation = known_list.known_relations[pc.l2id]?

        if old_relation && old_relation != relation
          rc = RelationChanged.new(self, relation, auto_attackable?(pc))
          pc.send_packet(rc)

          if smn = summon
            rc = RelationChanged.new(smn, relation, auto_attackable?(pc))
            pc.send_packet(rc)
          end
        end
      end
    end
  end

  def broadcast_packet(gsp : GameServerPacket, radius : Number)
    unless gsp.is_a?(CharInfo)
      send_packet(gsp)
    end

    gsp.invisible = invisible?

    known_list.each_player do |pc|
      if inside_radius?(pc, radius, false, false)
        pc.send_packet(gsp)

        if gsp.is_a?(CharInfo)
          relation = get_relation(pc)
          old_relation = known_list.known_relations[pc.l2id]?

          if old_relation && old_relation != relation
            rc = RelationChanged.new(self, relation, auto_attackable?(pc))
            pc.send_packet(rc)

            if smn = summon
              rc = RelationChanged.new(smn, relation, auto_attackable?(pc))
              pc.send_packet(rc)
            end
          end
        end
      end
    end
  end

  def get_relation(pc : L2PcInstance) : Int32
    rel = 0

    if clan = clan()
      rel |= RelationChanged::CLAN_MEMBER

      if clan == pc.clan
        rel |= RelationChanged::CLAN_MATE
      end

      if ally_id != 0
        rel |= RelationChanged::ALLY_MEMBER
      end
    end

    if clan_leader?
      rel |= RelationChanged::LEADER
    end

    party = party()

    if party && party == pc.party
      rel |= RelationChanged::HAS_PARTY

      case i = party.members.index(self)
      when 0
        rel |= RelationChanged::PARTYLEADER
      when 1
        rel |= RelationChanged::PARTY4
      when 2
        rel |= RelationChanged::PARTY3 + RelationChanged::PARTY2 + RelationChanged::PARTY1
      when 3
        rel |= RelationChanged::PARTY3 + RelationChanged::PARTY2
      when 4
        rel |= RelationChanged::PARTY3 + RelationChanged::PARTY1
      when 5
        rel |= RelationChanged::PARTY3
      when 6
        rel |= RelationChanged::PARTY2 + RelationChanged::PARTY1
      when 7
        rel |= RelationChanged::PARTY2
      when 8
        rel |= RelationChanged::PARTY1
      else
        raise "Wrong index for member in party: '#{i}'"
      end
    end

    if siege_state != 0
      if TerritoryWarManager.get_registered_territory_id(self) != 0
        rel |= RelationChanged::TERRITORY_WAR
      else
        rel |= RelationChanged::INSIEGE
        if siege_state != pc.siege_state
          rel |= RelationChanged::ENEMY
        else
          rel |= RelationChanged::ALLY
        end

        if siege_state == 1
          rel |= RelationChanged::ATTACKER
        end
      end
    end

    if clan && (pc_clan = pc.clan)
      if pc.pledge_type != L2Clan::SUBUNIT_ACADEMY
        if pledge_type != L2Clan::SUBUNIT_ACADEMY
          if pc_clan.at_war_with?(clan.id)
            rel |= RelationChanged::ONE_SIDED_WAR
            if clan.at_war_with?(pc_clan.id)
              rel |= RelationChanged::MUTUAL_WAR
            end
          end
        end
      end
    end

    if block_checker_arena != -1
      rel |= RelationChanged::INSIEGE
      holder = HandysBlockCheckerManager.get_holder(block_checker_arena)
      if holder.get_player_team(self) == 0
        rel |= RelationChanged::ENEMY
      else
        rel |= RelationChanged::ALLY
      end
      rel |= RelationChanged::ATTACKER
    end

    rel
  end

  protected def send_instance_update(instance : Instance, hide : Bool)
    start_time = ((Time.ms - instance.instance_start_time) / 1000).to_i32
    end_time = ((instance.instance_end_time - instance.instance_start_time) / 1000).to_i32
    if instance.timer_increase?
      ui = ExSendUIEvent.new(self, hide, true, start_time, end_time, instance.timer_text)
    else
      ui = ExSendUIEvent.new(self, hide, false, end_time - start_time, 0, instance.timer_text)
    end
    send_packet(ui)
  end

  def online_int : Int32
    if @online && (client = @client)
      return client.detached? ? 2 : 1
    end

    0
  end

  def set_online_status(online : Bool, update_db : Bool)
    @online = online if online != @online
    if update_db
      GameDB.player.update_online_status(self)
    end
  end

  def mail : Forum
    unless @forum_mail
      self.mail = ForumsBBSManager.get_forum_by_name("MailRoot").not_nil!
      .get_child_by_name(name)

      unless @forum_mail
        ForumsBBSManager.create_new_forum(
          name,
          ForumsBBSManager.get_forum_by_name("MailRoot"),
          Forum::MAIL,
          Forum::OWNERONLY,
          l2id
        )
        self.mail = ForumsBBSManager.get_forum_by_name("MailRoot").not_nil!
        .get_child_by_name(name)
      end
    end

    @forum_mail.not_nil!
  end

  def mail=(forum : Forum?)
    @forum_mail = forum
  end

  def memo : Forum
    unless @forum_memo
      self.mail = ForumsBBSManager.get_forum_by_name("MemoRoot").not_nil!
      .get_child_by_name(@account_name)

      unless @forum_memo
        ForumsBBSManager.create_new_forum(
          @account_name,
          ForumsBBSManager.get_forum_by_name("MemoRoot"),
          Forum::MEMO,
          Forum::OWNERONLY,
          l2id
        )
        self.mail = ForumsBBSManager.get_forum_by_name("MemoRoot").not_nil!
        .get_child_by_name(@account_name)
      end
    end

    @forum_memo.not_nil!
  end

  def memo=(forum : Forum?)
    @forum_memo = forum
  end

  def do_interact(char : L2Character?)
    if pc = char.as?(L2PcInstance)
      action_failed

      case pc.private_store_type
      when PrivateStoreType::SELL, PrivateStoreType::PACKAGE_SELL
        send_packet(PrivateStoreListSell.new(self, pc))
      when PrivateStoreType::BUY
        send_packet(PrivateStoreListBuy.new(self, pc))
      when PrivateStoreType::MANUFACTURE
        send_packet(RecipeShopSellList.new(self, pc))
      end
    elsif char
      char.on_action(self)
    end
  end

  def add_skill(new_skill : Skill) : Skill?
    add_custom_skill(new_skill)
    super
  end

  def add_skill(new_skill : Skill, store : Bool) : Skill?
    old_skill = add_skill(new_skill)

    if store
      store_skill(new_skill, old_skill, -1)
    end

    old_skill
  end

  def remove_skill(skill : Skill, store : Bool) : Skill?
    remove_custom_skill(skill)
    store ? remove_skill(skill) : super(skill, true)
  end

  def remove_skill(skill : Skill?, store : Bool, cancel_effect : Bool) : Skill?
    remove_custom_skill(skill)
    store ? remove_skill(skill) : super(skill, cancel_effect)
  end

  def remove_skill(skill : Skill?) : Skill?
    remove_custom_skill(skill)

    if old_skill = super(skill, true)
      GameDB.skill.delete(self, old_skill)
    end

    if transformation_id > 0 || cursed_weapon_equipped?
      return old_skill
    end

    if skill
      all_shortcuts.each do |sc|
        if sc.id == skill.id && sc.type.skill? && !skill.id.between?(3080, 3259)
          delete_shortcut(sc.slot, sc.page)
        end
      end
    end

    old_skill
  end

  private def store_skill(new_skill : Skill?, old_skill : Skill?, new_class_index : Int32)
    class_index = new_class_index > -1 ? new_class_index : @class_index
    if old_skill && new_skill
      GameDB.skill.update(self, class_index, new_skill, old_skill)
    elsif new_skill
      GameDB.skill.insert(self, class_index, new_skill)
    else
      warn "Could not store new skill because it's nil."
    end
  end

  def enable_skill(skill : Skill?)
    super
    remove_time_stamp(skill)
  end

  def check_do_cast_conditions(skill : Skill?) : Bool
    return false unless super
    return false if in_observer_mode?
    if in_olympiad_mode? && skill.blocked_in_olympiad?
      send_packet(SystemMessageId::THIS_SKILL_IS_NOT_AVAILABLE_FOR_THE_OLYMPIAD_EVENT)
      return false
    end

    if charges < skill.charge_consume || (in_airship? && !skill.has_effect_type?(EffectType::REFUEL_AIRSHIP))
      sm = SystemMessage.s1_cannot_be_used
      sm.add_skill_name(skill)
      send_packet(sm)
      return false
    end

    true
  end

  def add_custom_skill(skill : Skill?)
    if skill && skill.display_id != skill.id
      temp = @custom_skills ||= Concurrent::Map(Int32, Skill).new
      temp[skill.display_id] = skill
    end
  end

  def remove_custom_skill(skill : Skill?)
    if skill && skill.display_id != skill.id
      if temp = @custom_skills
        temp.delete(skill.display_id)
      end
    end
  end

  def remove_from_boss_zone
    GrandBossManager.zones.each_value &.remove_player(self)
  rescue e
    error e
  end

  def check_player_skills
    @skills.each do |id, skill|
      learn = SkillTreesData.get_class_skill(id, skill.level % 100, class_id)
      if learn
        lvl_diff = id == CommonSkill::EXPERTISE.id ? 0 : 9
        if level < learn.get_level &- lvl_diff
          decrease_skill_level(skill, lvl_diff)
        end
      end
    end
  end

  def decrease_skill_level(skill : Skill, lvl_diff : Int)
    next_level = -1
    skill_tree = SkillTreesData.get_complete_class_skill_tree(class_id)
    skill_tree.each_value do |sl|
      if sl.skill_id == skill.id && next_level < sl.skill_level
        if level >= sl.get_level &- lvl_diff
          next_level = sl.skill_level
        end
      end
    end

    if next_level == -1
      remove_skill(skill, true)
    else
      add_skill(SkillData[skill.id, next_level], true)
    end
  end

  def use_magic(skill : Skill, force : Bool, dont_move : Bool) : Bool
    if skill.passive?
      action_failed
      return false
    end

    if casting_now?
      current_skill = current_skill()
      if current_skill && skill.id == current_skill.skill_id
        # debug { "#use_magic(#{skill}, #{force}, #{dont_move}) aborted (a skill is being casted)." }
        action_failed
        return false
      elsif skill_disabled?(skill)
        action_failed
        return false
      end

      # debug { "#use_magic(#{skill}, #{force}, #{dont_move}) skill queued (char is casting)." }
      set_queued_skill(skill, force, dont_move)
      action_failed
      return false
    end

    self.casting_now = true
    set_current_skill(skill, force, dont_move)

    if queued_skill
      set_queued_skill(nil, false, false)
    end

    target = nil

    case skill.target_type
    when .aura?, .front_aura?, .behind_aura?, .ground?, .self?,
         .aura_corpse_mob?, .command_channel?, .aura_friendly?,
         .aura_undead_enemy?
      target = self
    else
      target = skill.get_first_of_target_list(self)
    end

    set_intention(AI::CAST, skill, target)

    true
  end

  private def check_use_magic_conditions(skill : Skill, force_use : Bool, dont_move : Bool) : Bool
    if out_of_control? || paralyzed? || stunned? || sleeping? || dead?
      action_failed
      return false
    end

    if fishing?
      unless skill.has_effect_type?(EffectType::FISHING, EffectType::FISHING_START)
        send_packet(SystemMessageId::ONLY_FISHING_SKILLS_NOW)
        return false
      end
    end

    if in_observer_mode?
      send_packet(SystemMessageId::OBSERVERS_CANNOT_PARTICIPATE)
      abort_cast
      action_failed
      return false
    end

    if sitting?
      send_packet(SystemMessageId::CANT_MOVE_SITTING)
      action_failed
      return false
    end

    if skill.toggle? && affected_by_skill?(skill.id) # should be after "if sitting?"
      stop_skill_effects(true, skill.id)
      action_failed
      return false
    end

    if fake_death?
      action_failed
      return false
    end

    target = nil
    target_type = skill.target_type

    pos = current_skill_world_position
    if target_type.ground? && pos.nil?
      action_failed
      return false
    end

    # debug "before target check"
    case target_type
    when .aura?, .front_aura?, .behind_aura?, .party?, .clan?, .party_clan?,
         .ground?, .self?, .area_summon?, .aura_corpse_mob?, .command_channel?,
         .aura_friendly?, .aura_undead_enemy?
      target = self
    when .pet?, .servitor?, .summon?
      target = summon
    else
      target = target()
    end

    unless target
      action_failed
      return false
    end

    if door = target.as?(L2DoorInstance)
      if door.castle? && door.castle.residence_id > 0
        unless door.castle.siege.in_progress?
          send_packet(SystemMessageId::INCORRECT_TARGET)
          return false
        end
      elsif door.fort? && door.fort.residence_id > 0
        if !door.fort.siege.in_progress? || !door.show_hp?
          send_packet(SystemMessageId::INCORRECT_TARGET)
          return false
        end
      end
    end

    if in_duel?
      pc = target.acting_player
      if pc && pc.duel_id != duel_id
        send_message("You cannot do this while duelling.")
        action_failed
        return false
      end
    end

    if skill_disabled?(skill)
      hash = skill.hash
      if has_skill_reuse?(hash)
        remaining_time = get_skill_remaining_reuse_time(hash) // 1000
        hours = remaining_time // 3600
        minutes = (remaining_time % 3600) // 60
        seconds = remaining_time % 60
        if hours > 0
          sm = SystemMessage.s2_hours_s3_minutes_s4_seconds_remaining_for_reuse_s1
          sm.add_skill_name(skill)
          sm.add_int(hours)
          sm.add_int(minutes)
        elsif minutes > 0
          sm = SystemMessage.s2_minutes_s3_seconds_remaining_for_reuse_s1
          sm.add_skill_name(skill)
          sm.add_int(minutes)
        else
          sm = SystemMessage.s2_seconds_remaining_for_reuse_s1
          sm.add_skill_name(skill)
        end
        sm.add_int(seconds)
      else
        sm = SystemMessage.s1_prepared_for_reuse
        sm.add_skill_name(skill)
      end

      send_packet(sm)
      return false
    end

    unless skill.check_condition(self, target, false)
      action_failed
      return false
    end

    if skill.bad?
      if inside_peace_zone?(self, target) && !access_level.allow_peace_attack?
        send_packet(SystemMessageId::TARGET_IN_PEACEZONE)
        action_failed
        return false
      end

      if in_olympiad_mode? && !olympiad_start?
        action_failed
        return false
      end

      pc_target = target.acting_player

      if pc_target && siege_state > 0 && inside_siege_zone?
        if pc_target.siege_state == siege_state
          if pc_target != self
            if pc_target.siege_side == siege_side
              if TerritoryWarManager.tw_in_progress?
                send_packet(SystemMessageId::YOU_CANNOT_ATTACK_A_MEMBER_OF_THE_SAME_TERRITORY)
              else
                send_packet(SystemMessageId::FORCED_ATTACK_IS_IMPOSSIBLE_AGAINST_SIEGE_SIDE_TEMPORARY_ALLIED_MEMBERS)
              end

              action_failed
              return false
            end
          end
        end
      end

      if !target.can_be_attacked? && !access_level.allow_peace_attack? && !target.door?
        action_failed
        return false
      end

      if target.is_a?(L2EventMonsterInstance)
        if target.block_skill_attack?
          return false
        end
      end

      if !target.auto_attackable?(self) && !force_use
        case target_type
        when .aura?, .front_aura?, .behind_aura?, .aura_corpse_mob?, .clan?,
          .party?, .self?, .ground?, .area_summon?, .unlockable?,
          .aura_friendly?, .aura_undead_enemy?
        else
          action_failed
          return false
        end
      end

      if dont_move
        if target_type.ground?
          pos = pos.not_nil!
          unless inside_radius?(*pos.xyz, skill.cast_range + template.collision_radius, false, false)
            send_packet(SystemMessageId::TARGET_TOO_FAR)
            action_failed
            return false
          end
        elsif skill.cast_range > 0
          unless inside_radius?(target, skill.cast_range + template.collision_radius, false, false)
            send_packet(SystemMessageId::TARGET_TOO_FAR)
            action_failed
            return false
          end
        end
      end
    end

    if skill.effect_point > 0 && target.monster? && !force_use
      action_failed
      return false
    end

    case target_type
    when .party?, .clan?, .party_clan?, .aura?, .front_aura?, .behind_aura?,
         .area_summon?, .ground?, .self?, .enemy?
      # do nothing
    else
      if target.playable? && !access_level.allow_peace_attack? && !check_pvp_skill(target, skill)
        send_packet(SystemMessageId::INCORRECT_TARGET)
        action_failed
        return false
      end
    end

    if skill.cast_range > 0
      if target_type.ground?
        unless GeoData.can_see_target?(self, pos)
          send_packet(SystemMessageId::CANT_SEE_TARGET)
          action_failed
          return false
        end
      elsif !GeoData.can_see_target?(self, target)
        send_packet(SystemMessageId::CANT_SEE_TARGET)
        action_failed
        return false
      end
    end

    if skill.fly_type? && !GeoData.can_move?(self, target)
      send_packet(SystemMessageId::THE_TARGET_IS_LOCATED_WHERE_YOU_CANNOT_CHARGE)
      return false
    end

    true
  end

  def check_pvp_skill(target : L2Object?, skill : Skill?) : Bool
    return false unless skill && target
    return true unless target.is_a?(L2Playable)

    if skill.debuff? || skill.has_effect_type?(EffectType::STEAL_ABNORMAL) || skill.bad?
      return false unless target_player = target.acting_player
      return false if self == target
      current_skill = current_skill()
      ctrl = !!current_skill && current_skill.ctrl?

      if target.inside_peace_zone?
        return false
      end

      if siege_state != 0 && target_player.siege_state != 0
        if siege_side == target_player.siege_side
          if siege_state == target_player.siege_state
            send_packet(SystemMessageId::FORCED_ATTACK_IS_IMPOSSIBLE_AGAINST_SIEGE_SIDE_TEMPORARY_ALLIED_MEMBERS)
            return false
          end
        end
      end

      if in_duel? && target_player.in_duel?
        if duel_id == target_player.duel_id
          return true
        end
      end

      if (party = party()) && (target_party = target_player.party)
        if party.leader == target_party.leader
          if skill.effect_range > 0 && ctrl && target() == target
            if skill.damage?
              return true
            end
          end

          return false
        elsif party.command_channel.try &.includes?(target_player)
          if skill.effect_range > 0 && ctrl && target() == target
            if skill.damage?
              return true
            end
          end

          return false
        end
      end

      if inside_pvp_zone? && target_player.inside_pvp_zone?
        return true
      end

      if in_olympiad_mode? && target_player.in_olympiad_mode?
        if olympiad_game_id == target_player.olympiad_game_id
          return true
        end
      end

      clan1, clan2 = clan, target_player.clan

      if clan1 && clan2
        if clan1.at_war_with?(clan2.id) && clan2.at_war_with?(clan1.id)
          if skill.aoe? && skill.effect_range > 0 && ctrl && target() == target
            return true
          end

          return ctrl
        elsif clan_id == target_player.clan_id || (ally_id > 0 && ally_id == target_player.ally_id)
          if skill.effect_range > 0 && ctrl && target() == target && skill.damage?
            return true
          end

          return false
        end
      end

      # Target player has a white name.
      if target_player.pvp_flag == 0 && target_player.karma == 0
        if skill.effect_range > 0 && ctrl && target() == target && skill.damage?
          return true
        end

        return false
      end

      if target_player.pvp_flag > 0 || target_player.karma > 0
        return true
      end

      return false
    end

    true
  end

  def set_current_skill(skill : Skill?, ctrl : Bool, shift : Bool)
    unless skill
      @current_skill = nil
      return
    end

    @current_skill = SkillUseHolder.new(skill, ctrl, shift)
  end

  def pet=(summon : L2Summon?)
    @summon = summon
  end

  def set_current_pet_skill(skill : Skill?, ctrl : Bool, shift : Bool)
    unless skill
      @current_pet_skill = nil
      return
    end

    @current_pet_skill = SkillUseHolder.new(skill, ctrl, shift)
  end

  def add_transform_skill(sk : Skill)
    unless @transform_skills
      sync { @transform_skills ||= Concurrent::Map(Int32, Skill).new }
    end

    @transform_skills.not_nil![sk.id] = sk

    if sk.passive?
      add_skill(sk, false)
    end
  end

  def get_transform_skill(id : Int32) : Skill?
    if tmp = @transform_skills
      tmp[id]?
    end
  end

  def has_transform_skill?(id : Int32) : Bool
    if tmp = @transform_skills
      return tmp.has_key?(id)
    end

    false
  end

  def remove_all_transform_skills
    @transform_skills = nil
  end

  def get_custom_skill(id : Int32) : Skill?
    if tmp = @custom_skills
      return tmp[id]?
    end

    nil
  end

  def reward_skills
    if Config.auto_learn_skills
      give_available_skills(Config.auto_learn_fs_skills, true)
    else
      give_available_auto_get_skills
    end

    check_player_skills
    check_item_restriction
    send_skill_list
  end

  def give_available_skills(fs : Bool, auto : Bool)
    count = 0
    skills = SkillTreesData.get_all_available_skills(self, class_id, fs, auto)
    skills_for_store = [] of Skill

    skills.each do |sk|
      next if get_known_skill(sk.id) == sk
      count &+= 1 if get_skill_level(sk.id) == -1

      if sk.toggle? && affected_by_skill?(sk.id)
        stop_skill_effects(true, sk.id)
      end

      add_skill(sk, false)
      skills_for_store << sk
    end

    GameDB.skill.insert(self, -1, skills_for_store)

    if Config.auto_learn_skills && count > 0
      send_message("You have learned #{count} new skills.")
    end

    count
  end

  def give_available_auto_get_skills
    SkillTreesData.get_available_auto_get_skills(self).each do |sk|
      if skill = SkillData[sk.skill_id, sk.skill_level]?
        add_skill(skill, true)
      end
    end
  end

  def regive_temporary_skills
    if noble?
      self.noble = true
    end

    if hero?
      self.hero = true
    end

    if clan = clan()
      clan.add_skill_effects(self)
      if clan.level >= SiegeManager.siege_clan_min_level && clan_leader?
        SiegeManager.add_siege_skills(self)
      end
      if clan.castle_id > 0
        CastleManager.get_castle_by_owner(clan).not_nil!.give_residential_skills(self)
      end
      if clan.fort_id > 0
        FortManager.get_fort_by_owner(clan).not_nil!.give_residential_skills(self)
      end
    end

    inventory.reload_equipped_items
    restore_death_penalty_buff_level
  end

  def check_item_restriction
    inv = inventory
    Inventory::TOTALSLOTS.times do |i|
      equipped_item = inv[i]
      if equipped_item && !equipped_item.template.check_condition(self, self, false)
        debug { "#{equipped_item} has failed the item restriction check." }
        inv.unequip_item_in_slot(i)

        send_packet(InventoryUpdate.modified(equipped_item))

        if equipped_item.template.body_part == L2Item::SLOT_BACK
          send_packet(SystemMessageId::CLOAK_REMOVED_BECAUSE_ARMOR_SET_REMOVED)
          return
        end

        if equipped_item.enchant_level > 0
          sm = SystemMessage.equipment_s1_s2_removed
          sm.add_int(equipped_item.enchant_level)
          sm.add_item_name(equipped_item)
        else
          sm = SystemMessage.s1_disarmed
          sm.add_item_name(equipped_item)
        end

        send_packet(sm)
      end
    end
  end

  def disarm_weapons : Bool
    return true unless wpn = inventory.rhand_slot
    return false if cursed_weapon_equipped?
    return false if combat_flag_equipped?
    return false if wpn.weapon_item!.force_equip?

    old = inventory.unequip_item_in_body_slot_and_record(wpn.template.body_part)
    if old.size == 1
      send_packet(InventoryUpdate.modified(old[0]))
    elsif old.size > 1
      iu = InventoryUpdate.new
      old.each { |i| iu.add_modified_item(i) }
      send_packet(iu)
    end

    abort_attack
    broadcast_user_info

    if old.size > 0
      item = old[0]
      if item.enchant_level > 0
        sm = SystemMessage.equipment_s1_s2_removed
        sm.add_int(item.enchant_level)
        sm.add_item_name(item)
      else
        sm = SystemMessage.s1_disarmed
        sm.add_item_name(item)
      end

      send_packet(sm)
    end

    true
  end

  def disarm_shield : Bool
    unless shld = inventory.lhand_slot
      return true
    end

    old = inventory.unequip_item_in_body_slot_and_record(shld.template.body_part)
    if old.size == 1
      send_packet(InventoryUpdate.modified(old.first))
    elsif old.size > 1
      iu = InventoryUpdate.new
      old.each { |i| iu.add_modified_item(i) }
      send_packet(iu)
    end

    abort_attack
    broadcast_user_info

    if old.size > 0
      item = old[0]
      if item.enchant_level > 0
        sm = SystemMessage.equipment_s1_s2_removed
        sm.add_int(item.enchant_level)
        sm.add_item_name(item)
      else
        sm = SystemMessage.s1_disarmed
        sm.add_item_name(item)
      end

      send_packet(sm)
    end

    true
  end

  def reviving_pet? : Bool
    @revive_pet
  end

  def remove_reviving
    @revive_equested = 0
    @revive_power = 0.0
  end

  def revive_requested? : Bool
    @revive_requested == 1
  end

  def in_party_with?(target : L2Character) : Bool
    in_party? && target.in_party? && party == target.party
  end

  def in_command_channel_with?(target : L2Character) : Bool
    return false unless party = party()
    return false unless target_party = target.party
    return false unless cc = party.command_channel
    return false unless target_cc = target_party.command_channel
    cc == target_cc
  end

  def at_war_with?(target : L2Character?) : Bool
    return false unless target
    return false if academy_member? || target.academy_member?
    return false unless (clan = clan()) && (target_clan = target.clan)
    clan.at_war_with?(target_clan)
  end

  def academy_member? : Bool
    @lvl_joined_academy > 0
  end

  def team=(team : Team)
    super

    broadcast_user_info
    summon.try &.broadcast_status_update
  end

  private def on_die_drop_item(killer : L2Character?)
    unless killer
      return
    end

    if L2Event.participant?(self)
      return
    end

    pk = killer.acting_player

    if karma <= 0 && pk && (pk_clan = pk.clan) && clan
      if pk_clan.at_war_with?(clan_id)
        return
      end
    end

    if (!inside_pvp_zone? || !pk) && (!gm? || Config.karma_drop_gm)
      karma_drop = false
      killer_npc = killer.is_a?(L2Npc)
      pk_limit = Config.karma_pk_limit

      drop_equip = 0
      drop_equip_weapon = 0
      drop_item = 0
      drop_limit = 0
      drop_percent = 0

      if karma > 0 && pk_kills >= pk_limit
        karma_drop = true
        drop_percent = Config.karma_rate_drop
        drop_equip = Config.karma_rate_drop_equip
        drop_equip_weapon = Config.karma_rate_drop_equip_weapon
        drop_item = Config.karma_rate_drop_item
        drop_limit = Config.karma_drop_limit
      elsif killer_npc && level > 4 && !festival_participant?
        karma_drop = true
        drop_percent = Config.player_rate_drop
        drop_equip = Config.player_rate_drop_equip
        drop_equip_weapon = Config.player_rate_drop_equip_weapon
        drop_item = Config.player_rate_drop_item
        drop_limit = Config.player_drop_limit
      end

      if drop_percent > 0 && Rnd.rand(100) < drop_percent
        drop_count = 0
        item_drop_percent = 0
        inventory.items.each do |i|
          if i.shadow_item? || i.time_limited_item? || !i.droppable? ||
            i.id == Inventory::ADENA_ID || i.template.type_2 == ItemType2::QUEST ||
            ((smn = summon) && smn.control_l2id == i.id) ||
            Config.karma_list_nondroppable_items.includes?(i.id) ||
            Config.karma_list_nondroppable_pet_items.includes?(i.id)

            next
          end

          if i.equipped?
            if i.template.type_2 == ItemType2::WEAPON
              item_drop_percent = drop_equip_weapon
            else
              item_drop_percent = drop_equip
            end
            inventory.unequip_item_in_slot(i.location_slot)
          else
            item_drop_percent = drop_item
          end

          if Rnd.rand(100) < item_drop_percent
            drop_item("DieDrop", i, killer, true)

            if karma_drop
              debug { "Dropped #{i} because he had karma." }
            else
              debug { "Dropped #{i}." }
            end

            drop_count &+= 1
            break if drop_count >= drop_limit
          end
        end
      end
    end
  end

  def calculate_death_penalty_buff_level(killer : L2Character?)
    unless killer
      return
    end

    if resurrect_special_affected? || lucky? || blocked_from_death_penalty? ||
      inside_pvp_zone? || inside_siege_zone? || override_death_penalty?

      return
    end

    percent = 1.0

    if killer.raid?
      percent *= calc_stat(Stats::REDUCE_DEATH_PENALTY_BY_RAID)
    elsif killer.monster?
      percent *= calc_stat(Stats::REDUCE_DEATH_PENALTY_BY_MOB)
    elsif killer.playable?
      percent *= calc_stat(Stats::REDUCE_DEATH_PENALTY_BY_PVP)
    end
    debug { "Death penalty chance: #{Config.death_penalty_chance * percent}%." }
    if Rnd.rand(1..100) <= Config.death_penalty_chance * percent
      debug { "!killer.playable? => #{!killer.playable?}, @karma > 0 => #{@karma > 0}." }
      if !killer.playable? || karma > 0
        increase_death_penalty_buff_level
      end
    end
  end

  def calculate_death_exp_penalty(killer : L2Character?, at_war : Bool)
    lvl = level
    percent_lost = PlayerXpPercentLostData[lvl]

    if killer
      if killer.raid?
        percent_lost *= calc_stat(Stats::REDUCE_EXP_LOST_BY_RAID)
      elsif killer.monster?
        percent_lost *= calc_stat(Stats::REDUCE_EXP_LOST_BY_MOB)
      elsif killer.playable?
        percent_lost *= calc_stat(Stats::REDUCE_EXP_LOST_BY_PVP)
      end
    end

    if karma > 0
      percent_lost *= Config.rate_karma_exp_lost
    end

    lost_exp = 0i64

    unless L2Event.participant?(self)
      if lvl < Config.max_player_level
        lost_exp = (((stat.get_exp_for_level(lvl &+ 1) - stat.get_exp_for_level(lvl)) * percent_lost) / 100).round
      else
        lost_exp = (((stat.get_exp_for_level(Config.max_player_level) - stat.get_exp_for_level(Config.max_player_level &- 1)) * percent_lost) / 100).round
      end
    end

    if festival_participant? || at_war
      lost_exp /= 4.0
    end

    self.exp_before_death = exp
    remove_exp(lost_exp.to_i64)
  end

  def increase_death_penalty_buff_level
    debug { "Increasing death penalty (current: #{death_penalty_buff_level})." }
    return if death_penalty_buff_level >= 15

    if death_penalty_buff_level != 0
      unless skill = SkillData[5076, death_penalty_buff_level]?
        remove_skill(skill, true)
      end
    end

    @death_penalty_buff_level += 1
    skill = SkillData[5076, death_penalty_buff_level]
    add_skill(skill, false)
    send_packet(EtcStatusUpdate.new(self))
    sm = SystemMessage.death_penalty_level_s1_added
    sm.add_int(death_penalty_buff_level)
    send_packet(sm)
  end

  def reduce_death_penalty_buff_level
    return if death_penalty_buff_level <= 0

    unless skill = SkillData[5076, death_penalty_buff_level]?
      remove_skill(skill, true)
    end

    @death_penalty_buff_level -= 1

    if death_penalty_buff_level > 0
      skill = SkillData[5076, death_penalty_buff_level]
      add_skill(skill, false)
      send_packet(EtcStatusUpdate.new(self))
      sm = SystemMessage.death_penalty_level_s1_added
      sm.add_int(death_penalty_buff_level)
      send_packet(sm)
    else
      send_packet(EtcStatusUpdate.new(self))
      send_packet(SystemMessageId::DEATH_PENALTY_LIFTED)
    end
  end

  def restore_death_penalty_buff_level
    if @death_penalty_buff_level > 0
      add_skill(SkillData[5076, @death_penalty_buff_level], false)
    end
  end

  def party_waiting? : Bool
    PartyMatchWaitingList.players.includes?(self)
  end

  def festival_participant? : Bool
    SevenSignsFestival.instance.participant?(self)
  end

  def set_current_skill(skill : Skill?, ctrl : Bool, shift : Bool)
    @current_skill = (SkillUseHolder.new(skill, ctrl, shift) if skill)
  end

  def set_queued_skill(skill : Skill?, ctrl : Bool, shift : Bool)
    @queued_skill = (SkillUseHolder.new(skill, ctrl, shift) if skill)
  end

  def level_mod : Float64
    if transformed? && (transform = transformation)
      level_mod = transform.get_level_mod(self)
      if level_mod > -1
        return level_mod
      end
    end

    super
  end

  def update_not_move_until
    @not_move_until = Time.ms + Config.player_movement_block_time
  end

  def charged_shot?(type : ShotType) : Bool
    wpn = active_weapon_instance
    !!wpn && wpn.charged_shot?(type)
  end

  def set_charged_shot(type : ShotType, charged : Bool)
    active_weapon_instance.try &.set_charged_shot(type, charged)
  end

  def add_auto_shot(id : Int32)
    @active_shots << id
  end

  def remove_auto_shot(id : Int32)
    @active_shots.delete(id)
  end

  def recharge_shots(physical : Bool, magic : Bool)
    return if @active_shots.empty?

    @active_shots.each do |item_id|
      if item = inventory.get_item_by_item_id(item_id)
        if magic && item.template.default_action.spiritshot?
          ItemHandler[item.etc_item].try &.use_item(self, item, false)
        end

        if physical && item.template.default_action.soulshot?
          ItemHandler[item.etc_item].try &.use_item(self, item, false)
        end
      else
        remove_auto_shot(item_id)
      end
    end
  end

  def disable_auto_shot_by_crystal_type(type : CrystalType)
    @active_shots.each do |item_id|
      if template = ItemTable[item_id]?
        if template.crystal_type.to_i == type
          disable_auto_shot(item_id)
        end
      else
        warn { "Item with id #{item_id} not found." }
      end
    end
  end

  def disable_auto_shot(item_id : Int32) : Bool
    if @active_shots.includes?(item_id)
      remove_auto_shot(item_id)
      send_packet(ExAutoSoulShot.new(item_id, 0))

      sm = SystemMessage.auto_use_of_s1_cancelled
      sm.add_item_name(item_id)
      send_packet(sm)

      return true
    end

    false
  end

  def disable_all_shots
    @active_shots.each do |item_id|
      send_packet(ExAutoSoulShot.new(item_id, 0))
      sm = SystemMessage.auto_use_of_s1_cancelled
      sm.add_item_name(item_id)
      send_packet(sm)
    end

    @active_shots.clear
  end

  def increase_charges(count : Int32, max : Int32)
    if @charges.get >= max
      send_packet(SystemMessageId::FORCE_MAXLEVEL_REACHED)
      return
    end

    restart_charge_task

    @charges.add(count)

    if @charges.get >= max
      @charges.set(max) if @charges.get > max
      send_packet(SystemMessageId::FORCE_MAXLEVEL_REACHED)
    else
      sm = SystemMessage.force_increased_to_s1
      sm.add_int(@charges.get)
      send_packet(sm)
    end

    send_packet(EtcStatusUpdate.new(self))
  end

  def decrease_charges(count : Int32)
    if @charges.get < count
      return false
    end

    @charges.sub(count)

    if @charges.get == 0
      stop_charge_task
    else
      restart_charge_task
    end

    send_packet(EtcStatusUpdate.new(self))
    true
  end

  def clear_charges
    @charges.set(0)
    send_packet(EtcStatusUpdate.new(self))
  end

  def restart_charge_task
    if @charge_task
      sync do
        @charge_task.try &.cancel
      end
    end

    task = ResetChargesTask.new(self)
    @charge_task = ThreadPoolManager.schedule_general(task, 600_000)
  end

  def stop_charge_task
    if task = @charge_task
      task.cancel
      @charge_task = nil
    end
  end

  def charged_souls : Int32
    @souls
  end

  def increase_souls(count : Int32)
    @souls += count
    sm = SystemMessage.your_soul_has_increased_by_s1_so_it_is_now_at_s2
    sm.add_int(count)
    sm.add_int(@souls)
    send_packet(sm)
    restart_soul_task
    send_packet(EtcStatusUpdate.new(self))
  end

  def decrease_souls(count : Int32) : Int32
    if @souls == 0
      return 0
    end

    if @souls <= count
      consumed = @souls
      @souls = 0
      stop_soul_task
    else
      @souls -= count
      consumed = count
      restart_soul_task
    end

    send_packet(EtcStatusUpdate.new(self))

    consumed
  end

  def clear_souls
    @souls = 0
    stop_soul_task
    send_packet(EtcStatusUpdate.new(self))
  end

  def restart_soul_task
    stop_soul_task
    task = ResetSoulsTask.new(self)
    @soul_task = ThreadPoolManager.schedule_general(task, 600_000)
  end

  def add_html_action(scope : HtmlActionScope, action : String)
    @html_action_caches[scope.to_i] << action
  end

  def clear_html_actions(scope : HtmlActionScope)
    @html_action_caches[scope.to_i].clear
  end

  def set_html_action_origin_l2id(scope : HtmlActionScope, id : Int32)
    if id < 0
      raise ArgumentError.new("#set_html_action_origin_l2id: id must be >= 0")
    end

    @html_action_origin_l2ids[scope.to_i] = id
  end

  def last_html_action_origin_id : Int32
    @last_html_action_origin_l2id
  end

  def stop_soul_task
    if task = @soul_task
      task.cancel
      @soul_task = nil
    end
  end

  def validate_html_action(iter, action : String) : Bool
    iter.each do |cached_action|
      if cached_action[-1] == AbstractHtmlPacket::VAR_PARAM_START_CHAR
        temp = cached_action[0...-1].strip
        if action.starts_with?(temp)
          return true
        end
      elsif cached_action == action
        return true
      end
    end

    false
  end

  def validate_html_action(action : String) : Int32
    @html_action_caches.each_with_index do |cache, i|
      if validate_html_action(cache, action)
        @last_html_action_origin_l2id = @html_action_origin_l2ids[i]
        return @last_html_action_origin_l2id
      end
    end

    -1
  end

  def learning_class : ClassId
    @learning_class || class_id
  end

  def stop_cubics
    unless @cubics.empty?
      @cubics.each_value do |cubic|
        cubic.stop_action
        cubic.cancel_disappear
      end
      @cubics.clear

      broadcast_user_info
    end
  end

  def stop_cubics_by_others
    unless @cubics.empty?
      broadcast = false
      @cubics.each_value do |cubic|
        if cubic.given_by_other?
          cubic.stop_action
          cubic.cancel_disappear
          @cubics.delete(cubic.id)
          broadcast = true
        end
      end

      if broadcast
        broadcast_user_info
      end
    end
  end

  def add_cubic(*args)
    cubic = L2CubicInstance.new(self, *args)
    @cubics[cubic.id] = cubic
  end

  def get_cubic_by_id(id : Int32) : L2CubicInstance?
    @cubics[id]?
  end

  def clan_leader? : Bool
    return false unless clan = clan()
    l2id == clan.leader_id
  end

  def sub_stat : PcStat
    subclass_active? ? subclasses[class_index].stat : stat
  end

  def level : Int32
    if subclass_active?
      subclasses[class_index].stat.level
    else
      stat.level
    end
  end

  def level=(level : Int32)
    sub_stat.level = Math.min(level, max_level)
  end

  def base_level : Int32
    stat.level
  end

  def base_exp : Int64
    stat.exp
  end

  def base_sp : Int32
    stat.sp
  end

  def max_level : Int32
    sub_stat.max_level
  end

  def max_exp_level : Int32
    sub_stat.max_exp_level
  end

  def add_level(value : Int32) : Bool
    if level &+ value > max_level
      return false
    end

    OnPlayerLevelChanged.new(self, level.to_i8!, (level + value).to_i8).async(self)
    level_increased = sub_stat.add_level(value)
    on_level_change(level_increased)

    level_increased
  end

  def on_level_change(level_increased : Bool)
    if level_increased
      heal!
      broadcast_packet(SocialAction.level_up(l2id))
      send_packet(SystemMessageId::YOU_INCREASED_YOUR_LEVEL)
    else
      if !gm? && Config.decrease_skill_level
        check_player_skills
      end
    end

    reward_skills

    if clan = clan()
      clan.update_clan_member(self)
      clan.broadcast_to_online_members(PledgeShowMemberListUpdate.new(self))
    end

    party.try &.recalculate_party_level

    if (transformed? || in_stance?) && (transform = transformation)
      transform.on_level_up(self)
    end

    if pet = summon.as?(L2PetInstance)
      if pet.pet_data.sync_level? && pet.level != level
        pet.stat.level = level
        pet.stat.get_exp_for_level(level)
        pet.heal!
        pet.broadcast_packet(SocialAction.level_up(l2id)) # shouldn't it be the pet's l2id?
        pet.update_and_broadcast_status(1)
      end
    end

    su = StatusUpdate.level_max_cp_hp_mp(self, level, max_cp, max_hp, max_mp)
    send_packet(su)

    refresh_overloaded
    refresh_expertise_penalty

    send_packet(UserInfo.new(self))
    send_packet(ExBrExtraUserInfo.new(self))
    send_packet(ExVoteSystemInfo.new(self))
  end

  def exp : Int64
    if subclass_active?
      subclasses[class_index].stat.exp
    else
      stat.exp
    end
  end

  def exp=(exp : Int64)
    if exp < 0
      exp = 0i64
    end

    sub_stat.exp = exp
  end

  def sp : Int32
    if subclass_active?
      subclasses[class_index].stat.sp
    else
      stat.sp
    end
  end

  def sp=(sp : Int32)
    if sp < 0
      sp = 0
    end

    if subclass_active?
      subclasses[class_index].stat.sp = sp
    else
      stat.sp = sp
    end
  end

  def add_exp_and_sp_quest(add_to_exp : Int64, add_to_sp : Int32)
    if add_to_exp != 0
      sub_stat.add_exp(add_to_exp)
      sm = SystemMessage.earned_s1_experience
      sm.add_long(add_to_exp)
      send_packet(sm)
    end

    if add_to_sp != 0
      sub_stat.add_sp(add_to_sp)
      sm = SystemMessage.acquired_s1_sp
      sm.add_int(add_to_sp)
      send_packet(sm)
    end

    send_packet(UserInfo.new(self))
    send_packet(ExBrExtraUserInfo.new(self))
  end

  def add_sp(sp : Int32)
    sub_stat.add_sp(sp)
  end

  def add_exp_and_sp(add_to_exp : Int64, add_to_sp : Int32)
    add_exp_and_sp(add_to_exp, add_to_sp, false)
  end

  def add_exp_and_sp(add_to_exp : Int64, add_to_sp : Int32, use_bonuses : Bool)
    unless access_level.can_gain_exp?
      return
    end

    change_karma(add_to_exp)

    base_exp = add_to_exp
    base_sp = add_to_sp

    if use_bonuses
      add_to_exp *= stat.exp_bonus_multiplier
      add_to_sp *= stat.sp_bonus_multiplier
    end

    ratio_taken_by_player = 0.0

    if has_pet?
      pet = summon.as(L2PetInstance)
      if Util.in_short_radius?(Config.alt_party_range, self, pet, false)
        ratio_taken_by_player = pet.pet_level_data.owner_exp_taken / 100.0

        if ratio_taken_by_player > 1
          ratio_taken_by_player = 1.0
        end

        unless pet.dead?
          pet_exp = add_to_exp * (1 - ratio_taken_by_player)
          pet_sp = add_to_sp * (1 - ratio_taken_by_player)
          pet.add_exp_and_sp(pet_exp.to_i64, pet_sp.to_i32)
        end

        base_exp = (add_to_exp * ratio_taken_by_player).to_i64
        base_sp = (add_to_sp * ratio_taken_by_player).to_i
        add_to_exp = (add_to_exp * ratio_taken_by_player).to_i64
        add_to_sp = (add_to_sp * ratio_taken_by_player).to_i
      end
    end

    sub_stat.add_exp(add_to_exp.to_i64)
    sub_stat.add_sp(add_to_sp.to_i32)

    sm = SystemMessage.you_earned_s1_exp_bonus_s2_and_s3_sp_bonus_s4
    sm.add_long(add_to_exp)
    sm.add_long(add_to_exp - base_exp)
    sm.add_int(add_to_sp)
    sm.add_int(add_to_sp - base_sp)
    send_packet(sm)

    send_packet(UserInfo.new(self))
    send_packet(ExBrExtraUserInfo.new(self))
  end

  def remove_exp(exp : Int64)
    change_karma(exp)
    sub_stat.remove_exp(exp)

    send_packet(UserInfo.new(self))
    send_packet(ExBrExtraUserInfo.new(self))
  end

  def remove_sp(sp : Int32) : Bool
    sub_stat.remove_sp(sp)
  end

  def remove_exp_and_sp(exp : Int64, sp : Int32)
    sub_stat.remove_exp(exp)
    sub_stat.remove_sp(sp)

    send_packet(UserInfo.new(self))
    send_packet(ExBrExtraUserInfo.new(self))
  end

  def change_karma(exp : Int64)
    if !cursed_weapon_equipped? && karma > 0 && (gm? || !inside_pvp_zone?)
      karma_lost = Formulas.karma_lost(self, exp)
      if karma_lost > 0
        self.karma -= karma_lost
        sm = SystemMessage.your_karma_has_been_changed_to_s1
        sm.add_int(karma)
        send_packet(sm)
      end
    end
  end

  def karma=(karma : Int32)
    OnPlayerKarmaChanged.new(self, karma(), karma).async(self)

    karma = Math.max(karma, 0)

    if karma() == 0 && karma > 0
      known_list.each_object do |obj|
        if obj.is_a?(L2GuardInstance)
          obj.intention = AI::ACTIVE
        end
      end
    elsif karma() > 0 && karma == 0
      self.karma_flag = 0
    end

    @karma = karma
    broadcast_karma
  end

  def karma_flag=(flag : Int32)
    send_packet(UserInfo.new(self))
    send_packet(ExBrExtraUserInfo.new(self))

    known_list.each_player do |pc|
      rc = RelationChanged.new(self, get_relation(pc), auto_attackable?(pc))
      pc.send_packet(rc)
      if smn = summon
        rc = RelationChanged.new(smn, get_relation(pc), auto_attackable?(pc))
        pc.send_packet(rc)
      end
    end
  end

  def broadcast_karma
    send_packet(StatusUpdate.karma(self))

    known_list.each_player do |pc|
      rc = RelationChanged.new(self, get_relation(pc), auto_attackable?(pc))
      pc.send_packet(rc)
      if smn = summon
        rc = RelationChanged.new(smn, get_relation(pc), auto_attackable?(pc))
        pc.send_packet(rc)
      end
    end
  end

  def fame=(fame : Int32)
    OnPlayerFameChanged.new(self, @fame, fame).async(self)
    @fame = Math.min(fame, Config.max_personal_fame_points)
  end

  def pvp_kills=(kills : Int32)
    OnPlayerPvPChanged.new(self, @pvp_kills, kills).async(self)
    @pvp_kills = kills
  end

  def player? : Bool
    true
  end

  def noble=(val : Bool)
    if val
      SkillTreesData.noble_skill_tree.each_value do |skill|
        add_skill(skill, false)
      end
    else
      SkillTreesData.noble_skill_tree.each_value do |skill|
        remove_skill(skill, false, true)
      end
    end

    @noble = val
    send_skill_list
  end

  def reduce_arrow_count(bolts : Bool)
    unless arrows = inventory.lhand_slot
      inventory.unequip_item_in_slot(Inventory::LHAND)
      if bolts
        @bolt_item = nil
      else
        @arrow_item = nil
      end

      send_packet(ItemList.new(self, false))
      return
    end

    if arrows.count > 0
      arrows.sync do
        arrows.change_count_without_trace(-1, self, nil)
        arrows.last_change = L2ItemInstance::MODIFIED

        if GameTimer.ticks % 10 == 0
          arrows.update_database
        end

        inventory.refresh_weight
      end
    else
      inventory.destroy_item("Consume", arrows, arrows.count, self, nil)
      if bolts
        @bolt_item = nil
      else
        @arrow_item = nil
      end

      send_packet(ItemList.new(self, false))
      return
    end

    if Config.force_inventory_update
      send_packet(ItemList.new(self, false))
    else
      send_packet(InventoryUpdate.modified(arrows))
    end
  end

  def check_and_equip_arrows : L2ItemInstance?
    if inventory.lhand_slot.nil?
      @arrow_item = inventory.find_arrow_for_bow(active_weapon_item)
      if @arrow_item
        inventory.lhand_slot = @arrow_item
        send_packet(ItemList.new(self, false))
      end
    else
      @arrow_item = inventory.lhand_slot
    end

    @arrow_item
  end

  def check_and_equip_bolts : L2ItemInstance?
    if inventory.lhand_slot.nil?
      @bolt_item = inventory.find_bolt_for_crossbow(active_weapon_item)
      if @bolt_item
        inventory.lhand_slot = @bolt_item
        send_packet(ItemList.new(self, false))
      end
    else
      @bolt_item = inventory.lhand_slot
    end

    @bolt_item
  end

  def vitality_points : Int32
    stat.vitality_points
  end

  def vitality_level : Int32
    stat.vitality_level.to_i32
  end

  def set_vitality_points(points : Int32, quiet : Bool)
    stat.set_vitality_points(points, quiet)
  end

  def update_vitality_level(quiet : Bool)
    stat.update_vitality_level(quiet)
  end

  def update_vitality_points(points : Float32, use_rates : Bool, quiet : Bool)
    stat.update_vitality_points(points, use_rates, quiet)
  end

  def all_shortcuts : Enumerable(Shortcut)
    shortcuts.all_shortcuts
  end

  def get_shortcut(slot : Int32, page : Int32) : Shortcut?
    shortcuts.get_shortcut(slot, page)
  end

  def register_shortcut(shortcut : Shortcut)
    shortcuts.register_shortcut(shortcut)
  end

  def update_shortcuts(id : Int32, level : Int32)
    shortcuts.update_shortcuts(id, level)
  end

  def delete_shortcut(slot : Int32, page : Int32)
    shortcuts.delete_shortcut(slot, page)
  end

  def remove_item_from_shortcut(id : Int32)
    shortcuts.delete_shortcut_by_l2id(id)
  end

  def register_macro(mcr : Macro)
    macros.register_macro(mcr)
  end

  def delete_macro(id : Int32)
    macros.delete_macro(id)
  end

  def registered_on_this_siege_field?(val : Int32) : Bool
    !(@siege_side != val && (@siege_side < 81 || @siege_side > 89))
  end

  def adena : Int64
    inventory.adena
  end

  def ancient_adena : Int64
    inventory.ancient_adena
  end

  def get_paperdoll_item(slot : Int32) : L2ItemInstance?
    inventory.get_paperdoll_item(slot)
  end

  def has_dwarven_craft? : Bool
    get_skill_level(CommonSkill::CREATE_DWARVEN.id) >= 1
  end

  def dwarven_craft : Int32
    get_skill_level(CommonSkill::CREATE_DWARVEN.id)
  end

  def has_common_craft? : Bool
    get_skill_level(CommonSkill::CREATE_COMMON.id) >= 1
  end

  def common_craft : Int32
    get_skill_level(CommonSkill::CREATE_COMMON.id)
  end

  def pk_kills=(kills : Int32)
    OnPlayerPKChanged.new(self, @pk_kills, kills).async(self)
    @pk_kills = kills
  end

  def get_race(i : Int32) : Int32
    @race[i]
  end

  def set_race(i : Int32, val : Int32)
    @race[i] = val
  end

  def message_refusal=(val : Bool)
    @message_refusal = val
    send_packet(EtcStatusUpdate.new(self))
  end

  def hero=(val : Bool)
    if val && @base_class == @active_class
      SkillTreesData.hero_skill_tree.each_value do |skill|
        add_skill(skill, false)
      end
    else
      SkillTreesData.hero_skill_tree.each_value do |skill|
        remove_skill(skill, false, true)
      end
    end

    @hero = val
    send_skill_list
  end

  def transformation_id : Int32
    if transformed? && (transform = transformation)
      return transform.id
    end

    0
  end

  def transformation_display_id : Int32
    if transformed? && (transform = transformation)
      return transform.display_id
    end

    0
  end

  def update_abnormal_effect
    broadcast_user_info
  end

  def broadcast_user_info
    send_packet(UserInfo.new(self))
    broadcast_packet(CharInfo.new(self))
    broadcast_packet(ExBrExtraUserInfo.new(self))
    if TerritoryWarManager.tw_in_progress? && TerritoryWarManager.registered?(-1, l2id)
      broadcast_packet(ExDominionWarStart.new(self))
    end
  end

  def broadcast_status_update
    su = StatusUpdate.cp_hp_mp(self)
    send_packet(su)

    need_cp_update = need_cp_update?
    need_hp_update = need_hp_update?

    if party = @party
      if need_cp_update || need_hp_update || need_mp_update?
        packet = PartySmallWindowUpdate.new(self)
        party.broadcast_to_party_members(self, packet)
      end
    end

    if in_olympiad_mode? && olympiad_start? && (need_cp_update || need_hp_update)
      game = OlympiadGameManager.get_olympiad_task(olympiad_game_id)
      if game && game.battle_started?
        game.zone.broadcast_status_update(self)
      end
    end

    if in_duel? && (need_cp_update || need_hp_update)
      packet = ExDuelUpdateUserInfo.new(self)
      DuelManager.broadcast_to_opposite_team(self, packet)
    end
  end

  def send_info(pc : L2PcInstance)
    if boat = boat()
      set_xyz(boat.location)

      pc.send_packet(CharInfo.new(self))
      pc.send_packet(ExBrExtraUserInfo.new(self))
      relation1 = get_relation(pc)
      relation2 = pc.get_relation(self)
      old_relation = known_list.known_relations[pc.l2id]?

      if old_relation != relation1
        rc = RelationChanged.new(self, relation1, auto_attackable?(pc))
        pc.send_packet(rc)
        if smn = summon
          rc = RelationChanged.new(smn, relation1, auto_attackable?(pc))
          pc.send_packet(rc)
        end
      end

      old_relation = pc.known_list.known_relations[l2id]?
      if old_relation != relation2
        rc = RelationChanged.new(pc, relation2, pc.auto_attackable?(self))
        send_packet(rc)
        if smn = pc.summon
          rc = RelationChanged.new(smn, relation2, pc.auto_attackable?(self))
          send_packet(rc)
        end
      end

      gov = GetOnVehicle.new(l2id, boat.l2id, in_vehicle_position.not_nil!)
      pc.send_packet(gov)
    elsif airship = airship()
      set_xyz(airship.location)

      pc.send_packet(CharInfo.new(self))
      pc.send_packet(ExBrExtraUserInfo.new(self))
      relation1 = get_relation(pc)
      relation2 = pc.get_relation(self)
      old_relation = known_list.known_relations[pc.l2id]?

      if old_relation != relation1
        rc = RelationChanged.new(self, relation1, auto_attackable?(pc))
        pc.send_packet(rc)
        if smn = summon
          rc = RelationChanged.new(smn, relation1, auto_attackable?(pc))
          pc.send_packet(rc)
        end
      end

      old_relation = pc.known_list.known_relations[l2id]?
      if old_relation != relation2
        rc = RelationChanged.new(pc, relation2, pc.auto_attackable?(self))
        send_packet(rc)
        if smn = pc.summon
          rc = RelationChanged.new(smn, relation2, pc.auto_attackable?(self))
          send_packet(rc)
        end
      end

      pc.send_packet(ExGetOnAirship.new(self, airship))
    else
      pc.send_packet(CharInfo.new(self))
      pc.send_packet(ExBrExtraUserInfo.new(self))
      relation1 = get_relation(pc)
      relation2 = pc.get_relation(self)
      old_relation = known_list.known_relations[pc.l2id]?

      if old_relation != relation1
        rc = RelationChanged.new(self, relation1, auto_attackable?(pc))
        pc.send_packet(rc)
        if smn = summon
          rc = RelationChanged.new(smn, relation1, auto_attackable?(pc))
          pc.send_packet(rc)
        end
      end

      old_relation = pc.known_list.known_relations[l2id]?
      if old_relation != relation2
        rc = RelationChanged.new(pc, relation2, pc.auto_attackable?(self))
        send_packet(rc)
        if smn = pc.summon
          rc = RelationChanged.new(smn, relation2, pc.auto_attackable?(self))
          send_packet(rc)
        end
      end
    end

    case private_store_type
    when PrivateStoreType::SELL
      pc.send_packet(PrivateStoreMsgSell.new(self))
    when PrivateStoreType::PACKAGE_SELL
      pc.send_packet(ExPrivateStoreSetWholeMsg.new(self))
    when PrivateStoreType::BUY
      pc.send_packet(PrivateStoreMsgBuy.new(self))
    when PrivateStoreType::MANUFACTURE
      pc.send_packet(RecipeShopMsg.new(self))
    end

    if transformed?
      send_packet(CharInfo.new(pc))
    end
  end

  def update_and_broadcast_status(type : Int32)
    refresh_overloaded
    refresh_expertise_penalty

    case type
    when 1
      send_packet(UserInfo.new(self))
      send_packet(ExBrExtraUserInfo.new(self))
    when 2
      broadcast_user_info
    end
  end

  def update_abnormal_effect
    broadcast_user_info
  end

  def broadcast_title_info
    send_packet(UserInfo.new(self))
    send_packet(ExBrExtraUserInfo.new(self))
    broadcast_packet(NicknameChanged.new(self))
  end

  def send_damage_message(target, damage, mcrit, pcrit, miss)
    if miss
      if target.is_a?(L2PcInstance)
        sm = SystemMessage.c1_evaded_c2_attack
        sm.add_pc_name(target)
        sm.add_char_name(self)
        target.send_packet(sm)
      end

      sm = SystemMessage.c1_attack_went_astray
      sm.add_pc_name(self)
      send_packet(sm)
      return
    end

    if pcrit
      sm = SystemMessage.c1_had_critical_hit
      sm.add_pc_name(self)
      send_packet(sm)
    end

    if mcrit
      send_packet(SystemMessageId::CRITICAL_HIT_MAGIC)
    end

    if in_olympiad_mode? && target.is_a?(L2PcInstance)
      if target.in_olympiad_mode?
        if target.olympiad_game_id == olympiad_game_id
          OlympiadGameManager.notify_competitor_damage(self, damage.to_i)
        end
      end
    end

    if target.invul? || target.hp_blocked? && !target.npc?
      sm = SystemMessageId::ATTACK_WAS_BLOCKED
    elsif target.door? || target.is_a?(L2ControlTowerInstance)
      sm = SystemMessage.you_did_s1_dmg
      sm.add_int(damage)
    else
      sm = SystemMessage.c1_done_s3_damage_to_c2
      sm.add_pc_name(self)
      sm.add_char_name(target)
      sm.add_int(damage)
    end

    send_packet(sm)
  end

  def update_last_item_auction_request
    @last_item_auction_info_request = Time.ms
  end

  def item_auction_polling? : Bool
    Time.ms - @last_item_auction_info_request < 2000
  end

  def show_quest_movie(id : Int32)
    return if @movie_id > 0

    abort_attack
    abort_cast
    stop_move(nil)
    @movie_id = id
    send_packet(ExStartScenePlayer.new(id))
  end

  def enter_observer_mode(loc : Location)
    set_last_location

    effect_list.stop_skill_effects(true, AbnormalType::HIDE)

    @observer_mode = true
    self.target = nil
    self.paralyzed = true
    start_paralyze
    self.invul = true
    self.invisible = true
    send_packet(ObservationMode.new(loc))

    tele_to_location(loc)

    broadcast_user_info
  end

  def enter_olympiad_observer_mode(loc : Location, id : Int32)
    summon.try &.unsummon(self)

    effect_list.stop_skill_effects(true, AbnormalType::HIDE)

    unless @cubics.empty?
      @cubics.each_value do |cubic|
        cubic.stop_action
        cubic.cancel_disappear
      end
      @cubics.clear
    end

    party.try &.remove_party_member(self, L2Party::MessageType::Expelled)

    @olympiad_game_id = id

    if sitting?
      stand_up
    end

    unless @observer_mode
      set_last_location
    end

    @observer_mode = true
    self.target = nil
    self.invul = true
    self.invisible = true
    tele_to_location(loc, false)
    send_packet(ExOlympiadMode.new(3))

    broadcast_user_info
  end

  def leave_observer_mode
    self.target = nil

    tele_to_location(@last_location, false)
    unset_last_location
    send_packet(ObservationReturn.new(location))

    self.paralyzed = false

    unless gm?
      self.invisible = false
      self.invul = false
    end

    if ai?
      set_intention(AI::IDLE)
    end

    set_falling
    @observer_mode = false

    broadcast_user_info
  end

  def leave_olympiad_observer_mode
    if @olympiad_game_id == -1
      return
    end

    @olympiad_game_id = -1
    @observer_mode = false
    self.target = nil
    send_packet(ExOlympiadMode.new(8))
    self.instance_id = 0
    tele_to_location(@last_location, true)

    unless gm?
      self.invisible = false
      self.invul = false
    end

    if ai?
      set_intention(AI::IDLE)
    end

    unset_last_location
    broadcast_user_info
  end

  def get_loto(i : Int32) : Int32
    @loto[i]
  end

  def set_loto(i : Int32, val : Int32)
    @loto[i] = val
  end

  def send_skill_list
    disabled = false

    sl = SkillList.new

    @skills.each do |id, s|
      if @transformation && !s.passive?
        next
      end

      if has_transform_skill?(id) && s.passive?
        next
      end

      enchantable = SkillData.enchantable?(id)
      if enchantable
        esl = EnchantSkillGroupsData.get_skill_enchantment_by_skill_id(id)
        if esl.nil? || s.level < esl.base_level
          enchantable = false
        end
      end

      sl.add_skill(s.display_id, s.display_level, s.passive?, disabled, enchantable)
    end

    if transform = @transformation
      ts = {} of Int32 => Int32
      if template = transform.get_template(self)
        template.skills.each do |holder|
          ts[holder.skill_id] ||= holder.skill_lvl
          if ts[holder.skill_id] < holder.skill_lvl
            ts[holder.skill_id] = holder.skill_lvl
          end
        end

        template.additional_skills.each do |holder|
          if level >= holder.min_level
            ts[holder.skill_id] ||= holder.skill_lvl
            if ts[holder.skill_id] < holder.skill_lvl
              ts[holder.skill_id] = holder.skill_lvl
            end
          end
        end
      end

      SkillTreesData.collect_skill_tree.each_value do |skill|
        if get_known_skill(skill.skill_id)
          add_transform_skill(SkillData[skill.skill_id, skill.skill_level])
        end
      end

      ts.each do |skill_id, skill_level|
        sk = SkillData[skill_id, skill_level]
        add_transform_skill(sk)
        sl.add_skill(skill_id, skill_level, false, false, false)
      end
    end

    send_packet(sl)
  end

  def in_airship? : Bool
    return false unless vehicle = @vehicle
    vehicle.airship?
  end

  def in_boat? : Bool
    return false unless vehicle = @vehicle
    vehicle.boat?
  end

  def airship : L2AirshipInstance?
    @vehicle.as?(L2AirshipInstance)
  end

  def in_store_mode? : Bool
    !private_store_type.none?
  end

  def find_fists_weapon_item(class_id : Int32) : L2Weapon?
    item_id =
    case class_id
    when 0x00..0x09; 246
    when 0x0a..0x11; 251
    when 0x12..0x18; 244
    when 0x19..0x1e; 249
    when 0x1f..0x25; 245
    when 0x26..0x2b; 250
    when 0x2c..0x30; 248
    when 0x31..0x34; 252
    when 0x35..0x39; 247
    end

    if item_id
      return ItemTable[item_id].as(L2Weapon)
    end

    # warn { "No fists found for #{ClassId[class_id]}." }
    nil
  end

  def active_weapon_instance : L2ItemInstance?
    inventory.rhand_slot
  end

  def active_weapon_item : L2Weapon?
    active_weapon_instance.try &.template.as(L2Weapon) || fists_weapon_item
  end

  def secondary_weapon_instance : L2ItemInstance?
    inventory.lhand_slot
  end

  def secondary_weapon_item : L2Item?
    secondary_weapon_instance.try &.template
  end

  def chest_armor_instance : L2ItemInstance?
    inventory.chest_slot
  end

  def legs_armor_instance : L2ItemInstance?
    inventory.legs_slot
  end

  def active_chest_armor_item : L2Armor?
    chest_armor_instance.try &.template
  end

  def active_legs_armor_item : L2Armor?
    legs_armor_instance.try &.template
  end

  def wearing_heavy_armor? : Bool
    legs = legs_armor_instance
    armor = chest_armor_instance

    if armor && legs
      if legs.item_type == ArmorType::HEAVY
        if armor.item_type == ArmorType::HEAVY
          return true
        end
      end
    end

    if armor
      if inventory.chest_slot.template.body_part == L2Item::SLOT_FULLARMOR
        if armor.item_type == ArmorType::HEAVY
          return true
        end
      end
    end

    false
  end

  def wearing_light_armor? : Bool
    legs = legs_armor_instance
    armor = chest_armor_instance

    if armor && legs
      if legs.item_type == ArmorType::LIGHT
        if armor.item_type == ArmorType::LIGHT
          return true
        end
      end
    end

    if armor
      if inventory.chest_slot.template.body_part == L2Item::SLOT_FULLARMOR
        if armor.item_type == ArmorType::LIGHT
          return true
        end
      end
    end

    false
  end

  def wearing_magic_armor? : Bool
    legs = legs_armor_instance
    armor = chest_armor_instance

    if armor && legs
      if legs.item_type == ArmorType::MAGIC
        if armor.item_type == ArmorType::MAGIC
          return true
        end
      end
    end

    if armor
      if inventory.chest_slot.template.body_part == L2Item::SLOT_FULLARMOR
        if armor.item_type == ArmorType::MAGIC
          return true
        end
      end
    end

    false
  end

  def trap! : L2TrapInstance
    trap || raise("Player #{name} has no trap")
  end

  def in_looter_party?(looter_id : Int32) : Bool
    if party = party()
      looter = L2World.get_player(looter_id)

      if (cc = party.command_channel) && looter
        return cc.members.includes?(looter)
      end

      if looter
        return party.members.includes?(looter)
      end
    end

    false
  end

  def do_pickup_item(target : L2Object)
    return if looks_dead? || fake_death? || invisible?

    set_intention(AI::IDLE)

    unless target.item?
      warn { "Tried to pick up a #{target.class}" }
      return
    end

    send_packet(StopMove.new(self))

    party = party()

    target.sync do
      unless target.visible?
        action_failed
        return
      end

      unless target.drop_protection.try_pick_up(self)
        action_failed
        sm = SystemMessage.failed_to_pickup_s1
        sm.add_item_name(target)
        send_packet(sm)
        return
      end

      if ((party && party.distribution_type.finders_keepers?) || !in_party?) && !inventory.validate_capacity(target)
        action_failed
        send_packet(SystemMessageId::SLOTS_FULL)
        return
      end

      if invisible? && !override_item_conditions?
        return
      end

      if target.owner_id != 0 && target.owner_id != l2id && !in_looter_party?(target.owner_id)
        debug "Tried to pick up an item that belongs to someone else."
        if target.id == Inventory::ADENA_ID
          sm = SystemMessage.failed_to_pickup_s1_adena
          sm.add_long(target.count)
        elsif target.count > 1
          sm = SystemMessage.failed_to_pickup_s2_s1_s
          sm.add_item_name(target)
          sm.add_long(target.count)
        else
          sm = SystemMessage.failed_to_pickup_s1
          sm.add_item_name(target)
        end

        action_failed
        send_packet(sm)
        return
      end

      if FortSiegeManager.combat?(target.id)
        unless FortSiegeManager.can_pickup?(self)
          return
        end
      end

      if target.item_loot_schedule
        if target.owner_id == l2id || in_looter_party?(target.owner_id)
          target.reset_owner_timer
        end
      end

      target.pickup_me(self)

      if Config.save_dropped_item
        ItemsOnGroundManager.remove_object(target)
      end
    end

    if target.template.has_ex_immediate_effect?
      if handler = ItemHandler[target.etc_item]
        handler.use_item(self, target, false)
      else
        warn { "No item handler for #{target} (id: #{target.id})." }
      end
      ItemTable.destroy_item("Consume", target, self, nil)
    elsif CursedWeaponsManager.cursed?(target.id)
      add_item("Pickup", target, nil, true)
    elsif FortSiegeManager.combat?(target.id)
      add_item("Pickup", target, nil, true)
    else
      if target.armor? || target.weapon?
        if target.enchant_level > 0
          sm = SystemMessage.announcement_c1_picked_up_s2_s3
          sm.add_pc_name(self)
          sm.add_int(target.enchant_level)
          sm.add_item_name(target.id)
        else
          sm = SystemMessage.announcement_c1_picked_up_s2
          sm.add_pc_name(self)
          sm.add_item_name(target.id)
        end
        broadcast_packet(sm, 1400)
      end

      if party
        party.distribute_item(self, target)
      elsif target.id == Inventory::ADENA_ID && inventory.adena_instance
        add_adena("Pickup", target.count, nil, true)
        ItemTable.destroy_item("Pickup", target, self, nil)
      else
        add_item("Pickup", target, nil, true)

        if weapon = inventory.rhand_slot
          if etc_item = target.as?(L2EtcItem)
            item_type = etc_item.item_type
            if weapon.item_type == WeaponType::BOW && item_type == EtcItemType::ARROW
              check_and_equip_arrows
            elsif weapon.item_type == WeaponType::CROSSBOW && item_type == EtcItemType::BOLT
              check_and_equip_bolts
            end
          end
        end
      end
    end
  end

  def refresh_overloaded
    max_load = max_load()

    return unless max_load > 0
    weight_proc = ((current_load - bonus_weight_penalty) * 1000) / max_load
    case
    when weight_proc < 500 || @diet_mode
      new_weight_penalty = 0
    when weight_proc < 666
      new_weight_penalty = 1
    when weight_proc < 800
      new_weight_penalty = 2
    when weight_proc < 1000
      new_weight_penalty = 3
    else
      new_weight_penalty = 4
    end

    if @cur_weight_penalty != new_weight_penalty
      @cur_weight_penalty = new_weight_penalty
      if new_weight_penalty > 0 && !@diet_mode
        add_skill(SkillData[4270, new_weight_penalty])
        self.overloaded = current_load > max_load
      else
        remove_skill(get_known_skill(4270), false, true)
        self.overloaded = false
      end
      send_packet(UserInfo.new(self))
      send_packet(EtcStatusUpdate.new(self))
      broadcast_packet(CharInfo.new(self))
      broadcast_packet(ExBrExtraUserInfo.new(self))
    end
  end

  def refresh_expertise_penalty
    return unless Config.expertise_penalty
    expertise_level = expertise_level()

    armor_penalty = 0
    weapon_penalty = 0

    inventory.items.each do |item|
      if item.equipped? && item.item_type != EtcItemType::ARROW
        if item.item_type != EtcItemType::BOLT
          crystal_type = item.template.crystal_type.to_i
          if crystal_type > expertise_level
            if item.weapon? && crystal_type > weapon_penalty
              weapon_penalty = crystal_type
            elsif crystal_type > armor_penalty
              armor_penalty = crystal_type
            end
          end
        end
      end
    end

    changed = false
    bonus = expertise_penalty_bonus

    weapon_penalty = weapon_penalty - expertise_level - bonus
    weapon_penalty = weapon_penalty.clamp(0, 4)

    if expertise_weapon_penalty != weapon_penalty || get_skill_level(CommonSkill::WEAPON_GRADE_PENALTY.id) != weapon_penalty
      @expertise_weapon_penalty = weapon_penalty
      if @expertise_weapon_penalty > 0
        add_skill(SkillData[CommonSkill::WEAPON_GRADE_PENALTY.id, @expertise_weapon_penalty])
      else
        remove_skill(get_known_skill(CommonSkill::WEAPON_GRADE_PENALTY.id), false, true)
      end
      changed = true
    end

    armor_penalty = armor_penalty - expertise_level - bonus
    armor_penalty = armor_penalty.clamp(0, 4)

    if expertise_armor_penalty != armor_penalty || get_skill_level(CommonSkill::ARMOR_GRADE_PENALTY.id) != armor_penalty
      @expertise_armor_penalty = armor_penalty
      if @expertise_armor_penalty > 0
        add_skill(SkillData[CommonSkill::ARMOR_GRADE_PENALTY.id, @expertise_armor_penalty])
      else
        remove_skill(get_known_skill(CommonSkill::ARMOR_GRADE_PENALTY.id), false, true)
      end
      changed = true
    end

    if changed
      send_packet(EtcStatusUpdate.new(self))
    end
  end

  def expertise_level : Int32
    Math.max(get_skill_level(239), 0)
  end

  def tele_to_location(loc : Locatable, random_offset : Bool)
    if (vehicle = vehicle()) && !vehicle.teleporting?
      self.vehicle = nil
    end

    if flying_mounted? && loc.z < -1005
      super(loc.x, loc.y, -1005, loc.heading, loc.instance_id)
    end

    super
  end

  def weight_penalty : Int32
    @diet_mode ? 0 : @cur_weight_penalty
  end

  def add_action(act : PlayerAction) : Bool
    unless has_action?(act)
      @action_mask |= act.mask
      return true
    end

    false
  end

  def remove_action(act : PlayerAction) : Bool
    if has_action?(act)
      @action_mask &= ~act.mask
      return true
    end

    false
  end

  def has_action?(act : PlayerAction) : Bool
    @action_mask & act.mask == act.mask
  end

  def party_banned? : Bool
    PunishmentManager.has_punishment?(
      l2id,
      PunishmentAffect::CHARACTER,
      PunishmentType::PARTY_BAN
    )
  end

  def check_birthday : Int32
    now = Calendar.new

    if @create_date.day == 29 && @create_date.month == 1
      @create_date.add(:HOUR, -24)
    end

    if now.month == @create_date.month && now.day == @create_date.day
      if now.year != @create_date.year
        return 0
      end
    end

    1.upto(5) do |i|
      now.add(:HOUR, 24)
      if now.month == @create_date.month && now.day == @create_date.day
        if now.year != @create_date.year
          return i
        end
      end
    end

    -1
  end

  def engage_answer(answer : Int32)
    if !@engage_request
      # do nothing
    elsif @engage_id == 0
      # do nothing
    else
      set_engage_request(false, 0)
      if target = L2World.get_player(@engage_id)
        if answer == 1
          CoupleManager.create_couple(target, self)
          target.send_message("Engagement request has been accepted.")
        else
          target.send_message("Engagement request has been refused.")
        end
      end
    end
  end

  def set_engage_request(@engage_request : Bool, @engage_id : Int32)
  end

  def set_event_status
    @event_status = PlayerEventHolder.new(self)
  end

  def collision_radius : Float64
    if mounted? && mount_npc_id > 0
      NpcData[mount_npc_id].f_collision_radius
    elsif transformed? && (transform = transformation)
      transform.get_collision_radius(self)
    else
      if appearance.sex
        base_template.f_collision_radius_female
      else
        base_template.f_collision_radius
      end
    end
  end

  def collision_height : Float64
    if mounted? && mount_npc_id > 0
      NpcData[mount_npc_id].f_collision_height
    elsif transformed? && (transform = transformation)
      transform.get_collision_height(self)
    else
      if appearance.sex
        base_template.f_collision_height_female
      else
        base_template.f_collision_height
      end
    end
  end

  def base_template : L2PcTemplate
    PlayerTemplateData[@base_class]
  end

  def castle_lord?(castle_id : Int32) : Bool
    return false unless clan = clan()

    if clan.leader.player_instance == self
      castle = CastleManager.get_castle_by_owner(clan)
      if castle && castle == CastleManager.get_castle_by_id(castle_id)
        return true
      end
    end

    false
  end

  def clan_crest_id : Int32
    @clan.try &.crest_id || 0
  end

  def ally_id : Int32
    @clan.try &.ally_id || 0
  end

  def ally_crest_id : Int32
    return 0 if clan_id == 0
    return 0 unless clan = clan()
    return 0 if clan.ally_id == 0
    clan.ally_crest_id
  end

  def inventory_limit : Int32
    if gm?
      limit = Config.inventory_maximum_gm
    elsif race.dwarf?
      limit = Config.inventory_maximum_dwarf
    else
      limit = Config.inventory_maximum_no_dwarf
    end

    limit + calc_stat(Stats::INV_LIM, 0).to_i
  end

  def quest_inventory_limit : Int32
    Config.inventory_maximum_quest_items
  end

  def add_item(process : String?, item : L2ItemInstance, reference, send_msg : Bool)
    return unless item.count > 0

    if send_msg
      if item.count > 1
        sm = SystemMessage.you_picked_up_s1_s2
        sm.add_item_name(item)
        sm.add_long(item.count)
        send_packet(sm)
      elsif item.enchant_level > 0
        sm = SystemMessage.you_picked_up_a_s1_s2
        sm.add_int(item.enchant_level)
        sm.add_item_name(item)
        send_packet(sm)
      else
        sm = SystemMessage.you_picked_up_s1
        sm.add_item_name(item)
        send_packet(sm)
      end
    end

    new_item = inventory.add_item(process, item, self, reference)
    if Config.force_inventory_update
      send_packet(ItemList.new(self, false))
    else
      send_packet(InventoryUpdate.single(new_item))
    end

    send_packet(StatusUpdate.current_load(self))

    if !override_item_conditions? && !inventory.validate_capacity(0, item.quest_item?) && new_item.droppable? && (!new_item.stackable? || new_item.last_change != L2ItemInstance::MODIFIED)
      drop_item("InvDrop", new_item, nil, true, true)
    elsif CursedWeaponsManager.cursed?(new_item.id)
      CursedWeaponsManager.activate(self, new_item)
    elsif FortSiegeManager.combat?(item.id)
      fort = FortManager.get_fort(self).not_nil!
      fort.siege.announce_to_player(SystemMessage.c1_acquired_the_flag, name)
    elsif item.id.between?(13560, 13568)
      if ward = TerritoryWarManager.get_territory_ward(item.id - 13479)
        ward.activate(self, item)
      end
    end
  end

  def add_item(process : String?, item_id : Int32, reference, send_msg : Bool) : L2ItemInstance?
    add_item(process, item_id, 1, -1, reference, send_msg)
  end

  def add_item(process : String?, item_id : Int32, count : Int64, reference, send_msg : Bool) : L2ItemInstance?
    add_item(process, item_id, count, -1, reference, send_msg)
  end

  def add_item(process : String?, item_id : Int32, count : Int64, enchant_level : Int32, reference, send_msg : Bool) : L2ItemInstance?
    unless item = ItemTable[item_id]?
      error { "Item with id #{item_id} does not exist." }
      return
    end

    if send_msg && ((!casting_now? && item.has_ex_immediate_effect?) || !item.has_ex_immediate_effect?)
      if count > 1
        if process.casecmp?("Sweeper") || process.casecmp?("Quest")
          sm = SystemMessage.earned_s2_s1_s
          sm.add_item_name(item_id)
          sm.add_long(count)
          send_packet(sm)
        else
          sm = SystemMessage.you_picked_up_s1_s2
          sm.add_item_name(item_id)
          sm.add_long(count)
          send_packet(sm)
        end
      else
        if process.casecmp?("Sweeper") || process.casecmp?("Quest")
          sm = SystemMessage.earned_item_s1
          sm.add_item_name(item_id)
          send_packet(sm)
        else
          sm = SystemMessage.you_picked_up_s1
          sm.add_item_name(item_id)
          send_packet(sm)
        end
      end
    end

    if item.has_ex_immediate_effect?
      ItemHandler[item.as?(L2EtcItem)].try &.use_item(self, L2ItemInstance.new(item_id), false)
    else
      created_item = inventory.add_item(process, item_id, count, enchant_level, self, reference)
      unless created_item
        raise "Very much expected inventory.add_item to succeed."
      end
      if !override_item_conditions? && !inventory.validate_capacity(0, item.quest_item?) && created_item.droppable? && (!created_item.stackable? || created_item.last_change != L2ItemInstance::MODIFIED)
        drop_item("InvDrop", created_item, nil, true)
      elsif CursedWeaponsManager.cursed?(created_item.id)
        CursedWeaponsManager.activate(self, created_item)
      elsif item.id.between?(13560, 13568)
        if ward = TerritoryWarManager.get_territory_ward(item.id - 13479)
          ward.activate(self, created_item)
        end
      end

      return created_item
    end

    nil
  end

  def add_item(process : String?, item : ItemHolder, reference, send_msg : Bool)
    add_item(process, item.id, item.count, reference, send_msg)
  end

  def drop_item(process : String?, item : L2ItemInstance, reference, send_msg : Bool) : Bool
    drop_item(process, item, reference, send_msg, false)
  end

  def drop_item(process : String?, item : L2ItemInstance, reference, send_msg : Bool, protect_item : Bool) : Bool
    item = inventory.drop_item(process, item, self, reference)

    unless item
      send_packet(SystemMessageId::NOT_ENOUGH_ITEMS) if send_msg
      return false
    end

    item.drop_me(self, x + Rnd.rand(50) - 25, y + Rnd.rand(50) - 25, z + 20)

    if Config.autodestroy_item_after > 0 && Config.destroy_dropped_player_item && !Config.list_protected_items.includes?(item.id)
      if (item.equippable? && Config.destroy_equipable_player_item) || !item.equippable?
        ItemsAutoDestroy.add_item(item)
      end
    end

    if Config.destroy_dropped_player_item
      if !item.equippable? || item.equippable? && Config.destroy_equipable_player_item
        item.protected = false
      else
        item.protected = true
      end
    else
      item.protected = true
    end

    if protect_item
      item.drop_protection.protect(self)
    end

    if Config.force_inventory_update
      send_packet(ItemList.new(self, false))
    else
      send_packet(InventoryUpdate.single(item))
    end

    send_packet(StatusUpdate.current_load(self))

    if send_msg
      sm = SystemMessage.you_dropped_s1
      sm.add_item_name(item)
      send_packet(sm)
    end

    true
  end

  def drop_item(process : String?, l2id : Int32, count : Int64, x : Int32, y : Int32, z : Int32, reference, send_msg : Bool, protect_item : Bool) : L2ItemInstance?
    inv_item = inventory.get_item_by_l2id(l2id).not_nil!
    item = inventory.drop_item(process, l2id, count, self, reference)

    unless item
      send_packet(SystemMessageId::NOT_ENOUGH_ITEMS) if send_msg
      return
    end

    item.drop_me(self, x, y, z)

    if Config.autodestroy_item_after > 0 && Config.destroy_dropped_player_item && !Config.list_protected_items.includes?(item.id)
      if (item.equippable? && Config.destroy_equipable_player_item) || !item.equippable?
        ItemsAutoDestroy.add_item(item)
      end
    end

    if Config.destroy_dropped_player_item
      if !item.equippable? ||(item.equippable? && Config.destroy_equipable_player_item)
        item.protected = false
      else
        item.protected = true
      end
    else
      item.protected = true
    end

    if protect_item
      item.drop_protection.protect(self)
    end

    if Config.force_inventory_update
      send_packet(ItemList.new(self, false))
    else
      send_packet(InventoryUpdate.single(inv_item))
    end

    send_packet(StatusUpdate.current_load(self))

    if send_msg
      sm = SystemMessage.you_dropped_s1
      sm.add_item_name(inv_item)
      send_packet(sm)
    end

    item
  end

  def validate_item_manipulation(id : Int32, action : String) : Bool
    item = inventory.get_item_by_l2id(id)

    if item.nil? || item.owner_id != l2id
      warn "Item not found or doesn't belong to player."
      return false
    end

    smn = summon
    if (smn && smn.control_l2id == id) || @mount_l2id == id
      return false
    end

    return false if active_enchant_item_id == id

    !CursedWeaponsManager.cursed?(item.id)
  end

  def destroy_item_by_item_id(process : String?, item_id : Int32, count : Int, reference, send_msg : Bool) : Bool
    count = count.to_i64
    if item_id == Inventory::ADENA_ID
      return reduce_adena(process, count, reference, send_msg)
    end

    item = inventory.get_item_by_item_id(item_id)

    if !item || item.count < count || !inventory.destroy_item_by_item_id(process, item_id, count, self, reference)
      if send_msg
        send_packet(SystemMessageId::NOT_ENOUGH_ITEMS)
      end

      return false
    end

    unless item
      raise "L2PcInstance#destroy_item_by_item_id: item should not be nil here"
    end

    if Config.force_inventory_update
      send_packet(ItemList.new(self, false))
    else
      send_packet(InventoryUpdate.single(item))
    end

    send_packet(StatusUpdate.current_load(self))

    if send_msg
      if count > 1
        sm = SystemMessage.s2_s1_disappeared
        sm.add_item_name(item_id)
        sm.add_long(count)
      else
        sm = SystemMessage.s1_disappeared
        sm.add_item_name(item_id)
      end

      send_packet(sm)
    end

    true
  end

  def destroy_item(process : String?, item : L2ItemInstance, reference, send_msg : Bool) : Bool
    destroy_item(process, item, item.count, reference, send_msg)
  end

  def destroy_item(process : String?, item : L2ItemInstance, count : Int64, reference, send_msg : Bool) : Bool
    item = inventory.destroy_item(process, item, count, self, reference)

    unless item
      if send_msg
        send_packet(SystemMessageId::NOT_ENOUGH_ITEMS)
      end

      return false
    end

    if Config.force_inventory_update
      send_packet(ItemList.new(self, false))
    else
      send_packet(InventoryUpdate.single(item))
    end

    send_packet(StatusUpdate.current_load(self))

    if send_msg
      if count > 1
        sm = SystemMessage.s2_s1_disappeared
        sm.add_item_name(item)
        sm.add_long(count)
      else
        sm = SystemMessage.s1_disappeared
        sm.add_item_name(item)
      end

      send_packet(sm)
    end

    true
  end

  def destroy_item(process : String?, l2id : Int32, count : Int64, reference, send_msg : Bool) : Bool
    unless item = inventory.get_item_by_l2id(l2id)
      if send_msg
        send_packet(SystemMessageId::NOT_ENOUGH_ITEMS)
      end

      return false
    end

    destroy_item(process, item, count, reference, send_msg)
  end

  def destroy_item_without_trace(process : String?, l2id : Int32, count : Int64, reference, send_msg : Bool) : Bool
    item = inventory.get_item_by_l2id(l2id)

    if !item || item.count < count
      if send_msg
        send_packet(SystemMessageId::NOT_ENOUGH_ITEMS)
      end
      return false
    end

    destroy_item(nil, item, count, reference, send_msg)
  end

  def add_adena(process : String?, count : Int64, reference, send_msg : Bool)
    if send_msg
      sm = SystemMessage.earned_s1_adena
      sm.add_long(count)
      send_packet(sm)
    end

    if count > 0
      inventory.add_adena(process, count, self, reference)

      if Config.force_inventory_update
        send_packet(ItemList.new(self, false))
      else
        send_packet(InventoryUpdate.single(inventory.adena_instance.not_nil!))
      end
    end
  end

  def add_ancient_adena(process : String?, count : Int, reference, send_msg : Bool)
    if send_msg
      sm = SystemMessage.earned_s2_s1_s
      sm.add_item_name(Inventory::ANCIENT_ADENA_ID)
      sm.add_long(count)
      send_packet(sm)
    end

    if count > 0
      inventory.add_ancient_adena(process, count, self, reference)

      if Config.force_inventory_update
        send_packet(ItemList.new(self, false))
      else
        send_packet(InventoryUpdate.single(inventory.ancient_adena_instance.not_nil!))
      end
    end
  end

  def reduce_adena(process : String?, count : Int, reference, send_msg : Bool) : Bool
    count = count.to_i64

    if count > adena
      if send_msg
        send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
      end

      return false
    end

    if count > 0
      adena_item = inventory.adena_instance.not_nil!
      unless inventory.reduce_adena(process, count, self, reference)
        return false
      end

      if Config.force_inventory_update
        send_packet(ItemList.new(self, false))
      else
        send_packet(InventoryUpdate.single(adena_item))
      end

      if send_msg
        sm = SystemMessage.s1_disappeared_adena
        sm.add_long(count)
        send_packet(sm)
      end
    end

    true
  end

  def reduce_ancient_adena(process : String?, count : Int, reference, send_msg : Bool) : Bool
    count = count.to_i64

    if count > ancient_adena
      if send_msg
        send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
      end

      return false
    end

    if count > 0
      aa_item = inventory.ancient_adena_instance.not_nil!
      unless inventory.reduce_ancient_adena(process, count, self, reference)
        return false
      end

      if Config.force_inventory_update
        send_packet(ItemList.new(self, false))
      else
        send_packet(InventoryUpdate.single(aa_item))
      end

      if send_msg
        sm = SystemMessage.s2_s1_disappeared
        sm.add_item_name(Inventory::ANCIENT_ADENA_ID)
        sm.add_long(count)
        send_packet(sm)
      end
    end

    true
  end

  def transfer_item(process : String?, l2id : Int32, count : Int, target : Inventory, reference)
    count = count.to_i64

    return unless old_item = check_item_manipulation(l2id, count, "transfer")
    return unless new_item = inventory.transfer_item(process, l2id, count, target, self, reference)

    if Config.force_inventory_update
      send_packet(ItemList.new(self, false))
    else
      if old_item.count > 0 && old_item != new_item
        iu = InventoryUpdate.modified(old_item)
      else
        iu = InventoryUpdate.removed(old_item)
      end

      send_packet(iu)
    end

    send_packet(StatusUpdate.current_load(self))

    if target.is_a?(PcInventory)
      target_player = target.owner
      if Config.force_inventory_update
        target_player.send_packet(ItemList.new(target_player, false))
      else
        if new_item.count > 0
          iu = InventoryUpdate.modified(new_item)
        else
          iu = InventoryUpdate.added(new_item)
        end

        target_player.send_packet(iu)
      end

      target_player.send_packet(StatusUpdate.current_load(target_player))
    elsif target.is_a?(PetInventory)
      iu = PetInventoryUpdate.new
      if new_item.count > count
        iu.add_modified_item(new_item)
      else
        iu.add_new_item(new_item)
      end

      target.owner.send_packet(iu)
    end

    new_item
  end

  def exchange_items_by_id(process, reference, coin_id : Int32, cost : Int64, reward_id : Int32, count : Int64, send_msg : Bool) : Bool
    inv = inventory

    unless inv.validate_capacity_by_item_id(reward_id, count)
      if send_msg
        send_packet(SystemMessageId::SLOTS_FULL)
      end

      return false
    end

    unless inv.validate_weight_by_item_id(reward_id, count)
      if send_msg
        send_packet(SystemMessageId::WEIGHT_LIMIT_EXCEEDED)
      end

      return false
    end

    if destroy_item_by_item_id(process, coin_id, cost, reference, send_msg)
      add_item(process, reward_id, count, reference, send_msg)
      return true
    end

    false
  end

  def mage_class? : Bool
    class_id.mage_class?
  end

  def mounted? : Bool
    !@mount_type.none?
  end

  def movement_disabled? : Bool
    super || @movie_id > 0
  end

  def enchant_effect : Int32
    if wpn = active_weapon_instance
      return Math.min(wpn.enchant_level, 127)
    end

    0
  end

  def clan_crest_large_id : Int32
    clan = clan()
    if clan && clan.castle_id != 0 && clan.hideout_id != 0
      return clan.crest_large_id
    end

    0
  end

  def online_time=(@online_time : Int64)
    @online_begin_time = Time.ms
  end

  def logout(close_client = true)
    close_net_connection(close_client)
  rescue e
    error "Calling #close_net_connection failed."
    error e
  end

  def henna_empty_slots : Int32
    slots = class_id.level == 1 ? 2 : 3
    slots -= @henna.count &.itself
    Math.max(slots, 0)
  end

  def remove_henna(slot : Int32) : Bool
    return false if slot < 1 || slot > 3
    slot &-= 1
    return false unless henna = @henna[slot]
    @henna[slot] = nil

    GameDB.henna.delete(self, slot &+ 1)

    recalc_henna_stats

    send_packet(HennaInfo.new(self))

    send_packet(UserInfo.new(self))
    send_packet(ExBrExtraUserInfo.new(self))

    inventory.add_item("Henna", henna.dye_item_id, henna.cancel_count.to_i64, self, nil)
    reduce_adena("Henna", henna.cancel_fee.to_i64, self, false)

    sm = SystemMessage.earned_s2_s1_s
    sm.add_item_name(henna.dye_item_id)
    sm.add_long(henna.cancel_count)
    send_packet(sm)
    send_packet(SystemMessageId::SYMBOL_DELETED)

    OnPlayerHennaRemove.new(self, henna).async(self)

    true
  end

  def add_henna(henna : L2Henna)
    3.times do |i|
      unless @henna[i]
        @henna[i] = henna
        recalc_henna_stats

        GameDB.henna.insert(self, henna, i &+ 1)

        send_packet(HennaInfo.new(self))
        send_packet(UserInfo.new(self))
        send_packet(ExBrExtraUserInfo.new(self))

        OnPlayerHennaAdd.new(self, henna).async(self) # L2J sends OnPlayerHennaRemove

        return true
      end
    end

    false
  end

  def recalc_henna_stats
    @henna_int = 0
    @henna_str = 0
    @henna_con = 0
    @henna_men = 0
    @henna_wit = 0
    @henna_dex = 0

    @henna.each do |h|
      next unless h
      @henna_int += @henna_int &+ h.int > 5 ? 5 &- @henna_int : h.int
      @henna_str += @henna_str &+ h.str > 5 ? 5 &- @henna_str : h.str
      @henna_con += @henna_con &+ h.con > 5 ? 5 &- @henna_con : h.con
      @henna_men += @henna_men &+ h.men > 5 ? 5 &- @henna_men : h.men
      @henna_wit += @henna_wit &+ h.wit > 5 ? 5 &- @henna_wit : h.wit
      @henna_dex += @henna_dex &+ h.dex > 5 ? 5 &- @henna_dex : h.dex
    end
  end

  def get_henna(slot : Int32) : L2Henna?
    @henna[slot &- 1] unless slot < 1 || slot > 3
  end

  def has_hennas? : Bool
    @henna.any?
  end

  def henna_list : Slice(L2Henna?)
    @henna
  end

  def total_subclasses : Int32
    subclasses.size
  end

  def subclass_active? : Bool
    @class_index > 0
  end

  def get_quest_state(quest_name : String) : QuestState?
    @quests[quest_name]?
  end

  def get_quest_state!(quest_name : String) : QuestState
    @quests[quest_name]
  end

  def set_quest_state(qs : QuestState)
    @quests[qs.quest_name] = qs
  end

  def has_quest_state?(quest_name : String) : Bool
    @quests.has_key?(quest_name)
  end

  def delete_quest_state(quest_name : String)
    @quests.delete(quest_name)
  end

  def all_active_quests : Array(Quest)
    quests = [] of Quest

    @quests.each_value do |qs|
      next if !qs.started? && !Config.developer
      quest = qs.quest
      next unless quest.id.between?(1, 19999)
      quests << quest
    end

    quests
  end

  def quest_completed?(name : String) : Bool
    return false unless qs = @quests[name]?
    qs.completed?
  end

  def inventory_under_90?(include_quest : Bool) : Bool
    inventory.get_size(include_quest) <= inventory_limit * 0.9
  end

  def remove_notify_quest_of_death(qs : QuestState?)
    return unless qs && @notify_quest_of_death
    notify_quest_of_death.delete(qs)
  end

  def notify_quest_of_death : Interfaces::Set(QuestState)
    @notify_quest_of_death || sync do
      @notify_quest_of_death ||= Concurrent::Set(QuestState).new
    end
  end

  def add_notify_quest_of_death(qs : QuestState?)
    if qs && !notify_quest_of_death.includes?(qs)
      notify_quest_of_death << qs
    end
  end

  def notify_quest_of_death_empty? : Bool
    return true unless tmp = @notify_quest_of_death
    tmp.empty?
  end

  def ip_address : String
    if client = @client
      return client.connection.ip
    end

    "N/A"
  end

  def close_net_connection(close_client : Bool)
    return unless client = @client

    if client.detached?
      client.clean_me(true)
      return
    end

    if client.connection.closed?
      return
    end

    if close_client
      client.close(LeaveWorld::STATIC_PACKET)
    else
      client.close(ServerClose::STATIC_PACKET)
    end
  end

  def lucky? : Bool
    level <= 9 && affected_by_skill?(CommonSkill::LUCKY.id)
  end

  def start_warn_user_take_break
    @task_warn_user_take_break ||=
    ThreadPoolManager.schedule_general_at_fixed_rate(
      WarnUserTakeBreakTask.new(self), 7_200_000, 7_200_000
    )
  end

  def stop_warn_user_take_break
    if task = @task_warn_user_take_break
      task.cancel
      @task_warn_user_take_break = nil
    end
  end

  def start_pvp_flag
    update_pvp_flag(1)
    @pvp_reg_task ||=
    ThreadPoolManager.schedule_general_at_fixed_rate(
      PvPFlagTask.new(self), 1000, 1000
    )
  end

  def stop_pvp_reg_task
    if task = @pvp_reg_task
      task.cancel
      @pvp_reg_task = nil
    end
  end

  def stop_pvp_flag
    stop_pvp_reg_task
    update_pvp_flag(0)
  end

  def account_name : String
    @client.try &.account_name || account_name_player
  end

  def account_name_player : String
    @account_name
  end

  def update_pvp_flag(value : Int32)
    return if pvp_flag == value

    self.pvp_flag = value.to_i8

    send_packet(UserInfo.new(self))
    send_packet(ExBrExtraUserInfo.new(self))

    if smn = summon
      send_packet(RelationChanged.new(smn, get_relation(self), false))
    end

    known_list.each_player do |pc|
      rc = RelationChanged.new(self, get_relation(pc), auto_attackable?(pc))
      pc.send_packet(rc)
      if smn
        rc = RelationChanged.new(smn, get_relation(pc), auto_attackable?(pc))
        pc.send_packet(rc)
      end
    end
  end

  def update_pvp_status(target : L2Character)
    unless pc = target.acting_player
      return
    end

    if in_duel? && pc.duel_id == duel_id
      return
    end

    if (!inside_pvp_zone? || !pc.inside_pvp_zone?) && pc.karma == 0
      if check_if_pvp(pc)
        self.pvp_flag_lasts = Time.ms + Config.pvp_pvp_time
      else
        self.pvp_flag_lasts = Time.ms + Config.pvp_normal_time
      end

      if pvp_flag == 0
        start_pvp_flag
      end
    end
  end

  def update_pvp_status
    return if inside_pvp_zone?
    self.pvp_flag_lasts = Time.ms + Config.pvp_normal_time
    if @pvp_flag == 0
      start_pvp_flag
    end
  end

  def on_kill_update_pvp_karma(target : L2Character?)
    return unless target.is_a?(L2Playable)
    target_player = target.acting_player
    return if target_player.nil? || target_player == self

    if cursed_weapon_equipped? && target.player?
      CursedWeaponsManager.increase_kills(@cursed_weapon_equipped_id)
      return
    end

    if in_duel? && target_player.in_duel?
      return
    end

    if inside_pvp_zone? || target_player.inside_pvp_zone?
      if siege_state > 0 && target_player.siege_state > 0
        if siege_state != target_player.siege_state
          if (killer_clan = clan) && (target_clan = target_player.clan)
            killer_clan.add_siege_kill
            target_clan.add_siege_death
          end
        end
      end

      return
    end

    if (check_if_pvp(target) && target_player.pvp_flag != 0) ||
       (inside_pvp_zone? && target_player.inside_pvp_zone?)

      increase_pvp_kills(target)
    else
      clan = clan()
      target_clan = target_player.clan
      if target_clan && clan && clan.at_war_with?(target_player.clan_id)
        if target_clan.at_war_with?(clan_id)
          if target_player.pledge_type != L2Clan::SUBUNIT_ACADEMY
            if pledge_type != L2Clan::SUBUNIT_ACADEMY
              increase_pvp_kills(target)
              return
            end
          end
        end
      end

      if target_player.karma > 0
        if Config.karma_award_pk_kill
          increase_pvp_kills(target)
        end
      elsif target_player.pvp_flag == 0
        increase_pk_kills_and_karma(target)
        stop_pvp_flag
        check_item_restriction
      end
    end
  end

  def increase_pvp_kills(target : L2Character)
    if target.is_a?(L2PcInstance) && AntiFeedManager.check(self, target)
      self.pvp_kills += 1
      send_packet(UserInfo.new(self))
      send_packet(ExBrExtraUserInfo.new(self))
    end
  end

  def increase_pk_kills_and_karma(target : L2Character)
    return unless target.is_a?(L2Playable)
    self.karma += Formulas.karma_gain(pk_kills, target.summon?)

    if target.is_a?(L2PcInstance)
      self.pk_kills += 1
    end

    send_packet(UserInfo.new(self))
    send_packet(ExBrExtraUserInfo.new(self))
  end

  def allowed_to_enchant_skills? : Bool
    return false if locked? || transformed? || in_stance?
    return false if AttackStances.includes?(self)
    return false if casting_now? || casting_simultaneously_now?
    !in_boat? && !in_airship?
  end

  def need_mp_update? : Bool
    current_mp = current_mp()
    max_mp = max_mp()

    return true if current_mp <= 1 || max_mp < MAX_BAR_PX

    if current_mp < @mp_update_dec_check || (current_mp - @mp_update_dec_check).abs <= 1e-6 || current_mp > @mp_update_inc_check || (current_mp - @mp_update_inc_check).abs <= 1e-6
      if (current_mp - max_mp).abs <= 1e-6
        @mp_update_inc_check = current_mp + 1
        @mp_update_dec_check = current_mp - @mp_update_interval
      else
        double_multi = current_mp / @mp_update_interval
        int_multi = double_multi.to_i

        @mp_update_dec_check = @mp_update_interval * (double_multi < int_multi ? int_multi - 1 : int_multi)
        @mp_update_inc_check = @mp_update_dec_check + @mp_update_interval
      end

      return true
    end

    false
  end

  def need_cp_update? : Bool
    current_cp = current_cp()
    max_cp = max_cp()

    return true if current_cp <= 1 || max_cp < MAX_BAR_PX

    if current_cp < @cp_update_dec_check || (current_cp - @cp_update_dec_check).abs <= 1e-6 || current_cp > @cp_update_inc_check || (current_cp - @cp_update_inc_check).abs <= 1e-6
      if (current_cp - max_cp).abs <= 1e-6
        @cp_update_inc_check = current_cp + 1
        @cp_update_dec_check = current_cp - @cp_update_interval
      else
        double_multi = current_cp / @cp_update_interval
        int_multi = double_multi.to_i

        @cp_update_dec_check = @cp_update_interval * (double_multi < int_multi ? int_multi - 1 : int_multi)
        @cp_update_inc_check = @cp_update_dec_check + @cp_update_interval
      end

      return true
    end

    false
  end

  def gm? : Bool
    access_level.gm?
  end

  def access_level=(level : Int32)
    @access_level = AdminData.get_access_level(level)
    appearance.name_color = access_level.name_color
    appearance.title_color = access_level.title_color
    broadcast_user_info

    CharNameTable.add_name(self)

    if !AdminData.includes?(level)
      warn { "Tried to set unregistered access level #{level} for #{self}. Setting access level without privileges." }
    elsif level > 0
      info { "#{access_level.name} access level set for #{self}." }
    end
  end

  def account_access_level=(level : Int32)
    LoginServerClient.instance.send_access_level(account_name, level)
  end

  def access_level : AccessLevel
    if Config.everybody_has_admin_rights
      return AdminData.max
    elsif @access_level.nil?
      self.access_level = 0
    end

    @access_level.not_nil!
  end

  def set_last_server_position(x : Int32, y : Int32, z : Int32)
    @last_server_position.set_xyz(x, y, z)
  end

  def locked? : Bool
    # @subclass_lock.locked?
    false
  end

  def get_last_server_distance(x : Int32, y : Int32, z : Int32)
    lsp = @last_server_position
    Util.calculate_distance(x, y, z, *lsp.xyz, true, false).to_i
  end

  def set_last_location
    @last_location.set_xyz(x, y, z)
  end

  def unset_last_location
    @last_location.set_xyz(0, 0, 0)
  end

  def reduce_current_hp(value : Float64, attacker : L2Character?, awake : Bool, dot : Bool, skill : Skill?)
    if skill
      status.reduce_hp(value, attacker, awake, dot, skill.toggle?, skill.dmg_directly_to_hp?)
    else
      status.reduce_hp(value, attacker, awake, dot, false, false)
    end

    if has_tamed_beasts?
      tamed_beasts.each &.on_owner_got_attacked(attacker)
    end
  end

  def broadcast_snoop(type : Int32, name : String, text : String)
    return if @snoop_listener.empty?
    sn = Snoop.new(l2id, name(), type, name, text)
    @snoop_listener.each &.send_packet(sn)
  end

  def add_snooper(pc : L2PcInstance)
    @snoop_listener << pc
  end

  def remove_snooper(pc : L2PcInstance)
    @snoop_listener.delete(pc)
  end

  def add_snooped(pc : L2PcInstance)
    @snooped_player << pc
  end

  def remove_snooped(pc : L2PcInstance)
    @snooped_player.delete(pc)
  end

  def sit_down(check_cast : Bool = true)
    if OnPlayerSit.new(self).notify(self).try &.terminate
      return
    end

    if check_cast && casting_now?
      return
    end

    if !@sitting && !attacking_disabled? && !out_of_control?
      unless immobilized?
        break_attack
        self.sitting = true
        set_intention(AI::REST)
        broadcast_packet(ChangeWaitType.new(self, ChangeWaitType::SITTING))
        ThreadPoolManager.schedule_general(SitDownTask.new(self), 2500)
        self.paralyzed = true
      end
    end
  end

  def stand_up
    if OnPlayerStand.new(self).notify(Containers::PLAYERS).try &.terminate
      return
    end

    if @sitting && !looks_dead? && !in_store_mode?
      if effect_list.affected?(EffectFlag::RELAXING)
        stop_effects(EffectType::RELAXING)
      end

      broadcast_packet(ChangeWaitType.new(self, ChangeWaitType::STANDING))
      ThreadPoolManager.schedule_general(StandUpTask.new(self), 2500)
    end
  end

  def protection=(protect : Bool)
    if protect
      @protect_end_time = GameTimer.ticks + (Config.player_spawn_protection * GameTimer::TICKS_PER_SECOND)
    else
      @protect_end_time = 0
    end
  end

  def teleport_protection=(protect : Bool)
    if protect
      @teleport_protect_end_time = GameTimer.ticks + (Config.player_teleport_protection * GameTimer::TICKS_PER_SECOND)
    else
      @teleport_protect_end_time = 0
    end
  end

  def recent_fake_death=(protect : Bool)
    if protect
      @recent_fake_death_end_time = GameTimer.ticks + (Config.player_fakedeath_up_protection * GameTimer::TICKS_PER_SECOND)
    else
      @recent_fake_death_end_time = 0
    end
  end

  def recent_fake_death? : Bool
    @recent_fake_death_end_time > GameTimer.ticks
  end

  def on_player_enter
    start_warn_user_take_break

    if SevenSigns.instance.seal_validation_period? || SevenSigns.instance.comp_results_period?
      if !gm? && in_7s_dungeon?
        if SevenSigns.instance.get_player_cabal(l2id) != SevenSigns.instance.cabal_highest_score
          tele_to_location(TeleportWhereType::TOWN)
          self.in_7s_dungeon = false
          send_message("You have been teleported to the nearest town due to the beginning of the Seal Validation period.")
        end
      end
    else
      if !gm? && in_7s_dungeon?
        if SevenSigns.instance.get_player_cabal(l2id) == SevenSigns::CABAL_NULL
          tele_to_location(TeleportWhereType::TOWN)
          self.in_7s_dungeon = false
          send_message("You have been teleported to the nearest town because you have not signed for any cabal.")
        end
      end
    end

    if gm?
      if invul?
        send_message("Entering world in invulnerable mode.")
      end
      if invisible?
        send_message("Entering world in invisible mode.")
      end

      if silence_mode?
        send_message("Entering world in silence mode.")
      end
    end

    revalidate_zone(true)

    notify_friends

    if Config.decrease_skill_level && !override_skill_conditions?
      check_player_skills
    end

    begin
      ZoneManager.get_zones(self) do |zone|
        zone.on_player_login_inside(self)
      end
    rescue e
      error e
    end

    OnPlayerLogin.new(self).async(self)
  end

  # The in_boat? check and ValidateLocationInVehicle is custom and works as
  # expected. Probably should give L2J the heads up.
  def target=(new_target : L2Object?)
    if new_target
      in_party = new_target.player? && party.try &.includes?(new_target)

      new_target = nil if !in_party && (new_target.z - z).abs > 1000
      new_target = nil if new_target && !in_party && !new_target.visible?
      new_target = nil if !gm? && new_target.is_a?(L2Vehicle)
    end

    old_target = target

    if old_target
      if old_target == new_target
        if new_target && new_target != self
          validate_location_of(new_target)
        end

        return
      end

      old_target.remove_status_listener(self)
    end

    if new_target.is_a?(L2Character)
      target = new_target
      if new_target != self
        validate_location_of(target)
      end
      send_packet(MyTargetSelected.new(self, target))
      target.add_status_listener(self)
      send_packet(StatusUpdate.hp(target))
      ts = TargetSelected.new(l2id, new_target.l2id, x, y, z)
      Broadcast.to_known_players(self, ts)
    end

    if !new_target && target()
      broadcast_packet(TargetUnselected.new(self))
    end

    super
  end

  private def validate_location_of(obj : L2Object)
    if obj.is_a?(L2PcInstance)
      if obj.in_boat?
        send_packet(ValidateLocationInVehicle.new(obj))
        return
      elsif obj.in_airship?
        send_packet(ExValidateLocationInAirship.new(obj))
        return
      end
    end

    send_packet(ValidateLocation.new(obj))
  end

  def on_teleported
    super

    airship.try &.send_info(self)

    revalidate_zone(true)

    check_item_restriction

    if Config.player_teleport_protection > 0 && !in_olympiad_mode?
      self.teleport_protection = true
    end

    if has_tamed_beasts?
      tamed_beasts.each &.delete_me
      tamed_beasts.clear
    end

    if sum = summon
      sum.follow_status = false
      sum.tele_to_location(location, false)
      sum.ai.as(L2SummonAI).start_follow_controller = true
      sum.follow_status = true
      sum.update_and_broadcast_status(0)
    end

    TvTEvent.on_teleported(self)
  end

  def teleporting=(tele : Bool)
    set_teleporting(tele, true)
  end

  def set_teleporting(tele : Bool, watch : Bool)
    super(tele)

    return unless watch

    if tele
      if @teleport_watchdog && Config.teleport_watchdog_timeout > 0
        sync do
          @teleport_watchdog ||=
          ThreadPoolManager.schedule_general(
            TeleportWatchdogTask.new(self), Config.teleport_watchdog_timeout
          )
        end
      end
    else
      if task = @teleport_watchdog
        task.cancel
        @teleport_watchdog = nil
      end
    end
  end

  def cursed_weapon_equipped? : Bool
    @cursed_weapon_equipped_id != 0
  end

  def charges : Int32
    @charges.get
  end

  def clear_warehouse
    if warehouse = @warehouse
      warehouse.delete_me
      @warehouse = nil
    end
  end

  def has_refund? : Bool
    return false unless Config.allow_refund
    return false unless refund = @refund
    refund.size > 0
  end

  def clear_refund
    if refund = @refund
      refund.delete_me
      @refund = nil
    end
  end

  def clan=(clan : L2Clan?)
    @clan = clan

    unless clan
      @clan_id = 0
      @clan_privileges = EnumBitmask(ClanPrivilege).new(false)
      @pledge_type = 0
      @power_grade = 0
      @lvl_joined_academy = 0
      @apprentice = 0
      @sponsor = 0
      @active_warehouse = nil
      return
    end

    unless clan.member?(l2id)
      self.clan = nil
      return
    end

    @clan_id = clan.id
  end

  def spawn_protected? : Bool
    @protect_end_time > GameTimer.ticks
  end

  def teleport_protected? : Bool
    @teleport_protect_end_time > GameTimer.ticks
  end

  def on_action_request
    if spawn_protected?
      send_packet(SystemMessageId::YOU_ARE_NO_LONGER_PROTECTED_FROM_AGGRESSIVE_MONSTERS)

      if Config.restore_servitor_on_reconnect && !has_summon?
        if SummonTable.servitors.has_key?(l2id)
          SummonTable.restore_servitor(self)
        end
      end

      if Config.restore_pet_on_reconnect && !has_summon?
        if SummonTable.pets.has_key?(l2id)
          SummonTable.restore_pet(self)
        end
      end
    end

    if teleport_protected?
      send_message("Teleport spawn protection ended.")
    end

    self.protection = false
    self.teleport_protection = false
  end

  def auto_attackable?(attacker : L2Character) : Bool
    return false if attacker == self || attacker == summon
    return false if attacker.is_a?(L2FriendlyMobInstance)
    return true if attacker.monster?

    attacker_pc = attacker.acting_player
    if attacker.playable? && attacker_pc && duel_state.duelling?
      if duel_id == attacker_pc.duel_id
        if duel = DuelManager.get_duel(duel_id)
          if duel.team_a.includes?(self) && duel.team_a.includes?(attacker)
            return false
          elsif duel.team_b.includes?(self) && duel.team_b.includes?(attacker)
            return false
          end

          return true
        end
      end
    end

    if party.try &.members.includes?(attacker)
      return false
    end

    if attacker.is_a?(L2PcInstance) && attacker.in_olympiad_mode?
      if in_olympiad_mode? && olympiad_start?
        if attacker.olympiad_game_id == olympiad_game_id
          return true
        end
      end

      return false
    end

    return true if on_event?

    if attacker.playable? && inside_peace_zone?
      return false
    end

    if attacker.playable? && attacker_pc
      if inside_peace_zone?
        return false
      end

      if clan = clan()
        siege = SiegeManager.get_siege(*xyz)
        attacker_pc_clan = attacker_pc.clan
        if siege && attacker_pc_clan
          if siege.defender?(attacker_pc_clan) && siege.defender?(clan)
            return false
          end

          if siege.attacker?(attacker_pc_clan) && siege.attacker?(clan)
            return false
          end
        end

        if attacker_pc_clan && clan.at_war_with?(attacker_pc.clan_id)
          if attacker_pc_clan.at_war_with?(clan_id) && wants_peace == 0
            if attacker_pc.wants_peace == 0 && !academy_member?
              return true
            end
          end
        end
      end

      if inside_pvp_zone? && attacker_pc.inside_pvp_zone?
        unless inside_siege_zone? || attacker_pc.inside_siege_zone?
          return true
        end
      end

      if clan.try &.member?(attacker.l2id)
        return false
      end

      if attacker.player? && ally_id != 0 && ally_id == attacker_pc.ally_id
        return false
      end

      if inside_pvp_zone? && attacker_pc.inside_pvp_zone?
        if inside_siege_zone? && attacker_pc.inside_siege_zone?
          return true
        end
      end
    elsif attacker.is_a?(L2DefenderInstance)
      if clan = clan()
        siege = SiegeManager.get_siege(self)
        return !!siege && siege.attacker?(clan)
      end
    end

    karma > 0 || pvp_flag > 0
  end

  def can_attack_character?(char : L2Character) : Bool
    case char
    when L2Attackable
      return true
    when L2Playable
      if char.inside_pvp_zone? && !char.inside_siege_zone?
        return true
      end

      if char.is_a?(L2Summon)
        target = char.owner
      else
        target = char
      end

      if in_duel? && target.in_duel? && target.duel_id == duel_id
        return true
      elsif (party = party()) && (target_party = target.party)
        if party == target_party
          return false
        end
        cc = party.command_channel
        if cc && cc == target_party.command_channel
          return false
        end
      elsif (clan = clan()) && (target_clan = target.clan)
        if clan_id == target.clan_id
          return false
        end
        if (ally_id > 0 || target.ally_id > 0) && ally_id == target.ally_id
          return false
        end
        if clan.at_war_with?(target_clan.id) && target_clan.at_war_with?(clan.id)
          return true
        end
      elsif clan? || target.clan
        if target.pvp_flag == 0 && target.karma == 0
          return false
        end
      end
    end

    true
  end

  def processing_request? : Bool
    !!active_requester || @request_expire_time > GameTimer.ticks
  end

  def processing_transaction? : Bool
    !!active_requester ||
    !!active_trade_list ||
    @request_expire_time > GameTimer.ticks
  end

  def on_transaction_request(partner : L2PcInstance)
    @request_expire_time = GameTimer.ticks + (REQUEST_TIMEOUT * GameTimer::TICKS_PER_SECOND)
    partner.active_requester = self
  end

  def active_requester : L2PcInstance?
    if requester = @active_requester
      if requester.request_expired? && !@active_trade_list
        @active_requester = nil
      end
    end

    @active_requester
  end

  def request_expired? : Bool
    !(@request_expire_time > GameTimer.ticks)
  end

  def on_transaction_response
    @request_expire_time = 0
  end

  def on_trade_start(partner : L2PcInstance)
    trade_list = TradeList.new(self)
    trade_list.partner = partner
    @active_trade_list = trade_list

    sm = SystemMessage.begin_trade_with_c1
    sm.add_pc_name(partner)
    send_packet(sm)
    send_packet(TradeStart.new(self))
  end

  def on_trade_confirm(partner : L2PcInstance)
    sm = SystemMessage.c1_confirmed_trade
    sm.add_pc_name(partner)
    send_packet(sm)
    send_packet(TradeOtherDone::STATIC_PACKET)
  end

  def on_trade_cancel(partner : L2PcInstance)
    return unless list = @active_trade_list

    list.lock
    @active_trade_list = nil

    send_packet(TradeDone::CANCEL)
    sm = SystemMessage.c1_canceled_trade
    sm.add_pc_name(partner)
    send_packet(sm)
  end

  def on_trade_finish(success : Bool)
    @active_trade_list = nil
    send_packet(TradeDone::ACCEPT)
    if success
      send_packet(SystemMessageId::TRADE_SUCCESSFUL)
    end
  end

  def start_trade(partner : L2PcInstance)
    on_trade_start(partner)
    partner.on_trade_start(self)
  end

  def cancel_active_trade
    return unless trade_list = @active_trade_list

    if partner = trade_list.partner
      partner.on_trade_cancel(self)
    end

    on_trade_cancel(self)
  end

  def check_item_manipulation(id : Int32, count : Int64, action : String) : L2ItemInstance?
    unless L2World.find_object(id)
      warn { "Tried to #{action} item not found in L2World." }
      return
    end

    item = inventory.get_item_by_l2id(id)

    if !item || item.owner_id != l2id
      warn { "Tried to #{action} item that belongs to somebody else." }
      return
    end

    if count < 0 || (count > 1 && !item.stackable?)
      warn { "Tried to #{action} item with invalid count: #{count}." }
      return
    end

    if count > item.count
      warn { "Tried to #{action} more items than owned: #{count}/#{item.count}." }
      return
    end

    if ((smn = summon) && smn.control_l2id == id) || mount_l2id == id
      debug { "Tried to #{action} pet control item." }

      return
    end

    if active_enchant_item_id == id
      debug { "Tried to #{action} an enchant scroll in use." }

      return
    end

    if item.augmented? && (casting_now? || casting_simultaneously_now?)
      return
    end

    item
  end

  def set_multi_social_action(id : Int32, target_id : Int32)
    @multi_social_action = id
    @multi_social_target = target_id
  end

  def use_equippable_item(item : L2ItemInstance, abort_attack : Bool)
    equipped = item.equipped?
    old_inv_limit = inventory_limit

    if equipped
      if item.enchant_level > 0
        sm = SystemMessage.equipment_s1_s2_removed
        sm.add_int(item.enchant_level)
        sm.add_item_name(item)
      else
        sm = SystemMessage.s1_disarmed
        sm.add_item_name(item)
      end
      send_packet(sm)

      slot = inventory.get_slot_from_item(item)
      if slot == L2Item::SLOT_DECO
        items = inventory.unequip_item_in_slot_and_record(item.location_slot)
      else
        items = inventory.unequip_item_in_body_slot_and_record(slot)
      end
    else
      items = inventory.equip_item_and_record(item)
      if item.equipped?
        if item.enchant_level > 0
          sm = SystemMessage.s1_s2_equipped
          sm.add_int(item.enchant_level)
          sm.add_item_name(item)
        else
          sm = SystemMessage.s1_equipped
          sm.add_item_name(item)
        end

        send_packet(sm)
      else
        send_packet(SystemMessageId::CANNOT_EQUIP_ITEM_DUE_TO_BAD_CONDITION)
      end

      item.decrease_mana(false)

      if item.template.body_part & L2Item::SLOT_MULTI_ALLWEAPON != 0
        recharge_shots(true, true)
      end
    end

    refresh_expertise_penalty

    broadcast_user_info

    iu = InventoryUpdate.new
    iu.add_items(items)
    send_packet(iu)

    abort_attack() if abort_attack

    if inventory_limit != old_inv_limit
      send_packet(ExStorageMaxCount.new(self))
    end

    OnPlayerEquipItem.new(self, item).async(self)
  end

  def query_game_guard
    if client = client()
      client.game_guard_ok = false
      send_packet(GameGuardQuery::STATIC_PACKET)
    end

    if Config.gameguard_enforce
      task = GameGuardCheckTask.new(self)
      ThreadPoolManager.schedule_general(task, 30 * 1000)
    end
  end

  def html_prefix : String?
    if Config.multilang_enable
      @html_prefix
    end
  end

  def set_lang(lang : String) : Bool
    result = false

    if Config.multilang_enable
      if Config.multilang_allowed.includes?(lang)
        @lang = lang
        result = true
      else
        @lang = Config.multilang_default
      end

      @html_prefix = "data/lang/#{@lang}/"
    else
      @lang = nil
      @html_prefix = nil
    end

    result
  end

  def flood_protectors : FloodProtectors
    client.not_nil!.flood_protectors
  end

  def check_reco_bonus_task
    task_time = GameDB.recommendation_bonus.load(self)

    if task_time > 0
      if task_time == 3_600_000
        self.recom_left += 20
      end

      @reco_bonus_task = ThreadPoolManager.schedule_general(
        RecoBonusTaskEnd.new(self), task_time
      )
    end

    @reco_give_task = ThreadPoolManager.schedule_general_at_fixed_rate(
      RecoGiveTask.new(self), 7_200_000, 3_600_000
    )

    store_recommendations
  end

  def store_recommendations
    if task = @reco_bonus_task
      task_end = Math.max(task.delay, 0i64)
    else
      task_end = 0i64
    end

    GameDB.recommendation_bonus.insert(self, task_end)
  end

  def mount(pet : L2Summon) : Bool
    return false if !disarm_weapons || !disarm_shield || transformed?
    effect_list.stop_all_toggles
    set_mount(pet.id, pet.level)
    self.mount_l2id = pet.control_l2id
    start_feed(pet.id)
    pet.unsummon(self)
    broadcast_packet(Ride.new(self))
    broadcast_user_info

    true
  end

  def mount(npc_id : Int32, control_item_l2id : Int32, use_food : Bool) : Bool
    return false if !disarm_weapons || !disarm_shield || transformed?
    effect_list.stop_all_toggles
    set_mount(npc_id, level)
    self.mount_l2id = control_item_l2id
    if use_food
      start_feed(npc_id)
    end
    broadcast_packet(Ride.new(self))
    broadcast_user_info

    true
  end

  def mount_player(pet : L2Summon?) : Bool
    if pet && pet.mountable? && !mounted? && !betrayed?
      case
      when dead?
        action_failed
        send_packet(SystemMessageId::STRIDER_CANT_BE_RIDDEN_WHILE_DEAD)
        return false
      when pet.dead?
        action_failed
        send_packet(SystemMessageId::DEAD_STRIDER_CANT_BE_RIDDEN)
        return false
      when pet.in_combat? || pet.rooted?
        action_failed
        send_packet(SystemMessageId::STRIDER_IN_BATTLE_CANT_BE_RIDDEN)
        return false
      when in_combat?
        action_failed
        send_packet(SystemMessageId::STRIDER_CANT_BE_RIDDEN_WHILE_IN_BATTLE)
        return false
      when sitting?
        action_failed
        send_packet(SystemMessageId::STRIDER_CAN_BE_RIDDEN_ONLY_WHILE_STANDING)
        return false
      when fishing?
        action_failed
        send_packet(SystemMessageId::CANNOT_DO_WHILE_FISHING_2)
        return false
      when transformed? || cursed_weapon_equipped?
        action_failed
        return false
      when inventory.get_item_by_item_id(9819)
        # Wrong message on L2J's part
        send_message("You cannot mount a steed while holding a flag.")
        return false
      when pet.hungry?
        action_failed
        send_packet(SystemMessageId::HUNGRY_STRIDER_NOT_MOUNT)
        return false
      when !Util.in_range?(200, self, pet, true)
        action_failed
        send_packet(SystemMessageId::TOO_FAR_AWAY_FROM_FENRIR_TO_MOUNT)
        return false
      when pet.alive? && !mounted?
        mount(pet)
      end
    elsif rented_pet?
      stop_rent_pet
    elsif mounted?
      if mount_type.wyvern? && inside_no_landing_zone?
        action_failed
        send_packet(SystemMessageId::NO_DISMOUNT_HERE)
        return false
      elsif hungry?
        action_failed
        send_packet(SystemMessageId::HUNGRY_STRIDER_NOT_MOUNT)
        return false
      else
        dismount
      end
    end

    true
  end

  def check_landing_state : Bool
    if inside_no_landing_zone?
      return true
    else
      if inside_siege_zone? && (clan = clan())
        if CastleManager.get_castle(self) == CastleManager.get_castle_by_owner(clan)
          if self == clan.leader.player_instance
            return true
          end
        end
      end
    end

    false
  end

  def dismount : Bool
    was_flying = flying?

    send_packet(SetupGauge.green(0, 0))
    pet_id = @mount_npc_id
    set_mount(0, 0)
    stop_feed
    if was_flying
      remove_skill(CommonSkill::WYVERN_BREATH.skill)
    end
    broadcast_packet(Ride.new(self))
    self.mount_l2id = 0
    GameDB.pet.update_food(self, pet_id)
    broadcast_user_info
    true
  end

  def set_mount(npc_id : Int32, npc_level : Int32)
    type = MountType.find_by_npc_id(npc_id)
    case type
    when MountType::NONE
      self.flying = false
    when MountType::STRIDER
      if noble?
        add_skill(CommonSkill::STRIDER_SIEGE_ASSAULT.skill, false)
      end
    when MountType::WYVERN
      self.flying = true
    end

    @mount_type = type
    @mount_npc_id = npc_id
    @mount_level = npc_level
  end

  def current_feed=(num : Int32)
    last_hungry_state = hungry?
    @current_feed = num > max_feed ? max_feed : num
    sg = SetupGauge.green(
      (current_feed * 10_000) / feed_consume, (max_feed * 10_000) / feed_consume
    )
    send_packet(sg)
    if last_hungry_state != hungry?
      broadcast_user_info
    end
  end

  def start_feed(npc_id : Int32)
    @can_feed = npc_id > 0
    return unless mounted?
    if has_summon?
      self.current_feed = summon.as(L2PetInstance).current_feed
      @control_item_id = summon.as(L2PetInstance).control_l2id
      sg = SetupGauge.green(
        (current_feed * 10_000) // feed_consume,
        (max_feed * 10_000) // feed_consume
      )
      send_packet(sg)
      if alive?
        @mount_feed_task = ThreadPoolManager.schedule_general_at_fixed_rate(
          PetFeedTask.new(self), 10_000, 10_000
        )
      end
    elsif @can_feed
      self.current_feed = max_feed
      sg = SetupGauge.green(
        (current_feed * 10_000) // feed_consume,
        (max_feed * 10_000) // feed_consume
      )
      send_packet(sg)
      if alive?
        @mount_feed_task = ThreadPoolManager.schedule_general_at_fixed_rate(
          PetFeedTask.new(self), 10_000, 10_000
        )
      end
    end
  end

  def stop_feed
    if task = @mount_feed_task
      task.cancel
      @mount_feed_task = nil
    end
  end

  def max_feed : Int32
    get_pet_level_data(@mount_npc_id).pet_max_feed
  end

  def feed_consume : Int32
    data = get_pet_level_data(@mount_npc_id)
    attacking_now? ? data.pet_feed_battle : data.pet_feed_normal
  end

  def current_feed=(num : Int32)
    last_hungry_state = hungry?
    @current_feed = num > max_feed ? max_feed : num
    sg = SetupGauge.green(
      (current_feed * 10_000) // feed_consume,
      (max_feed * 10_000) // feed_consume
    )
    send_packet(sg)
    if last_hungry_state != hungry?
      broadcast_user_info
    end
  end

  def hungry? : Bool
    if @can_feed
      data = PetDataTable.get_pet_data(mount_npc_id)
      return current_feed < data.hungry_limit.fdiv(100) * get_pet_level_data(mount_npc_id).pet_max_feed
    end

    false
  end

  def entered_no_landing(delay : Int)
    task = DismountTask.new(self)
    @dismount_task = ThreadPoolManager.schedule_general(task, delay.to_i64 * 1000)
  end

  def exited_no_landing
    if task = @dismount_task
      task.cancel
      @dismount_task = nil
    end
  end

  def get_pet_level_data(npc_id : Int32) : L2PetLevelData?
    @level_data ||=
    PetDataTable.get_pet_data(npc_id).get_pet_level_data(mount_level)
  end

  def rented_pet? : Bool
    !!@rent_pet_task
  end

  def uptime : Int64
    Time.ms - @uptime
  end

  def invul? : Bool
    super || @teleporting
  end

  def vehicle=(vehicle : L2Vehicle?)
    unless vehicle
      @vehicle.try &.remove_passenger(self)
    end

    @vehicle = vehicle
  end

  def boat : L2BoatInstance?
    @vehicle.as?(L2BoatInstance)
  end

  def boat! : L2BoatInstance
    boat.not_nil!
  end

  def has_clan_privilege?(priv : ClanPrivilege) : Bool
    @clan_privileges.has?(priv)
  end

  def clan_privileges=(privs : EnumBitmask(ClanPrivilege))
    @clan_privileges = privs.clone
  end

  def stop_all_timers
    stop_hp_mp_regeneration
    stop_warn_user_take_break
    stop_water_task
    stop_feed
    GameDB.pet.update_food(self, @mount_npc_id)
    stop_rent_pet
    stop_pvp_reg_task
    stop_soul_task
    stop_charge_task
    stop_fame_task
    stop_vitality_task
    stop_reco_bonus_task
    stop_reco_give_task
  end

  def tamed_beasts : Interfaces::Set(L2TamedBeastInstance)
    @tamed_beasts || sync do
      @tamed_beasts ||= Concurrent::Set(L2TamedBeastInstance).new
    end
  end

  def has_tamed_beasts? : Bool
    return false unless tmp = @tamed_beasts
    !tmp.empty?
  end

  def add_tamed_beast(tamed_beast : L2TamedBeastInstance)
    tamed_beasts << tamed_beast
  end

  def remove_tamed_beast(tamed_beast : L2TamedBeastInstance)
    if has_tamed_beasts?
      tamed_beasts.delete(tamed_beast)
    end
  end

  def stop_reco_bonus_task
    if task = @reco_bonus_task
      task.cancel
      @reco_bonus_task = nil
    end
  end

  def stop_reco_give_task
    if task = @reco_give_task
      task.cancel
      @reco_give_task = nil
    end
  end

  def stop_rent_pet
    if task = @rent_pet_task
      if check_landing_state && mount_type.wyvern?
        tele_to_location(TeleportWhereType::TOWN)
      end

      if dismount
        task.cancel
        @rent_pet_task = nil
      end
    end
  end

  def start_rent_pet(seconds : Int32)
    unless @rent_pet_task
      task = RentPetTask.new(self)
      seconds *= 1000
      @rent_pet_task = ThreadPoolManager.schedule_general_at_fixed_rate(task, seconds, seconds)
    end
  end

  def rented_pet? : Bool
    !!@rent_pet_task
  end

  def pledge_class=(class_id : Int32)
    @pledge_class = class_id
    check_item_restriction
  end

  def in_offline_mode? : Bool
    return true unless client = @client
    client.detached?
  end

  def active_enchant_item_id=(l2id : Int32)
    if l2id == ID_NONE
      self.active_enchant_support_item_id = ID_NONE
      self.active_enchant_timestamp = 0
      self.enchanting = false
    end

    @active_enchant_item_id = l2id
  end

  def can_make_social_action? : Bool
    private_store_type.none? &&
    !active_requester &&
    !looks_dead? &&
    !all_skills_disabled? &&
    !casting_now? &&
    !casting_simultaneously_now? &&
    intention.idle?
  end

  def can_revive? : Bool
    @event_listeners.each do |listener|
      if listener.on_event? && !listener.can_revive?
        return false
      end
    end

    @can_revive
  end

  def on_event? : Bool
    @event_listeners.each do |listener|
      if listener.on_event?
        return true
      end
    end

    super
  end

  def blocked_from_death_penalty? : Bool
    @event_listeners.any? { |l| l.on_event? && l.blocking_death_penalty? }
  end

  def blocked_from_exit? : Bool
    @event_listeners.any? { |l| l.on_event? && l.blocking_exit? }
  end

  def in_water? : Bool
    !!@water_task
  end

  def in_vehicle? : Bool
    !!@vehicle
  end

  def in_duel? : Bool
    !@duel_state.no_duel?
  end

  def in_duel=(duel_id : Int32)
    if duel_id > 0
      @duel_id = duel_id
      @duel_state = DuelState::DUELLING
    else
      if @duel_state.dead?
        enable_all_skills
        status.start_hp_mp_regeneration
      end

      @duel_id = 0
      @duel_state = DuelState::NO_DUEL
    end
  end

  def in_duel_with?(char : L2Character) : Bool
    in_duel? && char.in_duel? && duel_id == char.duel_id
  end

  def on_same_siege_side?(char : L2Character) : Bool
    @siege_state > 0 &&
    inside_siege_zone? &&
    @siege_state == char.siege_state &&
    @siege_side == char.siege_side
  end

  def in_ally_with?(char : L2Character) : Bool
    ally_id != 0 && ally_id == char.ally_id
  end

  def in_clan_with?(char : L2Character) : Bool
    clan_id != 0 && clan_id == char.clan_id
  end

  def on_same_siege_side_with?(char : L2Character) : Bool
    siege_state > 0 &&
    inside_siege_zone? &&
    siege_state == char.siege_state &&
    siege_side == char.siege_side
  end

  def can_open_private_store? : Bool
    !looks_dead? && !in_olympiad_mode? && !mounted? &&
    !inside_no_store_zone? && !casting_now?
  end

  def try_open_private_buy_store
    if can_open_private_store?
      if private_store_type.buy? || private_store_type.buy_manage?
        self.private_store_type = PrivateStoreType::NONE
      end

      if private_store_type.none?
        if sitting?
          stand_up
        end

        self.private_store_type = PrivateStoreType::BUY_MANAGE
        send_packet(PrivateStoreManageListBuy.new(self))
      end
    else
      if inside_no_store_zone?
        send_packet(SystemMessageId::NO_PRIVATE_STORE_HERE)
      end

      action_failed
    end
  end

  def try_open_private_sell_store(package_sale : Bool)
    if can_open_private_store?
      if private_store_type.sell? || private_store_type.sell_manage? || private_store_type.package_sell?
        self.private_store_type = PrivateStoreType::NONE
      end

      if private_store_type.none?
        if sitting?
          stand_up
        end

        self.private_store_type = PrivateStoreType::SELL_MANAGE
        send_packet(PrivateStoreManageListSell.new(self, package_sale))
      end
    else
      if inside_no_store_zone?
        send_packet(SystemMessageId::NO_PRIVATE_STORE_HERE)
      end

      action_failed
    end
  end

  def sell_list : TradeList
    @sell_list ||= TradeList.new(self)
  end

  def buy_list : TradeList
    @buy_list ||= TradeList.new(self)
  end

  def store_name=(name : String?)
    @store_name = name || ""
  end

  def private_store_type=(type : PrivateStoreType)
    @private_store_type = type

    if Config.offline_disconnect_finished && type.none?
      client = @client
      if client.nil? || client.detached?
        delete_me
      end
    end
  end

  def has_manufacture_shop? : Bool
    return false unless temp = @manufacture_items
    !temp.empty?
  end

  def warehouse : PcWarehouse
    wh = @warehouse ||= PcWarehouse.new(self).tap &.restore

    if Config.warehouse_cache
      WarehouseCache.add_cache_task(self)
    end

    wh
  end

  def warehouse_limit : Int32
    if race.dwarf?
      limit = Config.warehouse_slots_dwarf
    else
      limit = Config.warehouse_slots_no_dwarf
    end

    limit + calc_stat(Stats::WH_LIM, 0).to_i
  end

  def private_sell_store_limit : Int32
    if race.dwarf?
      Config.max_pvtstoresell_slots_dwarf
    else
      Config.max_pvtstoresell_slots_other
    end + calc_stat(Stats::P_SELL_LIM, 0).to_i
  end

  def private_buy_store_limit : Int32
    if race.dwarf?
      Config.max_pvtstorebuy_slots_dwarf
    else
      Config.max_pvtstorebuy_slots_other
    end + calc_stat(Stats::P_BUY_LIM, 0).to_i
  end

  def dwarf_recipe_limit : Int32
    Config.dwarf_recipe_limit + calc_stat(Stats::REC_D_LIM, 0).to_i
  end

  def common_recipe_limit : Int32
    Config.common_recipe_limit + calc_stat(Stats::REC_C_LIM, 0).to_i
  end

  def common_recipe_book : Slice(L2RecipeList)
    @common_recipe_book.values_slice
  end

  def dwarven_recipe_book : Slice(L2RecipeList)
    @dwarven_recipe_book.values_slice
  end

  def register_common_recipe_list(recipe : L2RecipeList, save_to_db : Bool)
    @common_recipe_book[recipe.id] = recipe
    if save_to_db
      GameDB.recipe_book.insert(self, recipe.id, false)
    end
  end

  def register_dwarven_recipe_list(recipe : L2RecipeList, save_to_db : Bool)
    @dwarven_recipe_book[recipe.id] = recipe
    if save_to_db
      GameDB.recipe_book.insert(self, recipe.id, true)
    end
  end

  def has_recipe_list?(recipe_id : Int) : Bool
    @dwarven_recipe_book.has_key?(recipe_id) ||
    @common_recipe_book.has_key?(recipe_id)
  end

  def unregister_recipe_list(recipe_id : Int)
    if @dwarven_recipe_book.delete(recipe_id)
      GameDB.recipe_book.delete(self, recipe_id, true)
    elsif @common_recipe_book.delete(recipe_id)
      GameDB.recipe_book.delete(self, recipe_id, false)
    else
      warn { "Attempted to remove a recipe with id #{recipe_id} that #{name} doesn't know." }
    end

    all_shortcuts.each do |sc|
      if sc.id == recipe_id && sc.type.recipe?
        delete_shortcut(sc.slot, sc.page)
      end
    end
  end

  def notify_friends
    return unless has_friends?

    fsp = FriendStatusPacket.new(l2id)

    friends.each do |id|
      if friend = L2World.get_player(id)
        friend.send_packet(fsp)
      end
    end
  end

  def jailed? : Bool
    PunishmentManager.has_punishment?(l2id, PunishmentAffect::CHARACTER, PunishmentType::JAIL) ||
    PunishmentManager.has_punishment?(account_name, PunishmentAffect::ACCOUNT, PunishmentType::JAIL) ||
    PunishmentManager.has_punishment?(ip_address, PunishmentAffect::IP, PunishmentType::JAIL)
  end

  def chat_banned? : Bool
    PunishmentManager.has_punishment?(l2id, PunishmentAffect::CHARACTER, PunishmentType::CHAT_BAN) ||
    PunishmentManager.has_punishment?(account_name, PunishmentAffect::ACCOUNT, PunishmentType::CHAT_BAN) ||
    PunishmentManager.has_punishment?(ip_address, PunishmentAffect::IP, PunishmentType::CHAT_BAN)
  end

  def silence_mode?(pc_id : Int32) : Bool
    if Config.silence_mode_exclude && @silence_mode && @silence_mode_excluded
      !@silence_mode_excluded.not_nil!.includes?(pc_id)
    else
      @silence_mode
    end
  end

  def silence_mode=(@silence_mode : Bool)
    @silence_mode_excluded.try &.clear
    send_packet(EtcStatusUpdate.new(self))
  end

  def add_silence_mode_excluded(pc_id : Int32)
    if temp = @silence_mode_excluded
      temp << pc_id
    else
      @silence_mode_excluded = [pc_id]
    end
  end

  def transformed? : Bool
    return false unless t = @transformation
    !t.stance?
  end

  def in_stance? : Bool
    return false unless t = @transformation
    t.stance?
  end

  def transform(transformation : Transform)
    if @transformation
      sm = SystemMessageId::YOU_ALREADY_POLYMORPHED_AND_CANNOT_POLYMORPH_AGAIN
      send_packet(sm)
      return
    end

    set_queued_skill(nil, false, false)

    dismount if mounted?

    @transformation = transformation
    effect_list.stop_all_toggles
    transformation.on_transform(self)
    send_skill_list
    send_packet(SkillCoolTime.new(self))
    broadcast_user_info

    OnPlayerTransform.new(self, transformation.id).async(self)
  end

  def untransform
    return unless transformation = @transformation
    set_queued_skill(nil, false, false)
    transformation.on_untransform(self)
    @transformation = nil
    effect_list.stop_all_toggles(false)
    effect_list.stop_skill_effects(false, AbnormalType::TRANSFORM)
    send_skill_list
    send_packet(SkillCoolTime.new(self))
    broadcast_user_info

    OnPlayerTransform.new(self, 0).async(self)
  end

  def stop_all_effects
    super
    update_and_broadcast_status(2)
  end

  def stop_all_effects_except_those_that_last_through_death
    super
    update_and_broadcast_status(2)
  end

  def stop_all_effects_not_stay_on_subclass_change
    effect_list.stop_all_effects_not_stay_on_subclass_change
    update_and_broadcast_status(2)
  end

  def inventory_blocking_status=(@inventory_disabled : Bool)
    if @inventory_disabled
      task = InventoryEnableTask.new(self)
      ThreadPoolManager.schedule_general(task, 1500)
    end
  end

  def start_vitality_task
    if Config.enable_vitality && !@vitality_task
      task = VitalityTask.new(self)
      @vitality_task = ThreadPoolManager.schedule_general_at_fixed_rate(task, 1000, 60_000)
    end
  end

  def stop_vitality_task
    if task = @vitality_task
      task.cancel
      @vitality_task = nil
    end
  end

  def start_fame_task(delay : Int64, fame_fix_rate : Int32)
    if level < 40 || class_id.level < 2
      return
    end

    unless @fame_task
      task = FameTask.new(self, fame_fix_rate)
      @fame_task = ThreadPoolManager.schedule_general_at_fixed_rate(task, delay, delay)
    end
  end

  def stop_fame_task
    if task = @fame_task
      task.cancel
      @fame_task = nil
    end
  end

  def falling?(z : Int32) : Bool
    if dead? || flying? || flying_mounted? || inside_water_zone?
      return false
    end

    if Time.ms < @falling_timestamp
      return true
    end

    delta_z = z() - z
    if delta_z <= base_template.safe_fall_height
      return false
    end

    unless GeoData.has_geo?(x, y)
      return false
    end

    damage = Formulas.fall_dam(self, delta_z).to_i
    if damage > 0
      reduce_current_hp(Math.min(damage, current_hp - 1).to_f64, nil, false, true, nil)
      sm = SystemMessage.fall_damage_s1
      sm.add_int(damage)
      send_packet(sm)
    end

    set_falling

    false
  end

  def set_falling
    @falling_timestamp = Time.ms + FALLING_VALIDATION_DELAY
  end

  def start_water_task
    if alive? && @water_task.nil?
      time_in_water = calc_stat(Stats::BREATH, 60_000, self)
      send_packet(SetupGauge.cyan(time_in_water.to_i32))
      task = WaterTask.new(self)
      @water_task = ThreadPoolManager.schedule_effect_at_fixed_rate(task, time_in_water, 1000)
    end
  end

  def stop_water_task
    if task = @water_task
      task.cancel
      @water_task = nil
      send_packet(SetupGauge.cyan(0))
    end
  end

  def check_water_state
    if inside_water_zone?
      start_water_task
    else
      stop_water_task
    end
  end

  def revalidate_zone(force : Bool)
    return unless reg = world_region

    if force
      @zone_validate_counter = 4i8
    else
      @zone_validate_counter &-= 1i8
      if @zone_validate_counter < 0
        @zone_validate_counter = 4i8
      else
        return
      end
    end

    reg.revalidate_zones(self)

    if Config.allow_water
      check_water_state
    end

    case
    when inside_altered_zone?
      if @last_compass_zone == ExSetCompassZoneCode::ALTEREDZONE
        return
      end
      @last_compass_zone = ExSetCompassZoneCode::ALTEREDZONE
      cz = ExSetCompassZoneCode.new(ExSetCompassZoneCode::ALTEREDZONE)
    when inside_siege_zone?
      if @last_compass_zone == ExSetCompassZoneCode::SIEGEWARZONE2
        return
      end
      @last_compass_zone = ExSetCompassZoneCode::SIEGEWARZONE2
      cz = ExSetCompassZoneCode.new(ExSetCompassZoneCode::SIEGEWARZONE2)
    when inside_pvp_zone?
      if @last_compass_zone == ExSetCompassZoneCode::PVPZONE
        return
      end
      @last_compass_zone = ExSetCompassZoneCode::PVPZONE
      cz = ExSetCompassZoneCode.new(ExSetCompassZoneCode::PVPZONE)
    when in_7s_dungeon?
      if @last_compass_zone == ExSetCompassZoneCode::SEVENSIGNSZONE
        return
      end
      @last_compass_zone = ExSetCompassZoneCode::SEVENSIGNSZONE
      cz = ExSetCompassZoneCode.new(ExSetCompassZoneCode::SEVENSIGNSZONE)
    when inside_peace_zone?
      if @last_compass_zone == ExSetCompassZoneCode::PEACEZONE
        return
      end
      @last_compass_zone = ExSetCompassZoneCode::PEACEZONE
      cz = ExSetCompassZoneCode.new(ExSetCompassZoneCode::PEACEZONE)
    else
      if @last_compass_zone == ExSetCompassZoneCode::GENERALZONE
        return
      end
      @last_compass_zone = ExSetCompassZoneCode::GENERALZONE
      cz = ExSetCompassZoneCode.new(ExSetCompassZoneCode::GENERALZONE)
    end

    send_packet(cz)
  end

  def add_subclass(class_id : Int32, class_index : Int32)
    # unless @subclass_lock.lock?
    #   debug "Subclass lock is locked."
    #   return false
    # end

    begin
      if total_subclasses == Config.max_subclass || class_index == 0
        debug { "total subclasses: #{total_subclasses}, class_index: #{class_index}." }
        return false
      end

      if subclasses.has_key?(class_index)
        debug "subclass already exists"
        return false
      end

      new_class = Subclass.new(self)
      new_class.class_id = class_id
      new_class.class_index = class_index

      unless GameDB.subclass.insert(self, new_class)
        return false
      end

      subclasses[new_class.class_index] = new_class

      sub_template = ClassId[class_id]
      skill_tree = SkillTreesData.get_complete_class_skill_tree(sub_template)
      prev_skill_list = {} of Int32 => Skill
      skill_tree.each_value do |skill_info|
        if skill_info.get_level <= 40
          prev_skill = prev_skill_list[skill_info.skill_id]?
          new_skill = SkillData[skill_info.skill_id, skill_info.skill_level]
          if prev_skill && prev_skill.level > new_skill.level
            next
          end
          prev_skill_list[new_skill.id] = new_skill
          store_skill(new_skill, prev_skill, class_index)
        end
      end

      true
    rescue e
      error e
      false
    # ensure
    #   @subclass_lock.unlock
    end
  end

  def modify_subclass(class_index : Int32, new_class_id : Int32) : Bool
    # return false unless @subclass_lock.lock?

    begin
      GameDB.transaction do
        GameDB.henna.delete_all(self, class_index)
        GameDB.skill.delete_all(self, class_index)
        GameDB.shortcut.delete(self, class_index)
        GameDB.player_skill_save.delete(self, class_index)
        GameDB.subclass.delete(self, class_index)
      end

      class_id = subclasses[class_index].class_id
      OnPlayerProfessionCancel.new(self, class_id).async(self)

      subclasses.delete(class_index)
    # ensure
    #   @subclass_lock.unlock
    end

    add_subclass(new_class_id, class_index)
  end

  def change_active_class(class_index : Int32)
    # return false unless @subclass_lock.lock?

    begin
      return false if @transformation

      inventory.augmented_items.each do |item|
        if item.equipped?
          item.augmentation.not_nil!.remove_bonus(self)
        end
      end

      abort_cast

      if channelized?
        skill_channelized.abort_channelization
      end

      store(Config.subclass_store_skill_cooltime)

      reset_time_stamps

      @charges.set(0)

      stop_charge_task

      summon.as?(L2ServitorInstance).try &.unsummon(self)

      if class_index == 0
        self.class_template = base_class
      else
        begin
          self.class_template = subclasses[class_index].class_id
        rescue e
          error e
        end
      end

      @class_index = class_index

      self.learning_class = class_id

      party.try &.recalculate_party_level

      all_skills.each { |skill| remove_skill(skill, false, true) }

      stop_all_effects_except_those_that_last_through_death
      stop_all_effects_not_stay_on_subclass_change
      stop_cubics

      GameDB.recipe_book.load(self, false)

      restore_death_penalty_buff_level

      GameDB.skill.load(self)

      reward_skills
      regive_temporary_skills

      reset_disabled_skills

      restore_effects

      send_packet(EtcStatusUpdate.new(self))

      if st = get_quest_state("Q00422_RepentYourSins")
        st.exit_quest(true)
      end

      @henna[0] = nil
      @henna[1] = nil
      @henna[2] = nil
      GameDB.henna.load(self)
      recalc_henna_stats
      send_packet(HennaInfo.new(self))

      if current_hp > max_hp
        self.current_hp = max_hp.to_f64
      end
      if current_mp > max_mp
        self.current_mp = max_mp.to_f64
      end
      if current_cp > max_cp
        self.current_cp = max_cp.to_f64
      end

      refresh_overloaded
      refresh_expertise_penalty
      broadcast_user_info

      self.exp_before_death = 0

      shortcuts.restore_me
      send_packet(ShortcutInit.new(self))

      broadcast_packet(SocialAction.level_up(l2id))
      send_packet(SkillCoolTime.new(self))
      send_packet(ExStorageMaxCount.new(self))

      true
    # ensure
    #   @subclass_lock.unlock
    end
  end

  def process_quest_event(quest_name : String, event : String)
    return unless event && !event.empty?

    unless quest = QuestManager.get_quest(quest_name)
      return
    end

    if last_quest_npc_l2id > 0
      if npc = L2World.find_object(last_quest_npc_l2id).as?(L2Npc)
        if inside_radius?(npc, L2Npc::INTERACTION_DISTANCE, false, false)
          quest.notify_event(event, npc, self)
        end
      end
    end
  end

  def max_load : Int32
    calc_stat(
      Stats::WEIGHT_LIMIT,
      (BaseStats::CON.calc_bonus(self) * 69000 * Config.alt_weight_limit).floor,
      self
    ).to_i32
  end

  def bonus_weight_penalty : Int32
    calc_stat(Stats::WEIGHT_PENALTY, 1, self).to_i32
  end

  def current_load : Int32
    inventory.total_weight
  end

  def get_servitor_share_bonus(stat : Stats) : Float64
    @servitor_share.try &.fetch(stat, 1.0) || 1.0
  end

  def do_attack(target : L2Character?)
    super
    self.recent_fake_death = false
  end

  def do_cast(skill : Skill)
    if cs = current_skill
      unless check_use_magic_conditions(skill, cs.ctrl?, cs.shift?)
        self.casting_now = false
        return
      end
    end

    super

    self.recent_fake_death = false
  end

  def looks_dead? : Bool
    super || fake_death?
  end

  def do_die(killer : L2Character?) : Bool
    return false unless super

    if killer
      if pk = killer.acting_player
        OnPlayerPvPKill.new(pk, self).async(self)

        TvTEvent.on_kill(killer, self)
        if L2Event.participant?(pk)
          pk.event_status.not_nil!.kills << self
        end
      end

      broadcast_status_update
      self.exp_before_death = 0

      if cursed_weapon_equipped?
        CursedWeaponsManager.drop(@cursed_weapon_equipped_id, killer)
      elsif combat_flag_equipped?
        if TerritoryWarManager.tw_in_progress?
          TerritoryWarManager.drop_combat_flag(self, true, false)
        else
          if fort = FortManager.get_fort(self)
            FortSiegeManager.drop_combat_flag(self, fort.residence_id)
          else
            flag = inventory.get_item_by_item_id(9819).not_nil!
            slot = inventory.get_slot_from_item(flag)
            inventory.unequip_item_in_body_slot(slot)
            destroy_item("CombatFlag", flag, nil, true)
          end
        end
      else
        pvp_zone = inside_pvp_zone?
        siege_zone = inside_siege_zone?
        if pk.nil? || pk.cursed_weapon_equipped?
          on_die_drop_item(killer)

          if !pvp_zone && !siege_zone
            if pk && (pk_clan = pk.clan) && (clan = clan()) && !academy_member? && !pk.academy_member?
              if (clan.at_war_with?(pk.clan_id) && pk_clan.at_war_with?(clan.id)) || (in_siege? && pk.in_siege?)
                if AntiFeedManager.check(killer, self)
                  if clan.reputation_score > 0
                    pk_clan.add_reputation_score(Config.reputation_score_per_kill, false)
                  end
                  if clan.reputation_score > 0
                    clan.add_reputation_score(Config.reputation_score_per_kill, false)
                  end
                end
              end
            end
          end

          if Config.alt_game_delevel && !lucky? && (siege_zone || !pvp_zone)
            calculate_death_exp_penalty(killer, at_war_with?(pk))
          end
        end
      end
    end

    stop_feed if mounted?

    sync { stop_fake_death(true) if fake_death? }

    unless @cubics.empty?
      @cubics.each_value do |cubic|
        cubic.stop_action
        cubic.cancel_disappear
      end
      @cubics.clear
    end

    if channelized?
      skill_channelized.abort_channelization
    end

    if rift = @party.try &.dimensional_rift
      rift.dead_member_list << self
    end

    if agathion_id != 0
      self.agathion_id = 0
    end

    calculate_death_penalty_buff_level(killer)

    stop_rent_pet
    stop_water_task

    AntiFeedManager.set_last_death_time(l2id)

    true
  end

  def do_revive(power : Float64)
    do_revive
    restore_exp(power)
  end

  def do_revive
    super

    update_effect_icons
    send_packet(EtcStatusUpdate.new(self))
    @revive_pet = false
    @revive_requested = 0
    @revive_power = 0.0

    if mounted?
      start_feed(@mount_npc_id)
    end

    if (party = party()) && (rift = party.dimensional_rift)
      unless DimensionalRiftManager.in_peace_zone?(*xyz)
        rift.member_resurrected(self)
      end
    end

    if instance_id > 0
      if instance = InstanceManager.get_instance(instance_id)
        instance.cancel_eject_dead_player(self)
      end
    end
  end

  def restore_exp(percent : Float64)
    if exp_before_death > 0
      exp = (((exp_before_death - exp()) * percent) / 100).round.to_i64
      sub_stat.add_exp(exp)
      self.exp_before_death = 0
    end
  end

  def revive_request(reviver : L2PcInstance, skill : Skill?, pet : Bool, power : Int32, recovery : Int32)
    if resurrection_blocked?
      debug "Resurrection is blocked."
      return
    end

    if @revive_requested == 1
      if @revive_pet == pet
        reviver.send_packet(SystemMessageId::RES_HAS_ALREADY_BEEN_PROPOSED)
      else
        if pet
          reviver.send_packet(SystemMessageId::CANNOT_RES_PET2)
        else
          reviver.send_packet(SystemMessageId::MASTER_CANNOT_RES)
        end
      end

      return
    end

    if (pet && ((p = summon.as?(L2PetInstance)) && p.dead?)) || (!pet && dead?)
      @revive_requested = 1
      @revive_recovery = recovery
      @revive_power = Formulas.skill_resurrect_restore_percent(power.to_f, reviver)
      restore_exp = (((exp_before_death - exp) * @revive_power) / 100).round.to_i!
      @revive_pet = pet

      if charm_of_courage?
        dlg = ConfirmDlg.resurrect_using_charm_of_courage
        dlg.time = 60_000
        send_packet(dlg)
      else
        dlg = ConfirmDlg.resurrection_request_by_c1_for_s2_xp
        dlg.add_pc_name(reviver)
        dlg.add_string(restore_exp.to_i64.abs.to_s)
        send_packet(dlg)
      end
    end
  end

  def revive_answer(answer : Int)
    return if @revive_requested != 1
    return if alive? && !@revive_pet
    return if @revive_pet && (pet = summon.as?(L2PetInstance)) && pet.alive?

    if answer == 1
      if !@revive_pet
        @revive_power != 0 ? do_revive(@revive_power) : do_revive

        if @revive_recovery != 0
          percent = @revive_recovery / 100
          set_current_hp_mp(max_hp * percent, max_mp * percent)
          set_current_cp(0)
        end
      elsif pet
        @revive_power != 0 ? pet.do_revive(@revive_power) : pet.do_revive

        if @revive_recovery != 0
          percent = @revive_recovery / 100
          pet.set_current_hp_mp(pet.max_hp * percent, pet.max_mp * percent)
        end
      end
    end

    @revive_pet = false
    @revive_requested = 0
    @revive_power = 0.0
    @revive_recovery = 0
  end

  def can_summon_target?(target : L2PcInstance) : Bool
    return false if self == target

    if target.looks_dead?
      sm = SystemMessage.c1_is_dead_at_the_moment_and_cannot_be_summoned
      sm.add_pc_name(target)
      send_packet(sm)
      return false
    end

    if target.in_store_mode?
      sm = SystemMessage.c1_currently_trading_or_operating_private_store_and_cannot_be_summoned
      sm.add_pc_name(target)
      send_packet(sm)
      return false
    end

    if target.rooted? || target.in_combat?
      sm = SystemMessage.c1_is_engaged_in_combat_and_cannot_be_summoned
      sm.add_pc_name(target)
      send_packet(sm)
      return false
    end

    if target.in_olympiad_mode? || OlympiadManager.registered_in_comp?(target)
      send_packet(SystemMessageId::YOU_CANNOT_SUMMON_PLAYERS_WHO_ARE_IN_OLYMPIAD)
      return false
    end

    if target.festival_participant? || target.flying_mounted? || target.combat_flag_equipped? || !TvTEvent.on_escape_use(target.l2id)
      send_packet(SystemMessageId::YOUR_TARGET_IS_IN_AN_AREA_WHICH_BLOCKS_SUMMONING)
      return false
    end

    if target.in_observer_mode?
      sm = SystemMessage.c1_state_forbids_summoning
      sm.add_pc_name(target)
      send_packet(sm)
      return false
    end

    if target.inside_no_summon_friend_zone? || target.inside_jail_zone?
      sm = SystemMessage.c1_in_summon_blocking_area
      sm.add_string(target.name)
      send_packet(sm)
      return false
    end

    if inside_no_summon_friend_zone? || inside_jail_zone? || flying_mounted?
      send_packet(SystemMessageId::YOUR_TARGET_IS_IN_AN_AREA_WHICH_BLOCKS_SUMMONING)
      return false
    end

    if instance_id > 0
      if !Config.allow_summon_in_instance || !InstanceManager.get_instance(instance_id).not_nil!.summon_allowed?
        send_packet(SystemMessageId::YOU_MAY_NOT_SUMMON_FROM_YOUR_CURRENT_LOCATION)
        return false
      end
    end

    # (L2J) TODO: on retail character can enter 7s dungeon with summon friend, but should be teleported away by mobs, because currently this is not working in L2J we do not allowing summoning.
    if in_7s_dungeon?
      target_cabal = SevenSigns.instance.get_player_cabal(target.l2id)
      if SevenSigns.instance.seal_validation_period?
        if target_cabal != SevenSigns.instance.cabal_highest_score
          send_packet(SystemMessageId::YOUR_TARGET_IS_IN_AN_AREA_WHICH_BLOCKS_SUMMONING)
          return false
        end
      elsif target_cabal == SevenSigns::CABAL_NULL
        send_packet(SystemMessageId::YOUR_TARGET_IS_IN_AN_AREA_WHICH_BLOCKS_SUMMONING)
        return false
      end
    end

    true
  end

  def start_fishing(x : Int32, y : Int32, z : Int32)
    stop_move(nil)
    self.immobilized = true
    @fishing = true
    @fish_x, @fish_y, @fish_z = x, y, z

    lvl = random_fish_lvl
    grade = random_fish_grade
    group = get_random_fish_group(grade)
    fish = FishData.get_fish(lvl, group, grade)

    if fish.nil? || fish.empty?
      send_message("Error: Can't find fish.")
      end_fishing(false)
      return
    end

    @fish = fish.sample(random: Rnd).clone
    fish.clear
    send_packet(SystemMessageId::CAST_LINE_AND_START_FISHING)
    if !GameTimer.night? && @lure.not_nil!.night_lure?
      @fish.not_nil!.fish_group = -1
    end

    broadcast_packet(ExFishingStart.new(self, @fish.not_nil!.fish_group, x, y, z, @lure.not_nil!.night_lure?))
    send_packet(Music::SF_P_01.packet)
    start_looking_for_fish_task
  end

  def stop_looking_for_fish_task
    if task = @task_for_fish
      task.cancel
      @task_for_fish = nil
    end
  end

  def start_looking_for_fish_task
    if alive? && @task_for_fish.nil?
      check_delay = 0
      noob = false
      upper_grade = false

      if lure = @lure
        lure_id = lure.not_nil!.id
        noob = @fish.not_nil!.fish_grade == 0
        upper_grade = @fish.not_nil!.fish_grade == 2

        case lure_id
        when 6519, 6522, 6525, 8505, 8511
          check_delay = @fish.not_nil!.guts_check_time * 133
        when 6520, 6523, 6526, 8505..8513, 7610..7613, 7807..7809, 8484..8486
          check_delay = @fish.not_nil!.guts_check_time * 100
        when 6521, 6524, 6527, 8507, 8510, 8513
          check_delay = @fish.not_nil!.guts_check_time * 66
        end
      end

      task = LookingForFishTask.new(self, @fish.not_nil!.start_combat_time, @fish.not_nil!.fish_guts, @fish.not_nil!.fish_group, noob, upper_grade)
      @task_for_fish = ThreadPoolManager.schedule_effect_at_fixed_rate(task, 10_000, check_delay)
    end
  end

  private def random_fish_grade : Int32
    case @lure.not_nil!.id
    when 7807..7809, 8486
      0
    when 8485, 8506, 8509, 8512
      2
    else
      1
    end
  end

  private def get_random_fish_group(group : Int) : Int32
    check = Rnd.rand(100)
    type = 1

    case group
    when 0 # fish for novices
      case @lure.not_nil!.id
      when 7807 # green lure, preferred by fast-moving (nimble) fish (type 5)
        if check <= 54
          type = 5
        elsif check <= 77
          type = 4
        else
          type = 6
        end
      when 7808 # purple lure, preferred by fat fish (type 4)
        if check <= 54
          type = 4
        elsif check <= 77
          type = 6
        else
          type = 5
        end
      when 7809 # yellow lure, preferred by ugly fish (type 6)
        if check <= 54
          type = 6
        elsif check <= 77
          type = 5
        else
          type = 4
        end
      when 8486 # prize-winning fishing lure for beginners
        if check <= 33
          type = 4
        elsif check <= 66
          type = 5
        else
          type = 6
        end
      end
    when 1 # normal fish
      case @lure.not_nil!.id
      when 7610..7613
        type = 3
      when 6519, 8505, 6520, 6521, 8507
        if check <= 54
          type = 1
        elsif check <= 74
          type = 0
        elsif check <= 94
          type = 2
        else
          type = 3
        end
      when 6522, 8508, 6523, 6524, 8510
        if check <= 54
          type = 0
        elsif check <= 74
          type = 1
        elsif check <= 94
          type = 2
        else
          type = 3
        end
      when 6525, 8511, 6526, 6527, 8513
        if check <= 55
          type = 2
        elsif check <= 74
          type = 1
        elsif check <= 94
          type = 0
        else
          type = 3
        end
      when 8484 # prize-winning fishing lure
        if check <= 33
          type = 0
        elsif check <= 66
          type = 1
        else
          type = 2
        end
      end
    when 2 # upper grade fish, luminous lure
      case @lure.not_nil!.id
      when 8506 # green lure, preferred by fast-moving (nimble) fish (type 8)
        if check <= 54
          type = 8
        elsif check <= 77
          type = 7
        else
          type = 9
        end
      when 8509 # purple lure, preferred by fat fish (type 7)
        if check <= 54
          type = 7
        elsif check <= 77
          type = 9
        else
          type = 8
        end
      when 8512 # yellow lure, preferred by ugly fish (type 9)
        if check <= 54
          type = 9
        elsif check <= 77
          type = 8
        else
          type = 7
        end
      when 8485 # prize-winning fishing lure
        if check <= 33
          type = 7
        elsif check <= 66
          type = 8
        else
          type = 9
        end
      end
    end

    type
  end

  private def random_fish_lvl : Int32
    skill_lvl = get_skill_level(1315)
    if info = effect_list.get_buff_info_by_skill_id(2274)
      case info.skill.level
      when 1
        skill_lvl = 2
      when 2
        skill_lvl = 5
      when 3
        skill_lvl = 8
      when 4
        skill_lvl = 11
      when 5
        skill_lvl = 14
      when 6
        skill_lvl = 17
      when 7
        skill_lvl = 20
      when 8
        skill_lvl = 23
      else
        skill_lvl = 0
      end
    end

    if skill_lvl <= 0
      return 1
    end

    check = Rnd.rand(100)

    if check <= 50
      random_lvl = skill_lvl
    elsif check <= 85
      random_lvl = skill_lvl &- 1
      if random_lvl <= 0
        random_lvl = 1
      end
    else
      random_lvl = skill_lvl &+ 1
      if random_lvl > 27
        random_lvl = 27
      end
    end

    random_lvl
  end

  def start_fish_combat(noob : Bool, upper_grade : Bool)
    @fish_combat = L2Fishing.new(self, @fish.not_nil!, noob, upper_grade)
  end

  def end_fishing(win : Bool)
    @fishing = false
    @fish_x = @fish_y = @fish_z = 0

    unless @fish_combat
      send_packet(SystemMessageId::BAIT_LOST_FISH_GOT_AWAY)
    end

    @fish_combat = nil
    @lure = nil

    broadcast_packet(ExFishingEnd.new(win, self))
    send_packet(SystemMessageId::REEL_LINE_AND_STOP_FISHING)
    self.immobilized = false
    stop_looking_for_fish_task
  end

  def friends : Interfaces::Set(Int32)
    @friends || sync { @friends ||= Concurrent::Set(Int32).new }
  end

  def has_friends? : Bool
    !!@friends && !friends.empty?
  end

  def friend?(id : Int32) : Bool
    has_friends? && friends.includes?(id)
  end

  def add_friend(id : Int32)
    friends << id
  end

  def remove_friend(id : Int32)
    if has_friends?
      friends.delete(id)
    end
  end

  def variables : PlayerVariables
    get_script(PlayerVariables) || add_script(PlayerVariables.new(l2id))
  end

  def has_variables? : Bool
    !!get_script(PlayerVariables)
  end

  def account_variables : AccountVariables
    get_script(AccountVariables) ||
    add_script(AccountVariables.new(account_name))
  end

  def has_account_variables? : Bool
    !!get_script(AccountVariables)
  end

  def add_event_listener(lst : EventListener)
    @event_listeners << lst
  end

  def remove_event_listener(lst : EventListener)
    @event_listeners.delete(lst)
  end

  def remove_event_listener(klass : EventListener.class)
    @event_listeners.delete_if { |lst| lst.class == klass }
  end

  def teleport_bookmarks : Slice(TeleportBookmark)
    @tp_bookmarks.values_slice
  end

  def bookmark_slot=(slot : Int32)
    @bookmark_slot = slot
    send_packet(ExGetBookMarkInfoPacket.new(self))
  end

  def teleport_bookmark_add(x : Int32, y : Int32, z : Int32, icon : Int32, tag : String, name : String)
    return unless teleport_bookmark_condition(1)

    if @tp_bookmarks.size >= @bookmark_slot
      send_packet(SystemMessageId::YOU_HAVE_NO_SPACE_TO_SAVE_THE_TELEPORT_LOCATION)
      return
    end

    if inventory.get_inventory_item_count(20033, 0) == 0
      send_packet(SystemMessageId::YOU_CANNOT_BOOKMARK_THIS_LOCATION_BECAUSE_YOU_DO_NOT_HAVE_A_MY_TELEPORT_FLAG)
      return
    end

    id = 1
    while id <= @bookmark_slot
      break unless @tp_bookmarks.has_key?(id)
      id &+= 1
    end

    @tp_bookmarks[id] = TeleportBookmark.new(id, x, y, z, icon, tag, name)

    destroy_item("Consume", inventory.get_item_by_item_id(20033).not_nil!.l2id, 1, nil, false)

    sm = SystemMessage.s1_disappeared
    sm.add_item_name(20033)
    send_packet(sm)

    GameDB.teleport_bookmark.insert(self, id, x, y, z, icon, tag, name)

    send_packet(ExGetBookMarkInfoPacket.new(self))
  end

  def teleport_bookmark_modify(id : Int32, icon : Int32, tag : String, name : String)
    if bookmark = @tp_bookmarks[id]?
      bookmark.icon = icon
      bookmark.name = name
      bookmark.tag = tag

      GameDB.teleport_bookmark.update(self, id, icon, tag, name)
    end

    send_packet(ExGetBookMarkInfoPacket.new(self))
  end

  def teleport_bookmark_delete(id : Int32)
    if bookmark = @tp_bookmarks.delete(id)
      GameDB.teleport_bookmark.delete(self, id)
      send_packet(ExGetBookMarkInfoPacket.new(self))
    end
  end

  def teleport_bookmark_go(id : Int32)
    return unless teleport_bookmark_condition(0)

    if inventory.get_inventory_item_count(13016, 0) == 0
      send_packet(SystemMessageId::YOU_CANNOT_TELEPORT_BECAUSE_YOU_DO_NOT_HAVE_A_TELEPORT_ITEM)
      return
    end

    sm = SystemMessage.s1_disappeared
    sm.add_item_name(13016)
    send_packet(sm)

    if bookmark = @tp_bookmarks[id]?
      item = inventory.get_item_by_item_id(13016).not_nil!
      destroy_item("Consume", item.l2id, 1, nil, false)
      tele_to_location(bookmark, false)
    else
      debug { "Bookmark with id #{id} not found on this player." }
    end

    send_packet(ExGetBookMarkInfoPacket.new(self))
  end

  def teleport_bookmark_condition(type : Int32) : Bool
    if in_combat?
      send_packet(SystemMessageId::YOU_CANNOT_USE_MY_TELEPORTS_DURING_A_BATTLE)
      false
    elsif in_siege? || siege_state != 0
      send_packet(SystemMessageId::YOU_CANNOT_USE_MY_TELEPORTS_WHILE_PARTICIPATING)
      false
    elsif in_duel?
      send_packet(SystemMessageId::YOU_CANNOT_USE_MY_TELEPORTS_DURING_A_DUEL)
      false
    elsif flying?
      send_packet(SystemMessageId::YOU_CANNOT_USE_MY_TELEPORTS_WHILE_FLYING)
      false
    elsif in_olympiad_mode?
      send_packet(SystemMessageId::YOU_CANNOT_USE_MY_TELEPORTS_WHILE_PARTICIPATING_IN_AN_OLYMPIAD_MATCH)
      false
    elsif paralyzed?
      send_packet(SystemMessageId::YOU_CANNOT_USE_MY_TELEPORTS_WHILE_YOU_ARE_PARALYZED)
      false
    elsif dead?
      send_packet(SystemMessageId::YOU_CANNOT_USE_MY_TELEPORTS_WHILE_YOU_ARE_DEAD)
      false
    elsif type == 1 && (in_7s_dungeon? || ((party = party()) && party.in_dimensional_rift?))
      send_packet(SystemMessageId::YOU_CANNOT_USE_MY_TELEPORTS_TO_REACH_THIS_AREA)
      false
    elsif in_water?
      send_packet(SystemMessageId::YOU_CANNOT_USE_MY_TELEPORTS_UNDERWATER)
      false
    elsif type == 1 && inside_siege_zone? || inside_clan_hall_zone? || inside_jail_zone? || inside_castle_zone? || inside_no_summon_friend_zone? || inside_fort_zone?
      send_packet(SystemMessageId::YOU_CANNOT_USE_MY_TELEPORTS_TO_REACH_THIS_AREA)
      false
    elsif inside_no_bookmark_zone? || in_boat? || in_airship?
      if type == 0
        send_packet(SystemMessageId::YOU_CANNOT_USE_MY_TELEPORTS_IN_THIS_AREA)
      elsif type == 1
        send_packet(SystemMessageId::YOU_CANNOT_USE_MY_TELEPORTS_TO_REACH_THIS_AREA)
      end
      false
      # L2J TODO: Instant Zone still not implemented elsif(isInsideZone(ZoneId.INSTANT)) { send_packet(SystemMessage.getSystemMessage(2357)); return; }
    else
      true
    end
  end

  def attack_type : WeaponType
    if transformed? && (t = transformation.try &.get_template(self))
      return t.base_attack_type
    end

    super
  end

  private def bad_coords
    tele_to_location(Location.new(0, 0, 0), false)
    send_message("Error with your coordinates.")
  end

  def to_log(io : IO)
    io.print("L2PcInstance(", name, ')')
  end
end
