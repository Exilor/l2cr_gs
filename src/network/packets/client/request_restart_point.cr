class Packets::Incoming::RequestRestartPoint < GameClientPacket
  @point = 0

  private def read_impl
    @point = d
  end

  private def run_impl
    return unless pc = active_char
    return unless pc.can_revive?
    if pc.fake_death?
      pc.stop_fake_death(true)
      return
    elsif pc.alive?
      warn { "Living player #{pc} sent a respawn request." }
      return
    end

    castle = CastleManager.get_castle(*pc.xyz)
    if castle && castle.siege.in_progress?
      clan = pc.clan
      if clan && castle.siege.attacker?(clan)
        delay = castle.siege.attacker_respawn_delay
        schedule_port_player(pc, delay)
        if delay > 0
          pc.send_message("You will be respawned in #{delay // 1000} seconds")
        end

        return
      end
    end

    port_player(pc)
  end

  private def schedule_port_player(pc, delay)
    task = -> { port_player(pc) }
    ThreadPoolManager.schedule_general(task, delay)
  end

  private def port_player(pc : L2PcInstance)
    loc = nil
    castle = nil
    fort = nil
    hall = nil
    in_defense = false # never modified in L2J
    instance_id = 0

    if pc.jailed?
      @point = 27
    elsif pc.festival_participant?
      @point = 5
    end

    clan = pc.clan

    case @point
    when 1 # clan hall
      if clan.nil? || clan.hideout_id == 0
        warn { "#{pc} attempted to respawn on a clan hall his clan doesn't own." }
        return
      end

      loc = MapRegionManager.get_tele_to_location(pc, TeleportWhereType::CLANHALL)
      if hall = ClanHallManager.get_clan_hall_by_owner(clan)
        if func = hall.get_function(ClanHall::FUNC_RESTORE_EXP)
          pc.restore_exp(func.lvl.to_f)
        end
      end
    when 2 # castle
      castle = CastleManager.get_castle(pc)
      if castle && castle.siege.in_progress?
        if castle.siege.defender?(clan)
          loc = MapRegionManager.get_tele_to_location(pc, TeleportWhereType::CASTLE)
        elsif castle.siege.attacker?(clan)
          loc = MapRegionManager.get_tele_to_location(pc, TeleportWhereType::TOWN)
        else
          warn { "#{pc} attempted to respawn on a castle his clan doesn't own." }
          return
        end
      else
        if clan.nil? || clan.castle_id == 0
          return
        end

        loc = MapRegionManager.get_tele_to_location(pc, TeleportWhereType::CASTLE)
        castle = nil # to make up for crystal's lack of case break
      end

      if castle
        if func = castle.get_function(Castle::FUNC_RESTORE_EXP)
          pc.restore_exp(func.lvl.to_f)
        end
      end
    when 3 # fortress
      return unless clan
      if clan.fort_id == 0 && !in_defense
        warn { "#{pc} attempted to respawn on a fort his clan doesn't own." }
        return
      end

      loc = MapRegionManager.get_tele_to_location(pc, TeleportWhereType::FORTRESS)
      if fort = FortManager.get_fort_by_owner(clan)
        if func = fort.get_function(Fort::FUNC_RESTORE_EXP)
          pc.restore_exp(func.lvl.to_f)
        end
      end
    when 4 # siege HQ
      return unless clan
      siege_clan = nil
      castle = CastleManager.get_castle(pc)
      fort = FortManager.get_fort(pc)
      hall = ClanHallSiegeManager.get_nearby_clan_hall(pc)
      flag = TerritoryWarManager.get_hq_for_clan(clan)

      if castle && castle.siege.in_progress?
        siege_clan = castle.siege.get_attacker_clan(clan)
      elsif fort && fort.siege.in_progress?
        siege_clan = fort.siege.get_attacker_clan(clan)
      elsif hall && hall.in_siege?
        siege_clan = hall.siege.get_attacker_clan(clan)
      end

      if (siege_clan.nil? || siege_clan.flag.empty?) && flag.nil?
        if hall
          unless loc = hall.siege.get_inner_spawn_loc(pc)
            warn { "#{pc} attempted to respawn on a siege HQ he doesn't own." }
          end
        end
      end

      unless loc
        loc = MapRegionManager.get_tele_to_location(pc, TeleportWhereType::SIEGEFLAG)
      end
    when 5 # fixed/festival
      if !pc.gm? && !pc.festival_participant? && !pc.inventory.has_item_for_self_resurrection?
        warn { "#{pc} attempted to respawn in place without being a festival participant." }
        return
      end

      if pc.gm? || pc.destroy_item_by_item_id("Feather", 10649, 1, pc, false) || pc.destroy_item_by_item_id("Feather", 13300, 1, pc, false) || pc.destroy_item_by_item_id("Feather", 10649, 1, pc, false)
        pc.do_revive(100.0)
      else
        instance_id = pc.instance_id
        loc = Location.new(pc)
      end
    when 6 # agathion res
      pc.send_message("Agathion revive is not implemented.")
      # L2J not done
    when 27 # jail
      unless pc.jailed?
        debug { "#{pc} is not jailed." }
        return
      end

      loc = Location.new(-114356, -249645, -2984)
    else # town
      loc = MapRegionManager.get_tele_to_location(pc, TeleportWhereType::TOWN)
    end

    if loc
      pc.instance_id = instance_id
      pc.in_7s_dungeon = false
      pc.pending_revive = true
      pc.tele_to_location(loc, true)
    end
  end
end
