module TvTEvent
  include Loggable
  enum EventState : UInt8
    INACTIVE
    INACTIVATING
    PARTICIPATING
    STARTING
    STARTED
    REWARDING
  end

  private HTML_PATH = "data/scripts/custom/events/TvT/TvTManager/"
  private TEAMS = Array(TvTEventTeam).new(2)

  @@state = EventState::INACTIVE
  @@npc_spawn : L2Spawn?
  @@last_npc_spawn : L2Npc?

  class_getter tvt_event_instance = 0

  {% for const in EventState.constants %}
    delegate {{const.stringify.underscore + "?"}}, to: @@state
  {% end %}

  #  * Teams initializing
  #  */
  def init
    AntiFeedManager.registerEvent(AntiFeedManager::TVT_ID)
    TEAMS << TvTEventTeam.new(Config.tvt_event_team_1_name, Config.tvt_event_team_1_coordinates)
    TEAMS << TvTEventTeam.new(Config.tvt_event_team_2_name, Config.tvt_event_team_2_coordinates)
  end

  #  * Starts the participation of the TvTEvent
  #  * 1. Get L2NpcTemplate by Config.tvt_event_participation_npc_id
  #  * 2. Try to spawn a new npc of it
  #  *
  #  * @return boolean: true if success, otherwise false
  #  */
  def start_participation
    begin
      @@npc_spawn = L2Spawn.new(Config.tvt_event_participation_npc_id)

      @@npc_spawn.x = Config.tvt_event_participation_npc_coordinates[0]
      @@npc_spawn.y = Config.tvt_event_participation_npc_coordinates[1]
      @@npc_spawn.z = Config.tvt_event_participation_npc_coordinates[2]
      @@npc_spawn.amount = 1
      @@npc_spawn.heading = Config.tvt_event_participation_npc_coordinates[3]
      @@npc_spawn.respawn_delay = 1
      # later no need to delete spawn from db, we don't store it (false)
      SpawnTable.add_new_spawn(@@npc_spawn, false)
      @@npc_spawn.init
      @@last_npc_spawn = @@npc_spawn.last_spawn
      @@last_npc_spawn.current_hp = @@last_npc_spawn.max_hp
      @@last_npc_spawn.title = "TvT Event Participation"
      @@last_npc_spawn.isAggressive # ??
      @@last_npc_spawn.decay_me
      @@last_npc_spawn.spawn_me(*@@npc_spawn.last_spawn.xyz)
      @@last_npc_spawn.broadcast_packet(MagicSkillUse.new(@@last_npc_spawn, @@last_npc_spawn, 1034, 1, 1, 1))
    rescue e
      warn e
      return false
    end

    set_state(EventState::PARTICIPATING)
    EventDispatcher.async(new OnTvTEventRegistrationStart)
    true
  end

  private def get_highest_level_player(Map<Integer, L2PcInstance> players)
    int maxLevel = Integer.MIN_VALUE, maxLevelId = -1
    for (player : players.values)
      if player.level >= maxLevel)
        maxLevel = player.level
        maxLevelId = player.l2id
    end
    }
    return maxLevelId
  }

  # Starts the TvTEvent fight
  # 1. Set state EventState::STARTING
  # 2. Close doors specified in configs
  # 3. Abort if not enough participants(return false)
  # 4. Set state EventState::STARTED
  # 5. Teleport all participants to team spot
  #
  # @return boolean: true if success, otherwise false
  def start_fight
    # Set state to STARTING
    set_state(EventState::STARTING)

    # Randomize and balance team distribution
    Map<Integer, L2PcInstance> participants = {
    participants.putAll(TEAMS[0].getParticipatedPlayers)
    participants.putAll(TEAMS[1].getParticipatedPlayers)
    TEAMS[0].clean_me
    TEAMS[1].clean_me

    player
    Iterator<L2PcInstance> iter
    if needParticipationFee)
      iter = participants.values.iterator
      while (iter.hasNext)
        player = iter.next
        if !hasParticipationFee(player))
          iter.remove
      end
      }
  end

    balance = {
      0,
      0
    }, priority = 0, highest_lvl_player_id
    # TODO: participants should be sorted by level instead of using get_highest_level_player for every fetch
    until participants.empty?
      # Priority team gets one player
      highest_lvl_player_id = get_highest_level_player(participants)
      highest_lvl_player = participants.get(highest_lvl_player_id)
      participants.remove(highest_lvl_player_id)
      TEAMS[priority].addPlayer(highest_lvl_player)
      balance[priority] += highest_lvl_player.getLevel
      # Exiting if no more players
      if participants.empty?
        break
      end
      # The other team gets one player
      # TODO: Code not dry
      priority = 1 - priority
      highest_lvl_player_id = get_highest_level_player(participants)
      highest_lvl_player = participants.get(highest_lvl_player_id)
      participants.remove(highest_lvl_player_id)
      TEAMS[priority].addPlayer(highest_lvl_player)
      balance[priority] += highest_lvl_player.getLevel
      # Recalculating priority
      priority = balance[0] > balance[1] ? 1 : 0
    }

    # Check for enought participants
    if (TEAMS[0].participant_player_count < Config.tvt_event_min_players_inteams) || (TEAMS[1].participant_player_count < Config.tvt_event_min_players_inteams))
      # Set state INACTIVE
      set_state(EventState::INACTIVE)
      # Cleanup of teams
      TEAMS[0].clean_me
      TEAMS[1].clean_me
      # Unspawn the event NPC
      despawn_npc
      AntiFeedManager.clear(AntiFeedManager::TVT_ID)
      return false
  end

    if needParticipationFee)
      iter = TEAMS[0].getParticipatedPlayers.values.iterator
      while (iter.hasNext)
        player = iter.next
        if !payParticipationFee(player))
          iter.remove
      end
      }
      iter = TEAMS[1].getParticipatedPlayers.values.iterator
      while (iter.hasNext)
        player = iter.next
        if !payParticipationFee(player))
          iter.remove
      end
      }
  end

    if Config.tvt_event_in_instance)
      try
        @@tvt_event_instance = InstanceManager.createDynamicInstance(Config.tvt_event_instance_file)
        InstanceManager.getInstance(@@tvt_event_instance).setAllowSummon(false)
        InstanceManager.getInstance(@@tvt_event_instance).setPvPInstance(true)
        InstanceManager.getInstance(@@tvt_event_instance).setEmptyDestroyTime((Config.tvt_event_start_leave_teleport_delay * 1000) + 60000L)
      }
      rescue e
        @@tvt_event_instance = 0
        _log.log(Level.WARNING, "TvTEventEngine[TvTEvent.createDynamicInstance]: exception: " + e.getMessage, e)
      }
  end

    # Opens all doors specified in configs for tvt
    openDoors(Config.tvt_doors_ids_to_open)
    # Closes all doors specified in configs for tvt
    closeDoors(Config.tvt_doors_ids_to_close)
    # Set state STARTED
    set_state(EventState::STARTED)

    # Iterate over all teams
    for (TvTEventTeam team : TEAMS)
      # Iterate over all participated player instances in this team
      for (playerInstance : team.getParticipatedPlayers.values)
        if playerInstance != nil)
          # Disable player revival.
          playerInstance.setCanRevive(false)
          # Teleporter implements Runnable and starts itself
          new TvTEventTeleporter(playerInstance, team.coordinates, false, false)
      end
      }
    }

    # Notify to scripts.
    EventDispatcher.async(new OnTvTEventStart)
    return true
  }

  # Calculates the TvTEvent reward
  # 1. If both teams are at a tie(points equals), send it as system message to all participants, if one of the teams have 0 participants left online abort rewarding
  # 2. Wait till teams are not at a tie anymore
  # 3. Set state EvcentState.REWARDING
  # 4. Reward team with more points
  # 5. Show win html to wining team participants
  #
  # @return String: winning team name
  def String calculateRewards
    if TEAMS[0].getPoints == TEAMS[1].getPoints)
      # Check if one of the teams have no more players left
      if (TEAMS[0].participant_player_count == 0) || (TEAMS[1].participant_player_count == 0))
        # set state to rewarding
        set_state(EventState::REWARDING)
        # return here, the fight can't be completed
        return "TvT Event: Event has ended. No team won due to inactivity!"
    end

      # Both teams have equals points
      sysMsgToparticipants("TvT Event: Event has ended, both teams have tied.")
      if Config.tvt_reward_team_tie)
        rewardTeam(TEAMS[0])
        rewardTeam(TEAMS[1])
        return "TvT Event: Event has ended with both teams tying."
    end
      return "TvT Event: Event has ended with both teams tying."
  end

    # Set state REWARDING so nobody can point anymore
    set_state(EventState::REWARDING)

    # Get team which has more points
    TvTEventTeam team = TEAMS[TEAMS[0].getPoints > TEAMS[1].getPoints ? 0 : 1]
    rewardTeam(team)

    # Notify to scripts.
    EventDispatcher.async(new OnTvTEventFinish)
    return "TvT Event: Event finish. Team " + team.name + " won with " + team.getPoints + " kills."
  }

  private static rewardTeam(TvTEventTeam team)
    # Iterate over all participated player instances of the winning team
    for (playerInstance : team.getParticipatedPlayers.values)
      # Check for nilpointer
      if playerInstance.nil?)
        continue
    end

      SystemMessage systemMessage = nil

      # Iterate over all tvt event rewards
      for (int[] reward : Config.tvt_event_rewards)
        PcInventory inv = playerInstance.getInventory

        # Check for stackable item, non stackabe items need to be added one by one
        if ItemTable.getTemplate(reward[0]).isStackable)
          inv.addItem("TvT Event", reward[0], reward[1], playerInstance, playerInstance)

          if reward[1] > 1)
            systemMessage = SystemMessage.getSystemMessage(SystemMessageId.EARNED_S2_S1_S)
            systemMessage.add_item_name(reward[0])
            systemMessage.addLong(reward[1])
          else
            systemMessage = SystemMessage.getSystemMessage(SystemMessageId.EARNED_ITEM_S1)
            systemMessage.add_item_name(reward[0])
        end

          playerInstance.send_packet(systemMessage)
        else
          for (int i = 0; i < reward[1]; ++i)
            inv.addItem("TvT Event", reward[0], 1, playerInstance, playerInstance)
            systemMessage = SystemMessage.getSystemMessage(SystemMessageId.EARNED_ITEM_S1)
            systemMessage.add_item_name(reward[0])
            playerInstance.send_packet(systemMessage)
          }
      end
      }

      StatusUpdate statusUpdate = new StatusUpdate(playerInstance)
      final NpcHtmlMessage npcHtmlMessage = NpcHtmlMessage.new

      statusUpdate.addAttribute(StatusUpdate.CUR_LOAD, playerInstance.getCurrentLoad)
      npcHtmlMessage.setHtml(HtmCache.get_htm(playerInstance, HTML_PATH + "Reward.html"))
      playerInstance.send_packet(statusUpdate)
      playerInstance.send_packet(npcHtmlMessage)
    }
  }

  # Stops the TvTEvent fight
  # 1. Set state EventState::INACTIVATING
  # 2. Remove tvt npc from world
  # 3. Open doors specified in configs
  # 4. Teleport all participants back to participation npc location
  # 5. Teams cleaning
  # 6. Set state EventState::INACTIVE
  def stopFight
    # Set state INACTIVATING
    set_state(EventState::INACTIVATING)
    # Unspawn event npc
    despawn_npc
    # Opens all doors specified in configs for tvt
    openDoors(Config.tvt_doors_ids_to_close)
    # Closes all doors specified in Configs for tvt
    closeDoors(Config.tvt_doors_ids_to_open)

    # Iterate over all teams
    for (TvTEventTeam team : TEAMS)
      for (playerInstance : team.getParticipatedPlayers.values)
        # Check for nilpointer
        if playerInstance
          # Enable player revival.
          playerInstance.setCanRevive(true)
          # Teleport back.
          new TvTEventTeleporter(playerInstance, Config.tvt_event_participation_npc_coordinates, false, false)
        end
      end
    end

    # Cleanup of teams
    TEAMS[0].clean_me
    TEAMS[1].clean_me
    # Set state INACTIVE
    set_state(EventState::INACTIVE)
    AntiFeedManager.clear(AntiFeedManager::TVT_ID)
  end

   # * Adds a player to a TvTEvent team
   # * 1. Calculate the id of the team in which the player should be added
   # * 2. Add the player to the calculated team
   # *
   # * @param playerInstance as L2PcInstance
   # * @return boolean: true if success, otherwise false
  def synchronized addParticipant(playerInstance) : Bool
    return false unless playerInstance

    sync do
      # Check to which team the player should be added
      if TEAMS[0].participant_player_count == TEAMS[1].participant_player_count)
        team_id = Rnd.rand(2i8)
      else
        team_id = TEAMS[0].participant_player_count > TEAMS[1].participant_player_count ? 1i8 : 0i8
      end
      playerInstance.add_event_listener(TvTEventListener.new(playerInstance))
      TEAMS[team_id].add_player(playerInstance)
    end
  end

  # Removes a TvTEvent player from it's team
  # 1. Get team id of the player
  # 2. Remove player from it's team
  #
  # @param playerObjectId
  # @return boolean: true if success, otherwise false
  def removeParticipant(int playerObjectId)
    # Get the teamId of the player
    byte teamId = getParticipantTeamId(playerObjectId)

    # Check if the player is participant
    if teamId != -1)
      # Remove the player from team
      TEAMS[teamId].removePlayer(playerObjectId)

      player = L2World.getPlayer(playerObjectId)
      if player
        player.removeEventListener(TvTEventListener.class)
    end
      return true
  end

    return false
  }

  def needParticipationFee
    return (Config.tvt_event_participation_fee[0] != 0) && (Config.tvt_event_participation_fee[1] != 0)
  }

  def hasParticipationFee(playerInstance)
    return playerInstance.getInventory.getInventoryItemCount(Config.tvt_event_participation_fee[0], -1) >= Config.tvt_event_participation_fee[1]
  }

  def payParticipationFee(playerInstance)
    return playerInstance.destroyItemByItemId("TvT Participation Fee", Config.tvt_event_participation_fee[0], Config.tvt_event_participation_fee[1], @@last_npc_spawn, true)
  }

  def String getParticipationFee
    int itemId = Config.tvt_event_participation_fee[0]
    int itemNum = Config.tvt_event_participation_fee[1]

    if (itemId == 0) || (itemNum == 0))
      return "-"
  end

    return StringUtil.concat(String.valueOf(itemNum), " ", ItemTable.getTemplate(itemId).name)
  }

  # Send a SystemMessage to all participated players
  # 1. Send the message to all players of team number one
  # 2. Send the message to all players of team number two
  #
  # @param message as String
  def sysMsgToparticipants(String message)
    for (playerInstance : TEAMS[0].getParticipatedPlayers.values)
      if playerInstance != nil)
        playerInstance.send_message(message)
    end
    }

    for (playerInstance : TEAMS[1].getParticipatedPlayers.values)
      if playerInstance != nil)
        playerInstance.send_message(message)
    end
    }
  }

  private static L2DoorInstance getDoor(int doorId)
    L2DoorInstance door = nil
    if @@tvt_event_instance <= 0)
      door = DoorData.getDoor(doorId)
    else
      final Instance inst = InstanceManager.getInstance(@@tvt_event_instance)
      if inst)
        door = inst.getDoor(doorId)
    end
  end
    return door
  }

  # Close doors specified in configs
  # @param doors
  private static closeDoors(List<Integer> doors)
    for (int doorId : doors)
      final L2DoorInstance doorInstance = getDoor(doorId)
      if doorInstance != nil)
        doorInstance.closeMe
    end
    }
  }

  # Open doors specified in configs
  # @param doors
  private static openDoors(List<Integer> doors)
    for (int doorId : doors)
      final L2DoorInstance doorInstance = getDoor(doorId)
      if doorInstance != nil)
        doorInstance.openMe
    end
    }
  }

  # UnSpawns the TvTEvent npc
  private static despawn_npc
    # Delete the npc
    @@last_npc_spawn.delete_me
    SpawnTable.deleteSpawn(@@last_npc_spawn.spawn?, false)
    # Stop respawning of the npc
    @@npc_spawn.stopRespawn
    @@npc_spawn = nil
    @@last_npc_spawn = nil
  }

  # Called when a player logs in
  #
  # @param playerInstance as L2PcInstance
  def onLogin(playerInstance)
    if (playerInstance.nil?) || (!starting? && !started?))
      return
  end

    byte teamId = getParticipantTeamId(playerInstance.l2id)

    if teamId == -1)
      return
  end

    TEAMS[teamId].addPlayer(playerInstance)
    new TvTEventTeleporter(playerInstance, TEAMS[teamId].coordinates, true, false)
  }

  # Called when a player logs out
  #
  # @param playerInstance as L2PcInstance
  def onLogout(playerInstance)
    if (playerInstance != nil) && (starting? || started? || participating?))
      if removeParticipant(playerInstance.l2id))
        playerInstance.setXYZInvisible((Config.tvt_event_participation_npc_coordinates[0] + Rnd.rand(101)) - 50, (Config.tvt_event_participation_npc_coordinates[1] + Rnd.rand(101)) - 50, Config.tvt_event_participation_npc_coordinates[2])
    end
  end
  }

  # Called on every onAction in L2PcIstance
  #
  # @param playerInstance
  # @param targetedPlayerObjectId
  # @return boolean: true if player is allowed to target, otherwise false
  def onAction(playerInstance, int targetedPlayerObjectId)
    if (playerInstance.nil?) || !started?)
      return true
  end

    if playerInstance.isGM)
      return true
  end

    byte playerTeamId = getParticipantTeamId(playerInstance.l2id)
    byte targetedPlayerTeamId = getParticipantTeamId(targetedPlayerObjectId)

    if ((playerTeamId != -1) && (targetedPlayerTeamId == -1)) || ((playerTeamId == -1) && (targetedPlayerTeamId != -1)))
      return false
  end

    if (playerTeamId != -1) && (targetedPlayerTeamId != -1) && (playerTeamId == targetedPlayerTeamId) && (playerInstance.l2id != targetedPlayerObjectId) && !Config.tvt_event_target_team_members_allowed)
      return false
  end

    return true
  }

  # Called on every scroll use
  #
  # @param playerObjectId
  # @return boolean: true if player is allowed to use scroll, otherwise false
  def onScrollUse(int playerObjectId)
    if !started?)
      return true
  end

    if player?Participant(playerObjectId) && !Config.tvt_event_scroll_allowed)
      return false
  end

    return true
  }

  # Called on every potion use
  # @param playerObjectId
  # @return boolean: true if player is allowed to use potions, otherwise false
  def onPotionUse(int playerObjectId)
    if !started?)
      return true
  end

    if player?Participant(playerObjectId) && !Config.tvt_event_potions_allowed)
      return false
  end

    return true
  }

  # Called on every escape use(thanks to nbd)
  # @param playerObjectId
  # @return boolean: true if player is not in tvt event, otherwise false
  def onEscapeUse(int playerObjectId)
    if !started?)
      return true
  end

    if player?Participant(playerObjectId))
      return false
  end

    return true
  }

  # Called on every summon item use
  # @param playerObjectId
  # @return boolean: true if player is allowed to summon by item, otherwise false
  def onItemSummon(int playerObjectId)
    if !started?)
      return true
  end

    if player?Participant(playerObjectId) && !Config.tvt_event_summon_by_item_allowed)
      return false
  end

    return true
  }

  # Is called when a player is killed
  #
  # @param killerCharacter as L2Character
  # @param killedPlayerInstance as L2PcInstance
  def onKill(L2Character killerCharacter, L2PcInstance killedPlayerInstance)
    if (killedPlayerInstance.nil?) || !started?)
      return
  end

    byte killedTeamId = getParticipantTeamId(killedPlayerInstance.l2id)

    if killedTeamId == -1)
      return
  end

    new TvTEventTeleporter(killedPlayerInstance, TEAMS[killedTeamId].coordinates, false, false)

    if killerCharacter.nil?)
      return
  end

    L2PcInstance killerPlayerInstance = nil

    if (killerCharacter.is_a?(L2PetInstance) || (killerCharacter.is_a?(L2ServitorInstance))
      killerPlayerInstance = ((L2Summon) killerCharacter).getOwner

      if killerPlayerInstance.nil?)
        return
    end
  end
    elsif killerCharacter.is_a?(L2PcInstance)
      killerPlayerInstance = (L2PcInstance) killerCharacter
    else
      return
  end

    byte killerTeamId = getParticipantTeamId(killerPlayerInstance.l2id)

    if (killerTeamId != -1) && (killedTeamId != -1) && (killerTeamId != killedTeamId))
      TvTEventTeam killerTeam = TEAMS[killerTeamId]

      killerTeam.increasePoints

      cs = CreatureSay.new(killerPlayerInstance.l2id, Say2::TELL, killerPlayerInstance.name, "I have killed " + killedPlayerInstance.name + "!")

      for (playerInstance : TEAMS[killerTeamId].getParticipatedPlayers.values)
        if playerInstance != nil)
          playerInstance.send_packet(cs)
      end
      }

      # Notify to scripts.
      EventDispatcher.async(OnTvTEventKill.new(killerPlayerInstance, killedPlayerInstance, killerTeam))
  end
  }

  #  * Called on Appearing packet received (player finished teleporting)
  #  * @param playerInstance
  #  */
  def on_teleported(playerInstance)
    if !started? || (playerInstance.nil?) || !player?Participant(playerInstance.l2id))
      return
  end

    if playerInstance.mage_class?
      if (Config.tvt_event_mage_buffs != nil) && !Config.tvt_event_mage_buffs.empty?)
        for (Entry<Integer, Integer> e : Config.tvt_event_mage_buffs.entrySet)
          Skill skill = SkillData.getSkill(e.getKey, e.getValue)
          if skill != nil)
            skill.apply_effects(playerInstance, playerInstance)
          end
        end
      end
    else
      Config.tvt_event_fighter_buffs.each do |k, v|
        if skill = SkillData[k, v]?
          skill.apply_effects(playerInstance, playerInstance)
        end
      end
    end
  end

  # @param source
  # @param target
  # @param skill
  # @return true if player valid for skill
  def final checkForTvTSkill(L2PcInstance source, L2PcInstance target, Skill skill)
    if !started?)
      return true
  end
    # TvT is started
    sourcePlayerId = source.l2id
    targetPlayerId = target.l2id
    final isSourceParticipant = player?Participant(sourcePlayerId)
    final isTargetParticipant = player?Participant(targetPlayerId)

    # both players not participating
    if !isSourceParticipant && !isTargetParticipant)
      return true
  end
    # one player not participating
    if !(isSourceParticipant && isTargetParticipant))
      return false
    end
    # players in the different teams ?
    if getParticipantTeamId(sourcePlayerId) != getParticipantTeamId(targetPlayerId))
      unless skill.bad?
        return false
      end
    end

    true
  end

  # Sets the TvTEvent state
  # @param state as EventState
  private def set_state(state)
    synchronized (@@state)
      @@state = state
    end
  end

  # Returns the team id of a player, if player is not participant it returns -1
  # @param playerObjectId
  # @return byte: team name of the given playerName, if not in event -1
  def byte getParticipantTeamId(int playerObjectId)
    return (byte) (TEAMS[0].include?Player(playerObjectId) ? 0 : (TEAMS[1].include?Player(playerObjectId) ? 1 : -1))
  }

  # Returns the team of a player, if player is not participant it returns nil
  # @param playerObjectId
  # @return TvTEventTeam: team of the given playerObjectId, if not in event nil
  def TvTEventTeam getParticipantTeam(int playerObjectId)
    return (TEAMS[0].include?Player(playerObjectId) ? TEAMS[0] : (TEAMS[1].include?Player(playerObjectId) ? TEAMS[1] : nil))
  }

  # Returns the enemy team of a player, if player is not participant it returns nil
  # @param playerObjectId
  # @return TvTEventTeam: enemy team of the given playerObjectId, if not in event nil
  def TvTEventTeam getParticipantEnemyTeam(int playerObjectId)
    return (TEAMS[0].include?Player(playerObjectId) ? TEAMS[1] : (TEAMS[1].include?Player(playerObjectId) ? TEAMS[0] : nil))
  }

  # Returns the team coordinates in which the player is in, if player is not in a team return
  # @param playerObjectId
  # @return int[]: coordinates of teams, 2 elements, index 0 for team 1 and index 1 for team 2
  def int[] getParticipantTeamCoordinates(int playerObjectId)
    return TEAMS[0].include?Player(playerObjectId) ? TEAMS[0].coordinates : (TEAMS[1].include?Player(playerObjectId) ? TEAMS[1].coordinates : nil)
  }

  # Is given player participant of the event?
  # @param playerObjectId
  # @return boolean: true if player is participant, ohterwise false
  def player?Participant(int playerObjectId)
    if !participating? && !starting? && !started?
      return false
  end

    return TEAMS[0].include?Player(playerObjectId) || TEAMS[1].include?Player(playerObjectId)
  }

  # Returns participated player count
  #
  # @return int: amount of players registered in the event
  def int getParticipatedPlayersCount
    if !participating? && !starting? && !started?
      return 0
    end

    return TEAMS[0].participant_player_count + TEAMS[1].participant_player_count
  }

  # Returns teams names
  #
  # @return String[]: names of teams, 2 elements, index 0 for team 1 and index 1 for team 2
  def team_names : {String, String}
    {TEAMS[0].name, TEAMS[1].name}
  end

  # Returns player count of both teams
  #
  # @return int[]: player count of teams, 2 elements, index 0 for team 1 and index 1 for team 2
  def getTeamsPlayerCounts
    TEAMS.map &.participant_player_count
  }

  # Returns points count of both teams
  # @return int[]: points of teams, 2 elements, index 0 for team 1 and index 1 for team 2
  def getTeamsPoints
    TEAMS.map &.points
  end
end
