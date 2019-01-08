require "../../core/src/core"

require "./models/object_hierarchy"
require "./config"
require "./game_db"
require "./util/thread_pool_manager"
require "./game_timer"
require "./id_factory"
require "./network/game_client"
require "./network/game_packet_handler"
require "./network/login_server_client"
require "./handlers/master_handler"
require "./geo_data"
require "./path_finding"
require "./items_auto_destroy"
require "./seven_signs"
require "./instance_managers/instance_manager"
require "./instance_managers/global_variables_manager"
require "./instance_managers/items_on_ground_manager"
require "./instance_managers/zone_manager"
require "./instance_managers/castle_manager"
require "./instance_managers/fort_manager"
require "./instance_managers/map_region_manager"
require "./instance_managers/walking_manager"
require "./instance_managers/quest_manager"
require "./instance_managers/raid_boss_points_manager"
require "./instance_managers/clan_hall_manager"
require "./instance_managers/castle_manor_manager"
require "./instance_managers/merc_ticket_manager"
require "./instance_managers/siege_manager"
require "./instance_managers/territory_war_manager"
require "./instance_managers/fort_siege_manager"
require "./instance_managers/ch_siege_manager"
require "./instance_managers/day_night_spawn_manager"
require "./instance_managers/raid_boss_spawn_manager"
require "./instance_managers/grand_boss_manager"
require "./instance_managers/boat_manager"
require "./instance_managers/mail_manager"
require "./instance_managers/cursed_weapons_manager"
require "./instance_managers/dimensional_rift_manager"
require "./instance_managers/couple_manager"
require "./instance_managers/anti_feed_manager"
require "./instance_managers/punishment_manager"
require "./instance_managers/four_sepulchers_manager"
require "./instance_managers/auction_manager"
require "./task_managers/task_manager"
require "./task_managers/known_list_updater"
require "./task_managers/attack_stances"
require "./data/sql/char_name_table"
require "./data/sql/territory_table"
require "./data/sql/crest_table"
require "./data/sql/clan_table"
require "./data/sql/summon_table"
require "./data/sql/summon_skills_table"
require "./data/sql/teleport_location_table"
require "./data/sql/npc_buffer_table"
require "./data/sql/announcements_table"
require "./data/sql/offline_traders_table"
require "./data/xml/base_stats"
require "./data/xml/secondary_auth_data"
require "./data/xml/admin_data"
require "./data/xml/skill_trees_data"
require "./data/xml/armor_sets_data"
require "./data/xml/class_list_data"
require "./data/xml/category_data"
require "./data/xml/initial_equipment_data"
require "./data/xml/player_template_data"
require "./data/xml/player_creation_point_data"
require "./data/xml/karma_data"
require "./data/xml/player_xp_percent_lost_data"
require "./data/xml/hit_condition_bonus_data"
require "./data/xml/enchant_item_data"
require "./data/xml/enchant_item_groups_data"
require "./data/xml/enchant_item_options_data"
require "./data/xml/enchant_item_hp_bonus_data"
require "./data/xml/transform_data"
require "./data/xml/henna_data"
require "./data/xml/buy_list_data"
require "./data/xml/multisell_data"
require "./data/xml/recipe_data"
require "./data/xml/initial_shortcut_data"
require "./data/xml/pet_data_table"
require "./data/xml/document_engine"
require "./data/xml/option_data"
require "./data/xml/skill_learn_data"
require "./data/xml/npc_data"
require "./data/xml/door_data"
require "./data/xml/static_object_data"
require "./data/xml/siege_schedule_data"
require "./data/xml/fish_data"
require "./data/xml/fishing_rods_data"
require "./data/xml/fishing_monsters_data"
require "./data/xml/ui_data"
require "./data/json/experience_data"
require "./data_tables/skill_data"
require "./data_tables/item_table"
require "./data_tables/spawn_table"
require "./data_tables/augmentation_data"
require "./data_tables/merchant_price_config_table"
require "./cache/htm_cache"
require "./cache/warehouse_cache"
require "./shutdown"
require "./models/entity/instance"
require "./custom/l2_cr"

