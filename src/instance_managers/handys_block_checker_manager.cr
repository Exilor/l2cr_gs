require "../models/arena_participants_holder"
require "./tasks/penalty_remove_task"

module HandysBlockCheckerManager
  extend self
  extend Synchronizable
  include Packets::Outgoing

  # All the participants and their team classified by arena
  private ARENA_PLAYERS = Array(ArenaParticipantsHolder).new(4)
  # Arena votes to start the game
  private ARENA_VOTES = Slice(Int32).new(4, 0)
  # Arena Status, True = is being used, otherwise, False
  private ARENA_STATUS = Slice[false, false, false, false]
  # Registration request penalty (10 seconds)
  private REGISTRATION_PENALTY = Concurrent::Set(Int32).new

  # Return the number of event-start votes for the specified arena id
  def get_arena_votes(arena_id : Int) : Int32
    sync { ARENA_VOTES[arena_id] }
  end

  # Add a new vote to start the event for the specified arena id
  def increase_arena_votes(arena : Int32)
    sync do
      new_votes = ARENA_VOTES[arena] &+ 1
      holder = ARENA_PLAYERS[arena]

      if new_votes > holder.size / 2 && !holder.event.started?
        clear_arena_votes(arena)
        if holder.blue_team_size == 0 || holder.red_team_size == 0
          return
        end
        if Config.hbce_fair_play
          holder.check_and_shuffle
        end
        ThreadPoolManager.execute_general(BlockCheckerEngine::StartEvent.new(holder.event))
      else
        ARENA_VOTES[arena] = new_votes
      end
    end
  end

  # Will clear the votes queue (of event start) for the specified arena id
  def clear_arena_votes(arena : Int32)
    sync { ARENA_VOTES[arena] = 0 }
  end

  # Returns the players holder
  def get_holder(arena : Int) : ArenaParticipantsHolder
    ARENA_PLAYERS[arena]
  end

  # Initializes the participants holder
  def start_up_participants_queue
    4.times do |i|
      ARENA_PLAYERS << ArenaParticipantsHolder.new(i)
    end
  end

  # Add the player to the specified arena (through the specified arena manager) and send the needed server -> client packets
  def add_player_to_arena(pc : L2PcInstance, arena_id : Int)
    holder = ARENA_PLAYERS[arena_id]

    holder.sync do
      4.times do |i|
        if ARENA_PLAYERS[i].includes?(pc)
          sm = SystemMessage.c1_is_already_registered_on_the_match_waiting_list
          sm.add_pc_name(pc)
          pc.send_packet(sm)
          return false
        end
      end

      if pc.cursed_weapon_equipped?
        pc.send_packet(SystemMessageId::CANNOT_REGISTER_PROCESSING_CURSED_WEAPON)
        return false
      end

      if pc.on_event? || pc.in_olympiad_mode?
        pc.send_message("Couldnt register you due other event participation")
        return false
      end

      if OlympiadManager.registered?(pc)
        OlympiadManager.unregister_noble(pc)
        pc.send_packet(SystemMessageId::COLISEUM_OLYMPIAD_KRATEIS_APPLICANTS_CANNOT_PARTICIPATE)
      end

      # if(UnderGroundColiseum.registered?Player(pc))
      # {
      # UngerGroundColiseum.removeParticipant(pc)
      # pc.send_packet(SystemMessageId::COLISEUM_OLYMPIAD_KRATEIS_APPLICANTS_CANNOT_PARTICIPATE))
      # }
      # if(KrateiCubeManager.registered?Player(pc))
      # {
      # KrateiCubeManager.removeParticipant(pc)
      # pc.send_packet(SystemMessageId::COLISEUM_OLYMPIAD_KRATEIS_APPLICANTS_CANNOT_PARTICIPATE))
      # }

      if REGISTRATION_PENALTY.includes?(pc.l2id)
        pc.send_packet(SystemMessageId::CANNOT_REQUEST_REGISTRATION_10_SECS_AFTER)
        return false
      end

      if holder.blue_team_size < holder.red_team_size
        holder.add_player(pc, 1)
        red = false
      else
        holder.add_player(pc, 0)
        red = true
      end
      holder.broadcast_packet_to_team(ExCubeGameAddPlayer.new(pc, red))

      true
    end
  end

  # Will remove the specified player from the specified team and arena and will send the needed packet to all his team mates / enemy team mates
  def remove_player(pc : L2PcInstance, arena_id : Int, team : Int32)
    holder = ARENA_PLAYERS[arena_id]
    holder.sync do
      red = team == 0

      holder.remove_player(pc, team)
      holder.broadcast_packet_to_team(ExCubeGameRemovePlayer.new(pc, red))

      # End event if theres an empty team
      team_size = red ? holder.red_team_size : holder.blue_team_size
      if team_size == 0
        holder.event.end_event_abnormally
      end

      REGISTRATION_PENALTY << pc.l2id
      schedule_penalty_removal(pc.l2id)
    end
  end

  # Will change the player from one team to other (if possible) and will send the needed packets
  def change_player_to_team(pc : L2PcInstance, arena : Int32, team : Int32)
    holder = ARENA_PLAYERS[arena]

    holder.sync do
      from_red = holder.red_players.includes?(pc)

      if from_red && holder.blue_team_size == 6
        pc.send_message("The team is full")
        return
      elsif !from_red && holder.red_team_size == 6
        pc.send_message("The team is full")
        return
      end

      future_team = from_red ? 1 : 0
      holder.add_player(pc, future_team)

      if from_red
        holder.remove_player(pc, 0)
      else
        holder.remove_player(pc, 1)
      end
      holder.broadcast_packet_to_team(ExCubeGameChangeTeam.new(pc, from_red))
    end
  end

  # Will erase all participants from the specified holder
  def clear_paticipant_queue_by_arena_id(arena_id : Int)
    sync { ARENA_PLAYERS[arena_id].clear_players }
  end

  # Returns true if arena is holding an event at this momment
  def arena_being_used?(arena_id : Int) : Bool
    arena_id.between?(0, 3) && ARENA_STATUS[arena_id]
  end

  # Set the specified arena as being used
  def arena_being_used=(arena_id : Int)
    ARENA_STATUS[arena_id] = true
  end

  # Set as free the specified arena for future events
  def set_arena_free(arena_id : Int)
    ARENA_STATUS[arena_id] = false
  end

  # Called when played logs out while participating in Block Checker Event
  def on_disconnect(pc : L2PcInstance)
    arena = pc.block_checker_arena
    team = get_holder(arena).get_player_team(pc)
    HandysBlockCheckerManager.remove_player(pc, arena, team)

    unless pc.team.none?
      pc.stop_all_effects
      # Remove team aura
      pc.team = Team::NONE

      # Remove the event items
      inv = pc.inventory

      if inv.get_item_by_item_id(13787)
        count = inv.get_inventory_item_count(13787, 0)
        inv.destroy_item_by_item_id("Handys Block Checker", 13787, count, pc, pc)
      end
      if inv.get_item_by_item_id(13788)
        count = inv.get_inventory_item_count(13788, 0)
        inv.destroy_item_by_item_id("Handys Block Checker", 13788, count, pc, pc)
      end
      pc.set_inside_zone(ZoneId::PVP, false)
      # Teleport Back
      pc.tele_to_location(-57478, -60367, -2370)
    end
  end

  def remove_penalty(l2id : Int32)
    REGISTRATION_PENALTY.delete(l2id)
  end

  private def schedule_penalty_removal(l2id)
    ThreadPoolManager.schedule_general(PenaltyRemoveTask.new(l2id), 10000)
  end
end
