module Hero
  include Packets::Outgoing
  extend self
  extend Synchronizable
  extend Loggable

  private GET_HEROES = "SELECT heroes.charId, characters.char_name, heroes.class_id, heroes.count, heroes.played, heroes.claimed FROM heroes, characters WHERE characters.charId = heroes.charId AND heroes.played = 1"
  private GET_ALL_HEROES = "SELECT heroes.charId, characters.char_name, heroes.class_id, heroes.count, heroes.played, heroes.claimed FROM heroes, characters WHERE characters.charId = heroes.charId"
  private UPDATE_ALL = "UPDATE heroes SET played = 0"
  private INSERT_HERO = "INSERT INTO heroes (charId, class_id, count, played, claimed) VALUES (?,?,?,?,?)"
  private UPDATE_HERO = "UPDATE heroes SET count = ?, played = ?, claimed = ? WHERE charId = ?"
  private GET_CLAN_ALLY = "SELECT characters.clanid AS clanid, coalesce(clan_data.ally_Id, 0) AS allyId FROM characters LEFT JOIN clan_data ON clan_data.clan_id = characters.clanid WHERE characters.charId = ?"
  private DELETE_ITEMS = "DELETE FROM items WHERE item_id IN (6842, 6611, 6612, 6613, 6614, 6615, 6616, 6617, 6618, 6619, 6620, 6621, 9388, 9389, 9390) AND owner_id NOT IN (SELECT charId FROM characters WHERE accesslevel > 0)"

  private HEROES = Concurrent::Map(Int32, StatsSet).new
  private COMPLETE_HEROS = Concurrent::Map(Int32, StatsSet).new
  private HERO_COUNTS = Concurrent::Map(Int32, StatsSet).new
  private HERO_FIGHTS = Concurrent::Map(Int32, Array(StatsSet)).new
  private HERO_DIARY = Concurrent::Map(Int32, Array(StatsSet)).new
  private HERO_MESSAGE = Concurrent::Map(Int32, String).new

  ACTION_RAID_KILLED = 1
  ACTION_HERO_GAINED = 2
  ACTION_CASTLE_TAKEN = 3

  COUNT = "count"
  PLAYED = "played"
  CLAIMED = "claimed"
  CLAN_NAME = "clan_name"
  CLAN_CREST = "clan_crest"
  ALLY_NAME = "ally_name"
  ALLY_CREST = "ally_crest"

  def load
    HEROES.clear
    COMPLETE_HEROS.clear
    HERO_COUNTS.clear
    HERO_FIGHTS.clear
    HERO_DIARY.clear
    HERO_MESSAGE.clear

    GameDB.each(GET_HEROES) do |rs|
      hero = StatsSet.new
      char_id = rs.get_i32(Olympiad::CHAR_ID)
      hero[Olympiad::CHAR_NAME] = rs.get_string(Olympiad::CHAR_NAME)
      hero[Olympiad::CLASS_ID] = rs.get_i32(Olympiad::CLASS_ID)
      hero[COUNT] = rs.get_i32(COUNT)
      hero[PLAYED] = rs.get_i32(PLAYED)
      hero[CLAIMED] = rs.get_bool(CLAIMED)

      load_fights(char_id)
      load_diary(char_id)
      load_message(char_id)

      process_heroes(GET_CLAN_ALLY, char_id, hero)

      HEROES[char_id] = hero
    end

    GameDB.each(GET_ALL_HEROES) do |rs|
      hero = StatsSet.new
      char_id = rs.get_i32(Olympiad::CHAR_ID)
      hero[Olympiad::CHAR_NAME] = rs.get_string(Olympiad::CHAR_NAME)
      hero[Olympiad::CLASS_ID] = rs.get_i32(Olympiad::CLASS_ID)
      hero[COUNT] = rs.get_i32(COUNT)
      hero[PLAYED] = rs.get_i32(PLAYED)
      hero[CLAIMED] = rs.get_bool(CLAIMED)

      process_heroes(GET_CLAN_ALLY, char_id, hero)

      COMPLETE_HEROS[char_id] = hero
    end

    info { "Loaded #{HEROES.size} heroes." }
    info { "Loaded #{COMPLETE_HEROS.size} historical heroes." }
  rescue e
    error e
  end

  private def process_heroes(sql, char_id, hero)
    GameDB.each(sql, char_id) do |rs|
      clan_id = rs.get_i32(:"clanid")
      ally_id = rs.get_i32(:"allyId")
      clan_name = ""
      ally_name = ""
      clan_crest = 0
      ally_crest = 0

      if clan_id > 0
        clan = ClanTable.get_clan(clan_id).not_nil!
        clan_name = clan.name
        clan_crest = clan.crest_id
        if ally_id > 0
          ally_name = clan.ally_name
          ally_crest = clan.ally_crest_id
        end
      end

      hero[CLAN_CREST] = clan_crest
      hero[CLAN_NAME] = clan_name
      hero[ALLY_CREST] = ally_crest
      hero[ALLY_NAME] = ally_name
    end
  end

  private def calc_fight_time(time : Int64) : String
    time /= 1000
    sprintf("%%0%dd:%%0%dd", time % 60, (time % 3600) / 60)
  end

  def load_message(char_id : Int32)
    sql = "SELECT message FROM heroes WHERE charId=?"
    GameDB.each(sql, char_id) do |rs|
      msg = rs.get_string(:"message")
      HERO_MESSAGE[char_id] = msg
    end
  rescue e
    error e
  end

  def load_diary(char_id : Int32)
    diary = [] of StatsSet
    diary_entries = 0
    sql = "SELECT * FROM  heroes_diary WHERE charId=? ORDER BY time ASC"
    GameDB.each(sql, char_id) do |rs|
      diary_entry = StatsSet.new
      time = rs.get_i64(:"time")
      action = rs.get_i32(:"action")
      param = rs.get_i32(:"param")

      date = Time.from_ms(time).to_s("%Y-%m-%d %H")
      diary_entry["date"] = date

      case action
      when ACTION_RAID_KILLED
        if template = NpcData[param]?
          diary_entry["action"] = template.name + " was defeated"
        end
      when ACTION_HERO_GAINED
        diary_entry["action"] = "Gained Hero status"
      when ACTION_CASTLE_TAKEN
        if castle = CastleManager.get_castle_by_id(param)
          diary_entry["action"] = castle.name + " Castle was successful taken"
        end
      end


      diary << diary_entry
      diary_entries &+= 1
    end

    HERO_DIARY[char_id] = diary

    char_name = CharNameTable.get_name_by_id(char_id)
    info { "Loaded #{diary_entries} diary entries for hero #{char_name}." }
  rescue e
    error e
  end

  def load_fights(char_id : Int32)
    fights = [] of StatsSet
    hero_count_data = StatsSet.new

    data = Calendar.new
    data.day = 1
    data.hour = 0
    data.minute = 0
    data.millisecond = 0

    from = data.ms
    number_of_fights = 0
    victories = 0
    losses = 0
    draws = 0

    sql = "SELECT * FROM olympiad_fights WHERE (charOneId=? OR charTwoId=?) AND start<? ORDER BY start ASC"
    GameDB.each(sql, char_id, char_id, from) do |rs|
      char_one_id = rs.get_i32(:"charOneId")
      char_one_class = rs.get_i32(:"charOneClass")
      char_two_id = rs.get_i32(:"charTwoId")
      char_two_class = rs.get_i32(:"charTwoClass")
      winner = rs.get_i32(:"winner")
      start = rs.get_i32(:"start")
      time = rs.get_i64(:"time")
      classed = rs.get_i32(:"classed")

      if char_id == char_one_id
        if name = CharNameTable.get_name_by_id(char_two_id)
          cls = ClassListData.get_class(char_two_class).client_code

          fight = StatsSet.new
          fight["opponent"] = name
          fight["opponentclass"] = cls

          fight["time"] = calc_fight_time(time)
          date = Time.from_ms(start).to_s("%Y-%m-%d %H:%m")
          fight["start"] = date

          fight["classed"] = classed

          if winner == 1
            fight["result"] = "<font color=\"00ff00\">victory</font>"
            victories &+= 1
          elsif winner == 2
            fight["result"] = "<font color=\"ff0000\">loss</font>"
            losses &+= 1
          elsif winner == 0
            fight["result"] = "<font color=\"ffff00\">draw</font>"
            draws &+= 1
          end

          fights << fight

          number_of_fights &+= 1
        end
      elsif char_id == char_two_id
        if name = CharNameTable.get_name_by_id(char_one_id)
          cls = ClassListData.get_class(char_one_class).client_code

          fight = StatsSet.new
          fight["opponent"] = name
          fight["opponentclass"] = cls

          fight["time"] = calc_fight_time(time)
          date = Time.from_ms(start).to_s("%Y-%m-%d %H:%m")
          fight["start"] = date

          fight["classed"] = classed

          if winner == 1
            fight["result"] = "<font color=\"ff0000\">loss</font>"
            losses &+= 1
          elsif winner == 2
            fight["result"] = "<font color=\"00ff00\">victory</font>"
            victories &+= 1
          elsif winner == 0
            fight["result"] = "<font color=\"ffff00\">draw</font>"
            draws &+= 1
          end

          fights << fight

          number_of_fights &+= 1
        end
      end
    end

    hero_count_data["victory"] = victories
    hero_count_data["draw"] = draws
    hero_count_data["loss"] = losses

    HERO_COUNTS[char_id] = hero_count_data
    HERO_FIGHTS[char_id] = fights
  rescue e
    error e
  end

  def heroes : Interfaces::Map(Int32, StatsSet)
    HEROES
  end

  def get_hero_by_class(class_id : Int32) : Int32
    HEROES.each do |k, v|
      if v.get_i32(Olympiad::CLASS_ID) == class_id
        return k
      end
    end

    0
  end

  def reset_data
    HERO_DIARY.clear
    HERO_FIGHTS.clear
    HERO_COUNTS.clear
    HERO_MESSAGE.clear
  end

  def show_hero_diary(pc : L2PcInstance, hero_class : Int32, char_id : Int32, page : Int32)
    per_page = 10

    unless main_list = HERO_DIARY[char_id]?
      return
    end

    htm_content = HtmCache.get_htm(pc, "data/html/olympiad/herodiary.htm")
    hero_message = HERO_MESSAGE[char_id]?

    if htm_content && hero_message
      diary_reply = NpcHtmlMessage.new
      diary_reply.html = htm_content
      diary_reply["%heroname%"] = CharNameTable.get_name_by_id(char_id)
      diary_reply["%message%"] = hero_message
      diary_reply.disable_validation

      if main_list.empty?
        diary_reply["%list%"] = ""
        diary_reply["%buttprev%"] = ""
        diary_reply["%buttnext%"] = ""
      else
        list = main_list.reverse
        color = true
        counter = 0
        breakat = 0
        flist = String.build(500) do |io|
          i = (page &- 1) &* per_page
          while i < list.size
            breakat = i
            diary_entry = list[i]
            io << "<tr><td>"
            if color
              io << "<table width=270 bgcolor=\"131210\">"
            else
              io << "<table width=270>"
            end
            io << "<tr><td width=270><font color=\"LEVEL\">"
            io << diary_entry.get_string("date")
            io << ":xx</font></td></tr>"
            io << "<tr><td width=270>"
            io << diary_entry.get_string("action")
            io << "</td></tr>"
            io << "<tr><td>&nbsp;</td></tr></table>"
            io << "</td></tr>"
            color = !color
            counter &+= 1
            if counter >= per_page
              break
            end
            i &+= 1
          end
        end

        if breakat < list.size - 1
          diary_reply["%buttprev%"] = "<button value=\"Prev\" action=\"bypass _diary?class=#{hero_class}&page=#{page + 1}\" width=60 height=25 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\">"
        else
          diary_reply["%buttprev%"] = ""
        end

        if page > 1
          diary_reply["%buttnext%"] = "<button value=\"Next\" action=\"bypass _diary?class=#{hero_class}&page=#{page - 1}\" width=60 height=25 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\">"
        else
          diary_reply["%buttnext%"] = ""
        end

        diary_reply["%%"] = flist
      end

      pc.send_packet(diary_reply)
    end
  end

  def show_hero_fights(pc : L2PcInstance, hero_class : Int32, char_id : Int32, page : Int32)
    per_page = 20
    win = 0
    loss = 0
    draw = 0

    unless hero_fights = HERO_FIGHTS[char_id]?
      return
    end

    fight_reply = NpcHtmlMessage.new
    if htm_content = HtmCache.get_htm(pc, "data/html/olympiad/herohistory.htm")
      fight_reply.html = htm_content
      fight_reply["%heroname%"] = CharNameTable.get_name_by_id(char_id)
    end

    if hero_fights.empty?
      fight_reply["%list%"] = ""
      fight_reply["%buttprev%"] = ""
      fight_reply["%buttnext%"] = ""
    else
      if hero_count = HERO_COUNTS[char_id]?
        win = hero_count.get_i32("victory")
        loss = hero_count.get_i32("loss")
        draw = hero_count.get_i32("draw")
      end
      flist = String.build(500) do |io|
        color = true
        counter = 0
        breakat = 0
        i = (page &- 1) &* per_page
        while i < hero_fights.size
          breakat = i
          fight = hero_fights[i]
          io << "<tr><td>"
          if color
            io << "<table width=270 bgcolor=\"131210\">"
          else
            io << "<table width=270>"
          end

          io << "<tr><td width=220><font color=\"LEVEL\">"
          io << fight.get_string("start")
          io << "</font>&nbsp;&nbsp;"
          io << fight.get_string("result")
          io << "</td><td width=50 align=right>"
          if fight.get_i32("classed") > 0
            io << "<font color=\"FFFF99\">cls</font>"
          else
            io << "<font color=\"999999\">non-cls<font>"
          end
          io << "</td></tr>"
          io << "<tr><td width=220>vs "
          io << fight.get_string("oponent")
          io << " ("
          io << fight.get_string("oponentclass")
          io << ")</td><td width=50 align=right>("
          io << fight.get_string("time")
          io << ")</td></tr>"
          io << "<tr><td colspan=2>&nbsp;</td></tr></table>"
          io << "</td></tr>"
          color = !color
          counter &+= 1
          if counter > per_page
            break
          end

          i &+= 1
        end

        if breakat < hero_fights.size - 1
          fight_reply["%buttprev%"] = "<button value=\"Prev\" action=\"bypass _match?class=#{hero_class}&page=#{page + 1}\" width=60 height=25 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\">"
        else
          fight_reply["%buttprev%"] = ""
        end

        if page > 1
          fight_reply["%buttnext%"] = "<button value=\"Next\" action=\"bypass _match?class=#{hero_class}&page=#{page - 1}\" width=60 height=25 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\">"
        else
          fight_reply["%buttnext%"] = ""
        end
      end

      fight_reply["%list%"] = flist
    end

    fight_reply["%win%"] = win
    fight_reply["%draw%"] = draw
    fight_reply["%loos%"] = loss

    pc.send_packet(fight_reply)
  end

  def compute_new_heroes(new_heroes : Array(StatsSet))
    sync do
      update_heroes(true)

      HEROES.each_key do |l2id|
        unless pc = L2World.get_player(l2id)
          next
        end

        pc.hero = false

        Inventory::TOTALSLOTS.times do |i|
          if equipped_item = pc.inventory[i]
            if equipped_item.hero_item?
              pc.inventory.unequip_item_in_slot(i)
            end
          end
        end

        iu = InventoryUpdate.new
        pc.inventory.items.safe_each do |item|
          pc.destroy_item("Hero", item, nil, true)
          iu.add_removed_item(item)
        end

        unless iu.items.empty?
          pc.send_packet(iu)
        end

        pc.broadcast_user_info
      end

      delete_items_in_db

      HEROES.clear

      if new_heroes.empty?
        return
      end

      new_heroes.each do |hero|
        char_id = hero.get_i32(Olympiad::CHAR_ID)

        if old_hero = COMPLETE_HEROS[char_id]?
          count = old_hero.get_i32(COUNT)
          old_hero[COUNT] = count + 1
          old_hero[PLAYED] = 1
          old_hero[CLAIMED] = false
          HEROES[char_id] = old_hero
        else
          new_hero = StatsSet.new
          new_hero[Olympiad::CHAR_NAME] = hero.get_string(Olympiad::CHAR_NAME)
          new_hero[Olympiad::CLASS_ID] = hero.get_string(Olympiad::CLASS_ID)
          new_hero[COUNT] = 1
          new_hero[PLAYED] = 1
          new_hero[CLAIMED] = false
          HEROES[char_id] = new_hero
        end
      end

      update_heroes(false)
    end
  end

  def update_heroes(set_default : Bool)
    if set_default
      begin
        GameDB.exec(UPDATE_ALL)
      rescue e
        error e
      end

      return
    end

    HEROES.each do |hero_id, hero|
      if COMPLETE_HEROS.has_key?(hero_id)
        begin
          GameDB.exec(
            UPDATE_HERO,
            hero.get_i32(COUNT),
            hero.get_i32(PLAYED),
            hero.get_bool(CLAIMED).to_s,
            hero_id
          )
        rescue e
          error e
        end
      else
        begin
          GameDB.exec(
            INSERT_HERO,
            hero_id,
            hero.get_i32(Olympiad::CLASS_ID),
            hero.get_i32(COUNT),
            hero.get_i32(PLAYED),
            hero.get_bool(CLAIMED).to_s
          )
        rescue e
          error e
        end

        begin
          GameDB.each(GET_CLAN_ALLY, hero_id) do |rs|
            clan_id = rs.get_i32(:"clanid")
            ally_id = rs.get_i32(:"allyId")
            clan_name = ally_name = ""
            clan_crest = ally_crest = 0
            if clan_id > 0
              clan = ClanTable.get_clan(clan_id).not_nil!
              clan_name = clan.name
              clan_crest = clan.crest_id
              if ally_id > 0
                ally_name = clan.ally_name
                ally_crest = clan.ally_crest_id
              end
            end

            hero[CLAN_CREST] = clan_crest
            hero[CLAN_NAME] = clan_name
            hero[ALLY_CREST] = ally_crest
            hero[ALLY_NAME] = ally_name
          end
        rescue e
          error e
        end

        HEROES[hero_id] = hero
        COMPLETE_HEROS[hero_id] = hero
      end
    end
  end

  def set_hero_gained(char_id : Int32)
    set_diary_data(char_id, ACTION_HERO_GAINED, 0)
  end

  def set_rb_killed(char_id : Int32, npc_id : Int32)
    set_diary_data(char_id, ACTION_RAID_KILLED, npc_id)

    template = NpcData[npc_id]?
    list = HERO_DIARY[char_id]?
    if list && template
      diary_entry = StatsSet.new
      date = Time.now.to_s("%Y-%m-%d %H")
      diary_entry["date"] = date
      diary_entry["action"] = template.name + " was defeated"
      list << diary_entry
    end
  end

  def set_castle_taken(char_id : Int32, castle_id : Int32)
    set_diary_data(char_id, ACTION_CASTLE_TAKEN, castle_id)

    castle = CastleManager.get_castle_by_id(castle_id)
    list = HERO_DIARY[char_id]?
    if castle && list
      diary_entry = StatsSet.new
      date = Time.now.to_s("%Y-%m-%d %H")
      diary_entry["date"] = date
      diary_entry["action"] = castle.name + " Castle was successfully taken"
      list << diary_entry
    end
  end

  def set_diary_data(char_id : Int32, action : Int32, param : Int32)
    sql = "INSERT INTO heroes_diary (charId, time, action, param) values(?,?,?,?)"
    GameDB.exec(sql, char_id, Time.ms, action, param)
  rescue e
    error e
  end

  def set_hero_message(pc : L2PcInstance, message : String)
    HERO_MESSAGE[pc.l2id] = message
  end

  def save_hero_message(char_id : Int32)
    unless msg = HERO_MESSAGE[char_id]?
      return
    end

    sql = "UPDATE heroes SET message=? WHERE charId=?;"
    GameDB.exec(sql, msg, char_id)
  rescue e
    error e
  end

  private def delete_items_in_db
    GameDB.exec(DELETE_ITEMS)
  rescue e
    error e
  end

  def shutdown
    HERO_MESSAGE.each_key { |k| save_hero_message(k) }
  end

  def hero?(l2id : Int32) : Bool
    return false unless tmp = HEROES[l2id]?
    tmp.get_bool(CLAIMED)
  end

  def unclaimed_hero?(l2id : Int32) : Bool
    return false unless tmp = HEROES[l2id]?
    !tmp.get_bool(CLAIMED)
  end

  def claim_hero(pc : L2PcInstance)
    unless hero = HEROES[pc.l2id]
      hero = StatsSet.new
      HEROES[pc.l2id] = hero
    end

    hero[CLAIMED] = true

    clan = pc.clan

    if clan && clan.level >= 5
      clan.add_reputation_score(Config.hero_points, true)
      sm = SystemMessage.clan_member_c1_became_hero_and_gained_s2_reputation_points
      sm.add_string(pc.name)
      sm.add_int(Config.hero_points)
      clan.broadcast_to_online_members(sm)
    end

    pc.hero = true
    pc.broadcast_packet(SocialAction.new(pc.l2id, 20016))
    pc.send_packet(UserInfo.new(pc))
    pc.send_packet(ExBrExtraUserInfo.new(pc))
    pc.broadcast_user_info
    set_hero_gained(pc.l2id)
    load_fights(pc.l2id)
    load_diary(pc.l2id)
    HERO_MESSAGE[pc.l2id] = ""

    update_heroes(false)
  end
end
