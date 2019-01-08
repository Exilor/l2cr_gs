module GameDB
  module PlayerDAOMySQLImpl
    extend self
    extend PlayerDAO
    extend Loggable

    private INSERT = "INSERT INTO characters (account_name,charId,char_name,level,maxHp,curHp,maxCp,curCp,maxMp,curMp,face,hairStyle,hairColor,sex,exp,sp,karma,fame,pvpkills,pkkills,clanid,race,classid,deletetime,cancraft,title,title_color,accesslevel,online,isin7sdungeon,clan_privs,wantspeace,base_class,newbie,nobless,power_grade,createDate) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    private SELECT = "SELECT * FROM characters WHERE charId=?"
    private UPDATE = "UPDATE characters SET level=?,maxHp=?,curHp=?,maxCp=?,curCp=?,maxMp=?,curMp=?,face=?,hairStyle=?,hairColor=?,sex=?,heading=?,x=?,y=?,z=?,exp=?,expBeforeDeath=?,sp=?,karma=?,fame=?,pvpkills=?,pkkills=?,clanid=?,race=?,classid=?,deletetime=?,title=?,title_color=?,accesslevel=?,online=?,isin7sdungeon=?,clan_privs=?,wantspeace=?,base_class=?,onlinetime=?,newbie=?,nobless=?,power_grade=?,subpledge=?,lvl_joined_academy=?,apprentice=?,sponsor=?,clan_join_expiry_time=?,clan_create_expiry_time=?,char_name=?,death_penalty_level=?,bookmarkslot=?,vitality_points=?,language=? WHERE charId=?"
    private UPDATE_ONLINE = "UPDATE characters SET online=?, lastAccess=? WHERE charId=?"
    private SELECT_CHARACTERS = "SELECT charId, char_name FROM characters WHERE account_name=? AND charId<>?"

    def load(l2id : Int32) : L2PcInstance?
      pc = nil

      GameDB.each(SELECT, l2id) do |rs|
        active_class_id = rs.get_u8("classid").to_i32
        female = rs.get_i32("sex") != Sex::MALE.to_i
        face = rs.get_i8("face")
        hair_color = rs.get_i8("hairColor")
        hair_style = rs.get_i8("hairStyle")
        app = PcAppearance.new(face, hair_color, hair_style, female)
        account = rs.get_string("account_name")

        pc = L2PcInstance.new(l2id, active_class_id, account, app)
        pc.name = rs.get_string("char_name")
        pc.last_access = rs.get_i64("lastAccess")
        pc.exp = rs.get_i64("exp")
        pc.exp_before_death = rs.get_i64("expBeforeDeath")
        pc.level = rs.get_i32("level")
        pc.sp = rs.get_i32("sp")
        pc.wants_peace = rs.get_i32("wantspeace")
        pc.heading = rs.get_i32("heading")
        pc.karma = rs.get_i32("karma")
        pc.fame = rs.get_i32("fame")
        pc.pvp_kills = rs.get_i32("pvpkills")
        pc.pk_kills = rs.get_i32("pkkills")
        pc.online_time = rs.get_i64("onlinetime")
        pc.newbie = rs.get_i32("newbie")
        pc.noble = rs.get_i32("nobless") == 1

        time = Time.ms

        pc.clan_join_expiry_time = rs.get_i64("clan_join_expiry_time")
        if pc.clan_join_expiry_time < time
          pc.clan_join_expiry_time = 0
        end
        pc.clan_create_expiry_time = rs.get_i64("clan_create_expiry_time")
        if pc.clan_create_expiry_time < time
          pc.clan_create_expiry_time = 0
        end

        pc.power_grade = rs.get_i32("power_grade")
        pc.pledge_type = rs.get_i32("subpledge")
        # pc.apprentice = rs.get_i32("apprentice") # commented out in L2J

        pc.delete_timer = rs.get_i64("deletetime")
        pc.title = rs.get_string("title")
        pc.access_level = rs.get_i32("accesslevel")
        pc.appearance.title_color = rs.get_i32("title_color")
        pc.fists_weapon_item = pc.find_fists_weapon_item(active_class_id)
        pc.uptime = time

        pc.current_cp = rs.get_f64("curCp")
        pc.current_hp = rs.get_f64("curHp")
        pc.current_mp = rs.get_f64("curMp")
        pc.class_index = 0
        pc.base_class = rs.get_u8("base_class").to_i32

        GameDB.subclass.load(pc)

        if active_class_id != pc.base_class
          pc.subclasses.each_value do |subclass|
            if subclass.class_id == active_class_id
              pc.class_index = subclass.class_index
            end
          end
        end

        if pc.class_index == 0 && active_class_id != pc.base_class
          pc.class_id = pc.base_class
          warn "Reverted to base class."
        else
          pc.active_class = active_class_id
        end

        pc.apprentice = rs.get_i32("apprentice")
        pc.sponsor = rs.get_i32("sponsor")
        pc.lvl_joined_academy = rs.get_i32("lvl_joined_academy")
        pc.in_7s_dungeon = rs.get_i32("isin7sdungeon") == 1

        CursedWeaponsManager.check_player(pc)

        pc.death_penalty_buff_level = rs.get_i32("death_penalty_level")
        pc.set_vitality_points(rs.get_i32("vitality_points"), true)

        pc.create_date.time = rs.get_time("createDate")

        x, y, z = rs.get_i32("x"), rs.get_i32("y"), rs.get_i32("z")
        pc.set_xyz_invisible(x, y, z)

        pc.clan = ClanTable.get_clan(rs.get_i32("clanid"))
        if pc.clan?
          if pc.clan.leader_id != pc.l2id
            if pc.power_grade == 0
              pc.power_grade = 5
            end
            pc.clan_privileges = pc.clan.get_rank_privs(pc.power_grade)
          else
            pc.clan_privileges.set_all
            pc.power_grade = 1
          end
          pc.pledge_class = L2ClanMember.calculate_pledge_class(pc)
        else
          if pc.noble?
            pc.pledge_class = 5
          end
          if pc.hero?
            pc.pledge_class = 8
          end
          pc.clan_privileges.clear
        end
      end

      pc
    end

    def load_characters(pc : L2PcInstance)
      GameDB.each(SELECT_CHARACTERS, pc.account_name, pc.l2id) do |rs|
        id = rs.get_i32("charId")
        name = rs.get_string("char_name")
        pc.account_chars[id] = name
      end
    rescue e
      error e
    end

    def insert(pc : L2PcInstance) : Bool
      GameDB.exec(
        INSERT,
        pc.account_name,
        pc.l2id,
        pc.name,
        pc.base_level,
        pc.max_hp,
        pc.current_hp,
        pc.max_cp,
        pc.current_cp,
        pc.max_mp,
        pc.current_mp,
        pc.appearance.face.to_i32,
        pc.appearance.hair_style.to_i32,
        pc.appearance.hair_color.to_i32,
        pc.appearance.sex ? 1 : 0,
        pc.base_exp,
        pc.base_sp,
        pc.karma,
        pc.fame,
        pc.pvp_kills,
        pc.pk_kills,
        pc.clan_id,
        pc.race.to_i,
        pc.class_id.to_i,
        pc.delete_timer,
        pc.has_dwarven_craft? ? 1 : 0,
        pc.title,
        pc.appearance.title_color,
        pc.access_level.level,
        pc.online_int,
        pc.in_7s_dungeon? ? 1 : 0,
        pc.clan_privileges.bitmask,
        pc.wants_peace,
        pc.base_class,
        pc.newbie,
        pc.noble? ? 1 : 0,
        0, # power grade, long
        Time.from_ms(pc.create_date.ms)# new Timestamp(pc.getCreateDate.getTimeInMillis))
      )

      true
    rescue e
      error e
      false
    end

    def store_char_base(pc : L2PcInstance)
      total_online_time = pc.online_time
      if pc.online_begin_time > 0
        total_online_time += (Time.ms - pc.online_begin_time) / 1000
      end

      GameDB.exec(
        UPDATE,
        pc.base_level,
        pc.max_hp,
        pc.current_hp,
        pc.max_cp,
        pc.current_cp,
        pc.max_mp,
        pc.current_mp,
        pc.appearance.face.to_i32,
        pc.appearance.hair_style.to_i32,
        pc.appearance.hair_color.to_i32,
        pc.appearance.sex ? 1 : 0,
        pc.heading,
        pc.in_observer_mode? ? pc.last_location.x : pc.x,
        pc.in_observer_mode? ? pc.last_location.y : pc.y,
        pc.in_observer_mode? ? pc.last_location.z : pc.z,
        pc.base_exp,
        pc.exp_before_death,
        pc.base_sp,
        pc.karma,
        pc.fame,
        pc.pvp_kills,
        pc.pk_kills,
        pc.clan_id,
        pc.race.to_i,
        pc.class_id.to_i,
        pc.delete_timer,
        pc.title,
        pc.appearance.title_color,
        pc.access_level.level,
        pc.online_int,
        pc.in_7s_dungeon? ? 1 : 0,
        pc.clan_privileges.bitmask,
        pc.wants_peace,
        pc.base_class,
        total_online_time,
        pc.newbie,
        pc.noble? ? 1 : 0,
        pc.power_grade,
        pc.pledge_type,
        pc.lvl_joined_academy,
        pc.apprentice,
        pc.sponsor,
        pc.clan_join_expiry_time,
        pc.clan_create_expiry_time,
        pc.name,
        pc.death_penalty_buff_level,
        pc.bookmark_slot,
        pc.vitality_points,
        pc.lang,
        pc.l2id
      )
      info "#{pc.name}'s basic data saved."
    rescue e
      p [pc.class_id.to_i, pc.base_class]
      error e
    end

    def update_online_status(pc : L2PcInstance)
      GameDB.exec(
        UPDATE_ONLINE,
        pc.online_int,
        Time.ms,
        pc.l2id
      )
    rescue e
      error e
    end
  end
end
