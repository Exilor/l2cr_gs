class L2SiegeZone < L2ZoneType
  private DISMOUNT_DELAY = 5

  def initialize(id)
    super
    self.settings = ZoneManager.get_settings(name) || Settings.new
  end

  def set_parameter(name : String, value : String)
    case name
    when "castleId", "fortId"
      if settings.siegable_id != -1
        raise "Siege object already defined"
      end
      settings.siegable_id = value.to_i
    when "clanHallId"
      if settings.siegable_id != -1
        raise "Siege object already defined"
      end

      settings.siegable_id = value.to_i

      hall = ClanHallSiegeManager.conquerable_halls[settings.siegable_id]?
      if hall
        hall.siege_zone = self
      else
        warn { "Siegable clan hall with id #{value} does not exist." }
      end
    else
      super
    end
  end

  def on_enter(char)
    if settings.active_siege?
      char.inside_pvp_zone = true
      char.inside_siege_zone = true
      char.inside_no_summon_friend_zone = true
      if pc = char.as?(L2PcInstance)
        if pc.registered_on_this_siege_field?(settings.siegable_id)
          pc.in_siege = true
          siege = settings.siege
          if siege.give_fame? && siege.fame_frequency > 0
            pc.start_fame_task(siege.fame_frequency.to_i64 * 1000, siege.fame_amount)
          end
        end

        pc.send_packet(SystemMessageId::ENTERED_COMBAT_ZONE)
        if !Config.allow_wyvern_during_siege && pc.mount_type.wyvern?
          pc.send_packet(SystemMessageId::AREA_CANNOT_BE_ENTERED_WHILE_MOUNTED_WYVERN)
          pc.entered_no_landing(DISMOUNT_DELAY)
        end
      end
    end
  end

  def on_exit(char)
    char.inside_pvp_zone = false
    char.inside_siege_zone = false
    char.inside_no_summon_friend_zone = false
    if settings.active_siege?
      if pc = char.as?(L2PcInstance)
        pc.send_packet(SystemMessageId::LEFT_COMBAT_ZONE)
        if pc.mount_type.wyvern?
          pc.exited_no_landing
        end

        if pc.pvp_flag == 0
          pc.start_pvp_flag
        end
      end
    end

    if pc = char.as?(L2PcInstance)
      pc.stop_fame_task
      pc.in_siege = false

      siege = settings.siege?
      if siege.is_a?(FortSiege)
        if item = pc.inventory.get_item_by_item_id(9819)
          if fort = FortManager.get_fort_by_id(settings.siegable_id)
            FortSiegeManager.drop_combat_flag(pc, fort.residence_id)
          else
            pc.inventory.get_item_by_item_id(9819)
            slot = pc.inventory.get_slot_from_item(item)
            pc.inventory.unequip_item_in_body_slot(slot)
            pc.destroy_item("CombatFlag", item, nil, true)
          end
        end
      end
    end
  end

  def on_die_inside(char)
    if settings.active_siege? && char.is_a?(L2PcInstance)
      if char.registered_on_this_siege_field?(settings.siegable_id)
        lvl = 1
        if info = char.effect_list.get_buff_info_by_skill_id(5660)
          lvl = Math.min(lvl &+ info.skill.level, 5)
        end
        if skill = SkillData[5660, lvl]?
          skill.apply_effects(char, char)
        end
      end
    end
  end

  def settings : Settings
    super.as(Settings)
  end

  class Settings < AbstractZoneSettings
    property siegable_id : Int32 = -1
    property! siege : Siegable?
    property? active_siege : Bool = false

    def initialize
      clear
    end

    def clear
      @siegable_id = -1
      @siege = nil
      @active_siege = false
    end
  end

  def siege_l2id : Int32
    settings.siegable_id
  end

  def siege_instance=(siege : Siegable?)
    settings.siege = siege
  end

  def active? : Bool
    settings.active_siege?
  end

  def active=(val : Bool)
    settings.active_siege = val
  end

  def banish_foreigners(owner_clan_id : Int32)
    each_player_inside do |pc|
      if pc.clan_id != owner_clan_id
        pc.tele_to_location(TeleportWhereType::TOWN)
      end
    end
  end

  def update_zone_status_for_characters_inside
    if settings.active_siege?
      each_character_inside do |char|
        on_enter(char)
      end
    else
      each_character_inside do |char|
        char.inside_pvp_zone = false
        char.inside_siege_zone = false
        char.inside_no_summon_friend_zone = false

        if pc = char.as?(L2PcInstance)
          pc.send_packet(SystemMessageId::LEFT_COMBAT_ZONE)
          pc.stop_fame_task
          if pc.mount_type.wyvern?
            pc.exited_no_landing
          end
        end
      end
    end
  end

  def announce_to_players(msg : String)
    each_player_inside &.send_message(msg)
  end
end
