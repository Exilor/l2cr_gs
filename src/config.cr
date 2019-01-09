require "./models/l2_world"
require "./util/stats_set"
require "./models/holders/item_holder"

module Config
  extend self
  extend Loggable

  {% if flag?(:win32) %}
    EOL = "\r\n"
  {% else %}
    EOL = "\n"
  {% end %}

  class FloodProtectorConfig
    property flood_protection_interval = 0
    property punishment_limit = 0
    property punishment_time = 0
    property punishment_type = ""
    property? log_flooding = false

    def initialize(@flood_protector_type : String)
    end
  end

  class ClassMasterSettings
    def initialize(line)
      @claim_items = {} of Int32 => Array(ItemHolder)
      @reward_items = {} of Int32 => Array(ItemHolder)
      @allowed_class_change = {} of Int32 => Bool
      parse_config_line(line)
    end

    private def parse_config_line(line)
      return if line.empty?
      st = line.split(';')
      until st.empty?
        job = st.shift.to_i
        @allowed_class_change[job] = true
        required_items = [] of ItemHolder
        unless st.empty?
          st2 = st.shift.split("[],")
          until st2.empty?
            st3 = st2.shift.split("()")
            item_id = st3.shift.to_i
            count = st3.shift.to_i64
            required_items << ItemHolder.new(item_id, count)
          end
        end

        @claim_items[job] = required_items

        reward_items = [] of ItemHolder
        unless st.empty?
          st2 = st.shift.split("[],")
          until st2.empty?
            st3 = st2.shift.split("()")
            item_id = st3.shift.to_i
            count = st3.shift.to_i64
            reward_items << ItemHolder.new(item_id, count)
          end
        end

        @reward_items[job] = reward_items
      end
    end

    def allowed?(job)
      @allowed_class_change[job]
    end

    def get_reward_items(job)
      @reward_items[job]?
    end

    def get_require_items(job)
      @claim_items[job]?
    end
  end

  CHARACTER_CONFIG_FILE = "/config/Character.properties"
  FEATURE_CONFIG_FILE = "/config/Feature.properties"
  FORTSIEGE_CONFIGURATION_FILE = "/config/FortSiege.properties"
  GENERAL_CONFIG_FILE = "/config/General.properties"
  HEXID_FILE = "/config/hexid.txt"
  ID_CONFIG_FILE = "/config/IdFactory.properties"
  L2JMOD_CONFIG_FILE = "/config/L2JMods.properties"
  LOGIN_CONFIGURATION_FILE = "/config/LoginServer.properties"
  NPC_CONFIG_FILE = "/config/NPC.properties"
  PVP_CONFIG_FILE = "/config/PVP.properties"
  RATES_CONFIG_FILE = "/config/Rates.properties"
  CONFIGURATION_FILE = "/config/Server.properties"
  IP_CONFIG_FILE = "/config/ipconfig.xml"
  SIEGE_CONFIGURATION_FILE = "/config/Siege.properties"
  TW_CONFIGURATION_FILE = "/config/TerritoryWar.properties"
  TELNET_FILE = "/config/Telnet.properties"
  FLOOD_PROTECTOR_FILE = "/config/FloodProtector.properties"
  MMO_CONFIG_FILE = "/config/MMO.properties"
  OLYMPIAD_CONFIG_FILE = "/config/Olympiad.properties"
  GRANDBOSS_CONFIG_FILE = "/config/GrandBoss.properties"
  GRACIASEEDS_CONFIG_FILE = "/config/GraciaSeeds.properties"
  CHAT_FILTER_FILE = "/config/chatfilter.txt"
  EMAIL_CONFIG_FILE = "/config/Email.properties"
  CH_SIEGE_FILE = "/config/ConquerableHallSiege.properties"
  GEODATA_FILE = "/config/GeoData.properties"
  # --------------------------------------------------
  # L2J Variable Definitions
  # --------------------------------------------------
  class_property alt_game_delevel = false
  class_property decrease_skill_level = false
  class_property alt_weight_limit = 0.0
  class_property run_spd_boost = 0
  class_property death_penalty_chance = 0
  class_property respawn_restore_cp = 0.0
  class_property respawn_restore_hp = 0.0
  class_property respawn_restore_mp = 0.0
  class_property enable_modify_skill_duration = false
  class_property skill_duration_list = {} of Int32 => Int32
  class_property enable_modify_skill_reuse = false
  class_property skill_reuse_list = {} of Int32 => Int32
  class_property auto_learn_skills = false
  class_property auto_learn_fs_skills = false
  class_property auto_loot_herbs = false
  class_property buffs_max_amount = 0i8
  class_property triggered_buffs_max_amount = 0i8
  class_property dances_max_amount = 0i8
  class_property dance_cancel_buff = false
  class_property dance_consume_additional_mp = false
  class_property alt_store_dances = false
  class_property auto_learn_divine_inspiration = false
  class_property alt_game_cancel_bow = false
  class_property alt_game_cancel_cast = false
  class_property alt_game_magicfailures = false
  class_property player_fakedeath_up_protection = 0
  class_property store_skill_cooltime = false
  class_property subclass_store_skill_cooltime = false
  class_property summon_store_skill_cooltime = false
  class_property alt_game_shield_blocks = false
  class_property alt_perfect_shld_block = 0
  class_property effect_tick_ratio = 0i64
  class_property allow_class_masters = false
  class_property class_master_settings : ClassMasterSettings?
  class_property allow_entire_tree = false
  class_property alternate_class_master = false
  class_property life_crystal_needed = false
  class_property es_sp_book_needed = false
  class_property divine_sp_book_needed = false
  class_property alt_game_skill_learn = false
  class_property alt_game_subclass_without_quests = false
  class_property alt_game_subclass_everywhere = false
  class_property allow_transform_without_quest = false
  class_property fee_delete_transfer_skills = 0i64
  class_property fee_delete_subclass_skills = 0i64
  class_property restore_servitor_on_reconnect = false
  class_property restore_pet_on_reconnect = false
  class_property max_bonus_exp = 0.0
  class_property max_bonus_sp = 0.0
  class_property max_run_speed = 0
  class_property max_pcrit_rate = 0
  class_property max_mcrit_rate = 0
  class_property max_patk_speed = 0
  class_property max_matk_speed = 0
  class_property max_evasion = 0
  class_property min_abnormal_state_success_rate = 0
  class_property max_abnormal_state_success_rate = 0
  class_property max_player_level = 0
  class_property max_pet_level = 0
  class_property max_subclass = 0 # byte
  class_property base_subclass_level = 0 # byte
  class_property max_subclass_level = 0 # byte
  class_property max_pvtstoresell_slots_dwarf = 0
  class_property max_pvtstoresell_slots_other = 0
  class_property max_pvtstorebuy_slots_dwarf = 0
  class_property max_pvtstorebuy_slots_other = 0
  class_property inventory_maximum_no_dwarf = 0
  class_property inventory_maximum_dwarf = 0
  class_property inventory_maximum_gm = 0
  class_property inventory_maximum_quest_items = 0
  class_property warehouse_slots_dwarf = 0
  class_property warehouse_slots_no_dwarf = 0
  class_property warehouse_slots_clan = 0
  class_property alt_freight_slots = 0
  class_property alt_freight_price = 0
  class_property alt_game_karma_player_can_be_killed_in_peacezone = false
  class_property alt_game_karma_player_can_shop = false
  class_property alt_game_karma_player_can_teleport = false
  class_property alt_game_karma_player_can_use_gk = false
  class_property alt_game_karma_player_can_trade = false
  class_property alt_game_karma_player_can_use_warehouse = false
  class_property max_personal_fame_points = 0
  class_property fortress_zone_fame_task_frequency = 0i64
  class_property fortress_zone_fame_aquire_points = 0
  class_property castle_zone_fame_task_frequency = 0i64
  class_property castle_zone_fame_aquire_points = 0
  class_property fame_for_dead_players = false
  class_property is_crafting_enabled = false
  class_property craft_masterwork = false
  class_property dwarf_recipe_limit = 0
  class_property common_recipe_limit = 0
  class_property alt_game_creation = false
  class_property alt_game_creation_speed = 0.0
  class_property alt_game_creation_xp_rate = 0.0
  class_property alt_game_creation_rare_xpsp_rate = 0.0
  class_property alt_game_creation_sp_rate = 0.0
  class_property alt_blacksmith_use_recipes = false
  class_property alt_clan_leader_date_change = 0
  class_property alt_clan_leader_hour_change : String?
  class_property alt_clan_leader_instant_activation = false
  class_property alt_clan_join_days = 0
  class_property alt_clan_create_days = 0
  class_property alt_clan_dissolve_days = 0
  class_property alt_ally_join_days_when_leaved = 0
  class_property alt_ally_join_days_when_dismissed = 0
  class_property alt_accept_clan_days_when_dismissed = 0
  class_property alt_create_ally_days_when_dissolved = 0
  class_property alt_max_num_of_clans_in_ally = 0
  class_property alt_clan_members_for_war = 0
  class_property alt_members_can_withdraw_from_clanwh = false
  class_property remove_castle_circlets = false
  class_property alt_party_range = 0
  class_property alt_party_range2 = 0
  class_property alt_leave_party_leader = false
  class_property initial_equipment_event = false
  class_property starting_adena = 0i64
  class_property starting_level = 0i8 # byte
  class_property starting_sp = 0
  class_property max_adena = 0i64
  class_property auto_loot = false
  class_property auto_loot_raids = false
  class_property loot_raids_privilege_interval = 0
  class_property loot_raids_privilege_cc_size = 0
  class_property unstuck_interval = 0
  class_property teleport_watchdog_timeout = 0
  class_property player_spawn_protection = 0
  class_property spawn_protection_allowed_items = [] of Int32
  class_property player_teleport_protection = 0
  class_property random_respawn_in_town_enabled = false
  class_property offset_on_teleport_enabled = false
  class_property max_offset_on_teleport = 0
  class_property petitioning_allowed = false
  class_property max_petitions_per_player = 0
  class_property max_petitions_pending = 0
  class_property alt_game_free_teleport = false
  class_property delete_days = 0
  class_property alt_game_exponent_xp = 0f32
  class_property alt_game_exponent_sp = 0f32
  class_property party_xp_cutoff_method = ""
  class_property party_xp_cutoff_percent = 0.0
  class_property party_xp_cutoff_level = 0
  class_property party_xp_cutoff_gaps = Array(Array(Int32)).new
  class_property party_xp_cutoff_gap_percents = [] of Int32
  class_property disable_tutorial = false
  class_property expertise_penalty = false
  class_property store_recipe_shoplist = false
  class_property store_ui_settings = false
  class_property forbidden_names = [] of String
  class_property silence_mode_exclude = false
  class_property alt_validate_trigger_skills = false

  # --------------------------------------------------
  # ClanHall Settings
  # --------------------------------------------------
  class_property ch_tele_fee_ratio = 0i64
  class_property ch_tele1_fee = 0
  class_property ch_tele2_fee = 0
  class_property ch_item_fee_ratio = 0i64
  class_property ch_item1_fee = 0
  class_property ch_item2_fee = 0
  class_property ch_item3_fee = 0
  class_property ch_mpreg_fee_ratio = 0i64
  class_property ch_mpreg1_fee = 0
  class_property ch_mpreg2_fee = 0
  class_property ch_mpreg3_fee = 0
  class_property ch_mpreg4_fee = 0
  class_property ch_mpreg5_fee = 0
  class_property ch_hpreg_fee_ratio = 0i64
  class_property ch_hpreg1_fee = 0
  class_property ch_hpreg2_fee = 0
  class_property ch_hpreg3_fee = 0
  class_property ch_hpreg4_fee = 0
  class_property ch_hpreg5_fee = 0
  class_property ch_hpreg6_fee = 0
  class_property ch_hpreg7_fee = 0
  class_property ch_hpreg8_fee = 0
  class_property ch_hpreg9_fee = 0
  class_property ch_hpreg10_fee = 0
  class_property ch_hpreg11_fee = 0
  class_property ch_hpreg12_fee = 0
  class_property ch_hpreg13_fee = 0
  class_property ch_expreg_fee_ratio = 0i64
  class_property ch_expreg1_fee = 0
  class_property ch_expreg2_fee = 0
  class_property ch_expreg3_fee = 0
  class_property ch_expreg4_fee = 0
  class_property ch_expreg5_fee = 0
  class_property ch_expreg6_fee = 0
  class_property ch_expreg7_fee = 0
  class_property ch_support_fee_ratio = 0i64
  class_property ch_support1_fee = 0
  class_property ch_support2_fee = 0
  class_property ch_support3_fee = 0
  class_property ch_support4_fee = 0
  class_property ch_support5_fee = 0
  class_property ch_support6_fee = 0
  class_property ch_support7_fee = 0
  class_property ch_support8_fee = 0
  class_property ch_curtain_fee_ratio = 0i64
  class_property ch_curtain1_fee = 0
  class_property ch_curtain2_fee = 0
  class_property ch_front_fee_ratio = 0i64
  class_property ch_front1_fee = 0
  class_property ch_front2_fee = 0
  class_property ch_buff_free = false
  # --------------------------------------------------
  # Castle Settings
  # --------------------------------------------------
  class_property cs_tele_fee_ratio = 0i64
  class_property cs_tele1_fee = 0
  class_property cs_tele2_fee = 0
  class_property cs_mpreg_fee_ratio = 0i64
  class_property cs_mpreg1_fee = 0
  class_property cs_mpreg2_fee = 0
  class_property cs_hpreg_fee_ratio = 0i64
  class_property cs_hpreg1_fee = 0
  class_property cs_hpreg2_fee = 0
  class_property cs_expreg_fee_ratio = 0i64
  class_property cs_expreg1_fee = 0
  class_property cs_expreg2_fee = 0
  class_property cs_support_fee_ratio = 0i64
  class_property cs_support1_fee = 0
  class_property cs_support2_fee = 0
  class_property siege_hour_list = [] of Int32
  class_property outer_door_upgrade_price2 = 0
  class_property outer_door_upgrade_price3 = 0
  class_property outer_door_upgrade_price5 = 0
  class_property inner_door_upgrade_price2 = 0
  class_property inner_door_upgrade_price3 = 0
  class_property inner_door_upgrade_price5 = 0
  class_property wall_upgrade_price2 = 0
  class_property wall_upgrade_price3 = 0
  class_property wall_upgrade_price5 = 0
  class_property trap_upgrade_price1 = 0
  class_property trap_upgrade_price2 = 0
  class_property trap_upgrade_price3 = 0
  class_property trap_upgrade_price4 = 0

  # --------------------------------------------------
  # Fortress Settings
  # --------------------------------------------------
  class_property fs_tele_fee_ratio = 0i64
  class_property fs_tele1_fee = 0
  class_property fs_tele2_fee = 0
  class_property fs_mpreg_fee_ratio = 0i64
  class_property fs_mpreg1_fee = 0
  class_property fs_mpreg2_fee = 0
  class_property fs_hpreg_fee_ratio = 0i64
  class_property fs_hpreg1_fee = 0
  class_property fs_hpreg2_fee = 0
  class_property fs_expreg_fee_ratio = 0i64
  class_property fs_expreg1_fee = 0
  class_property fs_expreg2_fee = 0
  class_property fs_support_fee_ratio = 0i64
  class_property fs_support1_fee = 0
  class_property fs_support2_fee = 0
  class_property fs_blood_oath_count = 0
  class_property fs_update_frq = 0
  class_property fs_max_supply_level = 0
  class_property fs_fee_for_castle = 0i64
  class_property fs_max_own_time = 0
  # --------------------------------------------------
  # Feature Settings
  # --------------------------------------------------
  class_property take_fort_points = 0
  class_property lose_fort_points = 0
  class_property take_castle_points = 0
  class_property lose_castle_points = 0
  class_property castle_defended_points = 0
  class_property festival_win_points = 0
  class_property hero_points = 0
  class_property royal_guard_cost = 0
  class_property knight_unit_cost = 0
  class_property knight_reinforce_cost = 0
  class_property ballista_points = 0
  class_property bloodalliance_points = 0
  class_property bloodoath_points = 0
  class_property knightsepaulette_points = 0
  class_property reputation_score_per_kill = 0
  class_property join_academy_min_rep_score = 0
  class_property join_academy_max_rep_score = 0
  class_property raid_ranking_1st = 0
  class_property raid_ranking_2nd = 0
  class_property raid_ranking_3rd = 0
  class_property raid_ranking_4th = 0
  class_property raid_ranking_5th = 0
  class_property raid_ranking_6th = 0
  class_property raid_ranking_7th = 0
  class_property raid_ranking_8th = 0
  class_property raid_ranking_9th = 0
  class_property raid_ranking_10th = 0
  class_property raid_ranking_up_to_50th = 0
  class_property raid_ranking_up_to_100th = 0
  class_property clan_level_6_cost = 0
  class_property clan_level_7_cost = 0
  class_property clan_level_8_cost = 0
  class_property clan_level_9_cost = 0
  class_property clan_level_10_cost = 0
  class_property clan_level_11_cost = 0
  class_property clan_level_6_requirement = 0
  class_property clan_level_7_requirement = 0
  class_property clan_level_8_requirement = 0
  class_property clan_level_9_requirement = 0
  class_property clan_level_10_requirement = 0
  class_property clan_level_11_requirement = 0
  class_property allow_wyvern_always = false
  class_property allow_wyvern_during_siege = false

  # --------------------------------------------------
  # General Settings
  # --------------------------------------------------
  class_property everybody_has_admin_rights = false
  class_property server_list_bracket = false
  class_property server_list_type = 0
  class_property server_list_age = 0
  class_property server_gmonly = false
  class_property gm_hero_aura = false
  class_property gm_startup_invulnerable = false
  class_property gm_startup_invisible = false
  class_property gm_startup_silence = false
  class_property gm_startup_auto_list = false
  class_property gm_startup_diet_mode = false
  class_property gm_item_restriction = false
  class_property gm_skill_restriction = false
  class_property gm_trade_restricted_items = false
  class_property gm_restart_fighting = false
  class_property gm_announcer_name = false
  class_property gm_critannouncer_name = false
  class_property gm_give_special_skills = false
  class_property gm_give_special_aura_skills = false
  class_property gameguard_enforce = false
  class_property gameguard_prohibitaction = false
  class_property log_chat = false
  class_property log_auto_announcements = false
  class_property log_items = false
  class_property log_items_small_log = false
  class_property log_item_enchants = false
  class_property log_skill_enchants = false
  class_property gmaudit = false
  class_property skill_check_enable = false
  class_property skill_check_remove = false
  class_property skill_check_gm = false
  class_property debug = false
  class_property debug_instances = false
  class_property html_action_cache_debug = false
  class_property packet_handler_debug = false
  class_property developer = false
  class_property no_handlers = false
  class_property no_quests = false
  class_property alt_dev_no_spawns = false
  class_property alt_dev_show_quests_load_in_logs = false
  class_property alt_dev_show_scripts_load_in_logs = false
  class_property thread_p_effects = 0
  class_property thread_p_general = 0
  class_property thread_e_events = 0
  class_property general_packet_thread_core_size = 0
  class_property io_packet_thread_core_size = 0
  class_property general_thread_core_size = 0
  class_property ai_max_thread = 0
  class_property event_max_thread = 0
  class_property client_packet_queue_size = 0
  class_property client_packet_queue_max_burst_size = 0
  class_property client_packet_queue_max_packets_per_second = 0
  class_property client_packet_queue_measure_interval = 0
  class_property client_packet_queue_max_average_packets_per_second = 0
  class_property client_packet_queue_max_floods_per_min = 0
  class_property client_packet_queue_max_overflows_per_min = 0
  class_property client_packet_queue_max_underflows_per_min = 0
  class_property client_packet_queue_max_unknown_per_min = 0
  class_property deadlock_detector = false
  class_property deadlock_check_interval = 0
  class_property restart_on_deadlock = false
  class_property allow_discarditem = false
  class_property autodestroy_item_after = 0
  class_property herb_auto_destroy_time = 0
  class_property list_protected_items = [] of Int32
  class_property database_clean_up = false
  class_property connection_close_time = 0i64
  class_property char_store_interval = 0i64
  class_property lazy_items_update = false
  class_property update_items_on_char_store = false
  class_property destroy_dropped_player_item = false
  class_property destroy_equipable_player_item = false
  class_property save_dropped_item = false
  class_property empty_dropped_item_table_after_load = false
  class_property save_dropped_item_interval = 0
  class_property clear_dropped_item_table = false
  class_property autodelete_invalid_quest_data = false
  class_property precise_drop_calculation = false
  class_property multiple_item_drop = false
  class_property force_inventory_update = false
  class_property lazy_cache = false
  class_property cache_char_names = false
  class_property min_npc_animation = 0
  class_property max_npc_animation = 0
  class_property min_monster_animation = 0
  class_property max_monster_animation = 0
  class_property enable_falling_damage = false
  class_property grids_always_on = false
  class_property grid_neighbor_turnon_time = 0
  class_property grid_neighbor_turnoff_time = 0
  class_property move_based_knownlist = false
  class_property knownlist_update_interval = 0i64
  class_property peace_zone_mode = 0
  class_property default_global_chat = ""
  class_property default_trade_chat = ""
  class_property allow_warehouse = false
  class_property warehouse_cache = false
  class_property warehouse_cache_time = 0
  class_property allow_refund = false
  class_property allow_mail = false
  class_property allow_attachments = false
  class_property allow_wear = false
  class_property wear_delay = 0
  class_property wear_price = 0
  class_property instance_finish_time = 0
  class_property restore_player_instance = false
  class_property allow_summon_in_instance = false
  class_property eject_dead_player_time = 0
  class_property allow_lottery = false
  class_property allow_race = false
  class_property allow_water = false
  class_property allow_rentpet = false
  class_property allowfishing = false
  class_property allow_boat = false
  class_property boat_broadcast_radius = 0
  class_property allow_cursed_weapons = false
  class_property allow_manor = false
  class_property allow_pet_walkers = false
  class_property server_news = false
  class_property enable_community_board = false
  class_property bbs_default = ""
  class_property use_say_filter = false
  class_property chat_filter_chars = ""
  class_property ban_chat_channels = [] of Int32
  class_property alt_oly_start_time = 0
  class_property alt_oly_min = 0
  class_property alt_oly_max_buffs = 0
  class_property alt_oly_cperiod = 0i64
  class_property alt_oly_battle = 0i64
  class_property alt_oly_wperiod = 0i64
  class_property alt_oly_vperiod = 0i64
  class_property alt_oly_start_points = 0
  class_property alt_oly_weekly_points = 0
  class_property alt_oly_classed = 0
  class_property alt_oly_nonclassed = 0
  class_property alt_oly_teams = 0
  class_property alt_oly_reg_display = 0
  class_property alt_oly_classed_reward = Slice(Slice(Int32)).empty
  class_property alt_oly_nonclassed_reward = Slice(Slice(Int32)).empty
  class_property alt_oly_team_reward = Slice(Slice(Int32)).empty
  class_property alt_oly_comp_ritem = 0
  class_property alt_oly_min_matches = 0
  class_property alt_oly_gp_per_point = 0
  class_property alt_oly_hero_points = 0
  class_property alt_oly_rank1_points = 0
  class_property alt_oly_rank2_points = 0
  class_property alt_oly_rank3_points = 0
  class_property alt_oly_rank4_points = 0
  class_property alt_oly_rank5_points = 0
  class_property alt_oly_max_points = 0
  class_property alt_oly_divider_classed = 0
  class_property alt_oly_divider_non_classed = 0
  class_property alt_oly_max_weekly_matches = 0
  class_property alt_oly_max_weekly_matches_non_classed = 0
  class_property alt_oly_max_weekly_matches_classed = 0
  class_property alt_oly_max_weekly_matches_team = 0
  class_property alt_oly_log_fights = false
  class_property alt_oly_show_monthly_winners = false
  class_property alt_oly_announce_games = false
  class_property list_oly_restricted_items = [] of Int32
  class_property alt_oly_enchant_limit = 0
  class_property alt_oly_wait_time = 0
  class_property alt_manor_refresh_time = 0
  class_property alt_manor_refresh_min = 0
  class_property alt_manor_approve_time = 0
  class_property alt_manor_approve_min = 0
  class_property alt_manor_maintenance_min = 0
  class_property alt_manor_save_all_actions = false
  class_property alt_manor_save_period_rate = 0
  class_property alt_lottery_prize = 0i64
  class_property alt_lottery_ticket_price = 0i64
  class_property alt_lottery_5_number_rate = 0f32
  class_property alt_lottery_4_number_rate = 0f32
  class_property alt_lottery_3_number_rate = 0f32
  class_property alt_lottery_2_and_1_number_prize = 0i64
  class_property alt_item_auction_enabled = false
  class_property alt_item_auction_expired_after = 0
  class_property alt_item_auction_time_extends_on_bid = 0i64
  class_property fs_time_attack = 0
  class_property fs_time_cooldown = 0
  class_property fs_time_entry = 0
  class_property fs_time_warmup = 0
  class_property fs_party_member_count = 0
  class_property rift_min_party_size = 0
  class_property rift_spawn_delay = 0
  class_property rift_max_jumps = 0
  class_property rift_auto_jumps_time_min = 0
  class_property rift_auto_jumps_time_max = 0
  class_property rift_boss_room_time_multiply = 0f32
  class_property rift_enter_cost_recruit = 0
  class_property rift_enter_cost_soldier = 0
  class_property rift_enter_cost_officer = 0
  class_property rift_enter_cost_captain = 0
  class_property rift_enter_cost_commander = 0
  class_property rift_enter_cost_hero = 0
  class_property default_punish : IllegalActionPunishmentType = IllegalActionPunishmentType::NONE
  class_property default_punish_param = 0
  class_property only_gm_items_free = false
  class_property jail_is_pvp = false
  class_property jail_disable_chat = false
  class_property jail_disable_transaction = false
  class_property custom_spawnlist_table = false
  class_property save_gmspawn_on_custom = false
  class_property custom_npc_data = false
  class_property custom_teleport_table = false
  class_property custom_npcbuffer_tables = false
  class_property custom_skills_load = false
  class_property custom_items_load = false
  class_property custom_multisell_load = false
  class_property custom_buylist_load = false
  class_property alt_birthday_gift = 0
  class_property alt_birthday_mail_subject : String?
  class_property alt_birthday_mail_text : String?
  class_property enable_block_checker_event = false
  class_property min_block_checker_team_members = 0
  class_property hbce_fair_play = false
  class_property hellbound_without_quest = false
  class_property player_movement_block_time = 0
  class_property normal_enchant_cost_multiplier = 0
  class_property safe_enchant_cost_multiplier = 0
  class_property botreport_enable = false
  class_property botreport_resetpoint_hour : Slice(String)?
  class_property botreport_report_delay = 0i64
  class_property botreport_allow_reports_from_same_clan_members = false

  # --------------------------------------------------
  # FloodProtector Settings
  # --------------------------------------------------
  class_property! flood_protector_use_item : FloodProtectorConfig
  class_property! flood_protector_roll_dice : FloodProtectorConfig
  class_property! flood_protector_firework : FloodProtectorConfig
  class_property! flood_protector_item_pet_summon : FloodProtectorConfig
  class_property! flood_protector_hero_voice : FloodProtectorConfig
  class_property! flood_protector_global_chat : FloodProtectorConfig
  class_property! flood_protector_subclass : FloodProtectorConfig
  class_property! flood_protector_drop_item : FloodProtectorConfig
  class_property! flood_protector_server_bypass : FloodProtectorConfig
  class_property! flood_protector_multisell : FloodProtectorConfig
  class_property! flood_protector_transaction : FloodProtectorConfig
  class_property! flood_protector_manufacture : FloodProtectorConfig
  class_property! flood_protector_manor : FloodProtectorConfig
  class_property! flood_protector_sendmail : FloodProtectorConfig
  class_property! flood_protector_character_select : FloodProtectorConfig
  class_property! flood_protector_item_auction : FloodProtectorConfig
  # --------------------------------------------------
  # L2JMods Settings
  # --------------------------------------------------
  class_property champion_enable = false
  class_property champion_passive = false
  class_property champion_frequency = 0
  class_property champ_title : String?
  class_property champ_min_lvl = 0
  class_property champ_max_lvl = 0
  class_property champion_hp = 0
  class_property champion_rewards_exp_sp = 0f32
  class_property champion_rewards_chance = 0f32
  class_property champion_rewards_amount = 0f32
  class_property champion_adenas_rewards_chance = 0f32
  class_property champion_adenas_rewards_amount = 0f32
  class_property champion_hp_regen = 0f32
  class_property champion_atk = 0f32
  class_property champion_spd_atk = 0f32
  class_property champion_reward_lower_lvl_item_chance = 0
  class_property champion_reward_higher_lvl_item_chance = 0
  class_property champion_reward_id = 0
  class_property champion_reward_qty = 0
  class_property champion_enable_vitality = false
  class_property champion_enable_in_instances = false
  class_property tvt_event_enabled = false
  class_property tvt_event_in_instance = false
  class_property tvt_event_instance_file : String?
  class_property tvt_event_interval : Slice(String)?
  class_property tvt_event_participation_time = 0
  class_property tvt_event_running_time = 0
  class_property tvt_event_participation_npc_id = 0
  class_property tvt_event_participation_npc_coordinates = Slice(Int32).new(4)
  class_property tvt_event_participation_fee = Slice(Int32).new(2)
  class_property tvt_event_min_players_in_teams = 0
  class_property tvt_event_max_players_in_teams = 0
  class_property tvt_event_respawn_teleport_delay = 0
  class_property tvt_event_start_leave_teleport_delay = 0
  class_property tvt_event_team_1_name : String?
  class_property tvt_event_team_1_coordinates = Slice(Int32).new(3)
  class_property tvt_event_team_2_name : String?
  class_property tvt_event_team_2_coordinates = Slice(Int32).new(3)
  class_property tvt_event_rewards = Slice(Slice(Int32)).empty
  class_property tvt_event_target_team_members_allowed = false
  class_property tvt_event_scroll_allowed = false
  class_property tvt_event_potions_allowed = false
  class_property tvt_event_summon_by_item_allowed = false
  class_property tvt_doors_ids_to_open = [] of Int32
  class_property tvt_doors_ids_to_close = [] of Int32
  class_property tvt_reward_team_tie = false
  class_property tvt_event_min_lvl = 0i8 # byte
  class_property tvt_event_max_lvl = 0i8 # byte
  class_property tvt_event_effects_removal = 0
  class_property tvt_event_fighter_buffs = {} of Int32 => Int32
  class_property tvt_event_mage_buffs = {} of Int32 => Int32
  class_property tvt_event_max_participants_per_ip = 0
  class_property tvt_allow_voiced_command = false
  class_property allow_wedding = false
  class_property wedding_price = 0
  class_property wedding_punish_infidelity = false
  class_property wedding_teleport = false
  class_property wedding_teleport_price = 0
  class_property wedding_teleport_duration = 0
  class_property wedding_samesex = false
  class_property wedding_formalwear = false
  class_property wedding_divorce_costs = 0
  class_property hellbound_status = false
  class_property banking_system_enabled = false
  class_property banking_system_goldbars = 0
  class_property banking_system_adena = 0
  class_property enable_warehousesorting_clan = false
  class_property enable_warehousesorting_private = false
  class_property offline_trade_enable = false
  class_property offline_craft_enable = false
  class_property offline_mode_in_peace_zone = false
  class_property offline_mode_no_damage = false
  class_property restore_offliners = false
  class_property offline_max_days = 0
  class_property offline_disconnect_finished = false
  class_property offline_set_name_color = false
  class_property offline_name_color = 0
  class_property offline_fame = false
  class_property enable_mana_potions_support = false
  class_property display_server_time = false
  class_property welcome_message_enabled = false
  class_property welcome_message_text : String?
  class_property welcome_message_time = 0
  class_property antifeed_enable = false
  class_property antifeed_dualbox = false
  class_property antifeed_disconnected_as_dualbox = false
  class_property antifeed_interval = 0
  class_property announce_pk_pvp = false
  class_property announce_pk_pvp_normal_message = false
  class_property announce_pk_msg : String?
  class_property announce_pvp_msg : String?
  class_property chat_admin = false
  class_property multilang_enable = false
  class_property multilang_allowed = [] of String
  class_property multilang_default : String?
  class_property multilang_voiced_allow = false
  class_property multilang_sm_enable = false
  class_property multilang_sm_allowed = [] of String
  class_property multilang_ns_enable = false
  class_property multilang_ns_allowed = [] of String
  class_property l2walker_protection = false
  class_property debug_voice_command = false
  class_property dualbox_check_max_players_per_ip = 0
  class_property dualbox_check_max_olympiad_participants_per_ip = 0
  class_property dualbox_check_max_l2event_participants_per_ip = 0
  class_property dualbox_check_whitelist = {} of Int32 => Int32
  class_property allow_change_password = false
  # --------------------------------------------------
  # NPC Settings
  # --------------------------------------------------
  class_property announce_mammon_spawn = false
  class_property alt_mob_agro_in_peacezone = false
  class_property alt_attackable_npcs = false
  class_property alt_game_viewnpc = false
  class_property max_drift_range = 0
  class_property deepblue_drop_rules = false
  class_property deepblue_drop_rules_raid = false
  class_property show_npc_lvl = false
  class_property show_crest_without_quest = false
  class_property enable_random_enchant_effect = false
  class_property min_npc_lvl_dmg_penalty = 0
  class_property npc_dmg_penalty = {} of Int32 => Float64
  class_property npc_crit_dmg_penalty = {} of Int32 => Float64
  class_property npc_skill_dmg_penalty = {} of Int32 => Float64
  class_property min_npc_lvl_magic_penalty = 0
  class_property npc_skill_chance_penalty = {} of Int32 => Float64
  class_property decay_time_task = 0
  class_property default_corpse_time = 0
  class_property spoiled_corpse_extend_time = 0
  class_property corpse_consume_skill_allowed_time_before_decay = 0
  class_property guard_attack_aggro_mob = false
  class_property allow_wyvern_upgrader = false
  class_property list_pet_rent_npc = [] of Int32
  class_property raid_hp_regen_multiplier = 0.0
  class_property raid_mp_regen_multiplier = 0.0
  class_property raid_pdefence_multiplier = 0.0
  class_property raid_mdefence_multiplier = 0.0
  class_property raid_pattack_multiplier = 0.0
  class_property raid_mattack_multiplier = 0.0
  class_property raid_minion_respawn_timer = 0.0
  class_property minions_respawn_time = {} of Int32 => Int32
  class_property raid_min_respawn_multiplier = 0f32
  class_property raid_max_respawn_multiplier = 0f32
  class_property raid_disable_curse = false
  class_property raid_chaos_time = 0
  class_property grand_chaos_time = 0
  class_property minion_chaos_time = 0
  class_property inventory_maximum_pet = 0
  class_property pet_hp_regen_multiplier = 0.0
  class_property pet_mp_regen_multiplier = 0.0
  class_property drop_adena_min_level_difference = 0
  class_property drop_adena_max_level_difference = 0
  class_property drop_adena_min_level_gap_chance = 0.0
  class_property drop_item_min_level_difference = 0
  class_property drop_item_max_level_difference = 0
  class_property drop_item_min_level_gap_chance = 0.0

  # --------------------------------------------------
  # PvP Settings
  # --------------------------------------------------
  class_property karma_drop_gm = false
  class_property karma_award_pk_kill = false
  class_property karma_pk_limit = 0
  class_property karma_nondroppable_pet_items : String?
  class_property karma_nondroppable_items : String?
  class_property karma_list_nondroppable_pet_items = [] of Int32
  class_property karma_list_nondroppable_items = [] of Int32

  # --------------------------------------------------
  # Rate Settings
  # --------------------------------------------------
  class_property rate_xp = 0f32
  class_property rate_sp = 0f32
  class_property rate_party_xp = 0f32
  class_property rate_party_sp = 0f32
  class_property rate_hb_trust_increase = 0f32
  class_property rate_hb_trust_decrease = 0f32
  class_property rate_extractable = 0f32
  class_property rate_drop_manor = 0
  class_property rate_quest_drop = 0f32
  class_property rate_quest_reward = 0f32
  class_property rate_quest_reward_xp = 0f32
  class_property rate_quest_reward_sp = 0f32
  class_property rate_quest_reward_adena = 0f32
  class_property rate_quest_reward_use_multipliers = false
  class_property rate_quest_reward_potion = 0f32
  class_property rate_quest_reward_scroll = 0f32
  class_property rate_quest_reward_recipe = 0f32
  class_property rate_quest_reward_material = 0f32
  class_property rate_death_drop_amount_multiplier = 0f32
  class_property rate_corpse_drop_amount_multiplier = 0f32
  class_property rate_herb_drop_amount_multiplier = 0f32
  class_property rate_raid_drop_amount_multiplier = 0f32
  class_property rate_death_drop_chance_multiplier = 0f32
  class_property rate_corpse_drop_chance_multiplier = 0f32
  class_property rate_herb_drop_chance_multiplier = 0f32
  class_property rate_raid_drop_chance_multiplier = 0f32
  class_property rate_drop_amount_multiplier = {} of Int32 => Float64
  class_property rate_drop_chance_multiplier = {} of Int32 => Float64
  class_property rate_karma_lost = 0f32
  class_property rate_karma_exp_lost = 0f32
  class_property rate_siege_guards_price = 0f32
  class_property rate_drop_common_herbs = 0f32
  class_property rate_drop_hp_herbs = 0f32
  class_property rate_drop_mp_herbs = 0f32
  class_property rate_drop_special_herbs = 0f32
  class_property player_drop_limit = 0
  class_property player_rate_drop = 0
  class_property player_rate_drop_item = 0
  class_property player_rate_drop_equip = 0
  class_property player_rate_drop_equip_weapon = 0
  class_property pet_xp_rate = 0f32
  class_property pet_food_rate = 0
  class_property sineater_xp_rate = 0f32
  class_property karma_drop_limit = 0
  class_property karma_rate_drop = 0
  class_property karma_rate_drop_item = 0
  class_property karma_rate_drop_equip = 0
  class_property karma_rate_drop_equip_weapon = 0

  # --------------------------------------------------
  # Seven Signs Settings
  # --------------------------------------------------
  class_property alt_game_castle_dawn = false
  class_property alt_game_castle_dusk = false
  class_property alt_game_require_clan_castle = false
  class_property alt_festival_min_player = 0
  class_property alt_maximum_player_contrib = 0i64
  class_property alt_festival_manager_start = 0i64
  class_property alt_festival_length = 0i64
  class_property alt_festival_cycle_length = 0i64
  class_property alt_festival_first_spawn = 0i64
  class_property alt_festival_first_swarm = 0i64
  class_property alt_festival_second_spawn = 0i64
  class_property alt_festival_second_swarm = 0i64
  class_property alt_festival_chest_spawn = 0i64
  class_property alt_siege_dawn_gates_pdef_mult = 0.0
  class_property alt_siege_dusk_gates_pdef_mult = 0.0
  class_property alt_siege_dawn_gates_mdef_mult = 0.0
  class_property alt_siege_dusk_gates_mdef_mult = 0.0
  class_property alt_strict_sevensigns = false
  class_property alt_sevensigns_lazy_update = false
  class_property ssq_dawn_ticket_quantity = 0
  class_property ssq_dawn_ticket_price = 0
  class_property ssq_dawn_ticket_bundle = 0
  class_property ssq_manors_agreement_id = 0
  class_property ssq_join_dawn_adena_fee = 0

  # --------------------------------------------------
  # Server Settings
  # --------------------------------------------------
  class_property enable_upnp = false
  class_property port_game = 0
  class_property port_login = 0
  class_property login_bind_address : String?
  class_property login_try_before_ban = 0
  class_property login_block_after_ban = 0
  class_property gameserver_hostname = ""
  class_property database_driver : String?
  class_property database_url : String = ""
  class_property database_login : String = ""
  class_property database_password : String = ""
  class_property database_connection_pool : String = ""
  class_property database_max_connections = 0
  class_property database_max_idle_time = 0
  class_property maximum_online_users = 0
  class_property player_name_template = /.*/
  class_property pet_name_template = /.*/
  class_property clan_name_template = /.*/
  class_property max_characters_number_per_account = 0
  class_property datapack_root = "?" # L2R: String, L2J: File
  class_property accept_alternate_id = false
  class_property database_engine = ""
  class_property request_id = 0
  class_property reserve_host_on_login = false
  class_property protocol_list = [] of Int32
  class_property login_server_schedule_restart = false
  class_property login_server_schedule_restart_time = 0i64

  # --------------------------------------------------
  # MMO Settings
  # --------------------------------------------------
  class_property mmo_selector_sleep_time = 0
  class_property mmo_max_send_per_pass = 0
  class_property mmo_max_read_per_pass = 0
  class_property mmo_helper_buffer_count = 0
  class_property mmo_tcp_nodelay = false

  # --------------------------------------------------
  # Vitality Settings
  # --------------------------------------------------
  class_property enable_vitality = false
  class_property recover_vitality_on_reconnect = false
  class_property enable_drop_vitality_herbs = false
  class_property rate_vitality_level_1 = 0f32
  class_property rate_vitality_level_2 = 0f32
  class_property rate_vitality_level_3 = 0f32
  class_property rate_vitality_level_4 = 0f32
  class_property rate_drop_vitality_herbs = 0f32
  class_property rate_recovery_vitality_peace_zone = 0f32
  class_property rate_vitality_lost = 0f32
  class_property rate_vitality_gain = 0f32
  class_property rate_recovery_on_reconnect = 0f32
  class_property starting_vitality_points = 0

  # --------------------------------------------------
  # No classification assigned to the following yet
  # --------------------------------------------------
  class_property max_item_in_packet = 0
  class_property check_known = false
  class_property game_server_login_port = 0
  class_property game_server_login_host : String?
  class_property game_server_subnets : Slice(String)?
  class_property game_server_hosts : Slice(String)?
  class_property pvp_normal_time = 0
  class_property pvp_pvp_time = 0

  # enum IdFactoryType: %i[Compaction BitSet Stack]

  # class_property idfactory_type = nil # IdFactoryType
  class_property bad_id_checking = false

  class_property enchant_chance_element_stone = 0.0
  class_property enchant_chance_element_crystal = 0.0
  class_property enchant_chance_element_jewel = 0.0
  class_property enchant_chance_element_energy = 0.0
  class_property enchant_blacklist = [] of Int32
  class_property augmentation_ng_skill_chance = 0
  class_property augmentation_ng_glow_chance = 0
  class_property augmentation_mid_skill_chance = 0
  class_property augmentation_mid_glow_chance = 0
  class_property augmentation_high_skill_chance = 0
  class_property augmentation_high_glow_chance = 0
  class_property augmentation_top_skill_chance = 0
  class_property augmentation_top_glow_chance = 0
  class_property augmentation_basestat_chance = 0
  class_property augmentation_acc_skill_chance = 0
  class_property retail_like_augmentation = false
  class_property retail_like_augmentation_ng_chance = [] of Int32
  class_property retail_like_augmentation_mid_chance = [] of Int32
  class_property retail_like_augmentation_high_chance = [] of Int32
  class_property retail_like_augmentation_top_chance = [] of Int32
  class_property retail_like_augmentation_accessory = false
  class_property augmentation_blacklist = [] of Int32
  class_property alt_allow_augment_pvp_items = false
  class_property hp_regen_multiplier = 0.0
  class_property mp_regen_multiplier = 0.0
  class_property cp_regen_multiplier = 0.0
  class_property is_telnet_enabled = false
  class_property show_licence = false
  class_property accept_new_gameserver = false
  class_property server_id = 1
  class_property hex_id : Bytes = Bytes.empty
  class_property auto_create_accounts = false
  class_property flood_protection = false
  class_property fast_connection_limit = 0
  class_property normal_connection_time = 0
  class_property fast_connection_time = 0
  class_property max_connection_per_ip = 0

  # GrandBoss Settings

  # Antharas
  class_property antharas_wait_time = 0
  class_property antharas_spawn_interval = 0
  class_property antharas_spawn_random = 0

  # Valakas
  class_property valakas_wait_time = 0
  class_property valakas_spawn_interval = 0
  class_property valakas_spawn_random = 0

  # Baium
  class_property baium_spawn_interval = 0
  class_property baium_spawn_random = 0

  # Core
  class_property core_spawn_interval = 0
  class_property core_spawn_random = 0

  # Offen
  class_property orfen_spawn_interval = 0
  class_property orfen_spawn_random = 0

  # Queen Ant
  class_property queen_ant_spawn_interval = 0
  class_property queen_ant_spawn_random = 0

  # Beleth
  class_property beleth_min_players = 0
  class_property beleth_spawn_interval = 0
  class_property beleth_spawn_random = 0

  # Gracia Seeds Settings
  class_property sod_tiat_kill_count = 0
  class_property sod_stage_2_length = 0i64

  # chatfilter
  class_property filter_list = [] of String

  # Email
  class_property email_serverinfo_name : String?
  class_property email_serverinfo_address : String?
  class_property email_sys_enabled = false
  class_property email_sys_host : String?
  class_property email_sys_port = 0
  class_property email_sys_smtp_auth = false
  class_property email_sys_factory : String?
  class_property email_sys_factory_callback = false
  class_property email_sys_username : String?
  class_property email_sys_password : String?
  class_property email_sys_address : String?
  class_property email_sys_selectquery : String?
  class_property email_sys_dbfield : String?

  # Conquerable Halls Settings
  class_property chs_clan_minlevel = 0
  class_property chs_max_attackers = 0
  class_property chs_max_flags_per_clan = 0
  class_property chs_enable_fame = false
  class_property chs_fame_amount = 0
  class_property chs_fame_frequency = 0

  # GeoData Settings
  class_property pathfinding = 0
  class_property pathnode_dir : String? # L2R: String, L2J: File
  class_property pathfind_buffers = ""
  class_property low_weight = 0f32
  class_property medium_weight = 0f32
  class_property high_weight = 0f32
  class_property advanced_diagonal_strategy = false
  class_property diagonal_weight = 0f32
  class_property max_postfilter_passes = 0
  class_property debug_path = false
  class_property force_geodata = false
  class_property coord_synchronize = 0
  class_property geodata_path = "" # L2R: String, L2J: Path
  class_property try_load_unspecified_regions = false
  class_property geodata_regions = {} of String => Bool

  private def load_protector_settings(cfg : StatsSet)
    load_flood_protector_config(cfg, @@flood_protector_use_item, "UseItem", 4)
    load_flood_protector_config(cfg, @@flood_protector_roll_dice, "RollDice", 42)
    load_flood_protector_config(cfg, @@flood_protector_firework, "Firework", 42)
    load_flood_protector_config(cfg, @@flood_protector_item_pet_summon, "ItemPetSummon", 16)
    load_flood_protector_config(cfg, @@flood_protector_hero_voice, "HeroVoice", 100)
    load_flood_protector_config(cfg, @@flood_protector_global_chat, "GlobalChat", 5)
    load_flood_protector_config(cfg, @@flood_protector_subclass, "Subclass", 20)
    load_flood_protector_config(cfg, @@flood_protector_drop_item, "DropItem", 10)
    load_flood_protector_config(cfg, @@flood_protector_server_bypass, "ServerBypass", 5)
    load_flood_protector_config(cfg, @@flood_protector_multisell, "MultiSell", 1)
    load_flood_protector_config(cfg, @@flood_protector_transaction, "Transaction", 10)
    load_flood_protector_config(cfg, @@flood_protector_manufacture, "Manufacture", 3)
    load_flood_protector_config(cfg, @@flood_protector_manor, "Manor", 30)
    load_flood_protector_config(cfg, @@flood_protector_sendmail, "SendMail", 100)
    load_flood_protector_config(cfg, @@flood_protector_character_select, "CharacterSelect", 30)
    load_flood_protector_config(cfg, @@flood_protector_item_auction, "ItemAuction", 9)
  end

  private def load_flood_protector_config(cfg, config, str, default_interval)
    config = config.not_nil!
    config.flood_protection_interval = cfg.get_i32("FloodProtector#{str}", default_interval)
    config.log_flooding = cfg.get_bool("FloodProtector#{str}LogFlooding", false)
    config.punishment_limit = cfg.get_i32("FloodProtector#{str}PunishmentLimit")
    config.punishment_type = cfg.get_string("FloodProtector#{str}PunishmentType", "none")
    config.punishment_time = cfg.get_i32("FloodProtector#{str}PunishmentTime") * 60000
  end

  private def get_server_type_id(array : Array(String))
    array.reduce(0) do |ret, t|
      case t.strip.downcase
      when "normal"     then ret | 0x01
      when "relax"      then ret | 0x02
      when "test"       then ret | 0x04
      when "nolabel"    then ret | 0x08
      when "restricted" then ret | 0x10
      when "event"      then ret | 0x20
      when "free"       then ret | 0x40
      else ret
      end
    end
  end

  def load
    timer = Timer.new

    cfg = StatsSet.new

    ## Server
    cfg.parse(Dir.current + CONFIGURATION_FILE)
    @@enable_upnp = cfg.get_bool("EnableUPnP", true)
    @@gameserver_hostname = cfg.get_string("GameserverHostname", "*")
    @@port_game = cfg.get_i32("GameserverPort", 7777)
    @@game_server_login_port = cfg.get_i32("LoginPort", 9014)
    @@game_server_login_host = cfg.get_string("LoginHost", "127.0.0.1")
    @@request_id = cfg.get_i32("RequestServerID", 0)
    @@accept_alternate_id = cfg.get_bool("AcceptAlternateID", true)
    @@database_engine = cfg.get_string("Database", "MySQL")
    @@database_driver = cfg.get_string("Driver", "com.mysql.jdbc.Driver")
    @@database_url = cfg.get_string("URL", "mysql://localhost/l2gs")
    @@database_login = cfg.get_string("Login", "root")
    @@database_password = cfg.get_string("Password")
    @@database_connection_pool = cfg.get_string("ConnectionPool", "C3P0")
    @@database_max_connections = cfg.get_i32("MaximumDbConnections", 10)
    @@database_max_idle_time = cfg.get_i32("MaximumDbIdleTime")
    datapack_root = cfg.get_string("DatapackRoot", ".")
    # if Dir.exists?(datapack_root)
    #   DATAPACK_ROOT = Dir.open datapack_root
    # else
    #   DATAPACK_ROOT = Dir.current
    # end
    @@datapack_root = Dir.current + "/data"
    @@player_name_template = cfg.get_regex("PlayerNameTemplate", /.*/)
    @@pet_name_template = cfg.get_regex("PetNameTemplate", /.*/)
    @@clan_name_template = cfg.get_regex("ClanNameTemplate", /.*/)
    @@max_characters_number_per_account = cfg.get_i32("CharMaxNumber", 7)
    @@maximum_online_users = cfg.get_i32("MaximumOnlineUsers", 100)
    @@protocol_list = cfg.get_i32_array("AllowedProtocolRevisions")

    # Feature
    cfg.parse(Dir.current + FEATURE_CONFIG_FILE)
    @@ch_tele_fee_ratio = cfg.get_i64("ClanHallTeleportFunctionFeeRatio", 604800000)
    @@ch_tele1_fee = cfg.get_i32("ClanHallTeleportFunctionFeeLvl1", 7000)
    @@ch_tele2_fee = cfg.get_i32("ClanHallTeleportFunctionFeeLvl2", 14000)
    @@ch_support_fee_ratio = cfg.get_i64("ClanHallSupportFunctionFeeRatio", 86400000)
    @@ch_support1_fee = cfg.get_i32("ClanHallSupportFeeLvl1", 2500)
    @@ch_support2_fee = cfg.get_i32("ClanHallSupportFeeLvl2", 5000)
    @@ch_support3_fee = cfg.get_i32("ClanHallSupportFeeLvl3", 7000)
    @@ch_support4_fee = cfg.get_i32("ClanHallSupportFeeLvl4", 11000)
    @@ch_support5_fee = cfg.get_i32("ClanHallSupportFeeLvl5", 21000)
    @@ch_support6_fee = cfg.get_i32("ClanHallSupportFeeLvl6", 36000)
    @@ch_support7_fee = cfg.get_i32("ClanHallSupportFeeLvl7", 37000)
    @@ch_support8_fee = cfg.get_i32("ClanHallSupportFeeLvl8", 52000)
    @@ch_mpreg_fee_ratio = cfg.get_i64("ClanHallMpRegenerationFunctionFeeRatio", 86400000)
    @@ch_mpreg1_fee = cfg.get_i32("ClanHallMpRegenerationFeeLvl1", 2000)
    @@ch_mpreg2_fee = cfg.get_i32("ClanHallMpRegenerationFeeLvl2", 3750)
    @@ch_mpreg3_fee = cfg.get_i32("ClanHallMpRegenerationFeeLvl3", 6500)
    @@ch_mpreg4_fee = cfg.get_i32("ClanHallMpRegenerationFeeLvl4", 13750)
    @@ch_mpreg5_fee = cfg.get_i32("ClanHallMpRegenerationFeeLvl5", 20000)
    @@ch_hpreg_fee_ratio = cfg.get_i64("ClanHallHpRegenerationFunctionFeeRatio", 86400000)
    @@ch_hpreg1_fee = cfg.get_i32("ClanHallHpRegenerationFeeLvl1", 700)
    @@ch_hpreg2_fee = cfg.get_i32("ClanHallHpRegenerationFeeLvl2", 800)
    @@ch_hpreg3_fee = cfg.get_i32("ClanHallHpRegenerationFeeLvl3", 1000)
    @@ch_hpreg4_fee = cfg.get_i32("ClanHallHpRegenerationFeeLvl4", 1166)
    @@ch_hpreg5_fee = cfg.get_i32("ClanHallHpRegenerationFeeLvl5", 1500)
    @@ch_hpreg6_fee = cfg.get_i32("ClanHallHpRegenerationFeeLvl6", 1750)
    @@ch_hpreg7_fee = cfg.get_i32("ClanHallHpRegenerationFeeLvl7", 2000)
    @@ch_hpreg8_fee = cfg.get_i32("ClanHallHpRegenerationFeeLvl8", 2250)
    @@ch_hpreg9_fee = cfg.get_i32("ClanHallHpRegenerationFeeLvl9", 2500)
    @@ch_hpreg10_fee = cfg.get_i32("ClanHallHpRegenerationFeeLvl10", 3250)
    @@ch_hpreg11_fee = cfg.get_i32("ClanHallHpRegenerationFeeLvl11", 3270)
    @@ch_hpreg12_fee = cfg.get_i32("ClanHallHpRegenerationFeeLvl12", 4250)
    @@ch_hpreg13_fee = cfg.get_i32("ClanHallHpRegenerationFeeLvl13", 5166)
    @@ch_expreg_fee_ratio = cfg.get_i64("ClanHallExpRegenerationFunctionFeeRatio", 86400000)
    @@ch_expreg1_fee = cfg.get_i32("ClanHallExpRegenerationFeeLvl1", 3000)
    @@ch_expreg2_fee = cfg.get_i32("ClanHallExpRegenerationFeeLvl2", 6000)
    @@ch_expreg3_fee = cfg.get_i32("ClanHallExpRegenerationFeeLvl3", 9000)
    @@ch_expreg4_fee = cfg.get_i32("ClanHallExpRegenerationFeeLvl4", 15000)
    @@ch_expreg5_fee = cfg.get_i32("ClanHallExpRegenerationFeeLvl5", 21000)
    @@ch_expreg6_fee = cfg.get_i32("ClanHallExpRegenerationFeeLvl6", 23330)
    @@ch_expreg7_fee = cfg.get_i32("ClanHallExpRegenerationFeeLvl7", 30000)
    @@ch_item_fee_ratio = cfg.get_i64("ClanHallItemCreationFunctionFeeRatio", 86400000)
    @@ch_item1_fee = cfg.get_i32("ClanHallItemCreationFunctionFeeLvl1", 30000)
    @@ch_item2_fee = cfg.get_i32("ClanHallItemCreationFunctionFeeLvl2", 70000)
    @@ch_item3_fee = cfg.get_i32("ClanHallItemCreationFunctionFeeLvl3", 140000)
    @@ch_curtain_fee_ratio = cfg.get_i64("ClanHallCurtainFunctionFeeRatio", 604800000)
    @@ch_curtain1_fee = cfg.get_i32("ClanHallCurtainFunctionFeeLvl1", 2000)
    @@ch_curtain2_fee = cfg.get_i32("ClanHallCurtainFunctionFeeLvl2", 2500)
    @@ch_front_fee_ratio = cfg.get_i64("ClanHallFrontPlatformFunctionFeeRatio", 259200000)
    @@ch_front1_fee = cfg.get_i32("ClanHallFrontPlatformFunctionFeeLvl1", 1300)
    @@ch_front2_fee = cfg.get_i32("ClanHallFrontPlatformFunctionFeeLvl2", 4000)
    @@ch_buff_free = cfg.get_bool("AltClanHallMpBuffFree")
    @@siege_hour_list = cfg.get_i32_array("SiegeHourList")

    @@cs_tele_fee_ratio = cfg.get_i64("CastleTeleportFunctionFeeRatio", 604800000)
    @@cs_tele1_fee = cfg.get_i32("CastleTeleportFunctionFeeLvl1", 1000)
    @@cs_tele2_fee = cfg.get_i32("CastleTeleportFunctionFeeLvl2", 10000)
    @@cs_support_fee_ratio = cfg.get_i64("CastleSupportFunctionFeeRatio", 604800000)
    @@cs_support1_fee = cfg.get_i32("CastleSupportFeeLvl1", 49000)
    @@cs_support2_fee = cfg.get_i32("CastleSupportFeeLvl2", 120000)
    @@cs_mpreg_fee_ratio = cfg.get_i64("CastleMpRegenerationFunctionFeeRatio", 604800000)
    @@cs_mpreg1_fee = cfg.get_i32("CastleMpRegenerationFeeLvl1", 45000)
    @@cs_mpreg2_fee = cfg.get_i32("CastleMpRegenerationFeeLvl2", 65000)
    @@cs_hpreg_fee_ratio = cfg.get_i64("CastleHpRegenerationFunctionFeeRatio", 604800000)
    @@cs_hpreg1_fee = cfg.get_i32("CastleHpRegenerationFeeLvl1", 12000)
    @@cs_hpreg2_fee = cfg.get_i32("CastleHpRegenerationFeeLvl2", 20000)
    @@cs_expreg_fee_ratio = cfg.get_i64("CastleExpRegenerationFunctionFeeRatio", 604800000)
    @@cs_expreg1_fee = cfg.get_i32("CastleExpRegenerationFeeLvl1", 63000)
    @@cs_expreg2_fee = cfg.get_i32("CastleExpRegenerationFeeLvl2", 70000)

    @@outer_door_upgrade_price2 = cfg.get_i32("OuterDoorUpgradePriceLvl2", 3000000)
    @@outer_door_upgrade_price3 = cfg.get_i32("OuterDoorUpgradePriceLvl3", 4000000)
    @@outer_door_upgrade_price5 = cfg.get_i32("OuterDoorUpgradePriceLvl5", 5000000)
    @@inner_door_upgrade_price2 = cfg.get_i32("InnerDoorUpgradePriceLvl2", 750000)
    @@inner_door_upgrade_price3 = cfg.get_i32("InnerDoorUpgradePriceLvl3", 900000)
    @@inner_door_upgrade_price5 = cfg.get_i32("InnerDoorUpgradePriceLvl5", 1000000)
    @@wall_upgrade_price2 = cfg.get_i32("WallUpgradePriceLvl2", 1600000)
    @@wall_upgrade_price3 = cfg.get_i32("WallUpgradePriceLvl3", 1800000)
    @@wall_upgrade_price5 = cfg.get_i32("WallUpgradePriceLvl5", 2000000)
    @@trap_upgrade_price1 = cfg.get_i32("TrapUpgradePriceLvl1", 3000000)
    @@trap_upgrade_price2 = cfg.get_i32("TrapUpgradePriceLvl2", 4000000)
    @@trap_upgrade_price3 = cfg.get_i32("TrapUpgradePriceLvl3", 5000000)
    @@trap_upgrade_price4 = cfg.get_i32("TrapUpgradePriceLvl4", 6000000)

    @@fs_tele_fee_ratio = cfg.get_i64("FortressTeleportFunctionFeeRatio", 604800000)
    @@fs_tele1_fee = cfg.get_i32("FortressTeleportFunctionFeeLvl1", 1000)
    @@fs_tele2_fee = cfg.get_i32("FortressTeleportFunctionFeeLvl2", 10000)
    @@fs_support_fee_ratio = cfg.get_i64("FortressSupportFunctionFeeRatio", 86400000)
    @@fs_support1_fee = cfg.get_i32("FortressSupportFeeLvl1", 7000)
    @@fs_support2_fee = cfg.get_i32("FortressSupportFeeLvl2", 17000)
    @@fs_mpreg_fee_ratio = cfg.get_i64("FortressMpRegenerationFunctionFeeRatio", 86400000)
    @@fs_mpreg1_fee = cfg.get_i32("FortressMpRegenerationFeeLvl1", 6500)
    @@fs_mpreg2_fee = cfg.get_i32("FortressMpRegenerationFeeLvl2", 9300)
    @@fs_hpreg_fee_ratio = cfg.get_i64("FortressHpRegenerationFunctionFeeRatio", 86400000)
    @@fs_hpreg1_fee = cfg.get_i32("FortressHpRegenerationFeeLvl1", 2000)
    @@fs_hpreg2_fee = cfg.get_i32("FortressHpRegenerationFeeLvl2", 3500)
    @@fs_expreg_fee_ratio = cfg.get_i64("FortressExpRegenerationFunctionFeeRatio", 86400000)
    @@fs_expreg1_fee = cfg.get_i32("FortressExpRegenerationFeeLvl1", 9000)
    @@fs_expreg2_fee = cfg.get_i32("FortressExpRegenerationFeeLvl2", 10000)
    @@fs_update_frq = cfg.get_i32("FortressPeriodicUpdateFrequency", 360)
    @@fs_blood_oath_count = cfg.get_i32("FortressBloodOathCount", 1)
    @@fs_max_supply_level = cfg.get_i32("FortressMaxSupplyLevel", 6)
    @@fs_fee_for_castle = cfg.get_i64("FortressFeeForCastle", 25000)
    @@fs_max_own_time = cfg.get_i32("FortressMaximumOwnTime", 168)

    @@alt_game_castle_dawn = cfg.get_bool("AltCastleForDawn", true)
    @@alt_game_castle_dusk = cfg.get_bool("AltCastleForDusk", true)
    @@alt_game_require_clan_castle = cfg.get_bool("AltRequireClanCastle")
    @@alt_festival_min_player = cfg.get_i32("AltFestivalMinPlayer", 5)
    @@alt_maximum_player_contrib = cfg.get_i64("AltMaxPlayerContrib", 1000000)
    @@alt_festival_manager_start = cfg.get_i64("AltFestivalManagerStart", 120000)
    @@alt_festival_length = cfg.get_i64("AltFestivalLength", 1080000)
    @@alt_festival_cycle_length = cfg.get_i64("AltFestivalCycleLength", 2280000)
    @@alt_festival_first_spawn = cfg.get_i64("AltFestivalFirstSpawn", 120000)
    @@alt_festival_first_swarm = cfg.get_i64("AltFestivalFirstSwarm", 300000)
    @@alt_festival_second_spawn = cfg.get_i64("AltFestivalSecondSpawn", 540000)
    @@alt_festival_second_swarm = cfg.get_i64("AltFestivalSecondSwarm", 720000)
    @@alt_festival_chest_spawn = cfg.get_i64("AltFestivalChestSpawn", 900000)
    @@alt_siege_dawn_gates_pdef_mult = cfg.get_f64("AltDawnGatesPdefMult", 1.1)
    @@alt_siege_dusk_gates_pdef_mult = cfg.get_f64("AltDuskGatesPdefMult", 0.8)
    @@alt_siege_dawn_gates_mdef_mult = cfg.get_f64("AltDawnGatesMdefMult", 1.1)
    @@alt_siege_dusk_gates_mdef_mult = cfg.get_f64("AltDuskGatesMdefMult", 0.8)
    @@alt_strict_sevensigns = cfg.get_bool("StrictSevenSigns", true)
    @@alt_sevensigns_lazy_update = cfg.get_bool("AltSevenSignsLazyUpdate", true)

    @@ssq_dawn_ticket_quantity = cfg.get_i32("SevenSignsDawnTicketQuantity", 300)
    @@ssq_dawn_ticket_price = cfg.get_i32("SevenSignsDawnTicketPrice", 1000)
    @@ssq_dawn_ticket_bundle = cfg.get_i32("SevenSignsDawnTicketBundle", 10)
    @@ssq_manors_agreement_id = cfg.get_i32("SevenSignsManorsAgreementId", 6388)
    @@ssq_join_dawn_adena_fee = cfg.get_i32("SevenSignsJoinDawnFee", 50000)

    @@take_fort_points = cfg.get_i32("TakeFortPoints", 200)
    @@lose_fort_points = cfg.get_i32("LooseFortPoints")
    @@take_castle_points = cfg.get_i32("TakeCastlePoints", 1500)
    @@lose_castle_points = cfg.get_i32("LooseCastlePoints", 3000)
    @@castle_defended_points = cfg.get_i32("CastleDefendedPoints", 750)
    @@festival_win_points = cfg.get_i32("FestivalOfDarknessWin", 200)
    @@hero_points = cfg.get_i32("HeroPoints", 1000)
    @@royal_guard_cost = cfg.get_i32("CreateRoyalGuardCost", 5000)
    @@knight_unit_cost = cfg.get_i32("CreateKnightUnitCost", 10000)
    @@knight_reinforce_cost = cfg.get_i32("ReinforceKnightUnitCost", 5000)
    @@ballista_points = cfg.get_i32("KillBallistaPoints", 30)
    @@bloodalliance_points = cfg.get_i32("BloodAlliancePoints", 500)
    @@bloodoath_points = cfg.get_i32("BloodOathPoints", 200)
    @@knightsepaulette_points = cfg.get_i32("KnightsEpaulettePoints", 20)
    @@reputation_score_per_kill = cfg.get_i32("ReputationScorePerKill", 1)
    @@join_academy_min_rep_score = cfg.get_i32("CompleteAcademyMinPoints", 190)
    @@join_academy_max_rep_score = cfg.get_i32("CompleteAcademyMaxPoints", 650)
    @@raid_ranking_1st = cfg.get_i32("1stRaidRankingPoints", 1250)
    @@raid_ranking_2nd = cfg.get_i32("2ndRaidRankingPoints", 900)
    @@raid_ranking_3rd = cfg.get_i32("3rdRaidRankingPoints", 700)
    @@raid_ranking_4th = cfg.get_i32("4thRaidRankingPoints", 600)
    @@raid_ranking_5th = cfg.get_i32("5thRaidRankingPoints", 450)
    @@raid_ranking_6th = cfg.get_i32("6thRaidRankingPoints", 350)
    @@raid_ranking_7th = cfg.get_i32("7thRaidRankingPoints", 300)
    @@raid_ranking_8th = cfg.get_i32("8thRaidRankingPoints", 200)
    @@raid_ranking_9th = cfg.get_i32("9thRaidRankingPoints", 150)
    @@raid_ranking_10th = cfg.get_i32("10thRaidRankingPoints", 100)
    @@raid_ranking_up_to_50th = cfg.get_i32("UpTo50thRaidRankingPoints", 25)
    @@raid_ranking_up_to_100th = cfg.get_i32("UpTo100thRaidRankingPoints", 12)
    @@clan_level_6_cost = cfg.get_i32("ClanLevel6Cost", 5000)
    @@clan_level_7_cost = cfg.get_i32("ClanLevel7Cost", 10000)
    @@clan_level_8_cost = cfg.get_i32("ClanLevel8Cost", 20000)
    @@clan_level_9_cost = cfg.get_i32("ClanLevel9Cost", 40000)
    @@clan_level_10_cost = cfg.get_i32("ClanLevel10Cost", 40000)
    @@clan_level_11_cost = cfg.get_i32("ClanLevel11Cost", 75000)
    @@clan_level_6_requirement = cfg.get_i32("ClanLevel6Requirement", 30)
    @@clan_level_7_requirement = cfg.get_i32("ClanLevel7Requirement", 50)
    @@clan_level_8_requirement = cfg.get_i32("ClanLevel8Requirement", 80)
    @@clan_level_9_requirement = cfg.get_i32("ClanLevel9Requirement", 120)
    @@clan_level_10_requirement = cfg.get_i32("ClanLevel10Requirement", 140)
    @@clan_level_11_requirement = cfg.get_i32("ClanLevel11Requirement", 170)
    @@allow_wyvern_always = cfg.get_bool("AllowRideWyvernAlways")
    @@allow_wyvern_during_siege = cfg.get_bool("AllowRideWyvernDuringSiege", true)

    # Character
    cfg.parse(Dir.current + CHARACTER_CONFIG_FILE)
    @@alt_game_delevel = cfg.get_bool("Delevel", true)
    @@decrease_skill_level = cfg.get_bool("DecreaseSkillOnDelevel", true)
    @@alt_weight_limit = cfg.get_f64("AltWeightLimit", 1)
    @@run_spd_boost = cfg.get_i32("RunSpeedBoost")
    @@death_penalty_chance = cfg.get_i32("DeathPenaltyChance", 20)
    @@respawn_restore_cp = cfg.get_f64("RespawnRestoreCP") / 100
    @@respawn_restore_hp = cfg.get_f64("RespawnRestoreHP", 65) / 100
    @@respawn_restore_mp = cfg.get_f64("RespawnRestoreMP") / 100
    @@cp_regen_multiplier = cfg.get_f64("CpRegenMultiplier", 100) / 100
    @@hp_regen_multiplier = cfg.get_f64("HpRegenMultiplier", 100) / 100
    @@mp_regen_multiplier = cfg.get_f64("MpRegenMultiplier", 100) / 100
    @@enable_modify_skill_duration = cfg.get_bool("EnableModifySkillDuration")
    if @@enable_modify_skill_duration
      @@skill_duration_list = cfg.get_i32_hash("SkillDurationList")
    end
    @@enable_modify_skill_reuse = cfg.get_bool("EnableModifySkillReuse")
    if @@enable_modify_skill_reuse
      @@skill_reuse_list = cfg.get_i32_hash("SkillReuseList")
    end
    @@auto_learn_skills = cfg.get_bool("AutoLearnSkills")
    @@auto_learn_fs_skills = cfg.get_bool("AutoLearnForgottenScrollSkills")
    @@auto_loot_herbs = cfg.get_bool("AutoLootHerbs")
    @@buffs_max_amount = cfg.get_i8("MaxBuffAmount", 20)
    @@triggered_buffs_max_amount = cfg.get_i8("MaxTriggeredBuffAmount", 12)
    @@dances_max_amount = cfg.get_i8("MaxDanceAmount", 12)
    @@dance_cancel_buff = cfg.get_bool("DanceCancelBuff")
    @@dance_consume_additional_mp = cfg.get_bool("DanceConsumeAdditionalMP", true)
    @@alt_store_dances = cfg.get_bool("AltStoreDances")
    @@auto_learn_divine_inspiration = cfg.get_bool("AutoLearnDivineInspiration")
    @@alt_game_cancel_bow = cfg.get_string("AltGameCancelByHit", "Cast").casecmp?("bow") || cfg.get_string("AltGameCancelByHit", "Cast").casecmp?("all")
    @@alt_game_cancel_cast = cfg.get_string("AltGameCancelByHit", "Cast").casecmp?("cast") || cfg.get_string("AltGameCancelByHit", "Cast").casecmp?("all")
    @@alt_game_magicfailures = cfg.get_bool("MagicFailures", true)
    @@player_fakedeath_up_protection = cfg.get_i32("PlayerFakeDeathUpProtection", 0)
    @@store_skill_cooltime = cfg.get_bool("StoreSkillCooltime", true)
    @@subclass_store_skill_cooltime = cfg.get_bool("SubclassStoreSkillCooltime")
    @@summon_store_skill_cooltime = cfg.get_bool("SummonStoreSkillCooltime", true)
    @@alt_game_shield_blocks = cfg.get_bool("AltShieldBlocks")
    @@alt_perfect_shld_block = cfg.get_i32("AltPerfectShieldBlockRate", 10)
    @@effect_tick_ratio = cfg.get_i64("EffectTickRatio", 666)
    @@allow_class_masters = cfg.get_bool("AllowClassMasters")
    @@allow_entire_tree = cfg.get_bool("AllowEntireTree")
    @@alternate_class_master = cfg.get_bool("AlternateClassMaster")
    if @@allow_class_masters || @@alternate_class_master
      cms = cfg.get_string("ConfigClassMaster")
      @@class_master_settings = ClassMasterSettings.new(cms)
    end
    @@life_crystal_needed = cfg.get_bool("LifeCrystalNeeded", true)
    @@es_sp_book_needed = cfg.get_bool("EnchantSkillSpBookNeeded", true)
    @@divine_sp_book_needed = cfg.get_bool("DivineInspirationSpBookNeeded", true)
    @@alt_game_skill_learn = cfg.get_bool("AltGameSkillLearn")
    @@alt_game_subclass_without_quests = cfg.get_bool("AltSubClassWithoutQuests")
    @@alt_game_subclass_everywhere = cfg.get_bool("AltSubclassEverywhere")
    @@restore_servitor_on_reconnect = cfg.get_bool("RestoreServitorOnReconnect", true)
    @@restore_pet_on_reconnect = cfg.get_bool("RestorePetOnReconnect", true)
    @@allow_transform_without_quest = cfg.get_bool("AltTransformationWithoutQuest")
    @@fee_delete_transfer_skills = cfg.get_i64("FeeDeleteTransferSkills", 10000000i64)
    @@fee_delete_subclass_skills = cfg.get_i64("FeeDeleteSubClassSkills", 10000000i64)
    @@enable_vitality = cfg.get_bool("EnableVitality", true)
    @@recover_vitality_on_reconnect = cfg.get_bool("RecoverVitalityOnReconnect", true)
    @@starting_vitality_points = cfg.get_i32("StartingVitalityPoints", 20000)
    @@max_bonus_exp = cfg.get_f64("MaxExpBonus", 3.5)
    @@max_bonus_sp = cfg.get_f64("MaxSpBonus", 3.5)
    @@max_run_speed = cfg.get_i32("MaxRunSpeed", 250)
    @@max_pcrit_rate = cfg.get_i32("MaxPCritRate", 500)
    @@max_mcrit_rate = cfg.get_i32("MaxMCritRate", 200)
    @@max_patk_speed = cfg.get_i32("MaxPAtkSpeed", 1500)
    @@max_matk_speed = cfg.get_i32("MaxMAtkSpeed", 1999)
    @@max_evasion = cfg.get_i32("MaxEvasion", 250)
    @@min_abnormal_state_success_rate = cfg.get_i32("MinAbnormalStateSuccessRate", 10)
    @@max_abnormal_state_success_rate = cfg.get_i32("MaxAbnormalStateSuccessRate", 90)
    @@max_player_level = cfg.get_i32("MaxPlayerLevel", 85)
    @@max_pet_level = cfg.get_i32("MaxPetLevel", 86)
    @@max_subclass = cfg.get_i32("MaxSubclass", 3)
    @@base_subclass_level = cfg.get_i32("BaseSubclassLevel", 40)
    @@max_subclass_level = cfg.get_i32("MaxSubclassLevel", 80)
    @@max_pvtstoresell_slots_dwarf = cfg.get_i32("MaxPvtStoreSellSlotsDwarf", 4)
    @@max_pvtstoresell_slots_other = cfg.get_i32("MaxPvtStoreSellSlotsOther", 3)
    @@max_pvtstorebuy_slots_dwarf = cfg.get_i32("MaxPvtStoreBuySlotsDwarf", 5)
    @@max_pvtstorebuy_slots_other = cfg.get_i32("MaxPvtStoreBuySlotsOther", 4)
    @@inventory_maximum_no_dwarf = cfg.get_i32("MaximumSlotsForNoDwarf", 80)
    @@inventory_maximum_dwarf = cfg.get_i32("MaximumSlotsForDwarf", 100)
    @@inventory_maximum_gm = cfg.get_i32("MaximumSlotsForGMPlayer", 250)
    @@inventory_maximum_quest_items = cfg.get_i32("MaximumSlotsForQuestItems", 100)
    @@max_item_in_packet = Math.max(Math.max(@@inventory_maximum_no_dwarf, @@inventory_maximum_dwarf), @@inventory_maximum_gm)
    @@warehouse_slots_dwarf = cfg.get_i32("MaximumWarehouseSlotsForDwarf", 120)
    @@warehouse_slots_no_dwarf = cfg.get_i32("MaximumWarehouseSlotsForNoDwarf", 100)
    @@warehouse_slots_clan = cfg.get_i32("MaximumWarehouseSlotsForClan", 150)
    @@alt_freight_slots = cfg.get_i32("MaximumFreightSlots", 200)
    @@alt_freight_price = cfg.get_i32("FreightPrice", 1000)
    @@enchant_chance_element_stone = cfg.get_f64("EnchantChanceElementStone", 50)
    @@enchant_chance_element_crystal = cfg.get_f64("EnchantChanceElementCrystal", 30)
    @@enchant_chance_element_jewel = cfg.get_f64("EnchantChanceElementJewel", 20)
    @@enchant_chance_element_energy = cfg.get_f64("EnchantChanceElementEnergy", 10)
    @@enchant_blacklist = cfg.get_i32_array("EnchantBlackList", [7816,7817,7818,7819,7820,7821,7822,7823,7824,7825,7826,7827,7828,7829,7830,7831,13293,13294,13296])
    @@enchant_blacklist.sort!

    @@augmentation_ng_skill_chance = cfg.get_i32("AugmentationNGSkillChance", 15)
    @@augmentation_ng_glow_chance = cfg.get_i32("AugmentationNGGlowChance")
    @@augmentation_mid_skill_chance = cfg.get_i32("AugmentationMidSkillChance", 30)
    @@augmentation_mid_glow_chance = cfg.get_i32("AugmentationMidGlowChance", 40)
    @@augmentation_high_skill_chance = cfg.get_i32("AugmentationHighSkillChance", 45)
    @@augmentation_high_glow_chance = cfg.get_i32("AugmentationHighGlowChance", 70)
    @@augmentation_top_skill_chance = cfg.get_i32("AugmentationTopSkillChance", 60)
    @@augmentation_top_glow_chance = cfg.get_i32("AugmentationTopGlowChance", 100)
    @@augmentation_basestat_chance = cfg.get_i32("AugmentationBaseStatChance", 1)
    @@augmentation_acc_skill_chance = cfg.get_i32("AugmentationAccSkillChance")

    @@retail_like_augmentation = cfg.get_bool("RetailLikeAugmentation", true)
    @@retail_like_augmentation_ng_chance = cfg.get_i32_array("RetailLikeAugmentationNoGradeChance", [55,35,7,3])
    @@retail_like_augmentation_mid_chance = cfg.get_i32_array("RetailLikeAugmentationMidGradeChance", [55,35,7,3])
    @@retail_like_augmentation_high_chance = cfg.get_i32_array("RetailLikeAugmentationHighGradeChance", [55,35,7,3])
    @@retail_like_augmentation_top_chance = cfg.get_i32_array("RetailLikeAugmentationTopGradeChance", [55,35,7,3])
    @@retail_like_augmentation_accessory = cfg.get_bool("RetailLikeAugmentationAccessory", true)
    @@augmentation_blacklist = cfg.get_i32_array("AugmentationBlackList", [6656,6657,6658,6659,6660,6661,6662,8191,10170,10314,13740,13741,13742,13743,13744,13745,13746,13747,13748,14592,14593,14594,14595,14596,14597,14598,14599,14600,14664,14665,14666,14667,14668,14669,14670,14671,14672,14801,14802,14803,14804,14805,14806,14807,14808,14809,15282,15283,15284,15285,15286,15287,15288,15289,15290,15291,15292,15293,15294,15295,15296,15297,15298,15299,16025,16026,21712,22173,22174,22175])
    @@augmentation_blacklist.sort!

    @@alt_allow_augment_pvp_items = cfg.get_bool("AltAllowAugmentPvPItems")
    @@alt_game_karma_player_can_be_killed_in_peacezone = cfg.get_bool("AltKarmaPlayerCanBeKilledInPeaceZone")
    @@alt_game_karma_player_can_shop = cfg.get_bool("AltKarmaPlayerCanShop", true)
    @@alt_game_karma_player_can_teleport = cfg.get_bool("AltKarmaPlayerCanTeleport", true)
    @@alt_game_karma_player_can_use_gk = cfg.get_bool("AltKarmaPlayerCanUseGK")
    @@alt_game_karma_player_can_trade = cfg.get_bool("AltKarmaPlayerCanTrade", true)
    @@alt_game_karma_player_can_use_warehouse = cfg.get_bool("AltKarmaPlayerCanUseWareHouse", true)
    @@max_personal_fame_points = cfg.get_i32("MaxPersonalFamePoints", 100000)
    @@fortress_zone_fame_task_frequency = cfg.get_i64("FortressZoneFameTaskFrequency", 300)
    @@fortress_zone_fame_aquire_points = cfg.get_i32("FortressZoneFameAquirePoints", 31)
    @@castle_zone_fame_task_frequency = cfg.get_i64("CastleZoneFameTaskFrequency", 300)
    @@castle_zone_fame_aquire_points = cfg.get_i32("CastleZoneFameAquirePoints", 125)
    @@fame_for_dead_players = cfg.get_bool("FameForDeadPlayers", true)
    @@is_crafting_enabled = cfg.get_bool("CraftingEnabled", true)
    @@craft_masterwork = cfg.get_bool("CraftMasterwork", true)
    @@dwarf_recipe_limit = cfg.get_i32("DwarfRecipeLimit", 50)
    @@common_recipe_limit = cfg.get_i32("CommonRecipeLimit", 50)
    @@alt_game_creation = cfg.get_bool("AltGameCreation")
    @@alt_game_creation_speed = cfg.get_f64("AltGameCreationSpeed", 1)
    @@alt_game_creation_xp_rate = cfg.get_f64("AltGameCreationXpRate", 1)
    @@alt_game_creation_sp_rate = cfg.get_f64("AltGameCreationSpRate", 1)
    @@alt_game_creation_rare_xpsp_rate = cfg.get_f64("AltGameCreationRareXpSpRate", 2)
    @@alt_blacksmith_use_recipes = cfg.get_bool("AltBlacksmithUseRecipes", true)
    @@alt_clan_leader_date_change = cfg.get_i32("AltClanLeaderDateChange", 3)
    if @@alt_clan_leader_date_change < 1 || @@alt_clan_leader_date_change > 7
      warn "wrong value for ALT_CLAN_LEADER_DATE_CHANGE"
      @@alt_clan_leader_date_change = 3
    end

    @@alt_clan_leader_hour_change = cfg.get_string("AltClanLeaderHourChange", "00:00:00")
    @@alt_clan_leader_instant_activation = cfg.get_bool("AltClanLeaderInstantActivation")
    @@alt_clan_join_days = cfg.get_i32("DaysBeforeJoinAClan", 1)
    @@alt_clan_create_days = cfg.get_i32("DaysBeforeCreateAClan", 10)
    @@alt_clan_dissolve_days = cfg.get_i32("DaysToPassToDissolveAClan", 7)
    @@alt_ally_join_days_when_leaved = cfg.get_i32("DaysBeforeJoinAllyWhenLeaved", 1)
    @@alt_ally_join_days_when_dismissed = cfg.get_i32("DaysBeforeJoinAllyWhenDismissed", 1)
    @@alt_accept_clan_days_when_dismissed = cfg.get_i32("DaysBeforeAcceptNewClanWhenDismissed", 1)
    @@alt_create_ally_days_when_dissolved = cfg.get_i32("DaysBeforeCreateNewAllyWhenDissolved", 1)
    @@alt_max_num_of_clans_in_ally = cfg.get_i32("AltMaxNumOfClansInAlly", 3)
    @@alt_clan_members_for_war = cfg.get_i32("AltClanMembersForWar", 15)
    @@alt_members_can_withdraw_from_clanwh = cfg.get_bool("AltMembersCanWithdrawFromClanWH")
    @@remove_castle_circlets = cfg.get_bool("RemoveCastleCirclets", true)
    @@alt_party_range = cfg.get_i32("AltPartyRange", 1600)
    @@alt_party_range2 = cfg.get_i32("AltPartyRange2", 1400)
    @@alt_leave_party_leader = cfg.get_bool("AltLeavePartyLeader")
    @@initial_equipment_event = cfg.get_bool("InitialEquipmentEvent")
    @@starting_adena = cfg.get_i64("StartingAdena", 0)
    @@starting_level = cfg.get_i8("StartingLevel", 1)
    @@starting_sp = cfg.get_i32("StartingSP", 0)
    @@max_adena = cfg.get_i64("MaxAdena", 99900000000) rescue Int64::MAX
    @@max_adena = Int64::MAX if @@max_adena < 0

    @@auto_loot = cfg.get_bool("AutoLoot")
    @@auto_loot_raids = cfg.get_bool("AutoLootRaids")
    @@loot_raids_privilege_interval = cfg.get_i32("RaidLootRightsInterval", 900) * 1000
    @@loot_raids_privilege_cc_size = cfg.get_i32("RaidLootRightsCCSize", 45)
    @@unstuck_interval = cfg.get_i32("UnstuckInterval", 300)
    @@teleport_watchdog_timeout = cfg.get_i32("TeleportWatchdogTimeout", 0)
    @@player_spawn_protection = cfg.get_i32("PlayerSpawnProtection", 0)
    @@spawn_protection_allowed_items = cfg.get_i32_array("PlayerSpawnProtectionAllowedItems")

    @@player_teleport_protection = cfg.get_i32("PlayerTeleportProtection", 0)
    @@random_respawn_in_town_enabled = cfg.get_bool("RandomRespawnInTownEnabled", true)
    @@offset_on_teleport_enabled = cfg.get_bool("OffsetOnTeleportEnabled", true)
    @@max_offset_on_teleport = cfg.get_i32("MaxOffsetOnTeleport", 50)
    @@petitioning_allowed = cfg.get_bool("PetitioningAllowed", true)
    @@max_petitions_per_player = cfg.get_i32("MaxPetitionsPerPlayer", 5)
    @@max_petitions_pending = cfg.get_i32("MaxPetitionsPending", 25)
    @@alt_game_free_teleport = cfg.get_bool("AltFreeTeleporting")
    @@delete_days = cfg.get_i32("DeleteCharAfterDays", 7)
    @@alt_game_exponent_xp = cfg.get_f32("AltGameExponentXp", 0)
    @@alt_game_exponent_sp = cfg.get_f32("AltGameExponentSp", 0)
    @@party_xp_cutoff_method = cfg.get_string("PartyXpCutoffMethod", "highfive")
    @@party_xp_cutoff_percent = cfg.get_f64("PartyXpCutoffPercent", 3)
    @@party_xp_cutoff_level = cfg.get_i32("PartyXpCutoffLevel", 20)
    # @@party_xp_cutoff_gaps = cfg.get_i32_hash("PartyXpCutoffGaps")
    gaps = cfg.get_string("PartyXpCutoffGaps", "0,9;10,14;15,99").split(';')
    @@party_xp_cutoff_gaps = Slice(Slice(Int32)).new(gaps.size) { |i| Slice(Int32).new(2) }
    gaps.each_with_index do |gap, i|
      temp = @@party_xp_cutoff_gaps[i]
      temp[0], temp[1] = gap.split(',').map &.to_i
    end
    @@party_xp_cutoff_gap_percents = cfg.get_i32_array("PartyXpCutoffGapPercent", [100,30,0])

    @@disable_tutorial = cfg.get_bool("DisableTutorial")
    @@expertise_penalty = cfg.get_bool("ExpertisePenalty", true)
    @@store_recipe_shoplist = cfg.get_bool("StoreRecipeShopList")
    @@store_ui_settings = cfg.get_bool("StoreCharUiSettings")
    @@forbidden_names = cfg.get_string_array("ForbiddenNames", %w(annou ammou amnou anmou anou amou announcements announce))
    @@forbidden_names.not_nil!.uniq!
    @@silence_mode_exclude = cfg.get_bool("AltValidateTriggerSkills")
    @@player_movement_block_time = cfg.get_i32("NpcTalkBlockingTime") * 1000

    # Telnet
    # cfg.parse(Dir.current + TELNET_FILE)
    # @@is_telnet_enabled = cfg.get_bool("EnableTelnet")
    # @@telnet_port = cfg.get_i32("StatusPort", 54321)
    # @@telnet_pass = cfg.get_string("StatusPW")
    # if @@is_telnet_enabled && @@telnet_pass.empty?
    #   @@telnet_pass = SecureRandom.hex(5)
    # end
    # @@list_of_hosts = cfg.get_string_array("ListOfHosts", %w(127.0.0.1 localhost))

    # MMO
    cfg.parse(Dir.current + MMO_CONFIG_FILE)
    @@mmo_selector_sleep_time = cfg.get_i32("SleepTime", 20)
    @@mmo_max_send_per_pass = cfg.get_i32("MaxSendPerPass", 12)
    @@mmo_max_read_per_pass = cfg.get_i32("MaxReadPerPass", 12)
    @@mmo_helper_buffer_count = cfg.get_i32("HelperBufferCount", 20)
    @@mmo_tcp_nodelay = cfg.get_bool("TcpNoDelay")

    # ID Factory
    cfg.parse(Dir.current + ID_CONFIG_FILE)
    # const_set :IDFACTORY_TYPE, (cfg.get_enum "IDFactory", IdFactoryType, IdFactoryType::BitSet)
    @@bad_id_checking = cfg.get_bool("BadIdChecking", true)

    # General
    cfg.parse(Dir.current + GENERAL_CONFIG_FILE)
    @@everybody_has_admin_rights = cfg.get_bool("EverybodyHasAdminRights")
    @@server_list_bracket = cfg.get_bool("ServerListBrackets")
    @@server_list_type = get_server_type_id(cfg.get_string("ServerListType", "Normal").split(","))
    @@server_list_age = cfg.get_i32("ServerListAge", 0)
    @@server_gmonly = cfg.get_bool("ServerGMOnly")
    @@gm_hero_aura = cfg.get_bool("GMHeroAura")
    @@gm_startup_invulnerable = cfg.get_bool("GMStartupInvulnerable")
    @@gm_startup_invisible = cfg.get_bool("GMStartupInvisible")
    @@gm_startup_silence = cfg.get_bool("GMStartupSilence")
    @@gm_startup_auto_list = cfg.get_bool("GMStartupAutoList")
    @@gm_startup_diet_mode = cfg.get_bool("GMStartupDietMode")
    @@gm_item_restriction = cfg.get_bool("GMItemRestriction", true)
    @@gm_skill_restriction = cfg.get_bool("GMSkillRestriction", true)
    @@gm_trade_restricted_items = cfg.get_bool("GMTradeRestrictedItems")
    @@gm_restart_fighting = cfg.get_bool("GMRestartFighting", true)
    @@gm_announcer_name = cfg.get_bool("GMShowAnnouncerName")
    @@gm_critannouncer_name = cfg.get_bool("GMShowCritAnnouncerName")
    @@gm_give_special_skills = cfg.get_bool("GMGiveSpecialSkills")
    @@gm_give_special_aura_skills = cfg.get_bool("GMGiveSpecialAuraSkills")
    @@gameguard_enforce = cfg.get_bool("GameGuardEnforce")
    @@gameguard_prohibitaction = cfg.get_bool("GameGuardProhibitAction")
    @@log_chat = cfg.get_bool("LogChat")
    @@log_auto_announcements = cfg.get_bool("LogAutoAnnouncements")
    @@log_items = cfg.get_bool("LogItems")
    @@log_items_small_log = cfg.get_bool("LogItemsSmallLog")
    @@log_item_enchants = cfg.get_bool("LogItemEnchants")
    @@log_skill_enchants = cfg.get_bool("LogSkillEnchants")
    @@gmaudit = cfg.get_bool("GMAudit")
    @@skill_check_enable = cfg.get_bool("SkillCheckEnable")
    @@skill_check_remove = cfg.get_bool("SkillCheckRemove")
    @@skill_check_gm = cfg.get_bool("SkillCheckGM", true)
    @@debug = cfg.get_bool("Debug")
    @@debug_instances = cfg.get_bool("InstanceDebug")
    @@html_action_cache_debug = cfg.get_bool("HtmlActionCacheDebug")
    @@packet_handler_debug = cfg.get_bool("PacketHandlerDebug")
    @@developer = cfg.get_bool("Developer")
    @@no_handlers = cfg.get_bool("nohandlers", false)
    @@no_quests = cfg.get_bool("noquests", false)
    @@alt_dev_no_spawns = cfg.get_bool("AltDevNoSpawns")
    # const_set(:ALT_DEV_NO_SPAWNS, true) if ARGV.include?("nospawns")
    @@alt_dev_show_quests_load_in_logs = cfg.get_bool("AltDevShowQuestsLoadInLogs")
    @@alt_dev_show_scripts_load_in_logs = cfg.get_bool("AltDevShowScriptsLoadInLogs")
    @@thread_p_effects = cfg.get_i32("ThreadPoolSizeEffects", 10)
    @@thread_p_general = cfg.get_i32("ThreadPoolSizeGeneral", 13)
    @@thread_e_events = cfg.get_i32("ThreadPoolSizeEvents", 2)
    @@io_packet_thread_core_size = cfg.get_i32("UrgentPacketThreadCoreSize", 2)
    @@general_packet_thread_core_size = cfg.get_i32("GeneralPacketThreadCoreSize", 4)
    @@general_thread_core_size = cfg.get_i32("GeneralThreadCoreSize", 4)
    @@ai_max_thread = cfg.get_i32("AiMaxThread", 6)
    @@event_max_thread = cfg.get_i32("EventsMaxThread", 5)
    client_packet_queue_size = cfg.get_i32("ClientPacketQueueSize", 0)
    if client_packet_queue_size == 0
      @@client_packet_queue_size = @@mmo_max_read_per_pass + 2
    else
      @@client_packet_queue_size = client_packet_queue_size
    end
    client_packet_queue_max_burst_size = cfg.get_i32("ClientPacketQueueMaxBurstSize")
    if client_packet_queue_max_burst_size == 0
      @@client_packet_queue_max_burst_size = @@mmo_max_read_per_pass + 1
    else
      @@client_packet_queue_max_burst_size = client_packet_queue_max_burst_size
    end
    @@client_packet_queue_max_packets_per_second = cfg.get_i32("ClientPacketQueueMaxPacketsPerSecond", 80)
    @@client_packet_queue_measure_interval = cfg.get_i32("ClientPacketQueueMeasureInterval", 5)
    @@client_packet_queue_max_average_packets_per_second = cfg.get_i32("ClientPacketQueueMaxAveragePacketsPerSecond", 40)
    @@client_packet_queue_max_floods_per_min = cfg.get_i32("ClientPacketQueueMaxFloodsPerMin", 2)
    @@client_packet_queue_max_overflows_per_min = cfg.get_i32("ClientPacketQueueMaxOverflowsPerMin", 1)
    @@client_packet_queue_max_underflows_per_min = cfg.get_i32("ClientPacketQueueMaxUnderflowsPerMin", 1)
    @@client_packet_queue_max_unknown_per_min = cfg.get_i32("ClientPacketQueueMaxUnknownPerMin", 5)
    @@deadlock_detector = cfg.get_bool("DeadLockDetector", true)
    @@deadlock_check_interval = cfg.get_i32("DeadLockCheckInterval", 20)
    @@restart_on_deadlock = cfg.get_bool("RestartOnDeadlock")
    @@allow_discarditem = cfg.get_bool("AllowDiscardItem", true)
    @@autodestroy_item_after = cfg.get_i32("AutoDestroyDroppedItemAfter", 600)
    @@herb_auto_destroy_time = cfg.get_i32("AutoDestroyHerbTime", 60) * 1000
    @@list_protected_items = cfg.get_i32_array("ListOfProtectedItems", [0])
    @@database_clean_up = cfg.get_bool("DatabaseCleanUp", true)
    @@connection_close_time = cfg.get_i64("ConnectionCloseTime", 60000)
    @@char_store_interval = cfg.get_i64("CharacterDataStoreInterval", 15)
    @@lazy_items_update = cfg.get_bool("LazyItemsUpdate")
    @@update_items_on_char_store = cfg.get_bool("UpdateItemsOnCharStore")
    @@destroy_dropped_player_item = cfg.get_bool("DestroyPlayerDroppedItem")
    @@destroy_equipable_player_item = cfg.get_bool("DestroyEquipableItem")
    @@save_dropped_item = cfg.get_bool("SaveDroppedItem")
    @@empty_dropped_item_table_after_load = cfg.get_bool("EmptyDroppedItemTableAfterLoad")
    @@save_dropped_item_interval = cfg.get_i32("SaveDroppedItemInterval", 60) * 60000
    @@clear_dropped_item_table = cfg.get_bool("ClearDroppedItemTable")
    @@autodelete_invalid_quest_data = cfg.get_bool("AutoDeleteInvalidQuestData")
    @@precise_drop_calculation = cfg.get_bool("PreciseDropCalculation", true)
    @@multiple_item_drop = cfg.get_bool("MultipleItemDrop", true)
    @@force_inventory_update = cfg.get_bool("ForceInventoryUpdate")
    @@lazy_cache = cfg.get_bool("LazyCache", true)
    @@cache_char_names = cfg.get_bool("CacheCharNames", true)
    @@min_npc_animation = cfg.get_i32("MinNPCAnimation", 10)
    @@max_npc_animation = cfg.get_i32("MaxNPCAnimation", 20)
    @@min_monster_animation = cfg.get_i32("MinMonsterAnimation", 5)
    @@max_monster_animation = cfg.get_i32("MaxMonsterAnimation", 20)
    @@move_based_knownlist = cfg.get_bool("MoveBasedKnownlist")
    @@knownlist_update_interval = cfg.get_i64("KnownListUpdateInterval", 1250)
    @@grids_always_on = cfg.get_bool("GridsAlwaysOn")
    @@grid_neighbor_turnon_time = cfg.get_i32("GridNeighborTurnOnTime", 1)
    @@grid_neighbor_turnoff_time = cfg.get_i32("GridNeighborTurnOffTime", 90)
    @@peace_zone_mode = cfg.get_i32("PeaceZoneMode", 0)
    @@default_global_chat = cfg.get_string("GlobalChat", "ON")
    @@default_trade_chat = cfg.get_string("TradeChat", "ON")
    @@allow_warehouse = cfg.get_bool("AllowWarehouse", true)
    @@warehouse_cache = cfg.get_bool("WarehouseCache")
    @@warehouse_cache_time = cfg.get_i32("WarehouseCacheTime", 15)
    @@allow_refund = cfg.get_bool("AllowRefund", true)
    @@allow_mail = cfg.get_bool("AllowMail", true)
    @@allow_attachments = cfg.get_bool("AllowAttachments", true)
    @@allow_wear = cfg.get_bool("AllowWear", true)
    @@wear_delay = cfg.get_i32("WearDelay", 5)
    @@wear_price = cfg.get_i32("WearPrice", 10)
    @@instance_finish_time = 1000 * cfg.get_i32("DefaultFinishTime", 300)
    @@restore_player_instance = cfg.get_bool("RestorePlayerInstance")
    @@allow_summon_in_instance = cfg.get_bool("AllowSummonInInstance")
    @@eject_dead_player_time = 1000 * cfg.get_i32("EjectDeadPlayerTime", 60)
    @@allow_lottery = cfg.get_bool("AllowLottery", true)
    @@allow_race = cfg.get_bool("AllowRace", true)
    @@allow_water = cfg.get_bool("AllowWater", true)
    @@allow_rentpet = cfg.get_bool("AllowRentPet")
    @@allowfishing = cfg.get_bool("AllowFishing", true)
    @@allow_manor = cfg.get_bool("AllowManor", true)
    @@allow_boat = cfg.get_bool("AllowBoat", true)
    @@boat_broadcast_radius = cfg.get_i32("BoatBroadcastRadius", 20000)
    @@allow_cursed_weapons = cfg.get_bool("AllowCursedWeapons", true)
    @@allow_pet_walkers = cfg.get_bool("AllowPetWalkers", true)
    @@server_news = cfg.get_bool("ShowServerNews")
    @@enable_community_board = cfg.get_bool("EnableCommunityBoard", true)
    @@bbs_default = cfg.get_string("BBSDefault", "_bbshome")
    @@use_say_filter = cfg.get_bool("UseChatFilter")
    @@chat_filter_chars = cfg.get_string("ChatFilterChars", "^_^")
    @@ban_chat_channels = cfg.get_i32_array("BanChatChannels", [0,1,8,17])
    @@alt_manor_refresh_time = cfg.get_i32("AltManorRefreshTime", 20)
    @@alt_manor_refresh_min = cfg.get_i32("AltManorRefreshMin", 0)
    @@alt_manor_approve_time = cfg.get_i32("AltManorApproveTime", 4)
    @@alt_manor_approve_min = cfg.get_i32("AltManorApproveMin", 30)
    @@alt_manor_maintenance_min = cfg.get_i32("AltManorMaintenanceMin", 6)
    @@alt_manor_save_all_actions = cfg.get_bool("AltManorSaveAllActions")
    @@alt_manor_save_period_rate = cfg.get_i32("AltManorSavePeriodRate", 2)
    @@alt_lottery_prize = cfg.get_i64("AltLotteryPrize", 50000)
    @@alt_lottery_ticket_price = cfg.get_i64("AltLotteryTicketPrice", 2000)
    @@alt_lottery_5_number_rate = cfg.get_f32("AltLottery5NumberRate", 0.6)
    @@alt_lottery_4_number_rate = cfg.get_f32("AltLottery4NumberRate", 0.2)
    @@alt_lottery_3_number_rate = cfg.get_f32("AltLottery3NumberRate", 0.2)
    @@alt_lottery_2_and_1_number_prize = cfg.get_i64("AltLottery2and1NumberPrize", 200)
    @@alt_item_auction_enabled = cfg.get_bool("AltItemAuctionEnabled", true)
    @@alt_item_auction_expired_after = cfg.get_i32("AltItemAuctionExpiredAfter", 14)
    @@alt_item_auction_time_extends_on_bid = cfg.get_i64("AltItemAuctionTimeExtendsOnBid", 0) * 1000
    @@fs_time_attack = cfg.get_i32("TimeOfAttack", 50)
    @@fs_time_cooldown = cfg.get_i32("TimeOfCoolDown", 5)
    @@fs_time_entry = cfg.get_i32("TimeOfEntry", 3)
    @@fs_time_warmup = cfg.get_i32("TimeOfWarmUp", 2)
    @@fs_party_member_count = cfg.get_i32("NumberOfNecessaryPartyMembers", 4)
    @@fs_time_attack = 50 if @@fs_time_attack <= 0
    @@fs_time_cooldown = 5 if @@fs_time_cooldown <= 0
    @@fs_time_entry = 3 if @@fs_time_entry <= 0
    @@fs_time_entry = 3 if @@fs_time_entry <= 0
    @@fs_time_entry = 3 if @@fs_time_entry <= 0
    @@rift_min_party_size = cfg.get_i32("RiftMinPartySize", 5)
    @@rift_max_jumps = cfg.get_i32("MaxRiftJumps", 4)
    @@rift_spawn_delay = cfg.get_i32("RiftSpawnDelay", 10000)
    @@rift_auto_jumps_time_min = cfg.get_i32("AutoJumpsDelayMin", 480)
    @@rift_auto_jumps_time_max = cfg.get_i32("AutoJumpsDelayMax", 600)
    @@rift_boss_room_time_multiply = cfg.get_f32("BossRoomTimeMultiply", 1.5)
    @@rift_enter_cost_recruit = cfg.get_i32("RecruitCost", 18)
    @@rift_enter_cost_soldier = cfg.get_i32("SoldierCost", 21)
    @@rift_enter_cost_officer = cfg.get_i32("OfficerCost", 24)
    @@rift_enter_cost_captain = cfg.get_i32("CaptainCost", 27)
    @@rift_enter_cost_commander = cfg.get_i32("CommanderCost", 30)
    @@rift_enter_cost_hero = cfg.get_i32("HeroCost", 33)
    @@default_punish = IllegalActionPunishmentType.parse(cfg.get_string("DefautPunish", "KICK"))
    @@default_punish_param = cfg.get_i32("DefaultPunishParam", 0)
    @@only_gm_items_free = cfg.get_bool("OnlyGMItemsFree", true)
    @@jail_is_pvp = cfg.get_bool("JailIsPvp")
    @@jail_disable_chat = cfg.get_bool("JailDisableChat", true)
    @@jail_disable_transaction = cfg.get_bool("JailDisableTransaction")
    @@custom_spawnlist_table = cfg.get_bool("CustomSpawnlistTable")
    @@save_gmspawn_on_custom = cfg.get_bool("SaveGmSpawnOnCustom")
    @@custom_npc_data = cfg.get_bool("CustomNpcData")
    @@custom_teleport_table = cfg.get_bool("CustomTeleportTable")
    @@custom_npcbuffer_tables = cfg.get_bool("CustomNpcBufferTables")
    @@custom_skills_load = cfg.get_bool("CustomSkillsLoad")
    @@custom_items_load = cfg.get_bool("CustomItemsLoad")
    @@custom_multisell_load = cfg.get_bool("CustomMultisellLoad")
    @@custom_buylist_load = cfg.get_bool("CustomBuyListLoad")
    @@alt_birthday_gift = cfg.get_i32("AltBirthdayGift", 22187)
    @@alt_birthday_mail_subject = cfg.get_string("AltBirthdayMailSubject", "Happy Birthday!")
    @@alt_birthday_mail_text = cfg.get_string("AltBirthdayMailText", "Hello Adventurer!! Seeing as you\"re one year older now, I thought I would send you some birthday cheer :) Please find your birthday pack attached. May these gifts bring you joy and happiness on this very special day.\n\nSincerely, Alegria")
    @@enable_block_checker_event = cfg.get_bool("EnableBlockCheckerEvent")
    min_block_checker_team_members = cfg.get_i32("BlockCheckerMinTeamMembers", 2)
    if min_block_checker_team_members < 1
      @@min_block_checker_team_members = 1
    elsif min_block_checker_team_members > 6
      @@min_block_checker_team_members = 6
    else
      @@min_block_checker_team_members = min_block_checker_team_members
    end
    @@hbce_fair_play = cfg.get_bool("HBCEFairPlay")
    @@hellbound_without_quest = cfg.get_bool("HellboundWithoutQuest")
    @@normal_enchant_cost_multiplier = cfg.get_i32("NormalEnchantCostMultipiler", 1)
    @@safe_enchant_cost_multiplier = cfg.get_i32("SafeEnchantCostMultipiler", 5)
    @@botreport_enable = cfg.get_bool("EnableBotReportButton")
    @@botreport_resetpoint_hour = cfg.get_string("BotReportPointsResetHour", "00:00").split(":").to_slice
    @@botreport_report_delay = cfg.get_i64("BotReportDelay", 30) * 60000
    @@botreport_allow_reports_from_same_clan_members = cfg.get_bool("AllowReportsFromSameClanMembers")
    @@enable_falling_damage = cfg.get_bool("EnableFallingDamage", true)

    # Flood Protector
    @@flood_protector_use_item = FloodProtectorConfig.new("UseItemFloodProtector")
    @@flood_protector_roll_dice = FloodProtectorConfig.new("RollDiceFloodProtector")
    @@flood_protector_firework = FloodProtectorConfig.new("FireworkFloodProtector")
    @@flood_protector_item_pet_summon = FloodProtectorConfig.new("ItemPetSummonFloodProtector")
    @@flood_protector_hero_voice = FloodProtectorConfig.new("HeroVoiceFloodProtector")
    @@flood_protector_global_chat = FloodProtectorConfig.new("GlobalChatFloodProtector")
    @@flood_protector_subclass = FloodProtectorConfig.new("SubclassFloodProtector")
    @@flood_protector_drop_item = FloodProtectorConfig.new("DropItemFloodProtector")
    @@flood_protector_server_bypass = FloodProtectorConfig.new("ServerBypassFloodProtector")
    @@flood_protector_multisell = FloodProtectorConfig.new("MultiSellFloodProtector")
    @@flood_protector_transaction = FloodProtectorConfig.new("TransactionFloodProtector")
    @@flood_protector_manufacture = FloodProtectorConfig.new("ManufactureFloodProtector")
    @@flood_protector_manor = FloodProtectorConfig.new("ManorFloodProtector")
    @@flood_protector_sendmail = FloodProtectorConfig.new("SendMailFloodProtector")
    @@flood_protector_character_select = FloodProtectorConfig.new("CharacterSelectFloodProtector")
    @@flood_protector_item_auction = FloodProtectorConfig.new("ItemAuctionFloodProtector")

    cfg.parse(Dir.current + FLOOD_PROTECTOR_FILE)
    load_protector_settings(cfg)

    # NPC
    cfg.parse(Dir.current + NPC_CONFIG_FILE)
    @@announce_mammon_spawn = cfg.get_bool("AnnounceMammonSpawn")
    @@alt_mob_agro_in_peacezone = cfg.get_bool("AltMobAgroInPeaceZone", true)
    @@alt_attackable_npcs = cfg.get_bool("AltAttackableNpcs", true)
    @@alt_game_viewnpc = cfg.get_bool("AltGameViewNpc")
    @@max_drift_range = cfg.get_i32("MaxDriftRange", 300)
    @@deepblue_drop_rules = cfg.get_bool("UseDeepBlueDropRules", true)
    @@deepblue_drop_rules_raid = cfg.get_bool("UseDeepBlueDropRulesRaid", true)
    @@show_npc_lvl = cfg.get_bool("ShowNpcLevel")
    @@show_crest_without_quest = cfg.get_bool("ShowCrestWithoutQuest")
    @@enable_random_enchant_effect = cfg.get_bool("EnableRandomEnchantEffect")
    @@min_npc_lvl_dmg_penalty = cfg.get_i32("MinNPCLevelForDmgPenalty", 78)
    @@npc_dmg_penalty = cfg.get_i32_float_hash("DmgPenaltyForLvLDifferences", [0.7, 0.6, 0.6, 0.55])
    @@npc_crit_dmg_penalty = cfg.get_i32_float_hash("CritDmgPenaltyForLvLDifferences", [0.75, 0.65, 0.6, 0.58])
    @@npc_skill_dmg_penalty = cfg.get_i32_float_hash("SkillDmgPenaltyForLvLDifferences", [0.8, 0.7, 0.65, 0.62])
    @@min_npc_lvl_magic_penalty = cfg.get_i32("MinNPCLevelForMagicPenalty", 78)
    @@npc_skill_chance_penalty = cfg.get_i32_float_hash("SkillChancePenaltyForLvLDifferences", [2.5, 3.0, 3.25, 3.5])
    @@decay_time_task = cfg.get_i32("DecayTimeTask", 5000)
    @@default_corpse_time = cfg.get_i32("DefaultCorpseTime", 7)
    @@spoiled_corpse_extend_time = cfg.get_i32("SpoiledCorpseExtendTime", 10)
    @@corpse_consume_skill_allowed_time_before_decay = cfg.get_i32("CorpseConsumeSkillAllowedTimeBeforeDecay", 2000)
    @@guard_attack_aggro_mob = cfg.get_bool("GuardAttackAggroMob")
    @@allow_wyvern_upgrader = cfg.get_bool("AllowWyvernUpgrader")
    @@list_pet_rent_npc = cfg.get_i32_array("ListPetRentNpc", [30827])
    @@raid_hp_regen_multiplier = cfg.get_f64("RaidHpRegenMultiplier", 100) / 100
    @@raid_mp_regen_multiplier = cfg.get_f64("RaidMpRegenMultiplier", 100) / 100
    @@raid_pdefence_multiplier = cfg.get_f64("RaidPDefenceMultiplier", 100) / 100
    @@raid_mdefence_multiplier = cfg.get_f64("RaidMDefenceMultiplier", 100) / 100
    @@raid_pattack_multiplier = cfg.get_f64("RaidPAttackMultiplier", 100) / 100
    @@raid_mattack_multiplier = cfg.get_f64("RaidMAttackMultiplier", 100) / 100
    @@raid_min_respawn_multiplier = cfg.get_f32("RaidMinRespawnMultiplier", 1.0)
    @@raid_max_respawn_multiplier = cfg.get_f32("RaidMaxRespawnMultiplier", 1.0)
    @@raid_minion_respawn_timer = cfg.get_f64("RaidMinionRespawnTime", 300000)
    @@minions_respawn_time = cfg.get_i32_hash("CustomMinionsRespawnTime")
    @@raid_disable_curse = cfg.get_bool("DisableRaidCurse")
    @@raid_chaos_time = cfg.get_i32("RaidChaosTime", 10)
    @@grand_chaos_time = cfg.get_i32("GrandChaosTime", 10)
    @@minion_chaos_time = cfg.get_i32("MinionChaosTime", 10)
    @@inventory_maximum_pet = cfg.get_i32("MaximumSlotsForPet", 12)
    @@pet_hp_regen_multiplier = cfg.get_f64("PetHpRegenMultiplier", 100) / 100
    @@pet_mp_regen_multiplier = cfg.get_f64("PetMpRegenMultiplier", 100) / 100

    @@drop_adena_min_level_difference = cfg.get_i32("DropAdenaMinLevelDifference", 8)
    @@drop_adena_max_level_difference = cfg.get_i32("DropAdenaMaxLevelDifference", 15)
    @@drop_adena_min_level_gap_chance = cfg.get_f64("DropAdenaMinLevelGapChance", 10)

    @@drop_item_min_level_difference = cfg.get_i32("DropItemMinLevelDifference", 5)
    @@drop_item_max_level_difference = cfg.get_i32("DropItemMaxLevelDifference", 10)
    @@drop_item_min_level_gap_chance = cfg.get_f64("DropItemMinLevelGapChance", 10)

    # Rates
    cfg.parse(Dir.current + RATES_CONFIG_FILE)
    @@rate_xp = cfg.get_f32("RateXp", 1)
    @@rate_sp = cfg.get_f32("RateSp", 1)
    @@rate_party_xp = cfg.get_f32("RatePartyXp", 1)
    @@rate_party_sp = cfg.get_f32("RatePartySp", 1)
    @@rate_extractable = cfg.get_f32("RateExtractable", 1)
    @@rate_drop_manor = cfg.get_i32("RateDropManor", 1)
    @@rate_quest_drop = cfg.get_f32("RateQuestDrop", 1)
    @@rate_quest_reward = cfg.get_f32("RateQuestReward", 1)
    @@rate_quest_reward_xp = cfg.get_f32("RateQuestRewardXP", 1)
    @@rate_quest_reward_sp = cfg.get_f32("RateQuestRewardSP", 1)
    @@rate_quest_reward_adena = cfg.get_f32("RateQuestRewardAdena", 1)
    @@rate_quest_reward_use_multipliers = cfg.get_bool("UseQuestRewardMultipliers")
    @@rate_quest_reward_potion = cfg.get_f32("RateQuestRewardPotion", 1)
    @@rate_quest_reward_scroll = cfg.get_f32("RateQuestRewardScroll", 1)
    @@rate_quest_reward_recipe = cfg.get_f32("RateQuestRewardRecipe", 1)
    @@rate_quest_reward_material = cfg.get_f32("RateQuestRewardMaterial", 1)
    @@rate_hb_trust_increase = cfg.get_f32("RateHellboundTrustIncrease", 1)
    @@rate_hb_trust_decrease = cfg.get_f32("RateHellboundTrustDecrease", 1)
    @@rate_vitality_level_1 = cfg.get_f32("RateVitalityLevel1", 1.5)
    @@rate_vitality_level_2 = cfg.get_f32("RateVitalityLevel2", 2)
    @@rate_vitality_level_3 = cfg.get_f32("RateVitalityLevel3", 2.5)
    @@rate_vitality_level_4 = cfg.get_f32("RateVitalityLevel4", 3)
    @@rate_recovery_vitality_peace_zone = cfg.get_f32("RateRecoveryPeaceZone", 1)
    @@rate_vitality_lost = cfg.get_f32("RateVitalityLost", 1)
    @@rate_vitality_gain = cfg.get_f32("RateVitalityGain", 1)
    @@rate_recovery_on_reconnect = cfg.get_f32("RateRecoveryOnReconnect", 4)
    @@rate_karma_lost = cfg.get_f32("RateKarmaLost", @@rate_xp)
    @@rate_karma_exp_lost = cfg.get_f32("RateKarmaExpLost", 1)
    @@rate_siege_guards_price = cfg.get_f32("RateSiegeGuardsPrice", 1)
    @@player_drop_limit = cfg.get_i32("PlayerDropLimit", 3)
    @@player_rate_drop = cfg.get_i32("PlayerRateDrop", 5)
    @@player_rate_drop_item = cfg.get_i32("PlayerRateDropItem", 70)
    @@player_rate_drop_equip = cfg.get_i32("PlayerRateDropEquip", 25)
    @@player_rate_drop_equip_weapon = cfg.get_i32("PlayerRateDropEquipWeapon", 5)
    @@pet_xp_rate = cfg.get_f32("PetXpRate", 1)
    @@pet_food_rate = cfg.get_i32("PetFoodRate", 1)
    @@sineater_xp_rate = cfg.get_f32("SinEaterXpRate", 1)
    @@karma_drop_limit = cfg.get_i32("KarmaDropLimit", 10)
    @@karma_rate_drop = cfg.get_i32("KarmaRateDrop", 70)
    @@karma_rate_drop_item = cfg.get_i32("KarmaRateDropItem", 50)
    @@karma_rate_drop_equip = cfg.get_i32("KarmaRateDropEquip", 40)
    @@karma_rate_drop_equip_weapon = cfg.get_i32("KarmaRateDropEquipWeapon", 10)
    @@rate_death_drop_amount_multiplier = cfg.get_f32("DeathDropAmountMultiplier", 1)
    @@rate_corpse_drop_amount_multiplier = cfg.get_f32("CorpseDropAmountMultiplier", 1)
    @@rate_herb_drop_amount_multiplier = cfg.get_f32("HerbDropAmountMultiplier", 1)
    @@rate_raid_drop_amount_multiplier = cfg.get_f32("RaidDropAmountMultiplier", 1)
    @@rate_death_drop_chance_multiplier = cfg.get_f32("DeathDropChanceMultiplier", 1)
    @@rate_corpse_drop_chance_multiplier = cfg.get_f32("CorpseDropChanceMultiplier", 1)
    @@rate_herb_drop_chance_multiplier = cfg.get_f32("HerbDropChanceMultiplier", 1)
    @@rate_raid_drop_chance_multiplier = cfg.get_f32("RaidDropChanceMultiplier", 1)
    @@rate_drop_amount_multiplier = cfg.get_i32_float_assoc("DropAmountMultiplierByItemId")
    @@rate_drop_chance_multiplier = cfg.get_i32_float_assoc("DropChanceMultiplierByItemId")

    # Mods
    cfg.parse(Dir.current + L2JMOD_CONFIG_FILE)
    @@champion_enable = cfg.get_bool("ChampionEnable")
    @@champion_passive = cfg.get_bool("ChampionPassive")
    @@champion_frequency = cfg.get_i32("ChampionFrequency", -1)
    @@champ_title = cfg.get_string("ChampionTitle", "Champion")
    @@champ_min_lvl = cfg.get_i32("ChampionMinLevel", 20)
    @@champ_max_lvl = cfg.get_i32("ChampionMaxLevel", 60)
    @@champion_hp = cfg.get_i32("ChampionHp", 7)
    @@champion_hp_regen = cfg.get_f32("ChampionHpRegen", 1)
    @@champion_rewards_exp_sp = cfg.get_f32("ChampionRewardsExpSp", 8)
    @@champion_rewards_chance = cfg.get_f32("ChampionRewardsChance", 8)
    @@champion_rewards_amount = cfg.get_f32("ChampionRewardsAmount", 1)
    @@champion_adenas_rewards_chance = cfg.get_f32("ChampionAdenasRewardsChance", 1)
    @@champion_adenas_rewards_amount = cfg.get_f32("ChampionAdenasRewardsAmount", 1)
    @@champion_atk = cfg.get_f32("ChampionAtk", 1)
    @@champion_spd_atk = cfg.get_f32("ChampionSpdAtk", 1)
    @@champion_reward_lower_lvl_item_chance = cfg.get_i32("ChampionRewardLowerLvlItemChance", 0)
    @@champion_reward_higher_lvl_item_chance = cfg.get_i32("ChampionRewardHigherLvlItemChance", 0)
    @@champion_reward_id = cfg.get_i32("ChampionRewardItemID", 6393)
    @@champion_reward_qty = cfg.get_i32("ChampionRewardItemQty", 1)
    @@champion_enable_vitality = cfg.get_bool("ChampionEnableVitality")
    @@champion_enable_in_instances = cfg.get_bool("ChampionEnableInInstances")

    @@tvt_event_enabled = cfg.get_bool("TvTEventEnabled")
    @@tvt_event_in_instance = cfg.get_bool("TvTEventInInstance")
    @@tvt_event_instance_file = cfg.get_string("TvTEventInstanceFile", "coliseum.xml")
    @@tvt_event_interval = cfg.get_string("TvTEventInterval", "20:00").split(",").to_slice
    @@tvt_event_participation_time = cfg.get_i32("TvTEventParticipationTime", 3600)
    @@tvt_event_running_time = cfg.get_i32("TvTEventRunningTime", 1800)
    @@tvt_event_participation_npc_id = cfg.get_i32("TvTEventParticipationNpcId", 0)

    @@allow_wedding = cfg.get_bool("AllowWedding")
    @@wedding_price = cfg.get_i32("WeddingPrice", 250000000)
    @@wedding_punish_infidelity = cfg.get_bool("WeddingPunishInfidelity", true)
    @@wedding_teleport = cfg.get_bool("WeddingTeleport", true)
    @@wedding_teleport_price = cfg.get_i32("WeddingTeleportPrice", 50000)
    @@wedding_teleport_duration = cfg.get_i32("WeddingTeleportDuration", 60)
    @@wedding_samesex = cfg.get_bool("WeddingAllowSameSex")
    @@wedding_formalwear = cfg.get_bool("WeddingFormalWear", true)
    @@wedding_divorce_costs = cfg.get_i32("WeddingDivorceCosts", 20)

    @@enable_warehousesorting_clan = cfg.get_bool("EnableWarehouseSortingClan")
    @@enable_warehousesorting_private = cfg.get_bool("EnableWarehouseSortingPrivate")
    # TODO: more TVT config
    @@banking_system_enabled = cfg.get_bool("BankingEnabled")
    @@banking_system_goldbars = cfg.get_i32("BankingGoldbarCount", 1)
    @@banking_system_adena = cfg.get_i32("BankingAdenaCount", 500000000)

    @@offline_trade_enable = cfg.get_bool("OfflineTradeEnable")
    @@offline_craft_enable = cfg.get_bool("OfflineCraftEnable")
    @@offline_mode_in_peace_zone = cfg.get_bool("OfflineModeInPeaceZone")
    @@offline_mode_no_damage = cfg.get_bool("OfflineModeNoDamage")
    @@offline_set_name_color = cfg.get_bool("OfflineSetNameColor")
    @@offline_name_color = ("0x" + cfg.get_string("OfflineNameColor", "808080")).to_i(16, prefix: true)
    @@offline_fame = cfg.get_bool("OfflineFame", true)
    @@restore_offliners = cfg.get_bool("RestoreOffliners")
    @@offline_max_days = cfg.get_i32("OfflineMaxDays", 10)
    @@offline_disconnect_finished = cfg.get_bool("OfflineDisconnectFinished", true)

    @@enable_mana_potions_support = cfg.get_bool("EnableManaPotionSupport")

    @@display_server_time = cfg.get_bool("DisplayServerTime")

    @@welcome_message_enabled = cfg.get_bool("ScreenWelcomeMessageEnable")
    @@welcome_message_text = cfg.get_string("ScreenWelcomeMessageText", "Welcome to L2J server!")
    @@welcome_message_time = cfg.get_i32("ScreenWelcomeMessageTime", 10) * 1000

    @@antifeed_enable = cfg.get_bool("AntiFeedEnable")
    @@antifeed_dualbox = cfg.get_bool("AntiFeedDualbox", true)
    @@antifeed_disconnected_as_dualbox = cfg.get_bool("AntiFeedDisconnectedAsDualbox", true)
    @@antifeed_interval = cfg.get_i32("AntiFeedInterval", 120) * 1000
    @@announce_pk_pvp = cfg.get_bool("AnnouncePkPvP")
    @@announce_pk_pvp_normal_message = cfg.get_bool("AnnouncePkPvPNormalMessage", true)
    @@announce_pk_msg = cfg.get_string("AnnouncePkMsg", "$killer has slaughtered $target")
    @@announce_pvp_msg = cfg.get_string("AnnouncePvpMsg", "$killer has defeated $target")

    @@chat_admin = cfg.get_bool("ChatAdmin")

    @@multilang_default = cfg.get_string("MultiLangDefault", "en")
    @@multilang_enable = cfg.get_bool("MultiLangEnable")
    # TODO: more multilang config

    # PVP
    cfg.parse(Dir.current + PVP_CONFIG_FILE)
    @@karma_drop_gm = cfg.get_bool("CanGMDropEquipment")
    @@karma_award_pk_kill = cfg.get_bool("AwardPKKillPVPPoint")
    @@karma_pk_limit = cfg.get_i32("MinimumPKRequiredToDrop", 5)
    @@karma_list_nondroppable_pet_items = cfg.get_i32_array("ListOfPetItems", [2375,3500,3501,3502,4422,4423,4424,4425,6648,6649,6650,9882])
    @@karma_list_nondroppable_items = cfg.get_i32_array("ListOfNonDroppableItems", [57,1147,425,1146,461,10,2368,7,6,2370,2369,6842,6611,6612,6613,6614,6615,6616,6617,6618,6619,6620,6621,7694,8181,5575,7694,9388,9389,9390])
    @@karma_list_nondroppable_items.sort!
    @@karma_list_nondroppable_pet_items.sort!
    @@pvp_normal_time = cfg.get_i32("PvPVsNormalTime", 120000)
    @@pvp_pvp_time = cfg.get_i32("PvPVsPvPTime", 60000)

    # Olympiad
    cfg.parse(Dir.current + OLYMPIAD_CONFIG_FILE)
    @@alt_oly_start_time = cfg.get_i32("AltOlyStartTime", 18)
    @@alt_oly_min = cfg.get_i32("AltOlyMin", 0)
    @@alt_oly_max_buffs = cfg.get_i32("AltOlyMaxBuffs", 5)
    @@alt_oly_cperiod = cfg.get_i64("AltOlyCPeriod", 21600000)
    @@alt_oly_battle = cfg.get_i64("AltOlyBattle", 300000)
    @@alt_oly_wperiod = cfg.get_i64("AltOlyWPeriod", 604800000)
    @@alt_oly_vperiod = cfg.get_i64("AltOlyVPeriod", 86400000)
    @@alt_oly_start_points = cfg.get_i32("AltOlyStartPoints", 10)
    @@alt_oly_weekly_points = cfg.get_i32("AltOlyWeeklyPoints", 10)
    @@alt_oly_classed = cfg.get_i32("AltOlyClassedParticipants", 11)
    @@alt_oly_nonclassed = cfg.get_i32("AltOlyNonClassedParticipants", 11)
    @@alt_oly_teams = cfg.get_i32("AltOlyTeamsParticipants", 6)
    @@alt_oly_reg_display = cfg.get_i32("AltOlyRegistrationDisplayNumber", 100)
    @@alt_oly_classed_reward = cfg.get_i32_assoc("AltOlyClassedReward", "13722,50")
    @@alt_oly_nonclassed_reward = cfg.get_i32_assoc("AltOlyNonClassedReward", "13722,40")
    @@alt_oly_team_reward = cfg.get_i32_assoc("AltOlyTeamReward", "13722,85")
    @@alt_oly_comp_ritem = cfg.get_i32("AltOlyCompRewItem", 13722)
    @@alt_oly_min_matches = cfg.get_i32("AltOlyMinMatchesForPoints", 15)
    @@alt_oly_gp_per_point = cfg.get_i32("AltOlyGPPerPoint", 1000)
    @@alt_oly_hero_points = cfg.get_i32("AltOlyHeroPoints", 200)
    @@alt_oly_rank1_points = cfg.get_i32("AltOlyRank1Points", 100)
    @@alt_oly_rank2_points = cfg.get_i32("AltOlyRank2Points", 75)
    @@alt_oly_rank3_points = cfg.get_i32("AltOlyRank3Points", 55)
    @@alt_oly_rank4_points = cfg.get_i32("AltOlyRank4Points", 40)
    @@alt_oly_rank5_points = cfg.get_i32("AltOlyRank5Points", 30)
    @@alt_oly_max_points = cfg.get_i32("AltOlyMaxPoints", 10)
    @@alt_oly_divider_classed = cfg.get_i32("AltOlyDividerClassed", 5)
    @@alt_oly_divider_non_classed = cfg.get_i32("AltOlyDividerNonClassed", 5)
    @@alt_oly_max_weekly_matches = cfg.get_i32("AltOlyMaxWeeklyMatches", 70)
    @@alt_oly_max_weekly_matches_non_classed = cfg.get_i32("AltOlyMaxWeeklyMatchesNonClassed", 60)
    @@alt_oly_max_weekly_matches_classed = cfg.get_i32("AltOlyMaxWeeklyMatchesClassed", 30)
    @@alt_oly_max_weekly_matches_team = cfg.get_i32("AltOlyMaxWeeklyMatchesTeam", 10)
    @@alt_oly_log_fights = cfg.get_bool("AltOlyLogFights")
    @@alt_oly_show_monthly_winners = cfg.get_bool("AltOlyShowMonthlyWinners", true)
    @@alt_oly_announce_games = cfg.get_bool("AltOlyAnnounceGames", true)
    @@list_oly_restricted_items = cfg.get_i32_array("AltOlyRestrictedItems")
    @@alt_oly_enchant_limit = cfg.get_i32("AltOlyEnchantLimit", -1)
    @@alt_oly_wait_time = cfg.get_i32("AltOlyWaitTime", 120)

    hexid_path = Dir.current + HEXID_FILE
    if File.exists?(hexid_path)
      cfg.parse(hexid_path)

      @@server_id = cfg.get_i32("ServerId", 1)
      if raw = cfg.get_string("HexID", nil)
        begin
          @@hex_id = BigInt.new(raw, 16).bytes
        rescue e
          error e
        end
      end
    end

    # Grand bosses
    cfg.parse(Dir.current + GRANDBOSS_CONFIG_FILE)
    @@antharas_wait_time = cfg.get_i32("AntharasWaitTime", 30)
    @@antharas_spawn_interval = cfg.get_i32("IntervalOfAntharasSpawn", 264)
    @@antharas_spawn_random = cfg.get_i32("RandomOfAntharasSpawn", 72)

    @@valakas_wait_time = cfg.get_i32("ValakasWaitTime", 30)
    @@valakas_spawn_interval = cfg.get_i32("IntervalOfValakasSpawn", 264)
    @@valakas_spawn_random = cfg.get_i32("RandomOfValakasSpawn", 72)

    @@baium_spawn_interval = cfg.get_i32("IntervalOfBaiumSpawn", 168)
    @@baium_spawn_random = cfg.get_i32("RandomOfBaiumSpawn", 48)

    @@core_spawn_interval = cfg.get_i32("IntervalOfCoreSpawn", 60)
    @@core_spawn_random = cfg.get_i32("RandomOfCoreSpawn", 24)

    @@orfen_spawn_interval = cfg.get_i32("IntervalOfOrfenSpawn", 48)
    @@orfen_spawn_random = cfg.get_i32("RandomOfOrfenSpawn", 20)

    @@queen_ant_spawn_interval = cfg.get_i32("IntervalOfQueenAntSpawn", 36)
    @@queen_ant_spawn_random = cfg.get_i32("RandomOfQueenAntSpawn", 17)

    @@beleth_spawn_interval = cfg.get_i32("IntervalOfBelethSpawn", 192)
    @@beleth_spawn_random = cfg.get_i32("RandomOfBelethSpawn", 148)
    @@beleth_min_players = cfg.get_i32("BelethMinPlayers", 36)

    # Gracia seeds
    cfg.parse(Dir.current + GRACIASEEDS_CONFIG_FILE)
    @@sod_tiat_kill_count = cfg.get_i32("TiatKillCountForNextState", 10)
    @@sod_stage_2_length = cfg.get_i64("Stage2Length", 720) * 60000

    filter_list = [] of String
    filter_path = Dir.current + "/config/chatfilter.txt"
    if File.exists?(filter_path)
      File.open(filter_path, "r") do |file|
        file.each_line do |line|
          line = line.strip
          next if line.starts_with?("#")
          line = line.chomp
          filter_list << line unless line.empty?
        end
      end
    end
    @@filter_list = filter_list unless filter_list.empty?

    # Clan Hall siege
    cfg.parse(Dir.current + CH_SIEGE_FILE)
    @@chs_max_attackers = cfg.get_i32("MaxAttackers", 500)
    @@chs_clan_minlevel = cfg.get_i32("MinClanLevel", 4)
    @@chs_max_flags_per_clan = cfg.get_i32("MaxFlagsPerClan", 1)
    @@chs_enable_fame = cfg.get_bool("EnableFame")
    @@chs_fame_amount = cfg.get_i32("FameAmount")
    @@chs_fame_frequency = cfg.get_i32("FameFrequency")

    cfg.parse(Dir.current + GEODATA_FILE)
    @@pathnode_dir = cfg.get_string("PathnodeDirectory", "data/pathnode")
    @@pathfinding = cfg.get_i32("PathFinding")
    @@pathfind_buffers = cfg.get_string("PathFindBuffers", "100x6;128x6;192x6;256x4;320x4;384x4;500x2")
    @@low_weight = cfg.get_f32("LowWeight", 0.5)
    @@medium_weight = cfg.get_f32("MediumWeight", 2.0)
    @@high_weight = cfg.get_f32("HighWeight", 3.0)
    @@advanced_diagonal_strategy = cfg.get_bool("AdvancedDiagonalStrategy", true)
    @@diagonal_weight = cfg.get_f32("DiagonalWeight", 0.707)
    @@max_postfilter_passes = cfg.get_i32("MaxPostfilterPasses", 3)
    @@debug_path = cfg.get_bool("DebugPath")
    @@force_geodata = cfg.get_bool("ForceGeoData", true)
    @@coord_synchronize = cfg.get_i32("CoordSynchronize", -1)
    @@geodata_path = File.expand_path(cfg.get_string("GeoDataPath", "./data/geodata"))
    @@try_load_unspecified_regions = cfg.get_bool("TryLoadUnspecifiedRegions", true)
    @@geodata_regions = {} of String => Bool

    L2World::TILE_X_MIN.upto(L2World::TILE_X_MAX) do |region_x|
      L2World::TILE_Y_MIN.upto(L2World::TILE_Y_MAX) do |region_y|
        key = "#{region_x}_#{region_y}"
        if cfg.has_key?(key)
          @@geodata_regions[key] = cfg.get_bool(key)
        end
      end
    end

    if ARGV.includes?("-g")
      @@pathfinding = 2
      @@try_load_unspecified_regions = true
      @@coord_synchronize = 2
    end

    info "Config files read in #{timer.result} s."
  end
end
