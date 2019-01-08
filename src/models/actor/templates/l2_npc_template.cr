require "./l2_char_template"
require "../../../enums/sex"
require "../../../enums/ai_type"
require "../../../enums/ai_skill_scope"

class L2NpcTemplate < L2CharTemplate
  @clans : Set(Int32)?
  getter ignore_clan_npc_ids : Set(Int32)?
  getter id = 0
  getter display_id = 0
  getter level = 0i8
  getter type = ""
  getter name = ""
  getter title = ""
  getter sex = Sex::ETC
  getter teach_info = [] of ClassId
  getter drop_lists : EnumMap(DropListScope, Slice(IDropItem))?
  getter ai_skill_lists : EnumMap(AISkillScope, Array(Skill))?
  getter chest_id = 0
  getter r_hand_id = 0
  getter l_hand_id = 0
  getter weapon_enchant = 0
  getter exp_rate = 0.0
  getter sp = 0.0
  getter raid_points = 0.0
  getter corpse_time = 0
  getter ai_type = AIType::FIGHTER
  getter aggro_range = 0
  getter clan_help_range = 0
  getter dodge = 0
  getter soulshot = 0
  getter spiritshot = 0
  getter soulshot_chance = 0
  getter spiritshot_chance = 0
  getter min_skill_chance = 0
  getter max_skill_chance = 0
  getter collision_radius_grown = 0.0
  getter collision_height_grown = 0.0
  getter? using_server_side_name = false
  getter? using_server_side_title = false
  getter? unique = false
  getter? attackable = false
  getter? targetable = false
  getter? undying = false
  getter? show_name = false
  getter? flying = false
  getter? can_move = false
  getter? no_sleep_mode = false
  getter? passable_door = false
  getter? has_summoner = false
  getter? can_be_sown = false
  getter? chaos = false
  getter? aggressive = false
  setter skills : Hash(Int32, Skill)?
  property parameters : StatsSet = StatsSet::EMPTY

  def initialize(set : StatsSet)
    super
  end

  def set(set : StatsSet)
    super

    @id = set.get_i32("id")
    @display_id = set.get_i32("displayId", @id)
    @level = set.get_i8("level", 70)
    @type = set.get_string("type", "L2Npc")
    @name = set.get_string("name", "")
    @using_server_side_name = set.get_bool("usingServerSideName", false)
    @title = set.get_string("title", "")
    @using_server_side_title = set.get_bool("usingServerSideTitle", false)
    @race = set.get_enum("race", Race, Race::NONE)
    @sex = set.get_enum("sex", Sex, Sex::ETC)

    @chest_id = set.get_i32("chestId", 0)
    @r_hand_id = set.get_i32("rhandId", 0)
    @l_hand_id = set.get_i32("lhandId", 0)
    @weapon_enchant = set.get_i32("weaponEnchant", 0)

    @exp_rate = set.get_f64("expRate", 0)
    @sp = set.get_f64("sp", 0)
    @raid_points = set.get_f64("raidPoints", 0)

    @unique = set.get_bool("unique", false)
    @attackable = set.get_bool("attackable", true)
    @targetable = set.get_bool("targetable", true)
    @undying = set.get_bool("undying", true)
    @show_name = set.get_bool("showName", true)
    @flying = set.get_bool("flying", false)
    @can_move = set.get_bool("canMove", true)
    @no_sleep_mode = set.get_bool("noSleepMode", false)
    @passable_door = set.get_bool("passableDoor", false)
    @has_summoner = set.get_bool("hasSummoner", false)
    @can_be_sown = set.get_bool("canBeSown", false)

    @corpse_time = set.get_i32("corpseTime", Config.default_corpse_time)

    @ai_type = set.get_enum("aiType", AIType, AIType::FIGHTER)
    @aggro_range = set.get_i32("aggroRange", 0)
    @clan_help_range = set.get_i32("clanHelpRange", 0)
    @dodge = set.get_i32("dodge", 0)
    @chaos = set.get_bool("isChaos", false)
    @aggressive = set.get_bool("isAggressive", true)

    @soulshot = set.get_i32("soulShot", 0)
    @spiritshot = set.get_i32("spiritShot", 0)
    @soulshot_chance = set.get_i32("shotShotChance", 0)
    @spiritshot_chance = set.get_i32("spiritShotChance", 0)

    @min_skill_chance = set.get_i32("minSkillChance", 7)
    @max_skill_chance = set.get_i32("maxSkillChance", 15)

    @collision_radius_grown = set.get_f64("collisionRadiusGrown", 0)
    @collision_height_grown = set.get_f64("collisionHeightGrown", 0)
  end

  def type?(str : String) : Bool
    @type.casecmp?(str)
  end

  def skills : Hash(Int32, Skill)
    @skills || super
  end

  def ai_skill_lists=(lists : EnumMap(AISkillScope, Array(Skill))?)
    if lists
      @ai_skill_lists = lists
    end
  end

  def get_ai_skills(scope : AISkillScope) : Slice(Skill) | Array(Skill)
    if lists = @ai_skill_lists
      return lists.fetch(scope, Slice(Skill).empty)
    end

    Slice(Skill).empty
  end

  def add_teach_info(info : Enumerable(ClassId))
    @teach_info.concat(info)
  end

  def can_teach?(class_id : ClassId) : Bool
    @teach_info.includes?(class_id.level == 3 ? class_id.parent : class_id)
  end

  def clans
    @clans || Slice(Int32).empty
  end

  def clans=(clans : Set(Int32)?)
    if clans && !clans.empty?
      @clans = clans
    end
  end

  def ignore_clan_npc_ids=(ids : Set(Int32)?)
    if ids && !ids.empty?
      @ignore_clan_npc_ids = ids
    end
  end

  def drop_lists=(drop_lists : EnumMap(DropListScope, Slice(IDropItem))?)
    if drop_lists
      @drop_lists = drop_lists
    end
  end

  def clan?(*clan_names : String) : Bool
    return false unless clans = @clans

    clan_id = NpcData.get_clan_id("ALL")
    if clans.includes?(clan_id)
      return true
    end

    clan_names.any? do |name|
      clan_id = NpcData.get_clan_id(name)
      clans.includes?(clan_id)
    end
  end

  def clan?(clans : Enumerable(Int32)?) : Bool
    return false unless clans
    return false unless clan_set = @clans

    clan_id = NpcData.get_clan_id("ALL")
    if clan_set.includes?(clan_id)
      return true
    end

    clans.any? { |id| clan_set.includes?(id) }
  end

  def get_drop_list(scope : DropListScope) : Slice(IDropItem)?
    if lists = @drop_lists
      lists[scope]?
    end
  end

  def calculate_drops(scope : DropListScope, victim : L2Character, killer : L2Character) : Array(ItemHolder)?
    unless drop_list = get_drop_list(scope)
      return
    end

    result = nil

    drop_list.each do |drop_item|
      drops : ItemHolder | Array(ItemHolder) | Nil
      drops = drop_item.calculate_drops(victim, killer)

      case drops
      when ItemHolder
        if result
          result << drops
        else
          result = [drops]
        end
      when Array
        unless drops.empty?
          if result
            result.concat(drops)
          else
            result = drops
          end
        end
      end
    end

    result
  end
end
