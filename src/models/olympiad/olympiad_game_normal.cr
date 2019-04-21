require "./abstract_olympiad_game"

abstract class OlympiadGameNormal < AbstractOlympiadGame
  @damage_p1 = 0
  @damage_p2 = 0

  @player_one : Participant
  @player_two : Participant

  def initialize(id : Int32, opponents : Indexable(Participant))
    super(id)

    @player_one = opponents[0]
    @player_two = opponents[1]

    @player_one.player.olympiad_game_id = id
    @player_two.player.olympiad_game_id = id
  end

  def self.create_list_of_participants(list : Array(Int32))
    if list.nil? || list.size < 2
      return
    end

    until list.empty?
      p1_l2id = list.delete_first(list.sample).not_nil!
      p1 = L2World.get_player(p1_l2id)
      if p1.nil? || !p1.online?
        next
      end

      p2 = L2World.get_player(list.delete_first(list.sample))
      if p2.nil? || !p2.online?
        list << p1_l2id
        next
      end

      result = {
        Participant.new(p1, 1),
        Participant.new(p2, 2)
      }

      return result
    end

    nil
  end

  def contains_participant?(pc_id : Int32) : Bool
    ((@player_one != nil) && (@player_one.l2id == pc_id)) || ((@player_two != nil) && (@player_two.l2id == pc_id))
  end

  def send_olympiad_info(pc : L2Character) # really? any l2character?
    pc.send_packet(ExOlympiadUserInfo.new(@player_one))
    pc.send_packet(ExOlympiadUserInfo.new(@player_two))
  end

  def broadcast_olympiad_info(stadium : L2OlympiadStadiumZone)
    stadium.broadcast_packet(ExOlympiadUserInfo.new(@player_one))
    stadium.broadcast_packet(ExOlympiadUserInfo.new(@player_two))
  end

  def broadcast_packet(gsp : GameServerPacket)
    if @player_one.update_player
      @player_one.player.send_packet(gsp)
    end

    if @player_two.update_player
      @player_two.player.send_packet(gsp)
    end
  end

  def port_players_to_arena(spawns : Array(Location)) : Bool
    result = true

    begin
      result &= port_player_to_arena(@player_one, spawns[0], @stadium_id)
      result &= port_player_to_arena(@player_two, spawns[spawns.size / 2], @stadium_id)
    rescue e
      error e
      return false
    end

    result
  end

  def needs_buffers? : Bool
    true
  end

  def removals
    if @aborted
      return
    end

    removals(@player_one.player?, true)
    removals(@player_two.player?, true)
  end

  def make_competition_start : Bool
    unless super
      return false
    end

    if @player_one.player?.nil? || @player_two.player?.nil?
      return false
    end

    @player_one.player.olympiad_start = true
    @player_one.player.update_effect_icons
    @player_two.player.olympiad_start = true
    @player_two.player.update_effect_icons

    true
  end

  def clean_effects
    if @player_one.player? && !@player_one.defaulted? && !@player_one.disconnected? && @player_one.player.olympiad_game_id == @stadium_id
      clean_effects(@player_one.player)
    end

    if @player_two.player? && !@player_two.defaulted? && !@player_two.disconnected? && @player_two.player.olympiad_game_id == @stadium_id
      clean_effects(@player_two.player)
    end
  end

  def port_players_back
    if @player_one.player? && !@player_one.defaulted? && !@player_one.disconnected?
      port_player_back(@player_one.player)
    end
    if @player_two.player? && !@player_two.defaulted? && !@player_two.disconnected?
      port_player_back(@player_two.player)
    end
  end

  def players_status_back
    if @player_one.player? && !@player_one.defaulted? && !@player_one.disconnected? && @player_one.player.olympiad_game_id == @stadium_id
      player_status_back(@player_one.player)
    end

    if @player_two.player? && !@player_two.defaulted? && !@player_two.disconnected? && @player_two.player.olympiad_game_id == @stadium_id
      player_status_back(@player_two.player)
    end
  end

  def clear_players
    @player_one.player = nil
    # @player_one = nil # now how do we deal with this nilable ivar
    @player_two.player = nil
    # @player_two = nil # now how do we deal with this nilable ivar
  end

  def handle_disconnect(pc : L2PcInstance)
    if pc.l2id == @player_one.l2id
      @player_one.disconnected = true
    elsif pc.l2id == @player_two.l2id
      @player_two.disconnected = true
    end
  end

  def check_battle_status : Bool
    if @aborted
      return false
    end

    if @player_one.player?.nil? || @player_one.disconnected?
      return false
    end

    if @player_two.player?.nil? || @player_two.disconnected?
      return false
    end

    true
  end

  def has_winner? : Bool
    unless check_battle_status
      return true
    end

    player_one_lost = true
    begin
      if @player_one.player.olympiad_game_id == @stadium_id
        player_one_lost = @player_one.player.dead?
      end
    rescue e
      player_one_lost = true
    end

    player_two_lost = true
    begin
      if @player_two.player.olympiad_game_id == @stadium_id
        player_two_lost = @player_two.player.dead?
      end
    rescue e
      player_two_lost = true
    end

    player_one_lost || player_two_lost
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

    p1_crash = @player_one.player?.nil? || @player_one.disconnected?
    p2_crash = @player_two.player?.nil? || @player_two.disconnected?

    p1_points = @player_one.stats.get_i32(POINTS)
    p2_points = @player_two.stats.get_i32(POINTS)
    point_diff = Math.min(p1_points, p2_points) / divider
    if point_diff <= 0
      point_diff = 1
    elsif point_diff > Config.alt_oly_max_points
      point_diff = Config.alt_oly_max_points
    end

    # Check for if a player defaulted before battle started
    if @player_one.defaulted? || @player_two.defaulted?
      begin
        if @player_one.defaulted?
          begin
            points = Math.min(p1_points / 3, Config.alt_oly_max_points)
            remove_points_from_participant(@player_one, points)
            list1 << OlympiadInfo.new(@player_one.name, @player_one.clan_name, @player_one.clan_id, @player_one.base_class, @damage_p1, p1_points - points, -points)

            winside = 2

            if Config.alt_oly_log_fights
              warn "TODO: log fight."
              # LogRecord record = new LogRecord(Level.INFO, @player_one.name + " default")
              # record.setParameters(new Object[]
              #   @player_one.name,
              #   @player_two.name,
              #   0,
              #   0,
              #   0,
              #   0,
              #   points,
              #   type.to_s
              # })
              # _logResults.log(record)
            end
          rescue e
            error e
          end
        end

        if @player_two.defaulted?
          begin
            points = Math.min(p2_points / 3, Config.alt_oly_max_points)
            remove_points_from_participant(@player_two, points)
            list2 << OlympiadInfo.new(@player_two.name, @player_two.clan_name, @player_two.clan_id, @player_two.base_class, @damage_p2, p2_points - points, -points)

            if winside == 2
              tie = true
            else
              winside = 1
            end

            if Config.alt_oly_log_fights
              warn "TODO: log fight."
              # LogRecord record = new LogRecord(Level.INFO, @player_two.name + " default")
              # record.setParameters(new Object[]
              #   @player_one.name,
              #   @player_two.name,
              #   0,
              #   0,
              #   0,
              #   0,
              #   points,
              #   type.to_s
              # })
              # _logResults.log(record)
            end
          rescue e
            error e
          end
        end
        if winside == 1
          result = ExOlympiadMatchResult.new(tie, winside, list1, list2)
        else
          result = ExOlympiadMatchResult.new(tie, winside, list2, list1)
        end
        stadium.broadcast_packet(result)
        return
      rescue e
        error e
        return
      end
    end

    # Create results for players if a player crashed
    if p1_crash || p2_crash
      begin
        if p2_crash && !p1_crash
          sm = SystemMessage.c1_has_won_the_game
          sm.add_string(@player_one.name)
          stadium.broadcast_packet(sm)

          @player_one.update_stat(COMP_WON, 1)
          add_points_to_participant(@player_one, point_diff)
          list1 << OlympiadInfo.new(@player_one.name, @player_one.clan_name, @player_one.clan_id, @player_one.base_class, @damage_p1, p1_points + point_diff, point_diff)

          @player_two.update_stat(COMP_LOST, 1)
          remove_points_from_participant(@player_two, point_diff)
          list2 << OlympiadInfo.new(@player_two.name, @player_two.clan_name, @player_two.clan_id, @player_two.base_class, @damage_p2, p2_points - point_diff, -point_diff)

          winside = 1

          reward_participant(@player_one.player, reward)

          if Config.alt_oly_log_fights
            warn "TODO: log fights"
            # LogRecord record = new LogRecord(Level.INFO, @player_two.name + " crash")
            # record.setParameters(new Object[]
            #   @player_one.name,
            #   @player_two.name,
            #   0,
            #   0,
            #   0,
            #   0,
            #   point_diff,
            #   type.to_s
            # })
            # _logResults.log(record)
          end

          # Notify to scripts
          OnOlympiadMatchResult.new(@player_one, @player_two, type).async(Olympiad.instance)
        elsif p1_crash && !p2_crash
          sm = SystemMessage.c1_has_won_the_game
          sm.add_string(@player_two.name)
          stadium.broadcast_packet(sm)

          @player_two.update_stat(COMP_WON, 1)
          add_points_to_participant(@player_two, point_diff)
          list2 << OlympiadInfo.new(@player_two.name, @player_two.clan_name, @player_two.clan_id, @player_two.base_class, @damage_p2, p2_points + point_diff, point_diff)

          @player_one.update_stat(COMP_LOST, 1)
          remove_points_from_participant(@player_one, point_diff)
          list1 << OlympiadInfo.new(@player_one.name, @player_one.clan_name, @player_one.clan_id, @player_one.base_class, @damage_p1, p1_points - point_diff, -point_diff)

          winside = 2

          reward_participant(@player_two.player, reward)

          if Config.alt_oly_log_fights
            warn "TODO: log fight."
            # LogRecord record = new LogRecord(Level.INFO, @player_one.name + " crash")
            # record.setParameters(new Object[]
            #   @player_one.name,
            #   @player_two.name,
            #   0,
            #   0,
            #   0,
            #   0,
            #   point_diff,
            #   type.to_s
            # })
            # _logResults.log(record)
          end
          # Notify to scripts
          OnOlympiadMatchResult.new(@player_two, @player_one, type).async(Olympiad.instance)
        elsif p1_crash && p2_crash
          stadium.broadcast_packet(SystemMessage.the_game_ended_in_a_tie)

          @player_one.update_stat(COMP_LOST, 1)
          remove_points_from_participant(@player_one, point_diff)
          list1 << OlympiadInfo.new(@player_one.name, @player_one.clan_name, @player_one.clan_id, @player_one.base_class, @damage_p1, p1_points - point_diff, -point_diff)

          @player_two.update_stat(COMP_LOST, 1)
          remove_points_from_participant(@player_two, point_diff)
          list2 << OlympiadInfo.new(@player_two.name, @player_two.clan_name, @player_two.clan_id, @player_two.base_class, @damage_p2, p2_points - point_diff, -point_diff)

          tie = true

          if Config.alt_oly_log_fights
            warn "TODO: log fight."
            # LogRecord record = new LogRecord(Level.INFO, "both crash")
            # record.setParameters(new Object[]
            #   @player_one.name,
            #   @player_two.name,
            #   0,
            #   0,
            #   0,
            #   0,
            #   point_diff,
            #   type.to_s
            # })
            # _logResults.log(record)
          end
        end

        @player_one.update_stat(COMP_DONE, 1)
        @player_two.update_stat(COMP_DONE, 1)
        @player_one.update_stat(COMP_DONE_WEEK, 1)
        @player_two.update_stat(COMP_DONE_WEEK, 1)
        @player_one.update_stat(weekly_match_type, 1)
        @player_two.update_stat(weekly_match_type, 1)

        if winside == 1
          result = ExOlympiadMatchResult.new(tie, winside, list1, list2)
        else
          result = ExOlympiadMatchResult.new(tie, winside, list2, list1)
        end
        stadium.broadcast_packet(result)

        # Notify to scripts
        OnOlympiadMatchResult.new(nil, @player_one, type).async(Olympiad.instance)
        OnOlympiadMatchResult.new(nil, @player_two, type).async(Olympiad.instance)
        return
      rescue e
        error e
        return
      end
    end

    begin
      winner = "draw"

      # Calculate Fight time
      fight_time = Time.ms - @start_time

      p1_hp = 0.0
      if @player_one.player? && !@player_one.player.dead?
        p1_hp = @player_one.player.current_hp + @player_one.player.current_cp
        if p1_hp < 0.5
          p1_hp = 0
        end
      end

      p2_hp = 0.0
      if @player_two.player? && !@player_two.player.dead?
        p2_hp = @player_two.player.current_hp + @player_two.player.current_cp
        if p2_hp < 0.5
          p2_hp = 0
        end
      end

      # if players crashed, search if they've relogged
      @player_one.update_player
      @player_two.update_player

      if (@player_one.player?.nil? || !@player_one.player.online?) && (@player_two.player?.nil? || !@player_two.player.online?)
        @player_one.update_stat(COMP_DRAWN, 1)
        @player_two.update_stat(COMP_DRAWN, 1)
        sm = SystemMessage.the_game_ended_in_a_tie
        stadium.broadcast_packet(sm)
      elsif @player_two.player?.nil? || !@player_two.player.online? || (p2_hp == 0 && p1_hp != 0) || (@damage_p1 > @damage_p2 && p2_hp != 0 && p1_hp != 0)
        sm = SystemMessage.c1_has_won_the_game
        sm.add_string(@player_one.name)
        stadium.broadcast_packet(sm)

        @player_one.update_stat(COMP_WON, 1)
        @player_two.update_stat(COMP_LOST, 1)

        add_points_to_participant(@player_one, point_diff)
        list1 << OlympiadInfo.new(@player_one.name, @player_one.clan_name, @player_one.clan_id, @player_one.base_class, @damage_p1, p1_points + point_diff, point_diff)

        remove_points_from_participant(@player_two, point_diff)
        list2 << OlympiadInfo.new(@player_two.name, @player_two.clan_name, @player_two.clan_id, @player_two.base_class, @damage_p2, p2_points - point_diff, -point_diff)
        winner = @player_one.name + " won"

        winside = 1

        # Save Fight Result
        save_results(@player_one, @player_two, 1, @start_time, fight_time, type)
        reward_participant(@player_one.player, reward)

        # Notify to scripts
        OnOlympiadMatchResult.new(@player_one, @player_two, type).async(Olympiad.instance)
      elsif @player_one.player?.nil? || !@player_one.player.online? || (p1_hp == 0 && p2_hp != 0) || (@damage_p2 > @damage_p1 && p1_hp != 0 && p2_hp != 0)
        sm = SystemMessage.c1_has_won_the_game
        sm.add_string(@player_two.name)
        stadium.broadcast_packet(sm)

        @player_two.update_stat(COMP_WON, 1)
        @player_one.update_stat(COMP_LOST, 1)

        add_points_to_participant(@player_two, point_diff)
        list2 << OlympiadInfo.new(@player_two.name, @player_two.clan_name, @player_two.clan_id, @player_two.base_class, @damage_p2, p2_points + point_diff, point_diff)

        remove_points_from_participant(@player_one, point_diff)
        list1 << OlympiadInfo.new(@player_one.name, @player_one.clan_name, @player_one.clan_id, @player_one.base_class, @damage_p1, p1_points - point_diff, -point_diff)

        winner = @player_two.name + " won"
        winside = 2

        # Save Fight Result
        save_results(@player_one, @player_two, 2, @start_time, fight_time, type)
        reward_participant(@player_two.player, reward)

        # Notify to scripts
        OnOlympiadMatchResult.new(@player_two, @player_one, type).async(Olympiad.instance)
      else
        # Save Fight Result
        save_results(@player_one, @player_two, 0, @start_time, fight_time, type)

        sm = SystemMessage.the_game_ended_in_a_tie
        stadium.broadcast_packet(sm)

        value = Math.min(p1_points / divider, Config.alt_oly_max_points)

        remove_points_from_participant(@player_one, value)
        list1 << OlympiadInfo.new(@player_one.name, @player_one.clan_name, @player_one.clan_id, @player_one.base_class, @damage_p1, p1_points - value, -value)

        value = Math.min(p2_points / divider, Config.alt_oly_max_points)
        remove_points_from_participant(@player_two, value)
        list2 << OlympiadInfo.new(@player_two.name, @player_two.clan_name, @player_two.clan_id, @player_two.base_class, @damage_p2, p2_points - value, -value)

        tie = true
      end

      @player_one.update_stat(COMP_DONE, 1)
      @player_two.update_stat(COMP_DONE, 1)
      @player_one.update_stat(COMP_DONE_WEEK, 1)
      @player_two.update_stat(COMP_DONE_WEEK, 1)
      @player_one.update_stat(weekly_match_type, 1)
      @player_two.update_stat(weekly_match_type, 1)

      if winside == 1
        result = ExOlympiadMatchResult.new(tie, winside, list1, list2)
      else
        result = ExOlympiadMatchResult.new(tie, winside, list2, list1)
      end
      stadium.broadcast_packet(result)

      if Config.alt_oly_log_fights
        warn "TODO: log fight."
        # LogRecord record = new LogRecord(Level.INFO, winner)
        # record.setParameters(new Object[]
        #   @player_one.name,
        #   @player_two.name,
        #   p1_hp,
        #   p2_hp,
        #   @damage_p1,
        #   @damage_p2,
        #   point_diff,
        #   type.to_s
        # })
        # _logResults.log(record)
      end
    rescue e
      error e
    end
  end

  def add_damage(player, damage : Int32)
    if @player_one.player?.nil? || @player_two.player?.nil?
      return
    end

    if player == @player_one.player
      @damage_p1 += damage
    elsif player == @player_two.player
      @damage_p2 += damage
    end
  end

  def player_names
    {@player_one.name, @player_two.name}
  end

  def check_defaulted : Bool
    @player_one.update_player
    @player_two.update_player

    if reason = check_defaulted(@player_one.player?)
      @player_one.defaulted = true
      if @player_two.player?
        @player_two.player.send_packet(reason)
      end
    end

    if reason = check_defaulted(@player_two.player?)
      @player_two.defaulted = true
      if @player_one.player?
        @player_one.player.send_packet(reason)
      end
    end

    @player_one.defaulted? || @player_two.defaulted?
  end

  def reset_damage
    @damage_p1 = 0
    @damage_p2 = 0
  end

  private def save_results(one : Participant, two : Participant, winner : Int32, start_time : Int64, fight_time : Int64, type : CompetitionType)
    sql = "INSERT INTO olympiad_fights (charOneId, charTwoId, charOneClass, charTwoClass, winner, start, time, classed) values(?,?,?,?,?,?,?,?)"
    GameDB.exec(
      sql,
      one.l2id,
      two.l2id,
      one.base_class,
      two.base_class,
      winner,
      start_time,
      fight_time,
      type.classed? ? 1 : 0
    )
  rescue e
    error e
  end
end
