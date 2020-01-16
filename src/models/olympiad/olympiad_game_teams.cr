require "./abstract_olympiad_game"
require "./olympiad_info"
require "./participant"

class OlympiadGameTeams < AbstractOlympiadGame
  include Packets::Outgoing

  MAX_TEAM_SIZE = 3

  @team_one_defaulted = false
  @team_two_defaulted = false
  @damage_t1 = 0
  @damage_t2 = 0
  @team_one_size : Int32
  @team_two_size : Int32

  def initialize(id : Int32, team_one : Array(Participant), team_two : Array(Participant))
    super(id)

    @team_one_size = Math.min(team_one.size, MAX_TEAM_SIZE)
    @team_two_size = Math.min(team_two.size, MAX_TEAM_SIZE)
    @team_one = Array(Participant).new(MAX_TEAM_SIZE)
    @team_two = Array(Participant).new(MAX_TEAM_SIZE)

    MAX_TEAM_SIZE.times do |i|
      if i < @team_one_size
        par = team_one[i]
        @team_one << par
        if par.player?
          par.player.olympiad_game_id = id
        end
      else
        @team_one << Participant.new(IdFactory.next, 1)
      end

      if i < @team_two_size
        par = team_two[i]
        @team_two << par
        if par.player?
          par.player.olympiad_game_id = id
        end
      else
        @team_two << Participant.new(IdFactory.next, 2)
      end
    end
  end

  def self.create_list_of_participants(list : IArray(IArray(Int32))) : Array(Array(Participant))?
    if list.nil? || list.size < 2
      return
    end

    t1 = nil
    t2 = nil
    team_one_players = [] of L2PcInstance
    team_two_players = [] of L2PcInstance

    until list.empty?
      t1 = list.delete_first(list.sample(random: Rnd))

      if t1.nil? || t1.empty?
        next
      end

      t1.each do |l2id|
        pc = L2World.get_player(l2id)
        if pc.nil? || !pc.online?
          team_one_players.clear
          break
        end
        team_one_players << pc
      end
      if team_one_players.empty?
        next
      end

      t2 = list.delete_first(list.sample(random: Rnd))
      if t2.nil? || t2.empty?
        list << t1
        team_one_players.clear
        next
      end

      t2.each do |l2id|
        pc = L2World.get_player(l2id)
        if pc.nil? || !pc.online?
          team_two_players.clear
          break
        end
        team_two_players << pc
      end
      if team_two_players.empty?
        list << t1
        team_one_players.clear
        next
      end

      t1 = Array(Participant).new(team_one_players.size)
      t2 = Array(Participant).new(team_two_players.size)
      result = [] of Array(Participant)

      t1.size.times do |i|
        t1 << Participant.new(team_one_players[i], 1)
      end

      t2.size.times do |i|
        t2 << Participant.new(team_two_players[i], 2)
      end

      result[0] = t1
      result[1] = t2
      return [t1, t2]
    end

    nil
  end

  def self.create_game(id : Int32, list : IArray(IArray(Int32))) : OlympiadGameTeams?
    unless teams = create_list_of_participants(list)
      return
    end

    new(id, teams[0], teams[1])
  end

  def type : CompetitionType
    CompetitionType::TEAMS
  end

  private def divider : Int32
    5
  end

  private def reward : Slice(Slice(Int32))
    Config.alt_oly_team_reward
  end

  private def weekly_match_type : String
    COMP_DONE_WEEK_TEAM
  end

  def contains_participant?(pc_id : Int32) : Bool
    @team_one_size.downto(0) do |i|
      if @team_one[i].l2id == pc_id
        return true
      end
    end

    @team_two_size.downto(0) do |i|
      if @team_two[i].l2id == pc_id
        return true
      end
    end

    false
  end

  def send_olympiad_info(player : L2Character)
    MAX_TEAM_SIZE.times do |i|
      player.send_packet(ExOlympiadUserInfo.new(@team_one[i]))
    end

    MAX_TEAM_SIZE.times do |i|
      player.send_packet(ExOlympiadUserInfo.new(@team_two[i]))
    end
  end

  def broadcast_olympiad_info(stadium : L2OlympiadStadiumZone)
    MAX_TEAM_SIZE.times do |i|
      stadium.broadcast_packet(ExOlympiadUserInfo.new(@team_one[i]))
    end

    MAX_TEAM_SIZE.times do |i|
      stadium.broadcast_packet(ExOlympiadUserInfo.new(@team_two[i]))
    end
  end

  def broadcast_packet(gsp : GameServerPacket)
    @team_one_size.times do |i|
      par = @team_one[i]
      if par.update_player
        par.player.send_packet(gsp)
      end
    end

    @team_two_size.times do |i|
      par = @team_two[i]
      par.update_player
      if pc = par.player?
        pc.send_packet(gsp)
      end
    end
  end

  # /**
  #  * UnAfraid: FIXME: Sometimes buffers appear on arena 3v3 match where it shouldn't or they don't get unspawned when match start.
  #  */
  def needs_buffers? : Bool
    false
  end

  def port_players_to_arena(spawns : Array(Location)) : Bool
    ret = true

    begin
      @team_one_size.times do |i|
        ret &= port_player_to_arena(@team_one[i], spawns[i], @stadium_id)
      end

      offset = spawns.size // 2
      @team_two_size.times do |i|
        ret &= port_player_to_arena(@team_two[i], spawns[i + offset], @stadium_id)
      end
    rescue e
      error e
      return false
    end

    ret
  end

  def removals
    @team_one_size.downto(0) do |i|
      removals(@team_one[i].try &.player?, false)
    end

    @team_two_size.downto(0) do |i|
      removals(@team_two[i].try &.player?, false)
    end
  end

  def make_competition_start
    unless super
      return false
    end

    @team_one_size.times do |i|
      par = @team_one[i]
      unless par.player?
        return false
      end

      par.player.olympiad_start = true
      par.player.update_effect_icons
    end

    @team_two_size.times do |i|
      par = @team_two[i]
      unless par.player?
        return false
      end

      par.player.olympiad_start = true
      par.player.update_effect_icons
    end

    true
  end

  def clean_effects
    @team_one_size.downto(0) do |i|
      par = @team_one[i]
      if par.player? && !par.defaulted? && !par.disconnected?
        if par.player.olympiad_game_id == @stadium_id
          clean_effects(par.player)
        end
      end
    end

    @team_two_size.downto(0) do |i|
      par = @team_two[i]
      if par.player? && !par.defaulted? && !par.disconnected?
        if par.player.olympiad_game_id == @stadium_id
          clean_effects(par.player)
        end
      end
    end
  end

  def port_players_back
    @team_one_size.downto(0) do |i|
      par = @team_one[i]
      if par.player? && !par.defaulted? && !par.disconnected?
        port_player_back(par.player)
      end
    end

    @team_two_size.downto(0) do |i|
      par = @team_two[i]
      if par.player? && !par.defaulted? && !par.disconnected?
        port_player_back(par.player)
      end
    end
  end

  def players_status_back
    @team_one_size.downto(0) do |i|
      par = @team_one[i]
      if par.player? && !par.defaulted? && !par.disconnected? && par.player.olympiad_game_id == @stadium_id
        player_status_back(par.player)
      end
    end

    @team_two_size.downto(0) do |i|
      par = @team_two[i]
      if par.player? && !par.defaulted? && !par.disconnected? && par.player.olympiad_game_id == @stadium_id
        player_status_back(par.player)
      end
    end
  end

  def clear_players
    MAX_TEAM_SIZE.times do |i|
      if i < @team_one_size
        @team_one[i].player = nil
      else
        IdFactory.release(@team_one[i].l2id)
      end

      if i < @team_two_size
        @team_two[i].player = nil
      else
        IdFactory.release(@team_two[i].l2id)
      end

      # @team_one[i] = nil
      # @team_two[i] = nil
    end
  end

  def handle_disconnect(player)
    @team_one_size.downto(0) do |i|
      par = @team_one[i]
      if par.l2id == player.l2id
        par.disconnected = true
        return
      end
    end

    @team_two_size.downto(0) do |i|
      par = @team_two[i]
      if par.l2id == player.l2id
        par.disconnected = true
        return
      end
    end
  end

  def has_winner? : Bool
    unless check_battle_status
      return true
    end

    t1_lost = true
    t2_lost = true
    @team_one_size.downto(0) do |i|
      par = @team_one[i]
      unless par.disconnected?
        player = par.player?
        if player && player.olympiad_game_id == @stadium_id
          t1_lost &= par.player.dead?
        end
      end
    end

    @team_two_size.downto(0) do |i|
      par = @team_two[i]
      unless par.disconnected?
        player = par.player?
        if player && player.olympiad_game_id == @stadium_id
          t2_lost &= par.player.dead?
        end
      end
    end

    t1_lost || t2_lost
  end

  def check_battle_status : Bool
    if @aborted
      return false
    end

    if team_one_all_disconnected?
      return false
    end

    if team_two_all_disconnected?
      return false
    end

    true
  end

  def validate_winner(stadium : L2OlympiadStadiumZone)
    if @aborted
      return
    end

    result = nil

    tie = false
    winside = 0

    list1 = [] of OlympiadInfo
    list2 = [] of OlympiadInfo

    t1_crash = team_one_all_disconnected?
    t2_crash = team_two_all_disconnected?

    # Check for if a team defaulted before battle started
    if @team_one_defaulted || @team_two_defaulted
      begin
        if @team_one_defaulted
          @team_one_size.downto(0) do |i|
            par = @team_one[i]
            points = par.stats.get_i32(POINTS) // divider
            val = Math.min(par.stats.get_i32(POINTS) // 3, Config.alt_oly_max_points)
            remove_points_from_participant(par, val)
            list1 << OlympiadInfo.new(par.name, par.clan_name, par.clan_id, par.base_class, @damage_t1, points - val, -val)
          end
          winside = 2
        end
        if @team_two_defaulted
          @team_two_size.downto(0) do |i|
            par = @team_two[i]
            points = par.stats.get_i32(POINTS) // divider
            val = Math.min(par.stats.get_i32(POINTS) // 3, Config.alt_oly_max_points)
            remove_points_from_participant(par, val)
            list2 << OlympiadInfo.new(par.name, par.clan_name, par.clan_id, par.base_class, @damage_t2, points - val, -val)
          end
          if winside == 2
            tie = true
          else
            winside = 1
          end
        end
        if winside == 1
          result = ExOlympiadMatchResult.new(tie, winside, list1, list2)
        else
          result = ExOlympiadMatchResult.new(tie, winside, list2, list1)
        end
        stadium.broadcast_packet(result)
      rescue e
        error e
      end

      return
    end

    # points to be dedicted in when of losing
    points_t1 = Slice(Int32).new(@team_one_size)
    points_t2 = Slice(Int32).new(@team_two_size)
    maxpoints_t1 = Slice(Int32).new(@team_one_size)
    maxpoints_t2 = Slice(Int32).new(@team_two_size)
    totalpoints_t1 = 0
    totalpoints_t2 = 0
    @team_one_size.times do |i|
      points = @team_one[i].stats.get_i32(POINTS) // divider
      if points <= 0
        points = 1
      elsif points > Config.alt_oly_max_points
        points = Config.alt_oly_max_points
      end

      totalpoints_t1 += points
      points_t1[i] = points
      maxpoints_t1[i] = points
    end

    @team_two_size.downto(0) do |i|
      points = @team_two[i].stats.get_i32(POINTS) // divider
      if points <= 0
        points = 1
      elsif points > Config.alt_oly_max_points
        points = Config.alt_oly_max_points
      end

      totalpoints_t2 += points
      points_t2[i] = points
      maxpoints_t2[i] = points
    end

    # Choose minimum sum
    min = Math.min(totalpoints_t1, totalpoints_t2).to_i

    # make sure all team members got same number of the points: round down to 3x
    min = (min // MAX_TEAM_SIZE) * MAX_TEAM_SIZE

    # calculating coefficients and trying to correct total number of points for each team
    # due to rounding errors total points after correction will always be lower or equal
    # than needed minimal sum
    divider_1 = totalpoints_t1.fdiv(min)
    divider_2 = totalpoints_t2.fdiv(min)
    totalpoints_t1 = min
    totalpoints_t2 = min
    @team_one_size.times do |i|
      points = Math.max((points_t1[i] // divider_1).to_i, 1)
      points_t1[i] = points
      totalpoints_t1 -= points
    end

    @team_two_size.downto(0) do |i|
      points = Math.max((points_t2[i] // divider_2).to_i, 1)
      points_t2[i] = points
      totalpoints_t2 -= points
    end

    # compensating remaining points, first team from begin to end, second from end to begin
    i = 0
    while totalpoints_t1 > 0 && i < @team_one_size
      if points_t1[i] < maxpoints_t1[i]
        points_t1[i] += 1
        totalpoints_t1 -= 1
      end
      i += 1
    end

    i = @team_two_size
    while totalpoints_t2 > 0 && (i -= 1) >= 0
      if points_t2[i] < maxpoints_t2[i]
        points_t2[i] += 1
        totalpoints_t2 -= 1
      end
    end

    # Create results for players if a team crashed
    if t1_crash || t2_crash
      begin
        if t2_crash && !t1_crash
          sm = SystemMessage.c1_has_won_the_game
          sm.add_string(@team_one[0].name)
          stadium.broadcast_packet(sm)

          @team_two_size.times do |i|
            par = @team_two[i]
            par.update_stat(COMP_LOST, 1)
            points = points_t2[i]
            remove_points_from_participant(par, points)
            list2 << OlympiadInfo.new(par.name, par.clan_name, par.clan_id, par.base_class, @damage_t2, par.stats.get_i32(POINTS) - points, -points)
          end

          points = min // MAX_TEAM_SIZE
          @team_one_size.times do |i|
            par = @team_one[i]
            par.update_stat(COMP_WON, 1)
            add_points_to_participant(par, points)
            list1 << OlympiadInfo.new(par.name, par.clan_name, par.clan_id, par.base_class, @damage_t1, par.stats.get_i32(POINTS) + points, points)
          end

          @team_one_size.times do |i|
            reward_participant(@team_one[i].player, reward)
          end

          winside = 1
        elsif t1_crash && !t2_crash
          sm = SystemMessage.c1_has_won_the_game
          sm.add_string(@team_two[0].name)
          stadium.broadcast_packet(sm)

          @team_one_size.times do |i|
            par = @team_one[i]
            par.update_stat(COMP_LOST, 1)
            points = points_t1[i]
            remove_points_from_participant(par, points)
            list1 << OlympiadInfo.new(par.name, par.clan_name, par.clan_id, par.base_class, @damage_t1, par.stats.get_i32(POINTS) - points, -points)
          end

          points = min // MAX_TEAM_SIZE
          @team_two_size.times do |i|
            par = @team_two[i]
            par.update_stat(COMP_WON, 1)
            add_points_to_participant(par, points)
            list2 << OlympiadInfo.new(par.name, par.clan_name, par.clan_id, par.base_class, @damage_t2, par.stats.get_i32(POINTS) + points, points)
          end

          winside = 2

          @team_two_size.times do |i|
            reward_participant(@team_two[i].player, reward)
          end
        elsif t1_crash && t2_crash
          stadium.broadcast_packet(SystemMessage.the_game_ended_in_a_tie)

          @team_one_size.downto(0) do |i|
            par = @team_one[i]
            par.update_stat(COMP_LOST, 1)
            remove_points_from_participant(par, points_t1[i])
            list1 << OlympiadInfo.new(par.name, par.clan_name, par.clan_id, par.base_class, @damage_t1, par.stats.get_i32(POINTS) - points_t1[i], -points_t1[i])
          end

          @team_two_size.downto(0) do |i|
            par = @team_two[i]
            par.update_stat(COMP_LOST, 1)
            remove_points_from_participant(par, points_t2[i])
            list2 << OlympiadInfo.new(par.name, par.clan_name, par.clan_id, par.base_class, @damage_t2, par.stats.get_i32(POINTS) - points_t1[i], -points_t1[i])
          end

          tie = true
        end

        @team_one_size.downto(0) do |i|
          par = @team_one[i]
          par.update_stat(COMP_DONE, 1)
          par.update_stat(COMP_DONE_WEEK, 1)
          par.update_stat(weekly_match_type, 1)
        end

        @team_two_size.downto(0) do |i|
          par = @team_two[i]
          par.update_stat(COMP_DONE, 1)
          par.update_stat(COMP_DONE_WEEK, 1)
          par.update_stat(weekly_match_type, 1)
        end
      rescue e
        error e
      end

      if winside == 1
        result = ExOlympiadMatchResult.new(tie, winside, list1, list2)
      else
        result = ExOlympiadMatchResult.new(tie, winside, list2, list1)
      end
      stadium.broadcast_packet(result)
      return
    end

    begin
      t1_hp = 0.0
      t2_hp = 0.0

      @team_one_size.downto(0) do |i|
        par = @team_one[i]
        if !par.disconnected? && par.player? && par.player.alive?
          hp = par.player.current_hp + par.player.current_cp
          if hp >= 0.5
            t1_hp += hp
          end
        end
        par.update_player
      end

      @team_two_size.downto(0) do |i|
        par = @team_two[i]
        if !par.disconnected? && par.player? && par.player.alive?
          hp = par.player.current_hp + par.player.current_cp
          if hp >= 0.5
            t2_hp += hp
          end
        end
        par.update_player
      end

      if (t2_hp == 0 && t1_hp != 0) || (@damage_t1 > @damage_t2 && t2_hp != 0 && t1_hp != 0)
        sm = SystemMessage.c1_has_won_the_game
        sm.add_string(@team_one[0].name)
        stadium.broadcast_packet(sm)

        @team_two_size.times do |i|
          par = @team_two[i]
          par.update_stat(COMP_LOST, 1)
          points = points_t2[i]
          remove_points_from_participant(par, points)
          list2 << OlympiadInfo.new(par.name, par.clan_name, par.clan_id, par.base_class, @damage_t2, par.stats.get_i32(POINTS) - points, -points)
        end

        points = min // MAX_TEAM_SIZE
        @team_one_size.times do |i|
          par = @team_one[i]
          par.update_stat(COMP_WON, 1)
          add_points_to_participant(par, points)
          list1 << OlympiadInfo.new(par.name, par.clan_name, par.clan_id, par.base_class, @damage_t1, par.stats.get_i32(POINTS) + points, points)
        end

        winside = 1

        @team_one_size.times do |i|
          reward_participant(@team_one[i].player, reward)
        end
      elsif (t1_hp == 0 && t2_hp != 0) || (@damage_t2 > @damage_t1 && t1_hp != 0 && t2_hp != 0)
        sm = SystemMessage.c1_has_won_the_game
        sm.add_string(@team_two[0].name)
        stadium.broadcast_packet(sm)

        @team_one_size.times do |i|
          par = @team_one[i]
          par.update_stat(COMP_LOST, 1)
          points = points_t1[i]
          remove_points_from_participant(par, points)
          list1 << OlympiadInfo.new(par.name, par.clan_name, par.clan_id, par.base_class, @damage_t1, par.stats.get_i32(POINTS) - points, -points)
        end

        points = min // MAX_TEAM_SIZE
        @team_two_size.times do |i|
          par = @team_two[i]
          par.update_stat(COMP_WON, 1)
          add_points_to_participant(par, points)
          list2 << OlympiadInfo.new(par.name, par.clan_name, par.clan_id, par.base_class, @damage_t2, par.stats.get_i32(POINTS) + points, points)
        end

        winside = 2

        @team_two_size.times do |i|
          reward_participant(@team_two[i].player, reward)
        end
      else
        stadium.broadcast_packet(SystemMessage.the_game_ended_in_a_tie)

        @team_one_size.times do |i|
          par = @team_one[i]
          par.update_stat(COMP_DRAWN, 1)
          points = Math.min(par.stats.get_i32(POINTS) // divider, Config.alt_oly_max_points)
          remove_points_from_participant(par, points)
          list1 << OlympiadInfo.new(par.name, par.clan_name, par.clan_id, par.base_class, @damage_t1, par.stats.get_i32(POINTS) - points, -points)
        end

        @team_two_size.times do |i|
          par = @team_two[i]
          par.update_stat(COMP_DRAWN, 1)
          points = Math.min(par.stats.get_i32(POINTS) // divider, Config.alt_oly_max_points)
          remove_points_from_participant(par, points)
          list2 << OlympiadInfo.new(par.name, par.clan_name, par.clan_id, par.base_class, @damage_t2, par.stats.get_i32(POINTS) - points, -points)
        end
        tie = true
      end

      @team_one_size.downto(0) do |i|
        par = @team_one[i]
        par.update_stat(COMP_DONE, 1)
        par.update_stat(COMP_DONE_WEEK, 1)
        par.update_stat(weekly_match_type, 1)
      end

      @team_two_size.downto(0) do |i|
        par = @team_two[i]
        par.update_stat(COMP_DONE, 1)
        par.update_stat(COMP_DONE_WEEK, 1)
        par.update_stat(weekly_match_type, 1)
      end
      if winside == 1
        result = ExOlympiadMatchResult.new(tie, winside, list1, list2)
      else
        result = ExOlympiadMatchResult.new(tie, winside, list2, list1)
      end
      stadium.broadcast_packet(result)
    rescue e
      error e
    end
  end

  # /**
  #  * UnAfraid: TODO: We should calculate the damage in array separately for each player so we can display it on ExOlympiadMatchResult correctly.
  #  */
  def add_damage(player, damage : Int32)
    @team_one_size.downto(0) do |i|
      par = @team_one[i]
      if par.l2id == player.l2id
        unless par.disconnected?
          @damage_t1 += damage
        end

        return
      end
    end

    @team_two_size.downto(0) do |i|
      par = @team_two[i]
      if par.l2id == player.l2id
        unless par.disconnected?
          @damage_t2 += damage
        end

        return
      end
    end
  end

  def player_names : Indexable(String)
    {@team_one[0].name, @team_two[0].name}
  end

  def check_defaulted : Bool
    @team_one_size.downto(0) do |i|
      par = @team_one[i]
      par.update_player
      if reason = check_defaulted(par.player?)
        par.defaulted = true
        unless @team_one_defaulted
          @team_one_defaulted = true
          @team_two.each do |t|
            if pc = t.not_nil!.player?
              pc.send_packet(reason)
            end
          end
        end
      end
    end

    @team_two_size.downto(0) do |i|
      par = @team_two[i]
      par.update_player
      if reason = check_defaulted(par.player?)
        par.defaulted = true
        unless @team_two_defaulted
          @team_two_defaulted = true
          @team_one.each do |t|
            if pc = t.not_nil!.player?
              pc.send_packet(reason)
            end
          end
        end
      end
    end

    @team_one_defaulted || @team_two_defaulted
  rescue e
    error e
    true
  end

  def reset_damage
    @damage_t1 = 0
    @damage_t2 = 0
  end

  def team_one_all_disconnected? : Bool
    @team_one_size.downto(0) do |i|
      unless @team_one[i].disconnected?
        return false
      end
    end

    true
  end

  def team_two_all_disconnected? : Bool
    @team_two_size.downto(0) do |i|
      unless @team_two[i].disconnected?
        return false
      end
    end

    true
  end
end
