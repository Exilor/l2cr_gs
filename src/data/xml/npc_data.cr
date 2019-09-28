require "../../models/actor/templates/l2_npc_template"
require "../../models/holders/minion_holder"
require "../../models/drops/drop_list_scope"

module NpcData
  extend self
  extend XMLReader
  extend Synchronizable

  private NPCS = Hash(Int32, L2NpcTemplate).new
  private CLANS = Hash(String, Int32).new

  private class_getter! minion_data : MinionData

  def load
    sync do
      info "Loading NPC data..."
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
    doc.find_element("list") do |n|
      n.find_element("npc") do |d|
        npc_id = d["id"].to_i

        set = StatsSet.new

        parameters = nil
        skills = nil
        clans = nil
        ignore_clan_npc_ids = nil
        drop_lists = nil

        set["id"] = npc_id
        set.add(d, "displayId")
        set.add(d, "level")
        set.add(d, "type")
        set.add(d, "name")
        set.add(d, "usingServerSideName")
        set.add(d, "title")
        set.add(d, "usingServerSideTitle")

        d.each_element do |npc|
          case npc.name.casecmp
          when "parameters"
            parameters ||= StatsSet.new
            npc.each_element do |params_node|
              case params_node.name.casecmp
              when "param"
                parameters[params_node["name"]] = params_node["value"]
              when "skill"
                name = params_node["name"]
                id = params_node["id"].to_i
                level = params_node["level"].to_i
                skill = SkillHolder.new(id, level)
                parameters[name] = skill
              when "minions"
                minions = Array(MinionHolder).new(1)
                params_node.find_element("npc") do |minions_node|
                  minion_id = minions_node["id"].to_i
                  minion_count = minions_node["count"].to_i
                  minion_respawn = minions_node["respawnTime"].to_i64
                  minion_point = minions_node["weightPoint"].to_i
                  minions << MinionHolder.new(minion_id, minion_count, minion_respawn, minion_point)
                end

                unless minions.empty?
                  parameters[params_node["name"]] = minions
                end
              end
            end
          when "race", "sex"
            set[npc.name] = npc.content.upcase
          when "equipment"
            set.add(npc, "chestId", "chest")
            set.add(npc, "rhandId", "rhand")
            set.add(npc, "lhandId", "lhand")
            set.add(npc, "weaponEnchant")
          when "acquire"
            set.add(npc, "expRate")
            set.add(npc, "sp")
            set.add(npc, "raidPoints")
          when "stats"
            set.add(npc, "baseSTR", "str")
            set.add(npc, "baseINT", "int")
            set.add(npc, "baseDEX", "dex")
            set.add(npc, "baseWIT", "wit")
            set.add(npc, "baseCON", "con")
            set.add(npc, "baseMEN", "men")

            npc.each_element do |stat|
              case stat.name.casecmp
              when "vitals"
                set.add(stat, "baseHpMax", "hp")
                set.add(stat, "baseHpReg", "hpRegen")
                set.add(stat, "baseMpMax", "mp")
                set.add(stat, "baseMpReg", "mpRegen")
              when "attack"
                set.add(stat, "basePAtk", "physical")
                set.add(stat, "baseMAtk", "magical")
                set.add(stat, "baseRndDam", "random")
                set.add(stat, "baseCritRate", "critical")
                set.add(stat, "accuracy", "accuracy")
                set.add(stat, "basePAtkSpd", "attackSpeed")
                set.add(stat, "reuseDelay", "reuseDelay")
                set.add(stat, "baseAtkType", "type")
                set.add(stat, "baseAtkRange", "range")
                set.add(stat, "distance", "distance")
                set.add(stat, "width", "width")
              when "defence"
                set.add(stat, "basePDef", "physical")
                set.add(stat, "baseMDef", "magical")
                set.add(stat, "evasion", "evasion")
                set.add(stat, "baseShldDef", "shield")
                set.add(stat, "baseShldRate", "shieldRate")
              when "attribute"
                stat.each_element do |st|
                  case st.name.casecmp
                  when "attack"
                    case st["type"]?.try &.casecmp
                    when "FIRE"
                      set.add(st, "baseFire", "value")
                    when "WATER"
                      set.add(st, "baseWater", "value")
                    when "WIND"
                      set.add(st, "baseWind", "value")
                    when "EARTH"
                      set.add(st, "baseEarth", "value")
                    when "DARK"
                      set.add(st, "baseDark", "value")
                    when "HOLY"
                      set.add(st, "baseHoly", "value")
                    end
                  when "defence"
                    set.add(st, "baseFireRes", "fire")
                    set.add(st, "baseWaterRes", "water")
                    set.add(st, "baseWindRes", "wind")
                    set.add(st, "baseEarthRes", "earth")
                    set.add(st, "baseHolyRes", "holy")
                    set.add(st, "baseDarkRes", "dark")
                    set.add(st, "baseElementRes", "default")
                  end
                end
              when "speed"
                stat.each_element do |spd|
                  case spd.name.casecmp
                  when "walk"
                    set.add(spd, "baseWalkSpd", "ground")
                    set.add(spd, "baseSwimWalkSpd", "swim")
                    set.add(spd, "baseFlyWalkSpd", "fly")
                  when "run"
                    set.add(spd, "baseRunSpd", "ground")
                    set.add(spd, "baseSwimRunSpd", "swim")
                    set.add(spd, "baseFlyRunSpd", "fly")
                  end
                end
              when "hittime"
                set["hitTime"] = stat.content
              end
            end
          when "status"
            set.add(npc, "unique")
            set.add(npc, "attackable")
            set.add(npc, "targetable")
            set.add(npc, "undying")
            set.add(npc, "showName")
            set.add(npc, "flying")
            set.add(npc, "canMove")
            set.add(npc, "noSleepMode")
            set.add(npc, "passableDoor")
            set.add(npc, "hasSummoner")
            set.add(npc, "canBeSown")
          when "skilllist"
            skills = {} of Int32 => Skill
            npc.each_element do |sn|
              if sn.name.casecmp?("skill")
                id = sn["id"].to_i
                level = sn["level"].to_i
                if skill = SkillData[id, level]?
                  skills[id] = skill
                else
                  warn { "No skill found with ID #{id} and level #{level}." }
                end
              end
            end
          when "shots"
            set.add(npc, "soulShot", "soul")
            set.add(npc, "spiritShot", "spirit")
            set.add(npc, "shotShotChance", "shotChance")
            set.add(npc, "spiritShotChance", "spiritChance")
          when "corpsetime"
            set["corpseTime"] = npc.text
          when "excrteffect"
            set["exCrtEffect"] = npc.text
          when "snpcprophprate"
            set["sNpcPropHpRate"] = npc.text
          when "ai"
            set.add(npc, "aiType", "type")
            set.add(npc, "aggroRange")
            set.add(npc, "clanHelpRange")
            set.add(npc, "dodge")
            set.add(npc, "isChaos")
            set.add(npc, "isAggressive")
            npc.each_element do |ai|
              case ai.name.casecmp
              when "skill"
                set.add(ai, "minSkillChance", "minChance")
                set.add(ai, "maxSkillChance", "maxChance")
                set.add(ai, "primarySkillId", "primaryId")
                set.add(ai, "shortRangeSkillId", "shortRangeId")
                set.add(ai, "shortRangeSkillChance", "shortRangeChance")
                set.add(ai, "longRangeSkillId", "longRangeId")
                set.add(ai, "longRangeSkillChance", "longRangeChance")
              when "clanlist"
                ai.each_element do |cln|
                  if cln.name.casecmp?("clan")
                    clans ||= Set(Int32).new
                    clans << get_or_create_clan_id(cln.text)
                  elsif cln.name.casecmp?("ignorenpcid")
                    ignore_clan_npc_ids ||= Set(Int32).new
                    ignore_clan_npc_ids << cln.text.to_i
                  end
                end
              end
            end
          when "droplists"
            npc.each_element do |dn|
              drop_list_scope = DropListScope.parse(dn.name)
              drop_lists ||= EnumMap(DropListScope, Slice(IDropItem)).new
              drop_list = [] of IDropItem
              parse_drop_list(dn, drop_list_scope, drop_list)
              drop_lists[drop_list_scope] = drop_list.to_slice!
            end
          when "collision"
            npc.each_element do |col|
              case col.name.casecmp
              when "radius"
                set.add(col, "collisionRadius", "normal")
                set.add(col, "collisionRadiusGrown", "grown")
              when "height"
                set.add(col, "collisionHeight", "normal")
                set.add(col, "collisionHeightGrown", "grown")
              end
            end
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

        template.parameters = parameters || StatsSet::EMPTY

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
                if skill.has_effect_type?(L2EffectType::DISPEL)
                  ai_skill_scopes << AISkillScope::NEGATIVE << range_scope
                elsif skill.has_effect_type?(L2EffectType::HP)
                  ai_skill_scopes << AISkillScope::HEAL
                elsif skill.has_effect_type?(L2EffectType::PHYSICAL_ATTACK, L2EffectType::MAGICAL_ATTACK, L2EffectType::HP_DRAIN)
                  ai_skill_scopes << AISkillScope::ATTACK << AISkillScope::UNIVERSAL
                  ai_skill_scopes << range_scope
                elsif skill.has_effect_type?(L2EffectType::SLEEP)
                  ai_skill_scopes << AISkillScope::IMMOBILIZE
                elsif skill.has_effect_type?(L2EffectType::STUN, L2EffectType::ROOT)
                  ai_skill_scopes << AISkillScope::IMMOBILIZE << range_scope
                elsif skill.has_effect_type?(L2EffectType::MUTE, L2EffectType::FEAR)
                  ai_skill_scopes << AISkillScope::COT << range_scope
                elsif skill.has_effect_type?(L2EffectType::PARALYZE)
                  ai_skill_scopes << AISkillScope::IMMOBILIZE << range_scope
                elsif skill.has_effect_type?(L2EffectType::DMG_OVER_TIME)
                  ai_skill_scopes << range_scope
                elsif skill.has_effect_type?(L2EffectType::RESURRECTION)
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
    drop_list_node.each_element do |dn|
      if dn.name.casecmp?("group")
        drop_item = drop_list_scope.new_grouped_drop_item(dn["chance"].to_f)
        grouped_drop_list = [] of IDropItem
        dn.each_element do |gn|
          parse_drop_list_item(gn, drop_list_scope, grouped_drop_list)
        end
        items = [] of GeneralDropItem
        grouped_drop_list.each do |item|
          if item.is_a?(GeneralDropItem)
            items << item
          else
            warn { "Grouped general drop item supports only general drop item (#{item.class})" }
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
    if dli.name.casecmp?("item")
      id = dli["id"].to_i
      min = dli["min"].to_i64
      max = dli["max"].to_i64
      chance = dli["chance"].to_f
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

  def get_templates(&block : L2NpcTemplate ->) : Array(L2NpcTemplate)
    ret = [] of L2NpcTemplate
    NPCS.each_value { |npc| ret << npc if yield npc }
    ret
  end

  def get_all_of_level(*lvls : Int32) : Array(L2NpcTemplate)
    get_templates { |npc| lvls.includes?(npc.level) }
  end

  def get_all_monsters_of_level(*lvls : Int32) : Array(L2NpcTemplate)
    get_templates do |npc|
      lvls.includes?(npc.level) && npc.type?("L2Monster")
    end
  end

  def get_all_npc_starting_with(text : String) : Array(L2NpcTemplate)
    get_templates do |npc|
      npc.type?("L2Npc") && npc.name.starts_with?(text)
    end
  end

  def get_all_npc_of_class_type(*types) : Array(L2NpcTemplate)
    get_templates do |npc|
      types.any? &.casecmp?(npc.type)
    end
  end

  private class MinionData
    include XMLReader
    include Loggable

    getter minions

    def initialize
      @minions = {} of Int32 => Array(MinionHolder)
      parse_datapack_file("minionData.xml")
      info { "Loaded #{@minions.size} minion data." }
    end

    private def parse_document(doc, file)
      doc.find_element("list") do |node|
        node.find_element("npc") do |list|
          minions = [] of MinionHolder
          id = list["id"].to_i
          list.each_element do |npc|
            if npc.name == "minion"
              id2 = npc["id"].to_i
              count = npc["count"].to_i
              respawn = npc["respawnTime"].to_i64
              minions << MinionHolder.new(id2, count, respawn, 0)
            end
          end
          @minions[id] = minions
        end
      end
    end
  end
end