module GameServer
  extend self
  extend Loggable

  class_getter start_time = Time.now
  class_getter! listener : MMO::PacketManager(GameClient)

  def start
    info "Starting..."
    timer = Timer.new

    Config.load
    if Config.debug
      Loggable.severity = :DEBUG
    end
    f = File.open(Dir.current + "/log/#{Time.ms}.txt", "w")
    Loggable::LOGGABLE_IOS << f
    L2World.load
    GameDB.load
    IdFactory.load
    InstanceManager.load
    GameTimer.load
    MapRegionManager.load
    AnnouncementsTable.load
    GlobalVariablesManager.load
    BaseStats.load
    TerritoryTable.load

    CategoryData.load
    SecondaryAuthData.load

    MasterHandler.load
    EnchantSkillGroupsData.load
    SkillTreesData.load
    DocumentEngine.load
    SkillData.load
    SummonSkillsTable.load

    ItemTable.load
    EnchantItemGroupsData.load
    EnchantItemData.load
    EnchantItemOptionsData.load
    OptionData.load
    EnchantItemHPBonusData.load
    MerchantPriceConfigTable.load_instances
    BuyListData.load
    MultisellData.load
    RecipeData.load
    ArmorSetsData.load
    FishData.load
    FishingMonstersData.load
    FishingRodsData.load
    HennaData.load

    ClassListData.load
    InitialEquipmentData.load
    InitialShortcutData.load
    ExperienceData.load
    PlayerXpPercentLostData.load
    KarmaData.load
    HitConditionBonusData.load
    PlayerTemplateData.load
    PlayerCreationPointData.load
    CharNameTable.load
    AdminData.load
    RaidBossPointsManager.load
    PetDataTable.load
    SummonTable.load
    ClanTable.load
    CHSiegeManager.load
    ClanHallManager.load
    AuctionManager.load

    GeoData.load

    if Config.pathfinding > 0
      PathFinding.load
    end

    SkillLearnData.load
    NpcData.load
    WalkingManager.load
    StaticObjectData.load
    DoorData.load
    ZoneManager.load
    CastleManager.load_instances
    NpcBufferTable.load
    GrandBossManager.load
    # EventDroplist.load
    # ItemAuctionManager.load

    # Olympiad.load
    # Hero.load

    AutoSpawnHandler.load # Needs to load before all Seven Signs stuff
    SevenSigns.load

    HtmCache.load
    CrestTable.load
    TeleportLocationTable.load
    UIData.load
    # PartyMatchWaitingList.load (not needed)
    # PartyMatchRoomList.load (not needed)
    # PetitionManager.load
    AugmentationData.load
    CursedWeaponsManager.load
    TransformData.load
    # BotReportTable.load

    QuestManager.load
    BoatManager.load
    AirshipManager.load
    # GraciaSeedsManager.load

    SpawnTable.load
    DayNightSpawnManager.trim
    DayNightSpawnManager.notify_change_mode
    FourSepulchersManager.init # 91.816 kb -> 93.594 kb
    DimensionalRiftManager.load
    RaidBossSpawnManager.load

    SiegeManager.load
    CastleManager.activate_instances
    FortManager.load_instances
    FortManager.activate_instances
    FortSiegeManager.load
    SiegeScheduleData.load

    MerchantPriceConfigTable.update_references
    TerritoryWarManager.load
    CastleManorManager.load
    MercTicketManager.load

    if Config.save_dropped_item
      ItemsOnGroundManager.load
    end

    if Config.autodestroy_item_after > 0 || Config.herb_auto_destroy_time > 0
      ItemsAutoDestroy.load
    end

    # MonsterRace.load (not needed)

    SevenSigns.spawn_seven_signs_npc
    SevenSignsFestival.load

    if Config.allow_wedding
      CoupleManager.load
    end

    # TaskManager.load

    AntiFeedManager.register_event(AntiFeedManager::GAME_ID)

    if Config.allow_mail
      MailManager.load
    end

    PunishmentManager.load

    at_exit { Shutdown.run }

    # TvTManager.load
    KnownListUpdater.load

    if Config.offline_trade_enable || Config.offline_craft_enable
      if Config.restore_offliners
        OfflineTradersTable.restore_offline_traders
      end
    end

    AttackStances.load
    WarehouseCache.load

    host = Config.gameserver_hostname
    port = Config.port_game

    handler = GamePacketHandler
    executor = GamePacketHandler

    listener = MMO::PacketManager.new(GameClient, handler, executor)
    listener.host = host == "*" ? "127.0.0.1" : host
    listener.port = port

    @@listener = listener

    timer2 = Timer.new
    GC.collect
    debug "Garbage collected in #{timer2} s."

    info "Maximum number of connected players: #{Config.maximum_online_users}."
    info "Server loaded in #{timer} s."

    LoginServerClient.start

    info "Listening for players at #{host}:#{port}"

    listener.run
  end
end

GameServer.start
