require "../models/cursed_weapon"

module CursedWeaponsManager
  extend self
  extend XMLReader
  extend Synchronizable
  include Packets::Outgoing

  private CURSED_WEAPONS = {} of Int32 => CursedWeapon

  def load
    return unless Config.allow_cursed_weapons

    parse_datapack_file("cursedWeapons.xml")
    restore
    control_players
    info { "Loaded #{CURSED_WEAPONS.size} cursed weapons." }
  end

  def reload
    CURSED_WEAPONS.clear
    return unless Config.allow_cursed_weapons
    restore
    control_players
    info { "Loaded #{CURSED_WEAPONS.size} cursed weapons." }
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |n|
      n.find_element("item") do |d|
        id = d["id"].to_i
        skill_id = d["skillId"].to_i
        name = d["name"]

        cw = CursedWeapon.new(id, skill_id, name)

        d.each_element do |cd|
          case cd.name.casecmp
          when "droprate"
            cw.drop_rate = cd["val"].to_i
          when "duration"
            cw.duration = cd["val"].to_i
          when "durationlost"
            cw.duration_lost = cd["val"].to_i
          when "disapearchance"
            cw.disappear_chance = cd["val"].to_i
          when "stagekills"
            cw.stage_kills = cd["val"].to_i
          else
            # [automatically added else]
          end

        end

        CURSED_WEAPONS[id] = cw
      end
    end
  end

  private def restore
    sql = "SELECT itemId, charId, playerKarma, playerPkKills, nbKills, endTime FROM cursed_weapons"
    GameDB.each(sql) do |rs|
      cw = CURSED_WEAPONS[rs.get_i32("itemId")]
      cw.player_id = rs.get_i32("charId")
      cw.player_karma = rs.get_i32("playerKarma")
      cw.player_pk_kills = rs.get_i32("playerPkKills")
      cw.nb_kills = rs.get_i32("nbKills")
      cw.end_time = rs.get_i64("endTime")
      cw.reactivate
    end
  rescue e
    error e
  end

  private def control_players
    CURSED_WEAPONS.each_value do |cw|
      next if cw.activated?

      item_id = cw.item_id

      sql = "SELECT owner_id FROM items WHERE item_id=?"
      GameDB.each(sql, item_id) do |rs|
        player_id = rs.get_i32("owner_id")
        warn { "Player #{player_id} owns the cursed weapon #{item_id} but he shouldn't." }
        begin
          sql = "DELETE FROM items WHERE owner_id=? AND item_id=?"
          GameDB.exec(sql, player_id, item_id)
        rescue e
          error e
        end

        begin
          sql = "UPDATE characters SET karma=?, pkkills=? WHERE charId=?"
          GameDB.exec(sql, cw.player_karma, cw.player_pk_kills, player_id)
        rescue e
          error e
        end

        remove_from_db(item_id)
      end
    end
  rescue e
    error e
  end

  def check_drop(attackable : L2Attackable, pc : L2PcInstance)
    return if attackable.is_a?(L2DefenderInstance)
    return if attackable.is_a?(L2RiftInvaderInstance)
    return if attackable.is_a?(L2FestivalMonsterInstance)
    return if attackable.is_a?(L2GuardInstance)
    return if attackable.is_a?(L2GrandBossInstance)
    return if attackable.is_a?(L2FeedableBeastInstance)
    return if attackable.is_a?(L2FortCommanderInstance)

    sync do
      CURSED_WEAPONS.each_value do |cw|
        next if cw.active?
        break if cw.check_drop(attackable, pc)
      end
    end
  end

  def activate(pc : L2PcInstance, item : L2ItemInstance)
    cw = CURSED_WEAPONS[item.id]

    if pc.cursed_weapon_equipped?
      cw2 = CURSED_WEAPONS[pc.cursed_weapon_equipped_id]
      cw2.nb_kills = cw2.stage_kills - 1
      cw2.increase_kills
      cw.player = pc
      cw.end_of_life
    else
      cw.activate(pc, item)
    end
  end

  def drop(item_id : Int, killer : L2Character?)
    CURSED_WEAPONS[item_id].drop_it(killer)
  end

  def increase_kills(item_id : Int)
    CURSED_WEAPONS[item_id].increase_kills
  end

  def get_level(item_id : Int) : Int32
    CURSED_WEAPONS[item_id].level
  end

  def announce(sm : SystemMessage)
    Broadcast.to_all_online_players(sm)
  end

  def check_player(pc : L2PcInstance)
    return unless pc

    CURSED_WEAPONS.each_value do |cw|
      if cw.activated? && pc.l2id == cw.player_id
        cw.player = pc
        cw.item = pc.inventory.get_item_by_item_id(cw.item_id)
        cw.give_skill
        pc.cursed_weapon_equipped_id = cw.item_id

        sm = SystemMessage.s2_minute_of_usage_time_are_left_for_s1
        sm.add_string(cw.name)
        time = (cw.end_time - Time.ms) // 60_000
        sm.add_int(time)
        pc.send_packet(sm)
      end
    end
  end

  def check_owns_weapon_id(owner_id : Int32) : Int32
    CURSED_WEAPONS.each_value do |cw|
      if cw.activated? && owner_id == cw.player_id
        return cw.item_id
      end
    end

    -1
  end

  def remove_from_db(item_id : Int)
    GameDB.exec("DELETE FROM cursed_weapons WHERE itemId = ?", item_id)
  rescue e
    error e
  end

  def save_data
    CURSED_WEAPONS.each_value &.save_data
  end

  def cursed?(item_id : Int) : Bool
    CURSED_WEAPONS.has_key?(item_id)
  end

  def cursed_weapons : Enumerable(CursedWeapon)
    CURSED_WEAPONS.local_each_value
  end

  def cursed_weapons_ids : Indexable(Int32)
    CURSED_WEAPONS.keys_slice
  end

  def get_cursed_weapon(item_id : Int) : CursedWeapon?
    CURSED_WEAPONS[item_id]?
  end

  def give_passive(item_id : Int)
    CURSED_WEAPONS[item_id].give_skill
  rescue e
    warn e # L2J doesn't do anything with the error
  end
end
