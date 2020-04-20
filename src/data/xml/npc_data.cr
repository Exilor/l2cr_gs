require "../../models/actor/templates/l2_npc_template"
require "../../models/holders/minion_holder"
require "../../models/drops/drop_list_scope"

module NpcData
  extend self
  extend XMLReader
  extend Synchronizable

  private NPCS = Concurrent::Map(Int32, L2NpcTemplate).new
  private CLANS = Concurrent::Map(String, Int32).new

  private class_getter! minion_data : MinionData

  def load
    sync do
      debug "Loading NPC data..."
      timer = Timer.new
      @@minion_data = MinionData.new
      parse_datapack_directory("stats/npcs")
      info { "Loaded #{NPCS.size} NPC templates in #{timer} s." }
      if Config.custom_npc_data
        timer.start
        count = NPCS.size
        parse_datapack_directory("stats/npcs/custom", true)
        info { "Loaded #{NPCS.size - count} custom NPC templates in #{timer} s." }
      end
      @@minion_data = nil
      load_npcs_skill_learn
    end
  end

  def [](id : Int32) : L2NpcTemplate
    NPCS.fetch(id) { raise "NPC with id #{id} not found" }
  end

  def []?(id : Int32) : L2NpcTemplate?
    NPCS[id]?
  end

  private def parse_document(doc, file)
    find_element(doc, "list") do |n|
      find_element(n, "npc") do |d|
        npc_id = parse_int(d, "id")

        set = StatsSet.new

        parameters = nil
        skills = nil
        clans = nil
        ignore_clan_npc_ids = nil
        drop_lists = nil

        set["id"] = npc_id
        add_from_node(d, set, "displayId")
        add_from_node(d, set, "level")
        add_from_node(d, set, "type")
        add_from_node(d, set, "name")
        add_from_node(d, set, "usingServerSideName")
        add_from_node(d, set, "title")
        add_from_node(d, set, "usingServerSideTitle")

        each_element(d) do |npc, npc_name|
          case npc_name.casecmp
          when "parameters"
            parameters ||= StatsSet.new
            each_element(npc) do |params_node, params_node_name|
              case params_node_name.casecmp
              when "param"
                parameters[parse_string(params_node, "name")] = parse_string(params_node, "value")
              when "skill"
                name = parse_string(params_node, "name")
                id = parse_int(params_node, "id")
                level = parse_int(params_node, "level")
                skill = SkillHolder.new(id, level)
                parameters[name] = skill
              when "minions"
                minions = Array(MinionHolder).new(1)
                find_element(params_node, "npc") do |minions_node|
                  minion_id = parse_int(minions_node, "id")
                  minion_count = parse_int(minions_node, "count")
                  minion_respawn = parse_long(minions_node, "respawnTime")
                  minion_point = parse_int(minions_node, "weightPoint")
                  minions << MinionHolder.new(minion_id, minion_count, minion_respawn, minion_point)
                end

                unless minions.empty?
                  parameters[params_node["name"]] = minions
                end
              else
                # [automatically added else]
              end
            end
          when "race", "sex"
            set[npc_name] = get_content(npc).upcase
          when "equipment"
            add_from_node(npc, set, "chestId", "chest")
            add_from_node(npc, set, "rhandId", "rhand")
            add_from_node(npc, set, "lhandId", "lhand")
            add_from_node(npc, set, "weaponEnchant")
          when "acquire"
            add_from_node(npc, set, "expRate")
            add_from_node(npc, set, "sp")
            add_from_node(npc, set, "raidPoints")
          when "stats"
            add_from_node(npc, set, "baseSTR", "str")
            add_from_node(npc, set, "baseINT", "int")
            add_from_node(npc, set, "baseDEX", "dex")
            add_from_node(npc, set, "baseWIT", "wit")
            add_from_node(npc, set, "baseCON", "con")
            add_from_node(npc, set, "baseMEN", "men")

            each_element(npc) do |stat, stat_name|
              case stat_name.casecmp
              when "vitals"
                add_from_node(stat, set, "baseHpMax", "hp")
                add_from_node(stat, set, "baseHpReg", "hpRegen")
                add_from_node(stat, set, "baseMpMax", "mp")
                add_from_node(stat, set, "baseMpReg", "mpRegen")
              when "attack"
                add_from_node(stat, set, "basePAtk", "physical")
                add_from_node(stat, set, "baseMAtk", "magical")
                add_from_node(stat, set, "baseRndDam", "random")
                add_from_node(stat, set, "baseCritRate", "critical")
                add_from_node(stat, set, "accuracy", "accuracy")
                add_from_node(stat, set, "basePAtkSpd", "attackSpeed")
                add_from_node(stat, set, "reuseDelay", "reuseDelay")
                add_from_node(stat, set, "baseAtkType", "type")
                add_from_node(stat, set, "baseAtkRange", "range")
                add_from_node(stat, set, "distance", "distance")
                add_from_node(stat, set, "width", "width")
              when "defence"
                add_from_node(stat, set, "basePDef", "physical")
                add_from_node(stat, set, "baseMDef", "magical")
                add_from_node(stat, set, "evasion", "evasion")
                add_from_node(stat, set, "baseShldDef", "shield")
                add_from_node(stat, set, "baseShldRate", "shieldRate")
              when "attribute"
                each_element(stat) do |st, st_name|
                  case st_name.casecmp
                  when "attack"
                    case parse_string(st, "type").casecmp
                    when "FIRE"
                      add_from_node(st, set, "baseFire", "value")
                    when "WATER"
                      add_from_node(st, set, "baseWater", "value")
                    when "WIND"
                      add_from_node(st, set, "baseWind", "value")
                    when "EARTH"
                      add_from_node(st, set, "baseEarth", "value")
                    when "DARK"
                      add_from_node(st, set, "baseDark", "value")
                    when "HOLY"
                      add_from_node(st, set, "baseHoly", "value")
                    else
                      # [automatically added else]
                    end
                  when "defence"
                    add_from_node(st, set, "baseFireRes", "fire")
                    add_from_node(st, set, "baseWaterRes", "water")
                    add_from_node(st, set, "baseWindRes", "wind")
                    add_from_node(st, set, "baseEarthRes", "earth")
                    add_from_node(st, set, "baseHolyRes", "holy")
                    add_from_node(st, set, "baseDarkRes", "dark")
                    add_from_node(st, set, "baseElementRes", "default")
                  else
                    # [automatically added else]
                  end
                end
              when "speed"
                each_element(stat) do |spd, spd_name|
                  case spd_name.casecmp
                  when "walk"
                    add_from_node(spd, set, "baseWalkSpd", "ground")
                    add_from_node(spd, set, "baseSwimWalkSpd", "swim")
                    add_from_node(spd, set, "baseFlyWalkSpd", "fly")
                  when "run"
                    add_from_node(spd, set, "baseRunSpd", "ground")
                    add_from_node(spd, set, "baseSwimRunSpd", "swim")
                    add_from_node(spd, set, "baseFlyRunSpd", "fly")
                  else
                    # [automatically added else]
                  end

                end
              when "hittime"
                set["hitTime"] = get_content(stat)
              else
                # [automatically added else]
              end
            end
          when "status"
            add_from_node(npc, set, "unique")
            add_from_node(npc, set, "attackable")
            add_from_node(npc, set, "targetable")
            add_from_node(npc, set, "undying")
            add_from_node(npc, set, "showName")
            add_from_node(npc, set, "flying")
            add_from_node(npc, set, "canMove")
            add_from_node(npc, set, "noSleepMode")
            add_from_node(npc, set, "passableDoor")
            add_from_node(npc, set, "hasSummoner")
            add_from_node(npc, set, "canBeSown")
          when "skilllist"
            skills = {} of Int32 => Skill
            find_element(npc, "skill") do |sn|
              id = parse_int(sn, "id")
              level = parse_int(sn, "level")
              if skill = SkillData[id, level]?
                skills[id] = skill
              else
                warn { "No skill found with id #{id} and level #{level}." }
              end
            end
          when "shots"
            add_from_node(npc, set, "soulShot", "soul")
            add_from_node(npc, set, "spiritShot", "spirit")
            add_from_node(npc, set, "shotShotChance", "shotChance")
            add_from_node(npc, set, "spiritShotChance", "spiritChance")
          when "corpsetime"
            set["corpseTime"] = get_content(npc)
          when "excrteffect"
            set["exCrtEffect"] = get_content(npc)
          when "snpcprophprate"
            set["sNpcPropHpRate"] = get_content(npc)
          when "ai"
             add_from_node(npc, set, "aiType", "type")
            add_from_node(npc, set, "aggroRange")
            add_from_node(npc, set, "clanHelpRange")
            add_from_node(npc, set, "dodge")
            add_from_node(npc, set, "isChaos")
            add_from_node(npc, set, "isAggressive")
            each_element(npc) do |ai, ai_name|
              case ai_name.casecmp
              when "skill"
                add_from_node(ai, set, "minSkillChance", "minChance")
                add_from_node(ai, set, "maxSkillChance", "maxChance")
                add_from_node(ai, set, "primarySkillId", "primaryId")
                add_from_node(ai, set, "shortRangeSkillId", "shortRangeId")
                add_from_node(ai, set, "shortRangeSkillChance", "shortRangeChance")
                add_from_node(ai, set, "longRangeSkillId", "longRangeId")
                add_from_node(ai, set, "longRangeSkillChance", "longRangeChance")
              when "clanlist"
                each_element(ai) do |cln, cln_name|
                  if cln_name.casecmp?("clan")
                    clans ||= Set(Int32).new
                    clans << get_or_create_clan_id(get_content(cln))
                  elsif cln_name.casecmp?("ignorenpcid")
                    ignore_clan_npc_ids ||= Set(Int32).new
                    ignore_clan_npc_ids << get_content(cln).to_i
                  end
                end
              else
                # [automatically added else]
              end
            end
          when "droplists"
            each_element(npc) do |dn, dn_name|
              drop_list_scope = DropListScope.parse(dn_name)
              drop_lists ||= EnumMap(DropListScope, Slice(IDropItem)).new
              drop_list = [] of IDropItem
              parse_drop_list(dn, drop_list_scope, drop_list)
              drop_lists[drop_list_scope] = drop_list.to_slice
            end
          when "collision"
            each_element(npc) do |col, col_name|
              case col_name.casecmp
              when "radius"
                add_from_node(col, set, "collisionRadius", "normal")
                add_from_node(col, set, "collisionRadiusGrown", "grown")
              when "height"
                add_from_node(col, set, "collisionHeight", "normal")
                add_from_node(col, set, "collisionHeightGrown", "grown")
              else
                # [automatically added else]
              end
            end
          else
            # [automatically added else]
          end
        end

        if template = NPCS[npc_id]?
          template.set(set)
        else
          template = L2NpcTemplate.new(set)
          NPCS[template.id] = template
        end

        if tmp = minion_data.minions[npc_id]?
          parameters ||= StatsSet.new
          parameters["Privates"] ||= tmp
        end

        if parameters && !parameters.empty?
          template.parameters = parameters
        end

        if skills
          ai_skill_lists = nil
          skills.each_value do |skill|
            next if skill.passive?
            ai_skill_lists ||= EnumMap(AISkillScope, Array(Skill)).new
            ai_skill_scopes = [] of AISkillScope

            if skill.cast_range <= 150
              range_scope = AISkillScope::SHORT_RANGE
            else
              range_scope = AISkillScope::LONG_RANGE
            end

            if skill.suicide_attack?
              ai_skill_scopes << AISkillScope::SUICIDE
            else
              ai_skill_scopes << AISkillScope::GENERAL

              if skill.continuous?
                if !skill.debuff?
                  ai_skill_scopes << AISkillScope::BUFF
                else
                  ai_skill_scopes << AISkillScope::DEBUFF << AISkillScope::COT
                  ai_skill_scopes << range_scope
                end
              else
                if skill.has_effect_type?(EffectType::DISPEL)
                  ai_skill_scopes << AISkillScope::NEGATIVE << range_scope
                elsif skill.has_effect_type?(EffectType::HP)
                  ai_skill_scopes << AISkillScope::HEAL
                elsif skill.has_effect_type?(EffectType::PHYSICAL_ATTACK, EffectType::MAGICAL_ATTACK, EffectType::HP_DRAIN)
                  ai_skill_scopes << AISkillScope::ATTACK << AISkillScope::UNIVERSAL
                  ai_skill_scopes << range_scope
                elsif skill.has_effect_type?(EffectType::SLEEP)
                  ai_skill_scopes << AISkillScope::IMMOBILIZE
                elsif skill.has_effect_type?(EffectType::STUN, EffectType::ROOT)
                  ai_skill_scopes << AISkillScope::IMMOBILIZE << range_scope
                elsif skill.has_effect_type?(EffectType::MUTE, EffectType::FEAR)
                  ai_skill_scopes << AISkillScope::COT << range_scope
                elsif skill.has_effect_type?(EffectType::PARALYZE)
                  ai_skill_scopes << AISkillScope::IMMOBILIZE << range_scope
                elsif skill.has_effect_type?(EffectType::DMG_OVER_TIME)
                  ai_skill_scopes << range_scope
                elsif skill.has_effect_type?(EffectType::RESURRECTION)
                  ai_skill_scopes << AISkillScope::RES
                else
                  ai_skill_scopes << AISkillScope::UNIVERSAL
                end
              end
            end

            ai_skill_scopes.each do |scope|
              ai_skills = ai_skill_lists[scope]?
              unless ai_skills
                ai_skills = [] of Skill
                ai_skill_lists[scope] = ai_skills
              end
              ai_skills << skill
            end
          end
          template.skills = skills
          template.ai_skill_lists = ai_skill_lists
        else
          template.skills = nil
          template.ai_skill_lists = nil
        end

        template.clans = clans
        template.ignore_clan_npc_ids = ignore_clan_npc_ids
        template.drop_lists = drop_lists
      end
    end
  end

  private def parse_drop_list(drop_list_node, drop_list_scope, drops)
    each_element(drop_list_node) do |dn, dn_name|
      if dn_name.casecmp?("group")
        drop_item = drop_list_scope.new_grouped_drop_item(parse_double(dn, "chance"))
        grouped_drop_list = [] of IDropItem
        each_element(dn) do |gn|
          parse_drop_list_item(gn, drop_list_scope, grouped_drop_list)
        end
        items = Array(GeneralDropItem).new(grouped_drop_list.size)
        grouped_drop_list.each do |item|
          if item.is_a?(GeneralDropItem)
            items << item
          else
            warn { "Grouped general drop item supports only general drop item (#{item.class})." }
          end
        end
        drop_item.items = items
        drops << drop_item
      else
        parse_drop_list_item(dn, drop_list_scope, drops)
      end
    end
  end

  private def parse_drop_list_item(dli, drop_list_scope, drops)
    if get_node_name(dli).casecmp?("item")
      id = parse_int(dli, "id")
      min = parse_long(dli, "min")
      max = parse_long(dli, "max")
      chance = parse_double(dli, "chance")
      drop_item = drop_list_scope.new_drop_item(id, min, max, chance)
      drops << drop_item
    end
  end

  private def get_or_create_clan_id(name)
    name = name.upcase
    CLANS.fetch(name) { CLANS[name] = CLANS.size }
  end

  private def load_npcs_skill_learn
    NPCS.each_value do |template|
      if teach_info = SkillLearnData[template.id]?
        template.add_teach_info(teach_info)
      end
    end
  end

  def get_clan_id(clan_name : String) : Int32
    CLANS.fetch(clan_name.upcase, -1)
  end

  def get_template_by_name(name : String) : L2NpcTemplate?
    NPCS.find_value &.name.casecmp?(name)
  end

  def templates : Enumerable(L2NpcTemplate)
    NPCS.local_each_value
  end

  def get_templates(& : L2NpcTemplate ->) : Array(L2NpcTemplate)
    ret = [] of L2NpcTemplate
    templates.each { |template| ret << template if yield template }
    ret
  end

  def get_all_of_level(*lvls : Int32) : Array(L2NpcTemplate)
    get_templates { |template| lvls.includes?(template.level) }
  end

  def get_all_monsters_of_level(*lvls : Int32) : Array(L2NpcTemplate)
    get_templates do |template|
      lvls.includes?(template.level) && template.type?("L2Monster")
    end
  end

  def get_all_npc_starting_with(text : String) : Array(L2NpcTemplate)
    get_templates do |template|
      template.type?("L2Npc") && template.name.starts_with?(text)
    end
  end

  def get_all_npc_of_class_type(*types) : Array(L2NpcTemplate)
    get_templates { |template| types.any? &.casecmp?(template.type) }
  end

  private struct MinionData
    include XMLReader
    include Loggable

    getter minions

    @minions = {} of Int32 => Array(MinionHolder)

    def initialize
      parse_datapack_file("minionData.xml")
      info { "Loaded #{@minions.size} minion data." }
    end

    private def parse_document(doc, file)
      find_element(doc, "list") do |node|
        find_element(node, "npc") do |list|
          minions = [] of MinionHolder
          id = parse_int(list, "id")
          find_element(list, "minion") do |npc|
            id2 = parse_int(npc, "id")
            count = parse_int(npc, "count")
            respawn = parse_long(npc, "respawnTime")
            minions << MinionHolder.new(id2, count, respawn, 0)
          end
          @minions[id] = minions
        end
      end
    end
  end
end
