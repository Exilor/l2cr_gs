class L2ClanMember
  include Loggable

  @level : Int32
  @title : String
  @power_grade : Int32
  @name : String
  @l2id : Int32
  @class_id : Int32
  @pledge_type : Int32
  @sex : Bool
  @race_ordinal : Int32
  getter clan
  getter! player_instance : L2PcInstance?

  def initialize(@clan : L2Clan, pc : L2PcInstance)
    @clan = clan
    @level = pc.level
    @title = pc.title
    @power_grade = pc.power_grade

    @name = pc.name
    @l2id = pc.l2id
    @class_id = pc.class_id.to_i
    @pledge_type = pc.pledge_type
    @apprentice = 0
    @sponsor = 0
    @sex = pc.appearance.sex
    @race_ordinal = pc.race.to_i
    @player_instance = pc
  end

  def initialize(@clan : L2Clan, rs)
    @name = rs.get_string("char_name")
    @level = rs.get_i32("level")
    @class_id = rs.get_i32("classid")
    @l2id = rs.get_i32("charId")
    @pledge_type = rs.get_i32("subpledge")
    @title = rs.get_string("title")
    @power_grade = rs.get_i32("power_grade")
    @apprentice = rs.get_i32("apprentice")
    @sponsor = rs.get_i32("sponsor")
    @sex = rs.get_i32("sex") != 0
    @race_ordinal = rs.get_i32("race")
  end

  def player_instance=(player : L2PcInstance?)
    pc = @player_instance
    if player.nil? && pc
      @name = pc.name
      @level = pc.level
      @class_id = pc.class_id.to_i
      @l2id = pc.l2id
      @power_grade = pc.power_grade
      @pledge_type = pc.pledge_type
      @title = pc.title
      @apprentice = pc.apprentice
      @sponsor = pc.sponsor
      @sex = pc.appearance.sex
      @race_ordinal = pc.race.to_i
    end

    if player
      @clan.add_skill_effects(player)
      if @clan.level > 3 && player.clan_leader?
        SiegeManager.add_siege_skills(player)
      end
      if player.clan_leader?
        @clan.leader = self
      end
    end

    @player_instance = player
  end

  def online? : Bool
    return false unless (pc = @player_instance) && pc.online?
    return false if pc.in_offline_mode?
    true
  end

  def class_id
    @player_instance.try &.class_id.to_i || @class_id
  end

  def level
    @player_instance.try &.level || @level
  end

  def name
    @player_instance.try &.name || @name
  end

  def l2id
    @player_instance.try &.l2id || @l2id
  end

  def title
    @player_instance.try &.title || @title
  end

  def pledge_type
    @player_instance.try &.pledge_type || @pledge_type
  end

  def pledge_type=(type : Int32)
    @pledge_type = type

    if @player_instance
      @player_instance.pledge_type = type
    else
      update_pledge_type
    end
  end

  def update_pledge_type
    sql = "UPDATE characters SET subpledge=? WHERE charId=?"
    GameDB.exec(sql, @pledge_type, l2id)
  rescue e
    error e
  end

  def power_grade
    @player_instance.try &.power_grade || @power_grade
  end

  def power_grade=(grade : Int32)
    @power_grade = grade
    if pc = @player_instance
      pc.power_grade = grade
    else
      update_power_grade
    end
  end

  def update_power_grade
    sql = "UPDATE characters SET power_grade=? WHERE charId=?"
    GameDB.exec(sql, @power_grade, l2id)
  rescue e
    error e
  end

  def set_apprentice_and_sponsor(@apprentice : Int32, @sponsor : Int32)
  end

  def race_ordinal
    @player_instance.try &.race.to_i || @race_ordinal
  end

  def sex
    @player_instance.try &.appearance.sex || @sex
  end

  def sponsor
    @player_instance.try &.sponsor || @sponsor
  end

  def apprentice
    @player_instance.try &.apprentice || @apprentice
  end

  def apprentice_or_sponsor_name : String
    if pc = @player_instance
      @apprentice = pc.apprentice
      @sponsor = pc.sponsor
    end

    if @apprentice != 0
      return @clan.get_clan_member(@apprentice).try &.name || "Error"
    end

    if @sponsor != 0
      return @clan.get_clan_member(@sponsor).try &.name || "Error"
    end

    ""
  end

  def calculate_pledge_class(pc : L2PcInstance?) : Int32
    L2ClanMember.calculate_pledge_class(pc)
  end

  def self.calculate_pledge_class(pc : L2PcInstance?) : Int32
    return 0 unless pc
    pledge_class = 0
    if clan = pc.clan?
      case clan.level
      when 4
        pledge_class = 3 if pc.clan_leader?
      when 5
        pledge_class = pc.clan_leader? ? 4 : 2
      when 6
        case pc.pledge_type
        when -1
          pledge_class = 1
        when 100, 200
          pledge_class = 2
        when 0
          if pc.clan_leader?
            pledge_class = 5
          else
            case clan.get_leader_subpledge(pc.l2id)
            when 100, 200
              pledge_class = 4
            # when 1
            else
              pledge_class = 3
            end
          end
        end
      when 7
        case pc.pledge_type
        when -1
          pledge_class = 1
        when 100, 200
          pledge_class = 3
        when 1001, 1002, 2001, 2002
          pledge_class = 2
        when 0
          if pc.clan_leader?
            pledge_class = 7
          else
            case clan.get_leader_subpledge(pc.l2id)
            when 100, 200
              pledge_class = 6
            when 1001, 1002, 2001, 2002
              pledge_class = 5
            # when -1
            else
              pledge_class = 4
            end
          end
        end
      when 8
        case pc.pledge_type
        when -1
          pledge_class = 1
        when 100, 200
          pledge_class = 4
        when 1001, 1002, 2001, 2002
          pledge_class = 3
        when 0
          if pc.clan_leader?
            pledge_class = 8
          else
            case clan.get_leader_subpledge(pc.l2id)
            when 100, 200
              pledge_class = 7
            when 1001, 1002, 2001, 2002
              pledge_class = 6
            # when -1
            else
              pledge_class = 5
            end
          end
        end
      when 9
        case pc.pledge_type
        when -1
          pledge_class = 1
        when 100, 200
          pledge_class = 5
        when 1001, 1002, 2001, 2002
          pledge_class = 4
        when 0
          if pc.clan_leader?
            pledge_class = 9
          else
            case clan.get_leader_subpledge(pc.l2id)
            when 100, 200
              pledge_class = 8
            when 1001, 1002, 2001, 2002
              pledge_class = 7
            # when -1
            else
              pledge_class = 6
            end
          end
        end
      when 10
        case pc.pledge_type
        when -1
          pledge_class = 1
        when 100, 200
          pledge_class = 6
        when 1001, 1002, 2001, 2002
          pledge_class = 5
        when 0
          if pc.clan_leader?
            pledge_class = 10
          else
            case clan.get_leader_subpledge(pc.l2id)
            when 100, 200
              pledge_class = 9
            when 1001, 1002, 2001, 2002
              pledge_class = 8
            # when -1
            else
              pledge_class = 7
            end
          end
        end
      when 11
        case pc.pledge_type
        when -1
          pledge_class = 1
        when 100, 200
          pledge_class = 7
        when 1001, 1002, 2001, 2002
          pledge_class = 6
        when 0
          if pc.clan_leader?
            pledge_class = 11
          else
            case clan.get_leader_subpledge(pc.l2id)
            when 100, 200
              pledge_class = 10
            when 1001, 1002, 2001, 2002
              pledge_class = 9
            # when -1
            else
              pledge_class = 8
            end
          end
        end
      else
        pledge_class = 1
      end
    end

    if pc.noble? && pledge_class < 5
      pledge_class = 5
    end

    if pc.hero? && pledge_class < 8
      pledge_class = 8
    end

    pledge_class
  end

  def save_apprentice_and_sponsor(apprentice : Int32, sponsor : Int32)
    GameDB.exec(
      "UPDATE characters SET apprentice=?,sponsor=? WHERE charId=?",
      apprentice,
      sponsor,
      l2id
    )
  rescue e
    error e
  end
end
