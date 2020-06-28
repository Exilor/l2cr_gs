require "./util/range_set"

module IdFactory
  extend self
  extend Synchronizable
  extend Loggable

  private ID_EXTRACTS = {
    {"characters","charId"},
    {"items","object_id"},
    {"clan_data","clan_id"},
    {"itemsonground","object_id"},
    {"messages","messageId"}
  }

  private ID_CHECKS = {
    "SELECT owner_id FROM items WHERE object_id >= ? AND object_id < ?",
    "SELECT object_id FROM items WHERE object_id >= ? AND object_id < ?",
    "SELECT charId FROM character_quests WHERE charId >= ? AND charId < ?",
    "SELECT charId FROM character_contacts WHERE charId >= ? AND charId < ?",
    "SELECT contactId FROM character_contacts WHERE contactId >= ? AND contactId < ?",
    "SELECT charId FROM character_friends WHERE charId >= ? AND charId < ?",
    "SELECT charId FROM character_friends WHERE friendId >= ? AND friendId < ?",
    "SELECT charId FROM character_hennas WHERE charId >= ? AND charId < ?",
    "SELECT charId FROM character_recipebook WHERE charId >= ? AND charId < ?",
    "SELECT charId FROM character_recipeshoplist WHERE charId >= ? AND charId < ?",
    "SELECT charId FROM character_shortcuts WHERE charId >= ? AND charId < ?",
    "SELECT charId FROM character_macroses WHERE charId >= ? AND charId < ?",
    "SELECT charId FROM character_skills WHERE charId >= ? AND charId < ?",
    "SELECT charId FROM character_skills_save WHERE charId >= ? AND charId < ?",
    "SELECT charId FROM character_subclasses WHERE charId >= ? AND charId < ?",
    "SELECT charId FROM character_ui_actions WHERE charId >= ? AND charId < ?",
    "SELECT charId FROM character_ui_categories WHERE charId >= ? AND charId < ?",
    "SELECT charId FROM characters WHERE charId >= ? AND charId < ?",
    "SELECT clanid FROM characters WHERE clanid >= ? AND clanid < ?",
    "SELECT clan_id FROM clan_data WHERE clan_id >= ? AND clan_id < ?",
    "SELECT clan_id FROM siege_clans WHERE clan_id >= ? AND clan_id < ?",
    "SELECT ally_id FROM clan_data WHERE ally_id >= ? AND ally_id < ?",
    "SELECT leader_id FROM clan_data WHERE leader_id >= ? AND leader_id < ?",
    "SELECT item_obj_id FROM pets WHERE item_obj_id >= ? AND item_obj_id < ?",
    "SELECT object_id FROM itemsonground WHERE object_id >= ? AND object_id < ?"
  }

  private TIMESTAMPS_CLEAN = {
    "DELETE FROM character_instance_time WHERE time <= ?",
    "DELETE FROM character_skills_save WHERE restore_type = 1 AND systime <= ?"
  }

  private FIRST_OID = 0x10000000

  # Ids start from FIRST_OID for compatibility with L2J.
  IDS = RangeSet.new(0..FIRST_OID)

  def load
    set_all_characters_offline

    if Config.database_clean_up
      debug "Cleaning up the database..."
      timer = Timer.new
      if Config.allow_wedding
        clean_invalid_weddings
      end
      clean_up_db
      debug { "Database cleaned in #{timer} s." }
    end

    clean_up_timestamps

    timer = Timer.new
    temp = [] of Int32
    sql = String.build do |io|
      ID_EXTRACTS.each do |table, column|
        io << "SELECT " << column << " FROM " << table << " UNION "
      end
    end
    sql = sql.chomp("UNION ")

    GameDB.query_each(sql) do |rs|
      value = rs.read(Number::Primitive)
      temp << value.to_i32
    end

    temp.sort!
    temp.each { |id| IDS << id }
    info { "#{temp.size} ids loaded in #{timer} s." }
  end

  def next : Int32
    sync do
      id = IDS.first_free
      IDS << id
      id
    end
  end

  def release(id : Int32)
    sync { IDS.delete(id) }
  end

  private def set_all_characters_offline
    GameDB.exec("UPDATE characters SET online = 0")
    info "Updated character online status."
  rescue e
    error e
  end

  private def clean_up_db
    GameDB.transaction do |tr|
      tr.exec("DELETE FROM account_gsdata WHERE account_gsdata.account_name NOT IN (SELECT account_name FROM characters);")
      tr.exec("DELETE FROM character_contacts WHERE character_contacts.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_contacts WHERE character_contacts.contactId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_friends WHERE character_friends.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_friends WHERE character_friends.friendId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_hennas WHERE character_hennas.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_macroses WHERE character_macroses.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_quests WHERE character_quests.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_recipebook WHERE character_recipebook.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_recipeshoplist WHERE character_recipeshoplist.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_shortcuts WHERE character_shortcuts.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_skills WHERE character_skills.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_skills_save WHERE character_skills_save.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_subclasses WHERE character_subclasses.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_raid_points WHERE character_raid_points.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_instance_time WHERE character_instance_time.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_ui_actions WHERE character_ui_actions.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_ui_categories WHERE character_ui_categories.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM items WHERE items.owner_id NOT IN (SELECT charId FROM characters) AND items.owner_id NOT IN (SELECT clan_id FROM clan_data) AND items.owner_id != -1;")
      tr.exec("DELETE FROM items WHERE items.owner_id = -1 AND loc LIKE 'MAIL' AND loc_data NOT IN (SELECT messageId FROM messages WHERE senderId = -1);")
      tr.exec("DELETE FROM item_auction_bid WHERE item_auction_bid.playerObjId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM item_attributes WHERE item_attributes.itemId NOT IN (SELECT object_id FROM items);")
      tr.exec("DELETE FROM item_elementals WHERE item_elementals.itemId NOT IN (SELECT object_id FROM items);")
      tr.exec("DELETE FROM cursed_weapons WHERE cursed_weapons.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM heroes WHERE heroes.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM olympiad_nobles WHERE olympiad_nobles.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM olympiad_nobles_eom WHERE olympiad_nobles_eom.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM pets WHERE pets.item_obj_id NOT IN (SELECT object_id FROM items);")
      tr.exec("DELETE FROM seven_signs WHERE seven_signs.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM merchant_lease WHERE merchant_lease.player_id NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_reco_bonus WHERE character_reco_bonus.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM clan_data WHERE clan_data.leader_id NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM clan_data WHERE clan_data.clan_id NOT IN (SELECT clanid FROM characters);")
      tr.exec("DELETE FROM olympiad_fights WHERE olympiad_fights.charOneId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM olympiad_fights WHERE olympiad_fights.charTwoId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM heroes_diary WHERE heroes_diary.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_offline_trade WHERE character_offline_trade.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_offline_trade_items WHERE character_offline_trade_items.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_quest_global_data WHERE character_quest_global_data.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_tpbookmark WHERE character_tpbookmark.charId NOT IN (SELECT charId FROM characters);")
      tr.exec("DELETE FROM character_variables WHERE character_variables.charId NOT IN (SELECT charId FROM characters);")

      tr.exec("DELETE FROM clan_privs WHERE clan_privs.clan_id NOT IN (SELECT clan_id FROM clan_data);")
      tr.exec("DELETE FROM clan_skills WHERE clan_skills.clan_id NOT IN (SELECT clan_id FROM clan_data);")
      tr.exec("DELETE FROM clan_subpledges WHERE clan_subpledges.clan_id NOT IN (SELECT clan_id FROM clan_data);")
      tr.exec("DELETE FROM clan_wars WHERE clan_wars.clan1 NOT IN (SELECT clan_id FROM clan_data);")
      tr.exec("DELETE FROM clan_wars WHERE clan_wars.clan2 NOT IN (SELECT clan_id FROM clan_data);")
      tr.exec("DELETE FROM clanhall_functions WHERE clanhall_functions.hall_id NOT IN (SELECT id FROM clanhall WHERE ownerId <> 0 union all SELECT clanHallId FROM siegable_clanhall WHERE ownerId <> 0);")
      tr.exec("DELETE FROM siege_clans WHERE siege_clans.clan_id NOT IN (SELECT clan_id FROM clan_data);")
      tr.exec("DELETE FROM clan_notices WHERE clan_notices.clan_id NOT IN (SELECT clan_id FROM clan_data);")
      tr.exec("DELETE FROM auction_bid WHERE auction_bid.bidderId NOT IN (SELECT clan_id FROM clan_data);")

      tr.exec("DELETE FROM forums WHERE forums.forum_owner_id NOT IN (SELECT clan_id FROM clan_data) AND forums.forum_parent=2;")
      tr.exec("DELETE FROM forums WHERE forums.forum_owner_id NOT IN (SELECT charId FROM characters) AND forums.forum_parent=3;")
      tr.exec("DELETE FROM posts WHERE posts.post_forum_id NOT IN (SELECT forum_id FROM forums);")
      tr.exec("DELETE FROM topic WHERE topic.topic_forum_id NOT IN (SELECT forum_id FROM forums);")

      tr.exec("UPDATE clan_data SET auction_bid_at = 0 WHERE auction_bid_at NOT IN (SELECT auctionId FROM auction_bid);")
      tr.exec("UPDATE clan_data SET new_leader_id = 0 WHERE new_leader_id <> 0 AND new_leader_id NOT IN (SELECT charId FROM characters);")
      tr.exec("UPDATE clan_subpledges SET leader_id=0 WHERE clan_subpledges.leader_id NOT IN (SELECT charId FROM characters) AND leader_id > 0;")
      tr.exec("UPDATE castle SET taxpercent=0 WHERE castle.id NOT IN (SELECT hasCastle FROM clan_data);")
      tr.exec("UPDATE characters SET clanid=0, clan_privs=0, wantspeace=0, subpledge=0, lvl_joined_academy=0, apprentice=0, sponsor=0, clan_join_expiry_time=0, clan_create_expiry_time=0 WHERE characters.clanid > 0 AND characters.clanid NOT IN (SELECT clan_id FROM clan_data);")
      tr.exec("UPDATE clanhall SET ownerId=0, paidUntil=0, paid=0 WHERE clanhall.ownerId NOT IN (SELECT clan_id FROM clan_data);")
      tr.exec("UPDATE fort SET owner=0 WHERE owner NOT IN (SELECT clan_id FROM clan_data);")
    end
  rescue e
    error e
  end

  private def clean_invalid_weddings
    GameDB.transaction do |tr|
      tr.exec("DELETE FROM mods_wedding WHERE player1Id NOT IN (SELECT charId FROM characters)")
      tr.exec("DELETE FROM mods_wedding WHERE player2Id NOT IN (SELECT charId FROM characters)")
    end
  rescue e
    error e
  end

  private def clean_up_timestamps
    time = Time.ms
    GameDB.transaction do |tr|
      TIMESTAMPS_CLEAN.each do |sql|
        tr.exec(sql, time)
      end
    end
  rescue e
    error e
  end
end



