require "../../../instance_managers/handys_block_checker_manager"

class Scripts::HandysBlockCheckerEvent < Quest
  # Arena Managers
  private A_MANAGER_1 = 32521
  private A_MANAGER_2 = 32522
  private A_MANAGER_3 = 32523
  private A_MANAGER_4 = 32524

  def initialize
    super(-1, self.class.simple_name, "Handy's Block Checker Event")

    if Config.enable_block_checker_event
      add_first_talk_id(A_MANAGER_1, A_MANAGER_2, A_MANAGER_3, A_MANAGER_4)
      HandysBlockCheckerManager.start_up_participants_queue
      info "Event enabled."
    else
      info "Event disabled."
    end
  end

  def on_first_talk(npc, pc)
    return unless npc && pc

    arena = npc.id - A_MANAGER_1
    if event_full?(arena)
      pc.send_packet(SystemMessageId::CANNOT_REGISTER_CAUSE_QUEUE_FULL)
      return
    end

    if HandysBlockCheckerManager.arena_being_used?(arena)
      pc.send_packet(SystemMessageId::MATCH_BEING_PREPARED_TRY_LATER)
      return
    end

    if HandysBlockCheckerManager.add_player_to_arena(pc, arena)
      holder = HandysBlockCheckerManager.get_holder(arena)

      tl = ExCubeGameTeamList.new(holder.red_players, holder.blue_players, arena)

      pc.send_packet(tl)

      count_blue = holder.blue_team_size
      count_red = holder.red_team_size
      min_members = Config.min_block_checker_team_members

      if count_blue >= min_members && count_red >= min_members
        holder.update_event
        holder.broadcast_packet_to_team(ExCubeGameRequestReady::STATIC_PACKET)
        holder.broadcast_packet_to_team(ExCubeGameChangeTimeToStart.new(10))
      end
    end

    nil
  end

  private def event_full?(arena)
    HandysBlockCheckerManager.get_holder(arena).size == 12
  end
end
