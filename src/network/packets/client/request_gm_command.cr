class Packets::Incoming::RequestGMCommand < GameClientPacket
  @target_name = ""
  @command = 0

  private def read_impl
    @target_name = s
    @command = d
  end

  private def run_impl
    return unless pc = active_char
    return unless pc.gm? && pc.access_level.allow_alt_g?

    player = L2World.get_player(@target_name)
    clan = ClanTable.get_clan_by_name(@target_name)

    if !player && (!clan || @command != 6)
      return
    end

    case @command
    when 1 # Player status
      if player
        send_packet(GMViewCharacterInfo.new(player))
        send_packet(GMHennaInfo.new(player))
      end
    when 2 # Player clan
      if player
        if clan = player.clan
          send_packet(GMViewPledgeInfo.new(clan, player))
        end
      end
    when 3 # Player skills
      if player
        send_packet(GMViewSkillInfo.new(player))
      end
    when 4 # Player quests
      if player
        send_packet(GmViewQuestInfo.new(player))
      end
    when 5 # Player inventory
      if player
        send_packet(GMViewItemList.new(player))
        send_packet(GMHennaInfo.new(player))
      end
    when 6 # Player warehouse
      if player
        send_packet(GMViewWarehouseWithdrawList.new(player))
      elsif clan
        send_packet(GMViewWarehouseWithdrawList.new(clan))
      end
    end

  end
end
