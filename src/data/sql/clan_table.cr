require "../../models/l2_clan"
require "../../community_bbs/manager/forums_bbs_manager"

module ClanTable
  extend self
  extend Synchronizable
  extend Loggable
  include Packets::Outgoing

  CLAN_NAME_MAX_LENGTH = 16
  private CLANS = Concurrent::Map(Int32, L2Clan).new

  def load
    if Config.enable_community_board
      ForumsBBSManager.init_root
    end

    clan_count = 0

    GameDB.each("SELECT clan_id FROM clan_data") do |rs|
      clan_id = rs.get_i32(:"clan_id")
      CLANS[clan_id] = L2Clan.new(clan_id)
      clan = get_clan(clan_id).not_nil!
      if clan.dissolving_expiry_time != 0
        schedule_remove_clan(clan.id)
      end
      clan_count &+= 1
    end

    info { "Loaded #{clan_count} clans." }

    alliance_check
    restore_wars
  end

  def clans : Enumerable(L2Clan)
    CLANS.local_each_value
  end

  def clan_count : Int32
    CLANS.size
  end

  def create_clan(pc : L2PcInstance, clan_name : String) : L2Clan?
    return unless pc

    debug { "#{pc.name} (#{pc.l2id}) requested a clan creation." }

    if pc.level < 10
      pc.send_packet(SystemMessageId::YOU_DO_NOT_MEET_CRITERIA_IN_ORDER_TO_CREATE_A_CLAN)
      return
    end

    if pc.clan_id != 0
      pc.send_packet(SystemMessageId::FAILED_TO_CREATE_CLAN)
      return
    end

    if Time.ms < pc.clan_create_expiry_time
      pc.send_packet(SystemMessageId::YOU_MUST_WAIT_XX_DAYS_BEFORE_CREATING_A_NEW_CLAN)
      return
    end

    if !clan_name.alnum? || clan_name.size < 2
      pc.send_packet(SystemMessageId::CLAN_NAME_INCORRECT)
      return
    end

    if clan_name.size > 16
      pc.send_packet(SystemMessageId::CLAN_NAME_TOO_LONG)
      return
    end

    if get_clan_by_name(clan_name)
      sm = SystemMessage.s1_already_exists
      sm.add_string(clan_name)
      pc.send_packet(sm)
      return
    end

    clan = L2Clan.new(IdFactory.next, clan_name)
    leader = L2ClanMember.new(clan, pc)
    clan.leader = leader
    leader.player_instance = pc
    clan.store
    pc.clan = clan
    pc.pledge_class = L2ClanMember.calculate_pledge_class(pc)
    pc.clan_privileges = EnumBitmask(ClanPrivilege).new(true)

    CLANS[clan.id] = clan

    pc.send_packet(PledgeShowInfoUpdate.new(clan))
    pc.send_packet(PledgeShowMemberListAll.new(clan, pc))
    pc.send_packet(UserInfo.new(pc))
    pc.send_packet(ExBrExtraUserInfo.new(pc))
    pc.send_packet(PledgeShowMemberListUpdate.new(pc))
    pc.send_packet(SystemMessageId::CLAN_CREATED)

    OnPlayerClanCreate.new(pc, clan).async

    clan
  end

  def destroy_clan(clan_id : Int32)
    sync do
      unless clan = get_clan(clan_id)
        return
      end

      clan.broadcast_to_online_members(SystemMessage.clan_has_dispersed)

      castle_id = clan.castle_id
      if castle_id == 0
        SiegeManager.sieges.each &.remove_siege_clan(clan)
      end

      fort_id = clan.fort_id
      if fort_id == 0
        FortSiegeManager.sieges.each &.remove_attacker(clan)
      end

      hall_id = clan.hideout_id
      if hall_id == 0
        ClanHallSiegeManager.conquerable_halls.each_value &.remove_attacker(clan)
      end

      if auction = AuctionManager.get_auction(clan.auction_bidded_at)
        auction.cancel_bid(clan_id)
      end

      if leader_member = clan.leader?
        clan.warehouse.destroy_all_items("ClanRemove", clan.leader.player_instance, nil)
      else
        clan.warehouse.destroy_all_items("ClanRemove", nil, nil)
      end

      clan.members.safe_each { |m| clan.remove_clan_member(m.l2id, 0) }

      CLANS.delete(clan_id)

      IdFactory.release(clan_id)

      GameDB.transaction do |tr|
        begin
          tr.exec("DELETE FROM character_contacts WHERE charId=? OR contactId=?", clan_id, clan_id)
        rescue e
          error e
        end

        begin
          tr.exec("DELETE FROM clan_data WHERE clan_id=?", clan_id)
        rescue e
          error e
        end

        begin
          tr.exec("DELETE FROM clan_privs WHERE clan_id=?", clan_id)
        rescue e
          error e
        end

        begin
          tr.exec("DELETE FROM clan_skills WHERE clan_id=?", clan_id)
        rescue e
          error e
        end

        begin
          tr.exec("DELETE FROM clan_subpledges WHERE clan_id=?", clan_id)
        rescue e
          error e
        end

        begin
          tr.exec("DELETE FROM clan_wars WHERE clan1=? OR clan2=?", clan_id, clan_id)
        rescue e
          error e
        end

        begin
          tr.exec("DELETE FROM clan_notices WHERE clan_id=?", clan_id)
        rescue e
          error e
        end

        if castle_id != 0
          begin
            tr.exec("UPDATE castle SET taxPercent = 0 WHERE id = ?", clan_id)
          rescue e
            error e
          end
        end

        if fort_id != 0
          if fort = FortManager.get_fort_by_id(fort_id)
            owner = fort.owner_clan?
            if clan == owner
              fort.remove_owner(true)
            end
          end
        end

        if hall_id != 0
          hall = ClanHallSiegeManager.get_siegable_hall(hall_id)
          if hall && hall.owner_id == clan_id
            hall.free
          end
        end
      end

      OnPlayerClanDestroy.new(leader_member, clan)
    end
  end

  def get_clan(clan_id : Int) : L2Clan?
    CLANS[clan_id]?
  end

  def get_clan_by_name(name : String) : L2Clan?
    CLANS.find_value &.name.casecmp?(name)
  end

  def get_clan_allies(ally_id : Int32, & : L2Clan ->)
    if ally_id != 0
      CLANS.each_value do |clan|
        if clan.ally_id == ally_id
          yield clan
        end
      end
    end
  end

  def get_clan_allies(ally_id : Int32) : Array(L2Clan)
    ret = [] of L2Clan

    get_clan_allies(ally_id) do |clan|
      ret << clan
    end

    ret
  end

  def store_clan_score
    CLANS.each_value &.update_clan_score_in_db
  end

  def check_surrender(clan1 : L2Clan, clan2 : L2Clan)
    count = 0
    clan.each_player do |pc|
      if pc.wants_peace == 1
        count &+= 1
      end
    end

    if count == clan1.size - 1
      clan1.delete_enemy_clan(clan2)
      clan2.delete_enemy_clan(clan1)
      delete_clan_war(clan1.id, clan2.id)
    end
  end

  def delete_clan_war(clan_id1 : Int32, clan_id2 : Int32)
    clan1 = get_clan(clan_id1).not_nil!
    clan2 = get_clan(clan_id2).not_nil!

    OnClanWarFinish.new(clan1, clan2)

    clan1.delete_enemy_clan(clan2)
    clan2.delete_attacker_clan(clan1)
    clan1.broadcast_clan_status
    clan2.broadcast_clan_status

    begin
      sql = "DELETE FROM clan_wars WHERE clan1=? AND clan2=?"
      GameDB.exec(sql, clan_id1, clan_id2)
    rescue e
      error e
    end

    sm = SystemMessage.war_against_s1_has_stopped
    sm.add_string(clan2.name)
    clan1.broadcast_to_online_members(sm)
    sm = SystemMessage.clan_s1_has_decided_to_stop
    sm.add_string(clan1.name)
    clan2.broadcast_to_online_members(sm)
  end

  def store_clan_war(clan_id1 : Int32, clan_id2 : Int32)
    clan1 = get_clan(clan_id1).not_nil!
    clan2 = get_clan(clan_id2).not_nil!

    OnClanWarStart.new(clan1, clan2)

    clan1.enemy_clan = clan2
    clan2.attacker_clan = clan1
    clan1.broadcast_clan_status
    clan2.broadcast_clan_status

    begin
      sql = "REPLACE INTO clan_wars (clan1, clan2, wantspeace1, wantspeace2) VALUES(?,?,?,?)"
      GameDB.exec(sql, clan_id1, clan_id2, 0, 0)
    rescue e
      error e
    end

    sm = SystemMessage.clan_war_declared_against_s1_if_killed_lose_low_exp
    sm.add_string(clan2.name)
    clan1.broadcast_to_online_members(sm)

    sm = SystemMessage.clan_s1_declared_war
    sm.add_string(clan1.name)
    clan2.broadcast_to_online_members(sm)
  end

  def schedule_remove_clan(clan_id : Int32)
    task = -> do
      unless clan = get_clan(clan_id)
        return
      end

      if clan.dissolving_expiry_time != 0
        destroy_clan(clan_id)
      end
    end

    delay = Math.max(get_clan(clan_id).not_nil!.dissolving_expiry_time - Time.ms, 300_000)

    ThreadPoolManager.schedule_general(task, delay)
  end

  def ally_exists?(ally_name : String) : Bool
    clans.any? do |clan|
      name = clan.ally_name
      !!name && name.casecmp?(ally_name)
    end
  end

  private def restore_wars
    sql = "SELECT clan1, clan2 FROM clan_wars"
    GameDB.each(sql) do |rs|
      clan1 = get_clan(rs.get_i32(:"clan1"))
      clan2 = get_clan(rs.get_i32(:"clan2"))

      if clan1 && clan2
        clan1.enemy_clan = clan2
        clan2.enemy_clan = clan1
      else
        warn "#restore_wars: one of the clans is missing."
      end
    end
  rescue e
    error e
  end

  private def alliance_check
    CLANS.each_value do |clan|
      ally_id = clan.ally_id

      if ally_id != 0 && clan.id != ally_id
        unless CLANS.has_key?(ally_id)
          clan.ally_id = 0
          clan.ally_name = nil
          clan.change_ally_crest(0, true)
          clan.update_clan_in_db
          info { "Removed alliance from clan #{clan.name}." }
        end
      end
    end
  end
end
