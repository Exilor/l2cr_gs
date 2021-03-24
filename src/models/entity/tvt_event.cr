require "./tvt_event_teleporter"
require "./tvt_event_listener"

module TvTEvent
  extend self
  include Loggable
  extend Synchronizable
  include Packets::Outgoing

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
  @@state_lock = Mutex.new
  @@npc_spawn : L2Spawn?
  @@last_npc_spawn : L2Npc?

  class_getter tvt_event_instance = 0

  {% for const in EventState.constants %}
    delegate {{const.stringify.underscore + "?"}}, to: @@state
  {% end %}

  def init
    AntiFeedManager.register_event(AntiFeedManager::TVT_ID)
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
      @@npc_spawn = sp = L2Spawn.new(Config.tvt_event_participation_npc_id)

      sp.x = Config.tvt_event_participation_npc_coordinates[0]
      sp.y = Config.tvt_event_participation_npc_coordinates[1]
      sp.z = Config.tvt_event_participation_npc_coordinates[2]
      sp.amount = 1
      sp.heading = Config.tvt_event_participation_npc_coordinates[3]
      sp.respawn_delay = 1
      # later no need to delete spawn from db, we don't store it (false)
      SpawnTable.add_new_spawn(sp, false)
      sp.init
      @@last_npc_spawn = last_sp = sp.last_spawn.not_nil!
      last_sp.max_hp!
      last_sp.title = "TvT Event Participation"
      last_sp.aggressive? # ??
      last_sp.decay_me
      last_sp.spawn_me(*sp.last_spawn.not_nil!.xyz)
      last_sp.broadcast_packet(MagicSkillUse.new(last_sp, last_sp, 1034, 1, 1, 1))
    rescue e
      warn e
      return false
    end

    set_state(EventState::PARTICIPATING)
    EventDispatcher.async(OnTvTEventRegistrationStart.new)
    true
  end

  private def get_highest_level_player(players)
    max_lvl = Int32::MIN
    max_lvl_id = -1

    players.each_value do |pc|
      if pc.level >= max_lvl
        max_lvl = pc.level
        max_lvl_id = pc.l2id
      end
    end

    max_lvl_id
  end

  # Starts the TvTEvent fight
  # 1. Set state EventState::STARTING
  # 2. Close doors specified in configs
  # 3. Abort if not enough participants(return false)
  # 4. Set state EventState::STARTED
  # 5. Teleport all participants to team spot
  #
  # @return boolean: true if success, otherwise false
  def start_fight : Bool
    # Set state to STARTING
    set_state(EventState::STARTING)

    # Randomize and balance team distribution
    participants = TEAMS[0].participants.merge(TEAMS[1].participants)
    TEAMS[0].clean_me
    TEAMS[1].clean_me

    if needs_participation_fee?
      participants.select! { |_, pc| has_participation_fee?(pc) }
    end

    balance = Slice.new(2, 0)
    priority = 0
    highest_lvl_player_id = 0
    # TODO: participants should be sorted by level instead of using get_highest_level_player for every fetch
    until participants.empty?
      # Priority team gets one player
      highest_lvl_player_id = get_highest_level_player(participants)
      highest_lvl_player = participants[highest_lvl_player_id]
      participants.delete(highest_lvl_player_id)
      TEAMS[priority].add_player(highest_lvl_player)
      balance[priority] &+= highest_lvl_player.level
      # Exiting if no more players
      if participants.empty?
        break
      end
      # The other team gets one player
      # TODO: Code not dry
      priority = 1 &- priority
      highest_lvl_player_id = get_highest_level_player(participants)
      highest_lvl_player = participants[highest_lvl_player_id]
      participants.delete(highest_lvl_player_id)
      TEAMS[priority].add_player(highest_lvl_player)
      balance[priority] &+= highest_lvl_player.level
      # Recalculating priority
      priority = balance[0] > balance[1] ? 1 : 0
    end

    # Check for enought participants
    if TEAMS[0].participants_count < Config.tvt_event_min_players_in_teams || TEAMS[1].participants_count < Config.tvt_event_min_players_in_teams
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

    if needs_participation_fee?
      TEAMS[0].participants.select! do |_, pc|
        pay_participation_fee(pc)
      end
      TEAMS[1].participants.select! do |_, pc|
        pay_participation_fee(pc)
      end
    end

    if Config.tvt_event_in_instance
      begin
        @@tvt_event_instance = InstanceManager.create_dynamic_instance(Config.tvt_event_instance_file)
        inst = InstanceManager.get_instance(@@tvt_event_instance).not_nil!
        inst.allow_summon = false
        inst.pvp_instance = true
        inst.empty_destroy_time = (Config.tvt_event_start_leave_teleport_delay.to_i64 * 1000) + 60000
      rescue e
        error e
        @@tvt_event_instance = 0
      end
    end

    # Opens all doors specified in configs for tvt
    open_doors(Config.tvt_doors_ids_to_open)
    # Closes all doors specified in configs for tvt
    close_doors(Config.tvt_doors_ids_to_close)
    # Set state STARTED
    set_state(EventState::STARTED)

    # Iterate over all teams
    TEAMS.each do |team|
      # Iterate over all participated player instances in this team
      team.participants.each_value do |pc|
        # Disable player revival.
        pc.can_revive = false
        # Teleporter implements Runnable and starts itself
        TvTEventTeleporter.new(pc, team.coordinates, false, false)
      end
    end

    # Notify to scripts.
    EventDispatcher.async(OnTvTEventStart.new)
    true
  end

  # Calculates the TvTEvent reward
  # 1. If both teams are at a tie(points equals), send it as system message to all participants, if one of the teams have 0 participants left online abort rewarding
  # 2. Wait till teams are not at a tie anymore
  # 3. Set state EvcentState.REWARDING
  # 4. Reward team with more points
  # 5. Show win html to wining team participants
  #
  # @return String: winning team name
  def calculate_rewards : String
    if TEAMS[0].points == TEAMS[1].points
      # Check if one of the teams have no more players left
      if TEAMS[0].participants_count == 0 || TEAMS[1].participants_count == 0
        # set state to rewarding
        set_state(EventState::REWARDING)
        # return here, the fight can't be completed
        return "TvT Event: Event has ended. No team won due to inactivity!"
      end

      # Both teams have equals points
      message_all_participants("TvT Event: Event has ended, both teams have tied.")
      if Config.tvt_reward_team_tie
        reward_team(TEAMS[0])
        reward_team(TEAMS[1])
        return "TvT Event: Event has ended with both teams tying."
      end

      return "TvT Event: Event has ended with both teams tying."
    end

    # Set state REWARDING so nobody can point anymore
    set_state(EventState::REWARDING)

    # Get team which has more points
    team = TEAMS[TEAMS[0].points > TEAMS[1].points ? 0 : 1]
    reward_team(team)

    # Notify to scripts.
    EventDispatcher.async(OnTvTEventFinish.new)

    "TvT Event: Event finish. Team #{team.name} won with #{team.points} kills."
  end

  private def reward_team(team)
    # Iterate over all participated player instances of the winning team
    team.participants.each_value do |pc|
      # Iterate over all tvt event rewards
      Config.tvt_event_rewards.each do |reward|
        inv = pc.inventory

        # Check for stackable item, non stackabe items need to be added one by one
        if ItemTable[reward[0]].stackable?
          inv.add_item("TvT Event", reward[0], reward[1].to_i64, pc, pc)

          if reward[1] > 1
            sm = SystemMessage.earned_s2_s1_s
            sm.add_item_name(reward[0])
            sm.add_long(reward[1])
          else
            sm = SystemMessage.earned_item_s1
            sm.add_item_name(reward[0])
          end

          pc.send_packet(sm)
        else
          reward[1].times do
            inv.add_item("TvT Event", reward[0], 1, pc, pc)
            sm = SystemMessage.earned_item_s1
            sm.add_item_name(reward[0])
            pc.send_packet(sm)
          end
        end
      end

      html_msg = NpcHtmlMessage.new
      html_msg.html = HtmCache.get_htm(pc, HTML_PATH + "Reward.html").not_nil!
      pc.send_packet(html_msg)
      pc.send_packet(StatusUpdate.current_load(pc))
    end
  end

  # Stops the TvTEvent fight
  # 1. Set state EventState::INACTIVATING
  # 2. Remove tvt npc from world
  # 3. Open doors specified in configs
  # 4. Teleport all participants back to participation npc location
  # 5. Teams cleaning
  # 6. Set state EventState::INACTIVE
  def stop_fight
    # Set state INACTIVATING
    set_state(EventState::INACTIVATING)
    # Unspawn event npc
    despawn_npc
    # Opens all doors specified in configs for tvt
    open_doors(Config.tvt_doors_ids_to_close)
    # Closes all doors specified in Configs for tvt
    close_doors(Config.tvt_doors_ids_to_open)

    # Iterate over all teams
    TEAMS.each do |team|
      team.participants.each_value do |pc|
        # Enable player revival.
        pc.can_revive = true
        # Teleport back.
        TvTEventTeleporter.new(pc, Config.tvt_event_participation_npc_coordinates, false, false)
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
   # * @param pc as L2PcInstance
   # * @return boolean: true if success, otherwise false
  def add_participant(pc) : Bool
    return false unless pc

    sync do
      # Check to which team the player should be added
      if TEAMS[0].participants_count == TEAMS[1].participants_count
        team_id = Rnd.rand(2i8)
      else
        team_id = TEAMS[0].participants_count > TEAMS[1].participants_count ? 1i8 : 0i8
      end
      pc.add_event_listener(TvTEventListener.new(pc))
      TEAMS[team_id].add_player(pc)
    end
  end

  # Removes a TvTEvent player from it's team
  # 1. Get team id of the player
  # 2. Remove player from it's team
  #
  # @param l2id
  # @return boolean: true if success, otherwise false
  def remove_participant(l2id : Int32) : Bool
    # Get the teamId of the player
    team_id = get_participant_team_id(l2id)

    # Check if the player is participant
    if team_id != -1
      # Remove the player from team
      TEAMS[team_id].remove_player(l2id)

      if pc = L2World.get_player(l2id)
        pc.remove_event_listener(TvTEventListener)
      end

      return true
    end

    false
  end

  def needs_participation_fee?
    Config.tvt_event_participation_fee[0] != 0 &&
    Config.tvt_event_participation_fee[1] != 0
  end

  def has_participation_fee?(pc : L2PcInstance) : Bool
    pc.inventory.get_inventory_item_count(Config.tvt_event_participation_fee[0], -1) >= Config.tvt_event_participation_fee[1]
  end

  def pay_participation_fee(pc : L2PcInstance) : Bool
    pc.destroy_item_by_item_id("TvT Participation Fee", Config.tvt_event_participation_fee[0], Config.tvt_event_participation_fee[1], @@last_npc_spawn, true)
  end

  def participation_fee : String
    item_id = Config.tvt_event_participation_fee[0]
    item_num = Config.tvt_event_participation_fee[1]

    if item_id == 0 || item_num == 0
      return "-"
    end

    "#{item_num} #{ItemTable[item_id].name}"
  end

  # Send a SystemMessage to all participated players
  # 1. Send the message to all players of team number one
  # 2. Send the message to all players of team number two
  #
  # @param message as String
  def message_all_participants(message : String)
    TEAMS[0].participants.each_value do |pc|
      pc.send_message(message)
    end

    TEAMS[1].participants.each_value do |pc|
      pc.send_message(message)
    end
  end

  private def get_door(door_id : Int32) : L2DoorInstance?
    if @@tvt_event_instance <= 0
      DoorData.get_door(door_id)
    else
      if inst = InstanceManager.get_instance(@@tvt_event_instance)
        inst.get_door(door_id)
      end
    end
  end

  # Close doors specified in configs
  # @param doors
  private def close_doors(doors : Array(Int32))
    doors.each do |door_id|
      if door = get_door(door_id)
        door.close_me
      end
    end
  end

  # Open doors specified in configs
  # @param doors
  private def open_doors(doors : Array(Int32))
    doors.each do |door_id|
      if door = get_door(door_id)
        door.open_me
      end
    end
  end

  # UnSpawns the TvTEvent npc
  private def despawn_npc
    # Delete the npc
    @@last_npc_spawn.not_nil!.delete_me
    SpawnTable.delete_spawn(@@last_npc_spawn.not_nil!.spawn, false)
    # Stop respawning of the npc
    @@npc_spawn.not_nil!.stop_respawn
    @@npc_spawn = nil
    @@last_npc_spawn = nil
  end

  # Called when a player logs in
  #
  # @param pc_instance as L2PcInstance
  def on_login(pc)
    if pc.nil? || (!starting? && !started?)
      return
    end

    team_id = get_participant_team_id(pc.l2id)

    if team_id == -1
      return
    end

    TEAMS[team_id].add_player(pc)
    TvTEventTeleporter.new(pc, TEAMS[team_id].coordinates, true, false)
  end

  # Called when a player logs out
  #
  # @param pc as L2PcInstance
  def on_logout(pc)
    if pc && (starting? || started? || participating?)
      if remove_participant(pc.l2id)
        pc.set_xyz_invisible(
          Config.tvt_event_participation_npc_coordinates[0] + rand(101) - 50,
          Config.tvt_event_participation_npc_coordinates[1] + rand(101) - 50,
          Config.tvt_event_participation_npc_coordinates[2]
        )
      end
    end
  end

  # Called on every on_action in L2PcInstance
  #
  # @param pc
  # @param target_l2id
  # @return boolean: true if player is allowed to target, otherwise false
  def on_action(pc : L2PcInstance, target_l2id : Int32) : Bool
    if pc.nil? || !started?
      return true
    end

    if pc.gm?
      return true
    end

    team_id = get_participant_team_id(pc.l2id)
    target_team_id = get_participant_team_id(target_l2id)

    if team_id != -1 && target_team_id == -1
      return false
    end

    if team_id == -1 && target_team_id != -1
      return false
    end

    if team_id != -1 && target_team_id != -1 && team_id == target_team_id
      if pc.l2id != target_l2id && !Config.tvt_event_target_team_members_allowed
        return false
      end
    end

    true
  end

  # Called on every scroll use
  #
  # @param l2id
  # @return boolean: true if player is allowed to use scroll, otherwise false
  def on_scroll_use(l2id : Int32) : Bool
    unless started?
      return true
    end

    if participant?(l2id) && !Config.tvt_event_scroll_allowed
      return false
    end

    true
  end

  # Called on every potion use
  # @param l2id
  # @return boolean: true if player is allowed to use potions, otherwise false
  def on_potion_use(l2id : Int32) : Bool
    unless started?
      return true
    end

    if participant?(l2id) && !Config.tvt_event_potions_allowed
      return false
    end

    true
  end

  # Called on every escape use(thanks to nbd)
  # @param l2id
  # @return boolean: true if player is not in tvt event, otherwise false
  def on_escape_use(l2id : Int32) : Bool
    unless started?
      return true
    end

    if participant?(l2id)
      return false
    end

    true
  end

  # Called on every summon item use
  # @param l2id
  # @return boolean: true if player is allowed to summon by item, otherwise false
  def on_item_summon(l2id : Int32) : Bool
    unless started?
      return true
    end

    if participant?(l2id) && !Config.tvt_event_summon_by_item_allowed
      return false
    end

    true
  end

  # Is called when a player is killed
  #
  # @param killer_char as L2Character
  # @param killed_pc as L2PcInstance
  def on_kill(killer_char : L2Character, killed_pc : L2PcInstance)
    if killed_pc.nil? || !started?
      return
    end

    killed_team_id = get_participant_team_id(killed_pc.l2id)

    if killed_team_id == -1
      return
    end

    TvTEventTeleporter.new(killed_pc, TEAMS[killed_team_id].coordinates, false, false)

    unless killer_char
      return
    end

    if killer_char.is_a?(L2PetInstance) || killer_char.is_a?(L2ServitorInstance)
      killer_pc_instance = killer_char.owner
    elsif killer_char.is_a?(L2PcInstance)
      killer_pc_instance = killer_char
    else
      return
    end

    killer_team_id = get_participant_team_id(killer_pc_instance.l2id)

    if killer_team_id != -1 && killed_team_id != -1 && killer_team_id != killed_team_id
      killer_team = TEAMS[killer_team_id]

      killer_team.increase_points

      cs = CreatureSay.new(killer_pc_instance.l2id, Packets::Incoming::Say2::TELL, killer_pc_instance.name, "I have killed " + killed_pc.name + "!")

      TEAMS[killer_team_id].participants.each_value do |pc|
        pc.send_packet(cs)
      end

      # Notify to scripts.
      EventDispatcher.async(OnTvTEventKill.new(killer_pc_instance, killed_pc, killer_team))
    end
  end

  #  * Called on Appearing packet received (player finished teleporting)
  #  * @param pc_instance
  #  */
  def on_teleported(pc : L2PcInstance)
    if !started? || pc.nil? || !participant?(pc.l2id)
      return
    end

    if pc.mage_class?
      Config.tvt_event_mage_buffs.each do |k, v|
        if skill = SkillData[k, v]?
          skill.apply_effects(pc, pc)
        end
      end
    else
      Config.tvt_event_fighter_buffs.each do |k, v|
        if skill = SkillData[k, v]?
          skill.apply_effects(pc, pc)
        end
      end
    end
  end

  # @param source
  # @param target
  # @param skill
  # @return true if player valid for skill
  def check_for_tvt_skill(source : L2PcInstance, target : L2PcInstance, skill : Skill) : Bool
    unless started?
      return true
    end
    # TvT is started
    source_id = source.l2id
    target_id = target.l2id
    is_source_participant = participant?(source_id)
    is_target_participant = participant?(target_id)

    # both players not participating
    if !is_source_participant && !is_target_participant
      return true
    end
    # one player not participating
    unless is_source_participant && is_target_participant
      return false
    end
    # players in the different teams ?
    if get_participant_team_id(source_id) != get_participant_team_id(target_id)
      unless skill.bad?
        return false
      end
    end

    true
  end

  # Sets the TvTEvent state
  # @param state as EventState
  private def set_state(state)
    @@state_lock.synchronize { @@state = state }
  end

  # Returns the team id of a player, if player is not participant it returns -1
  # @param l2id
  # @return byte: team name of the given playerName, if not in event -1
  def get_participant_team_id(l2id : Int32) : Int8
    if TEAMS[0].contains_player?(l2id)
      0i8
    else
      TEAMS[1].contains_player?(l2id) ? 1i8 : -1i8
    end
  end

  # Returns the team of a player, if player is not participant it returns nil
  # @param l2id
  # @return TvTEventTeam: team of the given l2id, if not in event nil
  def get_participant_team(l2id : Int32) : TvTEventTeam?
    if TEAMS[0].contains_player?(l2id)
      TEAMS[0]
    else
      TEAMS[1] if TEAMS[1].contains_player?(l2id)
    end
  end

  # Returns the enemy team of a player, if player is not participant it returns nil
  # @param l2id
  # @return TvTEventTeam: enemy team of the given l2id, if not in event nil
  def get_participant_enemy_team(l2id : Int32) : TvTEventTeam?
    if TEAMS[0].contains_player?(l2id)
      TEAMS[1]
    else
      TEAMS[0] if TEAMS[1].contains_player?(l2id)
    end
  end

  # Returns the team coordinates in which the player is in, if player is not in a team return
  # @param l2id
  # @return int[]: coordinates of teams, 2 elements, index 0 for team 1 and index 1 for team 2
  def get_participant_team_coordinates(l2id : Int32) : Slice(Int32)?
    if TEAMS[0].contains_player?(l2id)
      TEAMS[0].coordinates
    else
      TEAMS[1].coordinates if TEAMS[1].contains_player?(l2id)
    end
  end

  # Is given player participant of the event?
  # @param l2id
  # @return boolean: true if player is participant, ohterwise false
  def participant?(l2id : Int32)
    if !participating? && !starting? && !started?
      return false
    end

    TEAMS[0].contains_player?(l2id) || TEAMS[1].contains_player?(l2id)
  end

  # Returns participated player count
  #
  # @return int: amount of players registered in the event
  def participants_count : Int32
    if !participating? && !starting? && !started?
      return 0
    end

    TEAMS[0].participants_count + TEAMS[1].participants_count
  end

  # Returns teams names
  #
  # @return String[]: names of teams, 2 elements, index 0 for team 1 and index 1 for team 2
  def team_names : {String, String}
    {TEAMS[0].name, TEAMS[1].name}
  end

  # Returns player count of both teams
  #
  # @return int[]: player count of teams, 2 elements, index 0 for team 1 and index 1 for team 2
  def teams_player_counts : Array(Int32)
    TEAMS.map &.participants_count
  end

  # Returns points count of both teams
  # @return int[]: points of teams, 2 elements, index 0 for team 1 and index 1 for team 2
  def teams_points : Array(Int32)
    TEAMS.map &.points
  end
end
