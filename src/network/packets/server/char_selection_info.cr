require "../../../models/char_select_info_package"

class Packets::Outgoing::CharSelectionInfo < GameServerPacket
  extend Loggable

  getter char_info : Array(CharSelectInfoPackage)

  def initialize(@account : String, @session_id : Int32, @active_id : Int32 = -1)
    @char_info = CharSelectionInfo.load_character_select_info(account)
  end

  def write_impl
    c 0x09

    d @char_info.size
    d Config.max_characters_number_per_account
    c 0x00

    if @active_id == -1
      last_access = 0
      @char_info.each_with_index do |cip, i|
        if last_access < cip.last_access
          @active_id = i
          last_access = cip.last_access
        end
      end
    end

    @char_info.each_with_index do |cip, i|
      s cip.name
      d cip.l2id
      s @account
      d @session_id
      d cip.clan_id
      d 0x00

      d cip.sex
      d cip.race
      d cip.base_class_id

      d 0x01

      l cip

      f cip.current_hp
      f cip.current_mp

      d cip.sp
      q cip.exp
      f ExperienceData.get_percent_from_current_level(cip.exp, cip.level)

      d cip.level

      d cip.karma
      d cip.pk_kills
      d cip.pvp_kills

      7.times { d 0x00 }

      PAPERDOLL_ORDER.each do |slot|
        d cip.get_paperdoll_item_id(slot)
      end

      d cip.hair_style
      d cip.hair_color
      d cip.face

      f cip.max_hp
      f cip.max_mp

      d cip.delete_time > 0 ? (cip.delete_time - Time.ms) / 1000 : 0
      d cip.class_id
      d i == @active_id ? 0x01 : 0x00

      c Math.min(cip.enchant_effect, 127)
      d cip.augmentation_id

      d 0x00 # transformation

      4.times { d 0 } # pet id, level, pet food
      2.times { f 0.0 } # pet max hp, max mp

      d cip.vitality_points
    end
  end

  protected def self.load_character_select_info(account)
    char_list = [] of CharSelectInfoPackage

    begin
      sql = "SELECT * FROM characters WHERE account_name=? ORDER BY createDate"
      GameDB.each(sql, account) do |rs|
        if package = restore_char(rs)
          # p package
          char_list << package
        end
      end
    rescue e
      error "Could not restore char info."
      error e
    end

    char_list
  end

  protected def self.restore_char(rs) : CharSelectInfoPackage?
    l2id = rs.get_i32("charId")
    name = rs.get_string("char_name")

    delete_time = rs.get_i64("deletetime")
    if delete_time > 0
      debug "TODO: delete #{name}."
    end

    cip = CharSelectInfoPackage.new(l2id, name)
    cip.access_level = rs.get_i32("accesslevel")
    cip.level = rs.get_i32("level")
    cip.max_hp = rs.get_i32("maxhp")
    cip.current_hp = rs.get_f64("curhp")
    cip.max_mp = rs.get_i32("maxmp")
    cip.current_mp = rs.get_f64("curmp")
    cip.karma = rs.get_i32("karma")
    cip.pk_kills = rs.get_i32("pkkills")
    cip.pvp_kills = rs.get_i32("pvpkills")
    cip.face = rs.get_i32("face")
    cip.hair_style = rs.get_i32("hairstyle")
    cip.hair_color = rs.get_i32("haircolor")
    cip.sex = rs.get_i32("sex")

    cip.exp = rs.get_i64("exp")
    cip.sp = rs.get_i32("sp")
    cip.vitality_points = rs.get_i32("vitality_points")
    cip.clan_id = rs.get_i32("clanid")

    cip.race = rs.get_i32("race")

    base_class_id = rs.get_u8("base_class").to_i32
    active_class_id = rs.get_u8("classid").to_i32

    cip.x = rs.get_i32("x")
    cip.y = rs.get_i32("y")
    cip.z = rs.get_i32("z")

    # if Config.multilang_enable
    #   lang = rs.get_string("lang")
    #   unless Config.multilang_allowed.includes?(lang)
    #     lang = Config.multilang_default
    #   end
    #   cip.html_prefix = "data/lang/#{lang}/"
    # end

    if base_class_id != active_class_id
      load_character_subclass_info(cip, l2id, active_class_id)
    end

    cip.class_id = active_class_id

    weapon_id = cip.get_paperdoll_l2id(Inventory::RHAND)
    if weapon_id < 1
      weapon_id = cip.get_paperdoll_l2id(Inventory::RHAND) # L2J really does this
    end

    if weapon_id > 0
      sql = "SELECT augAttributes FROM item_attributes WHERE itemId=?"
      GameDB.each(sql, weapon_id) do |rs|
        augment = rs.get_i32("augAttributes")
        cip.augmentation_id = augment == -1 ? 0 : augment
      end
    end

    if base_class_id == 0 && active_class_id > 0
      cip.base_class_id = active_class_id
    else
      cip.base_class_id = base_class_id
    end

    cip.delete_time = delete_time
    cip.last_access = rs.get_i64("lastAccess")

    cip
  end

  private def self.load_character_subclass_info(cip, l2id, active_class_id)
    sql = "SELECT exp, sp, level FROM character_subclasses WHERE charId=? && class_id=? ORDER BY charId"
    GameDB.each(sql, l2id, active_class_id) do |rs|
      cip.exp = rs.get_i64("exp")
      cip.sp = rs.get_i32("sp")
      cip.level = rs.get_i32("level")
    end
  rescue e
    error "Could not restore char subclass info."
    error e
  end
end
