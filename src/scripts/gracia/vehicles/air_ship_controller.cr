abstract class AirShipController < Quest
  private struct DecayTask
    initializer controller : AirShipController

    def call
      @controller.docked_ship.try &.delete_me
    end
  end

  private struct DepartTask
    initializer controller : AirShipController

    def call
      if (ship = @controller.docked_ship) && ship.in_dock? && !ship.moving?
        if path = @controller.depart_path
          ship.execute_path(path)
        else
          ship.delete_me
        end
      end
    end
  end

  private DEPART_INTERVAL = 300000 # 5 min
  private LICENSE = 13559

  private STARSTONE = 13277
  private SUMMON_COST = 5

  @dock_zone = 0
  @ship_spawn_x = 0
  @ship_spawn_y = 0
  @ship_spawn_z = 0
  @ship_heading = 0
  @oust_loc : Location?
  @location_id = 0
  @arrival_path : Slice(VehiclePathPoint)?
  @teleports_table : Slice(Slice(VehiclePathPoint))?
  @fuel_table : Slice(Int32)?
  @movie_id = 0
  @bust = false
  @depart_schedule : Scheduler::DelayedTask?
  @arrival_message : NpcSay?

  getter depart_path : Slice(VehiclePathPoint)?
  getter docked_ship : L2ControllableAirShipInstance?

  def initialize(quest_id, name, descr)
    super

    @sm_need_more = SystemMessage.the_airship_need_more_s1
    @sm_need_more.add_item_name(STARSTONE)
    @decay_task = DecayTask.new(self)
    @depart_task = DepartTask.new(self)
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!
    npc = npc.not_nil!

    if event.casecmp?("summon")
      if ship = @docked_ship
        if ship.owner?(pc)
          pc.send_packet(SystemMessageId::THE_AIRSHIP_IS_ALREADY_EXISTS)
        end

        return
      end
      if @bust
        pc.send_packet(SystemMessageId::ANOTHER_AIRSHIP_ALREADY_SUMMONED)
        return
      end
      unless pc.has_clan_privilege?(ClanPrivilege::CL_SUMMON_AIRSHIP)
        pc.send_packet(SystemMessageId::THE_AIRSHIP_NO_PRIVILEGES)
        return
      end
      owner_id = pc.clan_id
      unless AirshipManager.has_airship_license?(owner_id)
        pc.send_packet(SystemMessageId::THE_AIRSHIP_NEED_LICENSE_TO_SUMMON)
        return
      end
      if AirshipManager.has_airship?(owner_id)
        pc.send_packet(SystemMessageId::THE_AIRSHIP_ALREADY_USED)
        return
      end
      unless pc.destroy_item_by_item_id("AirShipSummon", STARSTONE, SUMMON_COST, npc, true)
        pc.send_packet(@sm_need_more)
        return
      end

      @bust = true
      ship = AirshipManager.get_new_airship(@ship_spawn_x, @ship_spawn_y, @ship_spawn_z, @ship_heading, owner_id)
      if ship
        if path = @arrival_path
          ship.execute_path(path)
        end

        @arrival_message ||= NpcSay.new(npc.l2id, Say2::NPC_SHOUT, npc.id, NpcString::THE_AIRSHIP_HAS_BEEN_SUMMONED_IT_WILL_AUTOMATICALLY_DEPART_IN_5_MINUTES)

        npc.broadcast_packet(@arrival_message.not_nil!)
      else
        @bust = false
      end

      return
    elsif event.casecmp?("board")
      if pc.transformed?
        pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_TRANSFORMED)
        return
      elsif pc.paralyzed?
        pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_PETRIFIED)
        return
      elsif pc.looks_dead?
        pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_DEAD)
        return
      elsif pc.fishing?
        pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_FISHING)
        return
      elsif pc.in_combat?
        pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_IN_BATTLE)
        return
      elsif pc.in_duel?
        pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_IN_A_DUEL)
        return
      elsif pc.sitting?
        pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_SITTING)
        return
      elsif pc.casting_now?
        pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_CASTING)
        return
      elsif pc.cursed_weapon_equipped?
        pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_A_CURSED_WEAPON_IS_EQUIPPED)
        return
      elsif pc.combat_flag_equipped?
        pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_HOLDING_A_FLAG)
        return
      elsif pc.has_summon? || pc.mounted?
        pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_A_PET_OR_A_SERVITOR_IS_SUMMONED)
        return
      elsif pc.flying_mounted?
        pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_NOT_MEET_REQUEIREMENTS)
        return
      end

      if ship = @docked_ship
        ship.add_passenger(pc)
      else
        debug "@docked_ship is nil."
      end

      return
    elsif event.casecmp?("register")
      clan = pc.clan
      if clan.nil? || clan.level < 5
        pc.send_packet(SystemMessageId::THE_AIRSHIP_NEED_CLANLVL_5_TO_SUMMON)
        return
      end
      unless pc.clan_leader?
        pc.send_packet(SystemMessageId::THE_AIRSHIP_NO_PRIVILEGES)
        return
      end
      owner_id = pc.clan_id
      if AirshipManager.has_airship_license?(owner_id)
        pc.send_packet(SystemMessageId::THE_AIRSHIP_SUMMON_LICENSE_ALREADY_ACQUIRED)
        return
      end
      unless pc.destroy_item_by_item_id("AirShipLicense", LICENSE, 1, npc, true)
        pc.send_packet(@sm_need_more)
        return
      end

      AirshipManager.register_license(owner_id)
      pc.send_packet(SystemMessageId::THE_AIRSHIP_SUMMON_LICENSE_ENTERED)
      return
    else
      return event
    end
  end

  def on_enter_zone(char, zone)
    if char.is_a?(L2ControllableAirShipInstance)
      if @docked_ship.nil?
        ship = char
        @docked_ship = ship
        ship.in_dock = @dock_zone
        ship.oust_loc = @oust_loc

        # Ship is not empty - display movie to passengers and dock
        if ship.empty?
          @depart_schedule = ThreadPoolManager.schedule_general(@depart_task.not_nil!, DEPART_INTERVAL)
        else
          if @movie_id != 0
            ship.passengers.each do |passenger|
              passenger.show_quest_movie(@movie_id)
            end
          end

          ThreadPoolManager.schedule_general(@decay_task.not_nil!, 1000)
        end
      end
    end

    nil
  end

  def on_exit_zone(char, zone)
    if char.is_a?(L2ControllableAirShipInstance)
      if char == @docked_ship
        if task = @depart_schedule
          task.cancel
          @depart_schedule = nil
        end

        @docked_ship.not_nil!.in_dock = 0
        @docked_ship = nil
        @bust = false
      end
    end

    nil
  end

  def on_first_talk(npc, pc)
    "#{npc.id}.htm"
  end

  private def validity_check
    unless zone = ZoneManager.get_zone_by_id(@dock_zone, L2ScriptZone)
      warn { "Invalid zone #{@dock_zone}, controller disabled." }
      @bust = true
      return
    end

    if path = @arrival_path
      if path.empty?
        warn { "Zero arrival path length." }
        @arrival_path = nil
      else
        p = path.sample
        unless zone.inside_zone?(p.location)
          warn { "Arrival path finish point (#{p.x}, #{p.y}, #{p.z}) not in zone #{@dock_zone}." }
          @arrival_path = nil
        end
      end
    end

    if @arrival_path.nil?
      unless ZoneManager.get_zone_by_id(@dock_zone, L2ScriptZone).not_nil!.inside_zone?(@ship_spawn_x, @ship_spawn_y, @ship_spawn_z)
        warn { "Arrival path is nil and spawn point not in zone #{@dock_zone}, controller disabled." }
        @bust = true
        return
      end
    end

    if path = @depart_path
      if path.empty?
        warn "Empty path."
        @depart_path = nil
      else
        p = path.sample
        if zone.inside_zone?(p.location)
          warn { "Departure path finish point (#{p.x}, #{p.y}, #{p.z}) in zone #{@dock_zone}." }
          @depart_path = nil
        end
      end
    end

    if teleports_table = @teleports_table
      fuel_table = @fuel_table
      if fuel_table.nil?
        warn "Fuel consumption not defined."
      else
        if teleports_table.size == fuel_table.size
          AirshipManager.register_airship_teleport_list(@dock_zone, @location_id, @teleports_table.not_nil!, @fuel_table.not_nil!)
        else
          warn "Fuel consumption not match teleport list."
        end
      end
    end
  end
end
