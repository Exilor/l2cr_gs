require "./item_containers/clan_warehouse"
require "./l2_clan_member"
require "../community_bbs/forum"

class L2Clan
  # include Identifiable
  # include Namable
  include Synchronizable
  # include Enumerable
  include Loggable
  include Packets::Outgoing

  private INSERT_CLAN_DATA = "INSERT INTO clan_data (clan_id,clan_name,clan_level,hasCastle,blood_alliance_count,blood_oath_count,ally_id,ally_name,leader_id,crest_id,crest_large_id,ally_crest_id,new_leader_id) values (?,?,?,?,?,?,?,?,?,?,?,?,?)"
  private SELECT_CLAN_DATA = "SELECT * FROM clan_data where clan_id=?"

  # Ally Penalty Types
  # Clan leaved ally
  PENALTY_TYPE_CLAN_LEAVED = 1
  # Clan was dismissed from ally
  PENALTY_TYPE_CLAN_DISMISSED = 2
  # Leader clan dismiss clan from ally
  PENALTY_TYPE_DISMISS_CLAN = 3
  # Leader clan dissolve ally
  PENALTY_TYPE_DISSOLVE_ALLY = 4
  # Sub-unit types
  # Clan subunit type of Academy
  SUBUNIT_ACADEMY = -1
  # Clan subunit type of Royal Guard A
  SUBUNIT_ROYAL1 = 100
  # Clan subunit type of Royal Guard B
  SUBUNIT_ROYAL2 = 200
  # Clan subunit type of Order of Knights A-1
  SUBUNIT_KNIGHT1 = 1001
  # Clan subunit type of Order of Knights A-2
  SUBUNIT_KNIGHT2 = 1002
  # Clan subunit type of Order of Knights B-1
  SUBUNIT_KNIGHT3 = 2001
  # Clan subunit type of Order of Knights B-2
  SUBUNIT_KNIGHT4 = 2002

  MAX_NOTICE_LENGTH = 8192

  @members = Hash(Int32, L2ClanMember).new
  @at_war_with = Set(Int32).new
  @at_war_attackers = Set(Int32).new
  @privs = Hash(Int32, RankPrivs).new
  @subpledges = Hash(Int32, Subpledge).new
  @notice : String?
  @siege_kills = Atomic(Int32).new(0)
  @siege_deaths = Atomic(Int32).new(0)
  @forum : Forum?
  getter level = 0
  getter blood_alliance_count = 0
  getter blood_oath_count = 0
  getter skills = Hash(Int32, Skill).new
  getter subpledge_skills = Hash(Int32, Skill).new
  getter(warehouse) { ClanWarehouse.new(self) }
  getter hired_guards = 0
  getter reputation_score = 0
  getter auction_bidded_at = 0
  getter ally_penalty_expiry_time = 0i64
  getter ally_penalty_type = 0
  getter new_leader_id = 0
  getter! leader : L2ClanMember
  getter? notice_enabled = false
  setter clan_id : Int32
  property name : String = ""
  property ally_crest_id : Int32 = 0
  property crest_id : Int32 = 0
  property crest_large_id : Int32 = 0
  property ally_id : Int32 = 0
  property ally_name : String?
  property castle_id : Int32 = 0
  property fort_id : Int32 = 0
  property hideout_id : Int32 = 0
  property rank : Int32 = 0
  property char_penalty_expiry_time : Int64 = 0i64
  property dissolving_expiry_time : Int64 = 0i64

  def initialize(@clan_id : Int32)
    initialize_privs
    restore
    warehouse.restore
  end

  def initialize(@clan_id : Int32, @name : String)
    initialize_privs
  end

  def members
    @members.local_each_value
  end

  def each(&block : L2ClanMember ->) : Nil
    @members.each_value { |m| yield m }
  end

  def each_player(&block : L2PcInstance ->) : Nil
    @members.each_value { |m| yield m.player_instance if m.player_instance? }
  end

  def each_online_player(&block : L2PcInstance ->) : Nil
    each_player { |pc| yield pc if pc.online? }
  end

  def id : Int32
    @clan_id
  end

  def leader_id : Int32
    @leader.try &.l2id || 0
  end

  def leader=(@leader : L2ClanMember)
    @members[leader.l2id] = leader
  end

  def set_new_leader(member : L2ClanMember)
    new_leader = member.player_instance?
    ex_member = leader
    ex_leader = ex_member.player_instance?

    OnPlayerClanLeaderChange.new(ex_member, member, self).async

    if ex_leader
      if ex_leader.flying?
        ex_leader.dismount
      end
      if level >= SiegeManager.siege_clan_min_level
        SiegeManager.remove_siege_skills(ex_leader)
      end
      ex_leader.clan_privileges.clear
      ex_leader.broadcast_user_info
    else
      sql = "UPDATE characters SET clan_privs = ? WHERE charId = ?"
      GameDB.exec(sql, 0, leader_id)
    end

    self.leader = member

    if new_leader_id != 0
      set_new_leader_id(0, true)
    end

    update_clan_in_db

    if ex_leader
      ex_leader.pledge_class = L2ClanMember.calculate_pledge_class(ex_leader)
      ex_leader.broadcast_user_info
      ex_leader.check_item_restriction
    else
      sql = "UPDATE characters SET clan_privs = ? WHERE charId = ?"
      GameDB.exec(sql, ClanPrivilege.mask, leader_id)
    end

    broadcast_clan_status

    sm = SystemMessage.clan_leader_privileges_have_been_transferred_to_c1
    sm.add_char_name(member.name)
    broadcast_to_online_members(sm)
  end

  def leader_name : String
    leader.name
  end

  def add_clan_member(member : L2ClanMember)
    @members[member.l2id] = member
  end

  def add_clan_member(member : L2PcInstance)
    m = L2ClanMember.new(self, member)
    m.player_instance = member
    @members[m.l2id] = m
    member.clan = self
    member.pledge_class = L2ClanMember.calculate_pledge_class(member)
    member.send_packet(PledgeShowMemberListUpdate.new(member))
    member.send_packet(PledgeSkillList.new(self))

    add_skill_effects(member)

    OnPlayerClanJoin.new(member, self).async
  end

  def update_clan_member(pc : L2PcInstance)
    member = L2ClanMember.new(pc.clan, pc)
    if pc.clan_leader?
      self.leader = member
    end
    add_clan_member(member)
  end

  def get_clan_member(id : Int32) : L2ClanMember?
    @members[id]?
  end

  def get_clan_member(name : String) : L2ClanMember?
    @members.find_value { |m| m.name == name}
  end

  def remove_clan_member(l2id : Int32, clan_join_expiry_time : Int64)
    unless ex_member = @members.delete(l2id)
      warn "Member with ID #{l2id} not found in the clan."
      return
    end

    leads_subpledge = get_leader_subpledge(l2id)
    if leads_subpledge != 0
      get_subpledge(leads_subpledge).not_nil!.leader_id = 0
      update_subpledge_in_db(leads_subpledge)
    end

    if ex_member.apprentice != 0
      if apprentice = get_clan_member(ex_member.apprentice)
        if apprentice.player_instance
          apprentice.player_instance.sponsor = 0
        else
          apprentice.set_apprentice_and_sponsor(0, 0)
        end
        apprentice.save_apprentice_and_sponsor(0, 0)
      end
    end

    ex_member.save_apprentice_and_sponsor(0, 0)

    if Config.remove_castle_circlets
      CastleManager.remove_circlet(ex_member, castle_id)
    end

    if pc = ex_member.player_instance?
      unless pc.noble?
        pc.title = ""
      end
      pc.apprentice = 0
      pc.sponsor = 0

      if pc.clan_leader?
        SiegeManager.remove_siege_skills(pc)
        pc.clan_create_expiry_time = Time.ms + Time.days_to_ms(Config.alt_clan_create_days)
      end

      remove_skill_effects(pc)

      if pc.clan.castle_id > 0
        CastleManager.get_castle_by_owner!(pc.clan).remove_residential_skills(pc)
      end

      if pc.clan.fort_id > 0
        FortManager.get_fort_by_owner!(pc.clan).remove_residential_skills(pc)
      end

      pc.send_skill_list
      pc.clan = nil

      if ex_member.pledge_type != 1
        pc.clan_join_expiry_time = clan_join_expiry_time
      end

      pc.pledge_class = L2ClanMember.calculate_pledge_class(pc)
      pc.broadcast_user_info
      pc.send_packet(PledgeShowMemberListDeleteAll::STATIC_PACKET)
    else
      if leader_id == l2id
        time = Time.ms + Time.days_to_ms(Config.alt_clan_create_days)
      else
        time = 0
      end
      remove_member_in_database(ex_member.l2id, clan_join_expiry_time, time)
    end

    OnPlayerClanLeft.new(ex_member, self).async
  end

  def members_count : Int32
    @members.size
  end

  def get_subpledge_members_count(subpl : Int32) : Int32
    @members.count { |_, m| m.pledge_type == subpl }
  end

  def get_max_nr_of_members(pledge_type : Int32) : Int32
    case pledge_type
    when 0
      case level
      when 3 then 30
      when 2 then 29
      when 1 then 15
      when 0 then 10
      else 40
      end
    when -1
      20
    when 100, 200
      case level
      when 11 then 30
      else 20
      end
    when 1001, 1002, 2001, 2002
      case level
      when 9..11 then 25
      else 10
      end
    else 0
    end
  end

  def get_online_members(exclude : Int32, &block : L2PcInstance ->)
    @members.each_value { |m| yield m.player_instance if m.online? && m.l2id != exclude }
  end

  def get_online_members(exclude : Int32)
    @members.local_each_value.select { |m| m.online? && m.l2id != exclude }.map &.player_instance
  end

  def online_members_count : Int32
    @members.count { |_, m| m.online? }
  end

  def level=(@level : Int32)
    if level >= 2 && @forum && Config.enable_community_board
      if forum = ForumsBBSManager.get_forum_by_name("ClanRoot")
        unless @forum = forum.get_child_by_name(@name)
          @forum = ForumsBBSManager.create_new_forum(
            @name,
            ForumsBBSManager.get_forum_by_name("ClanRoot").not_nil!,
            Forum::CLAN,
            Forum::CLANMEMBERONLY,
            id
          )
        end
      end
    end
  end

  def member?(id : Int32) : Bool
    id != 0 && @members.has_key?(id)
  end

  def increase_blood_alliance_count
    @blood_alliance_count += SiegeManager.blood_alliance_reward
    update_blood_alliance_count_in_db
  end

  def reset_blood_alliance_count
    @blood_alliance_count = 0
    update_blood_alliance_count_in_db
  end

  def update_blood_alliance_count_in_db
    sql = "UPDATE clan_data SET blood_alliance_count=? WHERE clan_id=?"
    GameDB.exec(sql, blood_alliance_count, id)
  rescue e
    error e
  end

  def increase_blood_oath_count
    @blood_oath_count += Config.fs_blood_oath_count
    update_blood_oath_count_in_db
  end

  def reset_blood_oath_count
    @blood_oath_count = 0
    update_blood_oath_count_in_db
  end

  def update_blood_oath_count_in_db
    sql = "UPDATE clan_data SET blood_oath_count=? WHERE clan_id=?"
    GameDB.exec(sql, blood_oath_count, id)
  rescue e
    error e
  end

  def update_clan_score_in_db
    sql = "UPDATE clan_data SET reputation_score=? WHERE clan_id=?"
    GameDB.exec(sql, reputation_score, id)
  rescue e
    error e
  end

  def update_clan_in_db
    sql = "UPDATE clan_data SET leader_id=?,ally_id=?,ally_name=?,reputation_score=?,ally_penalty_expiry_time=?,ally_penalty_type=?,char_penalty_expiry_time=?,dissolving_expiry_time=?,new_leader_id=? WHERE clan_id=?"
    GameDB.exec(
      sql,
      leader_id,
      ally_id,
      ally_name,
      reputation_score,
      ally_penalty_expiry_time,
      ally_penalty_type,
      char_penalty_expiry_time,
      dissolving_expiry_time,
      new_leader_id,
      id
    )
  rescue e
    error e
  end

  def store
    GameDB.exec(
      INSERT_CLAN_DATA,
      id,
      name,
      level,
      castle_id,
      blood_alliance_count,
      blood_oath_count,
      ally_id,
      ally_name,
      leader_id,
      crest_id,
      crest_large_id,
      ally_crest_id,
      new_leader_id
    )
  rescue e
    error e
  end

  def remove_member_in_database(pc_id, clan_join_expiry_time, clan_create_expiry_time)
    sql1 = "UPDATE characters SET clanid=0, title=?, clan_join_expiry_time=?, clan_create_expiry_time=?, clan_privs=0, wantspeace=0, subpledge=0, lvl_joined_academy=0, apprentice=0, sponsor=0 WHERE charId=?"
    sql2 = "UPDATE characters SET apprentice=0 WHERE apprentice=?"
    sql3 = "UPDATE characters SET sponsor=0 WHERE sponsor=?"

    begin
      GameDB.exec(sql1, "", clan_join_expiry_time, clan_create_expiry_time, pc_id)
    rescue e
      error e
    end

    begin
      GameDB.exec(sql2, pc_id)
    rescue e
      error e
    end

    begin
      GameDB.exec(sql3, pc_id)
    rescue e
      error e
    end
  end

  def restore
    GameDB.each(SELECT_CLAN_DATA, id) do |rs|
      self.name = rs.get_string("clan_name")
      self.level = rs.get_i32("clan_level")
      self.castle_id = rs.get_i32("hasCastle")
      @blood_alliance_count = rs.get_i32("blood_alliance_count")
      @blood_oath_count = rs.get_i32("blood_oath_count")
      self.ally_id = rs.get_i32("ally_id")
      self.ally_name = rs.get_string?("ally_name")
      set_ally_penalty_expiry_time(
        rs.get_i64("ally_penalty_expiry_time"),
        rs.get_i32("ally_penalty_type")
      )
      if ally_penalty_expiry_time < Time.ms
        set_ally_penalty_expiry_time(0, 0)
      end
      self.char_penalty_expiry_time = rs.get_i64("char_penalty_expiry_time")
      if char_penalty_expiry_time + (Config.alt_clan_join_days * 86400000) < Time.ms
        self.char_penalty_expiry_time = 0
      end
      self.dissolving_expiry_time = rs.get_i64("dissolving_expiry_time")

      self.crest_id = rs.get_i32("crest_id")
      self.crest_large_id = rs.get_i32("crest_large_id")
      self.ally_crest_id = rs.get_i32("ally_crest_id")

      set_reputation_score(rs.get_i32("reputation_score"), false)
      set_auction_bidded_at(rs.get_i32("auction_bid_at"), false)
      set_new_leader_id(rs.get_i32("new_leader_id"), false)

      leader_id = rs.get_i32("leader_id")

      sql = "SELECT char_name,level,classid,charId,title,power_grade,subpledge,apprentice,sponsor,sex,race FROM characters WHERE clanid=?"
      GameDB.each(sql, id) do |rs2|
        member = L2ClanMember.new(self, rs2)
        if member.l2id == leader_id
          self.leader = member
        else
          add_clan_member(member)
        end
      end
    end

    restore_subpledges
    restore_rank_privs
    restore_skills
    restore_notice
  end

  private def restore_notice
    sql = "SELECT enabled,notice FROM clan_notices WHERE clan_id=?"
    GameDB.each(sql, id) do |rs|
      @notice_enabled = rs.get_bool("enabled")
      @notice = rs.get_string("notice")
    end
  end

  private def store_notice(notice : String?, enabled : Bool)
    if notice.nil?
      notice = ""
    elsif notice.size > MAX_NOTICE_LENGTH
      notice = notice.to(MAX_NOTICE_LENGTH)
    end

    sql = "INSERT INTO clan_notices (clan_id,notice,enabled) values (?,?,?) ON DUPLICATE KEY UPDATE notice=?,enabled=?"
    GameDB.exec(sql, id, notice, enabled.to_s, notice, enabled.to_s)
    @notice = notice
    @notice_enabled = enabled
  rescue e
    error e
  end

  def notice_enabled=(bool : Bool)
    store_notice(@notice, bool)
  end

  def notice=(notice : String)
    store_notice(notice, @notice_enabled)
  end

  def notice
    @notice || ""
  end

  def restore_skills
    sql = "SELECT skill_id,skill_level,sub_pledge_id FROM clan_skills WHERE clan_id=?"
    GameDB.each(sql, id) do |rs|
      id = rs.get_i32("skill_id")
      level = rs.get_i32("skill_level")
      skill = SkillData[id, level]
      sub_type = rs.get_i32("sub_pledge_id")
      if sub_type == -1
        @skills[skill.id] = skill
      elsif sub_type == 0
        @subpledge_skills[skill.id] = skill
      else
        if subunit = @subpledges[sub_type]?
          subunit.add_new_skill(skill)
        else
          warn "Missing subpledge #{sub_type}."
        end
      end
    end
  rescue e
    error e
  end

  def all_skills
    @skills.local_each_value
  end

  def add_skill(new_skill : Skill?) : Skill?
    if new_skill
      old_skill = @skills[new_skill.id]?
      @skills[new_skill.id] = new_skill
    end

    old_skill
  end

  def add_new_skill(new_skill : Skill?) : Skill?
    add_new_skill(new_skill, -2)
  end

  def add_new_skill(new_skill : Skill?, subtype : Int32) : Skill?
    old_skill = nil

    if new_skill
      if subtype == -2
        old_skill = @skills[new_skill.id]?
        @skills[new_skill.id] = new_skill
      elsif subtype == 0
        old_skill = @subpledge_skills[new_skill.id]?
        @subpledge_skills[new_skill.id] = new_skill
      else
        if subunit = get_subpledge(subtype)
          old_skill = subunit.add_new_skill(new_skill)
        else
          warn "Subpledge #{subtype} does not exist for this clan."
          return old_skill
        end
      end

      begin
        if old_skill
          sql = "UPDATE clan_skills SET skill_level=? WHERE skill_id=? AND clan_id=?"
          GameDB.exec(sql, new_skill.level, old_skill.id, id)
        else
          sql = "INSERT INTO clan_skills (clan_id,skill_id,skill_level,skill_name,sub_pledge_id) VALUES (?,?,?,?,?)"
          GameDB.exec(
            sql,
            id,
            new_skill.id,
            new_skill.level,
            new_skill.name,
            subtype
          )
        end
      rescue e
        error e
      end

      sm = SystemMessage.clan_skill_s1_added
      sm.add_skill_name(new_skill.id)

      @members.each_value do |m|
        if (pc = m.player_instance?) && pc.online?
          if subtype == -2
            if new_skill.min_pledge_class <= pc.pledge_class
              pc.add_skill(new_skill, false)
              pc.send_packet(PledgeSkillListAdd.new(new_skill.id, new_skill.level))
              pc.send_packet(sm)
              pc.send_skill_list
            end
          else
            if m.pledge_type == subtype
              pc.add_skill(new_skill, false)
              pc.send_packet(ExSubPledgeSkillAdd.new(subtype, new_skill.id, new_skill.level))
              pc.send_packet(sm)
              pc.send_skill_list
            end
          end
        end
      end
    end

    old_skill
  end

  def add_skill_effects
    @skills.each_value do |skill|
      each_online_player do |pc|
        if skill.min_pledge_class <= pc.pledge_class
          pc.add_skill(skill, false)
        end
      end
    end
  end

  def add_skill_effects(pc : L2PcInstance?)
    return unless pc
    @skills.each_value do |skill|
      if skill.min_pledge_class <= pc.pledge_class
        pc.add_skill(skill, false)
      end
    end
    if pc.pledge_type == 0
      @subpledge_skills.each_value do |skill|
        pc.add_skill(skill, false)
      end
    else
      return unless subunit = get_subpledge(pc.pledge_type)
      subunit.skills.each do |skill|
        pc.add_skill(skill, false)
      end
    end

    if @reputation_score < 0
      skills_status(pc, true)
    end
  end

  def remove_skill_effects(pc : L2PcInstance?)
    return unless pc

    @skills.each_value do |skill|
      if skill.min_pledge_class <= pc.pledge_class
        pc.remove_skill(skill, false)
      end
    end
    if pc.pledge_type == 0
      @subpledge_skills.each_value do |skill|
        pc.remove_skill(skill, false)
      end
    else
      return unless subunit = get_subpledge(pc.pledge_type)
      subunit.skills.each do |skill|
        pc.remove_skill(skill, false)
      end
    end
  end

  def skills_status(pc : L2PcInstance?, disable : Bool)
    return unless pc

    @skills.each_value do |skill|
      if disable
        pc.disable_skill(skill, -1)
      else
        pc.enable_skill(skill)
      end
    end

    if pc.pledge_type == 0
      @subpledge_skills.each_value do |skill|
        if disable
          pc.disable_skill(skill, -1)
        else
          pc.enable_skill(skill)
        end
      end
    else
      return unless subunit = get_subpledge(pc.pledge_type)
      subunit.skills.each do |skill|
        if disable
          pc.disable_skill(skill, -1)
        else
          pc.enable_skill(skill)
        end
      end
    end
  end

  def broadcast_to_online_ally_members(packet : GameServerPacket)
    ClanTable.get_clan_allies(ally_id) do |clan|
      clan.broadcast_to_online_members(packet)
    end
  end

  def broadcast_to_online_members(packet : GameServerPacket)
    each_online_player &.send_packet(packet)
  end

  def broadcast_cs_to_online_members(packet : CreatureSay, sender : L2PcInstance)
    each_online_player do |pc|
      unless BlockList.blocked?(pc, sender)
        pc.send_packet(packet)
      end
    end
  end

  def broadcast_to_other_online_members(packet, pc : L2PcInstance)
    each_online_player do |pc2|
      unless pc == pc2
        pc2.send_packet(packet)
      end
    end
  end

  def at_war_with?(clan : self) : Bool
    at_war_with?(clan.id)
  end

  def at_war_with?(id) : Bool
    @at_war_with.includes?(id)
  end

  def at_war_attacker?(clan : self) : Bool
    at_war_attacker?(clan.id)
  end

  def at_war_attacker?(id) : Bool
    @at_war_attackers.includes?(id)
  end

  def enemy_clan=(clan : self)
    self.enemy_clan = clan.id
  end

  def enemy_clan=(id : Int32)
    @at_war_with << id
  end

  def attacker_clan=(clan : self)
    self.attacker_clan = clan.id
  end

  def attacker_clan=(id : Int32)
    @at_war_attackers << id
  end

  def delete_enemy_clan(clan : self)
    @at_war_with.delete(clan.id)
  end

  def delete_attacker_clan(clan : self)
    @at_war_attackers.delete(clan.id)
  end

  def increment_hired_guards
    @hired_guards += 1
  end

  def at_war? : Bool
    !@at_war_with.empty?
  end

  def war_list : Set(Int32)
    @at_war_with
  end

  def attacker_list : Set(Int32)
    @at_war_attackers
  end

  def broadcast_clan_status
    get_online_members(0) do |pc|
      pc.send_packet(PledgeShowMemberListDeleteAll::STATIC_PACKET)
      pc.send_packet(PledgeShowMemberListAll.new(self, pc))
    end
  end

  class Subpledge
    getter_initializer id: Int32, name: String, leader_id: Int32
    property name : String
    property leader_id : Int32
    property! clan : L2Clan # necessary because no inner classes

    def add_new_skill(skill : Skill)
      clan.subpledge_skills[skill.id] = skill
    end

    def skills
      clan.subpledge_skills.local_each_value
    end

    def get_skill(id : Int32) : Skill?
      clan.subpledge_skills[id]?
    end
  end

  class RankPrivs
    getter rank, party
    getter privs : EnumBitmask(ClanPrivilege)

    getter_initializer rank: Int32, party: Int32, privs: EnumBitmask(ClanPrivilege)

    def initialize(@rank : Int32, @party : Int32, privs : Int32)
      @privs = EnumBitmask(ClanPrivilege).new(privs)
    end

    def privs=(privs : Int32)
      @privs.bitmask = privs
    end
  end

  private def restore_subpledges
    sql = "SELECT sub_pledge_id,name,leader_id FROM clan_subpledges WHERE clan_id=?"
    GameDB.each(sql, id) do |rs|
      id = rs.get_i32("sub_pledge_id")
      name = rs.get_string("name")
      leader_id = rs.get_i32("leader_id")
      pledge = Subpledge.new(id, name, leader_id)
      @subpledges[id] = pledge
    end
  rescue e
    error e
  end

  def get_subpledge(type : Int32) : Subpledge?
    @subpledges[type]?
  end

  def get_subpledge(name : String) : Subpledge?
    @subpledges.find_value { |sp| sp.name.casecmp?(name) }
  end

  def all_subpledges
    @subpledges.local_each_value
  end

  def create_subpledge(pc : L2PcInstance, pledge_type : Int32, leader_id : Int32, name : String) : Subpledge?
    pledge_type = get_available_pledge_types(pledge_type)
    if pledge_type == 0
      if pledge_type == L2Clan::SUBUNIT_ACADEMY
        pc.send_packet(SystemMessageId::CLAN_HAS_ALREADY_ESTABLISHED_A_CLAN_ACADEMY)
      else
        pc.send_message("You can't create any more sub-units of this type")
      end
      return
    end

    if @leader.l2id == leader_id
      pc.send_message("Leader is not correct")
      return
    end

    if pledge_type != -1 && (((reputation_score < Config.royal_guard_cost) && (pledge_type < L2Clan::SUBUNIT_KNIGHT1)) || ((reputation_score < Config.knight_unit_cost) && (pledge_type > L2Clan::SUBUNIT_ROYAL2)))
      pc.send_packet(SystemMessageId::THE_CLAN_REPUTATION_SCORE_IS_TOO_LOW)
      return
    end

    sql = "INSERT INTO clan_subpledges (clan_id,sub_pledge_id,name,leader_id) values (?,?,?,?)"
    begin
      GameDB.exec(
        sql,
        id,
        pledge_type,
        name,
        pledge_type != -1 ? leader_id : 0
      )
    rescue e
      error e
    end

    subpledge = Subpledge.new(pledge_type, name, leader_id)
    subpledge.clan = self
    @subpledges[pledge_type] = subpledges

    if pledge_type != -1
      if pledge_type < L2Clan::SUBUNIT_KNIGHT1
        set_reputation_score reputation_score - Config.royal_guard_cost, true
      else
        set_reputation_score reputation_score - Config.knight_unit_cost, true
      end
    end

    broadcast_to_online_members(PledgeShowInfoUpdate.new(@leader.clan))
    broadcast_to_online_members(PledgeReceiveSubPledgeCreated.new(subpledge, @leader.clan))

    subpledge
  end

  def get_available_pledge_types(pledge_type : Int32) : Int32
    if @subpledges[pledge_type]?
      case pledge_type
      when SUBUNIT_ACADEMY, SUBUNIT_ROYAL2, SUBUNIT_KNIGHT4
        return 0
      when SUBUNIT_ROYAL1
        pledge_type = get_available_pledge_types(SUBUNIT_ROYAL2)
      when SUBUNIT_KNIGHT1
        pledge_type = get_available_pledge_types(SUBUNIT_KNIGHT2)
      when SUBUNIT_KNIGHT2
        pledge_type = get_available_pledge_types(SUBUNIT_KNIGHT3)
      when SUBUNIT_KNIGHT3
        pledge_type = get_available_pledge_types(SUBUNIT_KNIGHT4)
      end
    end

    pledge_type
  end

  def update_subpledge_in_db(pledge_type)
    sql = "UPDATE clan_subpledges SET leader_id=?, name=? WHERE clan_id=? AND sub_pledge_id=?"
    GameDB.exec(
      sql,
      get_subpledge(pledge_type).not_nil!.leader_id,
      get_subpledge(pledge_type).not_nil!.name,
      id,
      pledge_type
    )
  rescue e
    error e
  end

  private def restore_rank_privs
    sql = "SELECT privs,rank,party FROM clan_privs WHERE clan_id=?"
    GameDB.each(sql, id) do |rs|
      rank = rs.get_i32("rank")
      privileges = rs.get_i32("privs")
      next if rank == -1
      @privs[rank].privs = privileges
    end
  rescue e
    error e
  end

  def initialize_privs
    (1...10).each do |i|
      @privs[i] = RankPrivs.new(i, 0, EnumBitmask(ClanPrivilege).new(false))
    end
  end

  def get_rank_privs(rank : Int32) : EnumBitmask(ClanPrivilege)
    @privs[rank]?.try &.privs || EnumBitmask(ClanPrivilege).new(false)
  end

  def set_rank_privs(rank : Int32, privs : Int32)
    if pr = @privs[rank]?
      priv.privs = pr
      begin
        sql = "INSERT INTO clan_privs (clan_id,rank,party,privs) VALUES (?,?,?,?) ON DUPLICATE KEY UPDATE privs = ?"
        GameDB.exec(
          sql,
          id,
          rank,
          0,
          privs,
          privs
        )
      rescue e
        error e
      end

      each do |cm|
        if cm.online? && cm.power_grade == rank && cm.player_instance?
          cm.player_instance.clan_privileges.bitmask = privs
          cm.player_instance.send_packet(UserInfo.new(cm.player_instance))
          cm.player_instance.send_packet(ExBrExtraUserInfo.new(cm.player_instance))
        end
      end
      broadcast_clan_status
    else
      @privs[rank] = RankPrivs.new(rank, 0, privs)
      begin
        sql = "INSERT INTO clan_privs (clan_id,rank,party,privs) VALUES (?,?,?,?)"
        GameDB.exec(
          sql,
          id,
          rank,
          0,
          privs
        )
      rescue e
        error e
      end
    end
  end

  def all_rank_privs
    @privs.local_each_value || Slice(RankPrivs).empty
  end

  def get_leader_subpledge(leader_id : Int32) : Int32
    id = 0
    @subpledges.each_value do |sp|
      if sp.leader_id == 0
        next
      end
      if sp.leader_id == leader_id
        id = sp.id
      end
    end
    id
  end

  def add_reputation_score(value : Int32, save : Bool)
    sync { set_reputation_score(reputation_score + value, save) }
  end

  def take_reputation_score(value : Int32, save : Bool)
    sync { set_reputation_score(reputation_score - value, save) }
  end

  private def set_reputation_score(value : Int32, save : Bool)
    if @reputation_score >= 0 && value < 0
      broadcast_to_online_members(SystemMessage.reputation_points_0_or_lower_clan_skills_deactivated)
      each_online_player do |pc|
        skills_status(pc, true)
      end
    elsif @reputation_score < 0 && value >= 0
      broadcast_to_online_members(SystemMessage.clan_skills_will_be_activated_since_reputation_is_0_or_higher)
      each_online_player do |pc|
        skills_status(pc, false)
      end
    end

    @reputation_score = value.clamp(-100000000, 100000000)
    broadcast_to_online_members(PledgeShowInfoUpdate.new(self))
    update_clan_in_db if save
  end

  def set_auction_bidded_at(id : Int32, store_in_db : Bool)
    @auction_bidded_at = id
    if store_in_db
      sql = "UPDATE clan_data SET auction_bid_at=? WHERE clan_id=?"
      GameDB.exec(
        sql,
        id,
        id()
      )
    end
  rescue e
    error e
  end

  def check_clan_join_condition(pc : L2PcInstance?, target : L2PcInstance?, pledge_type : Int32) : Bool
    return false unless pc

    unless pc.has_clan_privilege?(ClanPrivilege::CL_JOIN_CLAN)
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
      return false
    end

    unless target
      pc.send_packet(SystemMessageId::YOU_HAVE_INVITED_THE_WRONG_TARGET)
      return false
    end

    if pc == target
      pc.send_packet(SystemMessageId::CANNOT_INVITE_YOURSELF)
      return false
    end

    if char_penalty_expiry_time > Time.ms
      pc.send_packet(SystemMessageId::YOU_MUST_WAIT_BEFORE_ACCEPTING_A_NEW_MEMBER)
      return false
    end

    if target.clan_id != 0
      sm = SystemMessage.s1_working_with_another_clan
      sm.add_string(target.name)
      pc.send_packet(sm)
      return false
    end

    if target.clan_join_expiry_time > Time.ms
      sm = SystemMessage.c1_must_wait_before_joining_another_clan
      sm.add_string(target.name)
      pc.send_packet(sm)
      return false
    end

    if (target.level > 40 || target.class_id.level >= 2) && pledge_type == -1
      sm = SystemMessage.s1_doesnot_meet_requirements_to_join_academy
      sm.add_string(target.name)
      pc.send_packet(sm)
      pc.send_packet(SystemMessageId::ACADEMY_REQUIREMENTS)
      return false
    end

    if get_subpledge_members_count(pledge_type) >= get_max_nr_of_members(pledge_type)
      if pledge_type == 0
        sm = SystemMessage.s1_clan_is_full
        sm.add_string(name)
        pc.send_packet(sm)
      else
        pc.send_packet(SystemMessageId::SUBCLAN_IS_FULL)
      end

      return false
    end

    true
  end

  def check_ally_join_condition(pc : L2PcInstance?, target : L2PcInstance?) : Bool
    return false unless pc

    if pc.ally_id == 0 || !pc.clan_leader? || pc.clan_id != pc.ally_id
      pc.send_packet(SystemMessageId::FEATURE_ONLY_FOR_ALLIANCE_LEADER)
      return false
    end

    leader_clan = pc.clan

    if leader_clan.ally_penalty_expiry_time > Time.ms
      if leader_clan.ally_penalty_type == PENALTY_TYPE_DISMISS_CLAN
        pc.send_packet(SystemMessageId::CANT_INVITE_CLAN_WITHIN_1_DAY)
        return false
      end
    end

    unless target
      pc.send_packet(SystemMessageId::YOU_HAVE_INVITED_THE_WRONG_TARGET)
      return false
    end

    if pc == target
      pc.send_packet(SystemMessageId::CANNOT_INVITE_YOURSELF)
      return false
    end

    unless target.clan
      pc.send_packet(SystemMessageId::TARGET_MUST_BE_IN_CLAN)
      return false
    end

    unless target.clan_leader?
      sm = SystemMessage.s1_is_not_a_clan_leader
      sm.add_string(target.name)
      pc.send_packet(sm)
      return false
    end

    target_clan = target.clan

    if target.ally_id != 0
      sm = SystemMessage.s1_clan_already_member_of_s2_alliance
      sm.add_string(target_clan.name)
      sm.add_string(target_clan.ally_name.not_nil!)
      pc.send_packet(sm)
      return false
    end

    if target_clan.ally_penalty_expiry_time > Time.ms
      if target_clan.ally_penalty_type == PENALTY_TYPE_CLAN_LEAVED
        sm = SystemMessage.s1_cant_enter_alliance_within_1_day
        sm.add_string(target_clan.name)
        sm.add_string(target_clan.ally_name.not_nil!)
        pc.send_packet(sm)
        return false
      end

      if target_clan.ally_penalty_type == PENALTY_TYPE_CLAN_DISMISSED
        pc.send_packet(SystemMessageId::CANT_ENTER_ALLIANCE_WITHIN_1_DAY)
        return false
      end
    end

    if pc.inside_siege_zone? && target.inside_siege_zone?
      pc.send_packet(SystemMessageId::OPPOSING_CLAN_IS_PARTICIPATING_IN_SIEGE)
      return false
    end

    if leader_clan.at_war_with?(target_clan.id)
      pc.send_packet(SystemMessageId::MAY_NOT_ALLY_CLAN_BATTLE)
      return false
    end

    if ClanTable.get_clan_allies(pc.ally_id).size >= Config.alt_max_num_of_clans_in_ally
      pc.send_packet(SystemMessageId::YOU_HAVE_EXCEEDED_THE_LIMIT)
      return false
    end

    true
  end

  def set_ally_penalty_expiry_time(time : Int64, type : Int32)
    @ally_penalty_expiry_time = time
    @ally_penalty_type = type
  end

  def create_ally(pc : L2PcInstance?, name : String)
    return unless pc

    unless pc.clan_leader?
      pc.send_packet(SystemMessageId::ONLY_CLAN_LEADER_CREATE_ALLIANCE)
      return
    end

    if ally_id != 0
      pc.send_packet(SystemMessageId::ALREADY_JOINED_ALLIANCE)
      return
    end

    if level < 5
      pc.send_packet(SystemMessageId::TO_CREATE_AN_ALLY_YOU_CLAN_MUST_BE_LEVEL_5_OR_HIGHER)
      return
    end

    if ally_penalty_expiry_time > Time.ms
      if ally_penalty_type == L2Clan::PENALTY_TYPE_DISSOLVE_ALLY
        pc.send_packet(SystemMessageId::CANT_CREATE_ALLIANCE_10_DAYS_DISOLUTION)
        return
      end
    end

    if dissolving_expiry_time > Time.ms
      pc.send_packet(SystemMessageId::YOU_MAY_NOT_CREATE_ALLY_WHILE_DISSOLVING)
      return
    end

    unless name.alnum?
      pc.send_packet(SystemMessageId::INCORRECT_ALLIANCE_NAME)
      return
    end

    if name.size > 16 || name.size < 2
      pc.send_packet(SystemMessageId::INCORRECT_ALLIANCE_NAME_LENGTH)
      return
    end

    if ClanTable.ally_exists?(name)
      pc.send_packet(SystemMessageId::ALLIANCE_ALREADY_EXISTS)
      return
    end

    self.ally_id = id
    self.ally_name = name.strip
    set_ally_penalty_expiry_time(0, 0)
    update_clan_in_db

    pc.send_packet(UserInfo.new(pc))
    pc.send_packet(ExBrExtraUserInfo.new(pc))

    pc.send_message("Alliance #{name} has been created.")
  end

  def dissolve_ally(pc : L2PcInstance)
    if ally_id == 0
      pc.send_packet(SystemMessageId::NO_CURRENT_ALLIANCES)
      return
    end

    if !pc.clan_leader? || id != ally_id
      pc.send_packet(SystemMessageId::FEATURE_ONLY_FOR_ALLIANCE_LEADER)
      return
    end

    if pc.inside_siege_zone?
      pc.send_packet(SystemMessageId::CANNOT_DISSOLVE_ALLY_WHILE_IN_SIEGE)
      return
    end

    broadcast_to_online_ally_members(SystemMessage.alliance_disolved)

    time = Time.ms
    ClanTable.get_clan_allies(ally_id).each do |clan|
      if clan.id != id
        clan.ally_id = 0
        clan.ally_name = nil
        clan.set_ally_penalty_expiry_time(0, 0)
        clan.update_clan_in_db
      end
    end

    self.ally_id = 0
    self.ally_name = nil
    change_ally_crest 0, false
    set_ally_penalty_expiry_time time + (Config.alt_create_ally_days_when_dissolved * 86400000), L2Clan::PENALTY_TYPE_DISSOLVE_ALLY
    update_clan_in_db
  end

  def level_up_clan(pc : L2PcInstance) : Bool
    unless pc.clan_leader?
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
      return false
    end

    if Time.ms < dissolving_expiry_time
      pc.send_packet(SystemMessageId::CANNOT_RISE_LEVEL_WHILE_DISSOLUTION_IN_PROGRESS)
      return false
    end

    case level
    when 0
      if pc.sp >= 20000 && pc.adena >= 650000
        if pc.reduce_adena("ClanLvl", 650000, pc.target, true)
          pc.sp -= 20000
          sm = SystemMessage.sp_decreased_s1
          sm.add_int(20000)
          pc.send_packet(sm)
          increase_clan_level = true
        end
      end
    when 1
      if pc.sp >= 100000 && pc.adena >= 2500000
        if pc.reduce_adena("ClanLvl", 2500000, pc.target, true)
          pc.sp -= 100000
          sm = SystemMessage.sp_decreased_s1
          sm.add_int(100000)
          pc.send_packet(sm)
          increase_clan_level = true
        end
      end
    when 2
      if pc.sp >= 350000 && pc.inventory.get_item_by_item_id(1419)
        if pc.destroy_item_by_item_id("ClanLvl", 1419, 1, pc.target, false)
          pc.sp -= 350000
          sm = SystemMessage.sp_decreased_s1
          sm.add_int(350000)
          pc.send_packet(sm)
          sm = SystemMessage.s1_disappeared
          sm.add_item_name(1419)
          pc.send_packet(sm)
          increase_clan_level = true
        end
      end
    when 3
      if pc.sp >= 1000000 && pc.inventory.get_item_by_item_id(3874)
        if pc.destroy_item_by_item_id("ClanLvl", 3874, 1, pc.target, false)
          pc.sp -= 1000000
          sm = SystemMessage.sp_decreased_s1
          sm.add_int(1000000)
          pc.send_packet(sm)
          sm = SystemMessage.s1_disappeared
          sm.add_item_name(3874)
          pc.send_packet(sm)
          increase_clan_level = true
        end
      end
    when 4
      if pc.sp >= 2500000 && pc.inventory.get_item_by_item_id(3870)
        if pc.destroy_item_by_item_id("ClanLvl", 3870, 1, pc.target, false)
          pc.sp -= 2500000
          sm = SystemMessage.sp_decreased_s1
          sm.add_int(2500000)
          pc.send_packet(sm)
          sm = SystemMessage.s1_disappeared
          sm.add_item_name(3870)
          pc.send_packet(sm)
          increase_clan_level = true
        end
      end
    when 5
      if reputation_score >= Config.clan_level_6_cost && members_count >= Config.clan_level_6_requirement
        set_reputation_score(reputation_score - Config.clan_level_6_cost, true)
        sm = SystemMessage.s1_deducted_from_clan_rep
        sm.add_int(Config.clan_level_6_cost)
        pc.send_packet(sm)
        increase_clan_level = true
      end
    when 6
      if reputation_score >= Config.clan_level_7_cost && members_count >= Config.clan_level_7_requirement
        set_reputation_score(reputation_score - Config.clan_level_7_cost, true)
        sm = SystemMessage.s1_deducted_from_clan_rep
        sm.add_int(Config.clan_level_7_cost)
        pc.send_packet(sm)
        increase_clan_level = true
      end
    when 7
      if reputation_score >= Config.clan_level_8_cost && members_count >= Config.clan_level_8_requirement
        set_reputation_score(reputation_score - Config.clan_level_8_cost, true)
        sm = SystemMessage.s1_deducted_from_clan_rep
        sm.add_int(Config.clan_level_8_cost)
        pc.send_packet(sm)
        increase_clan_level = true
      end
    when 8
      if reputation_score >= Config.clan_level_9_cost && pc.inventory.get_item_by_item_id(9910) && members_count >= Config.clan_level_9_requirement
        if pc.destroy_item_by_item_id("ClanLvl", 9910, 150, pc.target, false)
          set_reputation_score(reputation_score - Config.clan_level_9_cost, true)
          sm = SystemMessage.s1_deducted_from_clan_rep
          sm.add_int(Config.clan_level_9_cost)
          pc.send_packet(sm)
          sm = SystemMessage.s2_s1_disappeared
          sm.add_item_name(9910)
          sm.add_long(150)
          pc.send_packet(sm)
          increase_clan_level = true
        end
      end
    when 9
      if reputation_score >= Config.clan_level_10_cost && pc.inventory.get_item_by_item_id(9910) && members_count >= Config.clan_level_10_requirement
        if pc.destroy_item_by_item_id("ClanLvl", 9911, 5, pc.target, false)
          set_reputation_score(reputation_score - Config.clan_level_10_cost, true)
          sm = SystemMessage.s1_deducted_from_clan_rep
          sm.add_int(Config.clan_level_10_cost)
          pc.send_packet(sm)
          sm = SystemMessage.s2_s1_disappeared
          sm.add_item_name(9911)
          sm.add_long(5)
          pc.send_packet(sm)
          increase_clan_level = true
        end
      end
    when 10
      territories = TerritoryWarManager.territories
      has_territory = territories.any? { |t| t.owner_clan.id == id }
      if has_territory && reputation_score >= Config.clan_level_11_cost && members_count >= Config.clan_level_11_requirement
        set_reputation_score(reputation_score - Config.clan_level_11_cost, true)
        sm = SystemMessage.s1_deducted_from_clan_rep
        sm.add_int(Config.clan_level_11_cost)
        pc.send_packet(sm)
        increase_clan_level = true
      end
    else
      return false
    end

    unless increase_clan_level
      pc.send_packet(SystemMessageId::FAILED_TO_INCREASE_CLAN_LEVEL)
      return false
    end

    pc.send_packet(StatusUpdate.sp(pc))
    pc.send_packet(ItemList.new(pc, false))
    change_level(level + 1)
    OnPlayerClanLvlUp.new(self).async

    true
  end

  def change_level(level : Int32)
    begin
      sql = "UPDATE clan_data SET clan_level = ? WHERE clan_id = ?"
      GameDB.exec(
        sql,
        level,
        id
      )
    rescue e
      error e
    end
    self.level = level

    if leader().online?
      leader = leader().player_instance
      if level > 4
        SiegeManager.add_siege_skills(leader)
        leader.send_packet(SystemMessageId::CLAN_CAN_ACCUMULATE_CLAN_REPUTATION_POINTS)
      elsif level < 5
        SiegeManager.remove_siege_skills(leader)
      end
    end

    broadcast_to_online_members(SystemMessage.clan_level_increased)
    broadcast_to_online_members(PledgeShowInfoUpdate.new(self))
  end

  def change_clan_crest(crest_id : Int32)
    if crest_id() != 0
      CrestTable.remove_crest(crest_id())
    end

    self.crest_id = crest_id

    begin
      sql = "UPDATE clan_data SET crest_id = ? WHERE clan_id = ?"
      GameDB.exec(sql, crest_id, id)
    rescue e
      error e
    end
    get_online_members(0, &.broadcast_user_info)
  end

  def change_ally_crest(crest_id : Int32, only_this_clan : Bool)
    sql = "UPDATE clan_data SET ally_crest_id = ? WHERE clan_id = ?"
    ally_id = id
    unless only_this_clan
      if ally_crest_id != 0
        CrestTable.remove_crest(ally_crest_id)
      end
      sql = "UPDATE clan_data SET ally_crest_id = ? WHERE ally_id = ?"
      ally_id = ally_id()

      begin
        GameDB.exec(sql, crest_id, ally_id)
      rescue e
        error e
      end
    end

    if only_this_clan
      self.ally_crest_id = crest_id
      get_online_members(0, &.broadcast_user_info)
    else
      ClanTable.get_clan_allies(ally_id()).each do |clan|
        clan.ally_crest_id = crest_id
        clan.get_online_members(0, &.broadcast_user_info)
      end
    end
  end

  def change_large_crest(id : Int32)
    if crest_large_id != 0
      CrestTable.remove_crest(crest_large_id)
    end

    self.crest_large_id = id
    begin
      sql = "UPDATE clan_data SET crest_large_id = ? WHERE clan_id = ?"
      GameDB.exec(sql, id, id())
    rescue e
      error e
    end

    each_online_player &.broadcast_user_info
  end

  def learnable_sub_skill?(id : Int32, lvl : Int32) : Bool
    current = @subpledge_skills[id]?

    if current && current.level + 1 == lvl
      return true
    end

    if current.nil? && lvl == 1
      return true
    end

    @subpledges.each_value do |subunit|
      next if subunit.id == -1
      current = subunit.get_skill(id)
      if current && current.level + 1 == lvl
        return true
      end
      if current.nil? && lvl == 1
        return true
      end
    end

    false
  end

  def learnable_subpledge_skill?(skill : Skill, subtype : Int32) : Bool
    return false if subtype == -1

    id = skill.id

    if subtype == 0
      current = @subpledge_skills[id]?
    else
      current = @subpledges[subtype].get_skill(id)
    end

    if current && current.level + 1 == skill.level
      return true
    end

    if current.nil? && skill.level == 1
      return true
    end

    false
  end

  def all_sub_skills : Array(PledgeSkillList::SubpledgeSkill)
    list = Array(PledgeSkillList::SubpledgeSkill).new(@subpledge_skills.size + @subpledges.size)
    @subpledge_skills.each_value do |skill|
      list << PledgeSkillList::SubpledgeSkill.new(0, skill.id, skill.level)
    end
    @subpledges.each_value do |subunit|
      subunit.skills.each do |skill|
        list << PledgeSkillList::SubpledgeSkill.new(subunit.id, skill.id, skill.level)
      end
    end
    list
  end

  def set_new_leader_id(l2id : Int32, store_in_db : Bool)
    @new_leader_id = l2id
    update_clan_in_db if store_in_db
  end

  def new_leader : L2PcInstance?
    L2World.get_player(@new_leader_id)
  end

  def new_leader_name : String?
    CharNameTable.get_name_by_id(@new_leader_id)
  end

  def siege_kills : Int32
    @siege_kills.get
  end

  def siege_deaths : Int32
    @siege_deaths.get
  end

  def add_siege_kill
    @siege_kills.add(1)
  end

  def add_siege_death
    @siege_deaths.add(1)
  end

  def clear_siege_kills
    @siege_kills.set(0)
  end

  def clear_siege_deaths
    @siege_deaths.set(0)
  end
end
