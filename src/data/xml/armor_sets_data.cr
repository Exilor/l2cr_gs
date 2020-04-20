require "../../models/armor_set"

module ArmorSetsData
  extend self
  extend XMLReader

  private SETS = {} of Int32 => ArmorSet

  def load
    SETS.clear
    parse_datapack_directory("stats/armorsets")
    info { "Loaded #{SETS.size} armor set data." }
  end

  def [](id : Int32) : ArmorSet
    SETS.fetch(id) { raise "No armor set with id #{id}" }
  end

  def []?(id : Int32) : ArmorSet?
    SETS[id]?
  end

  def includes?(id : Int32) : Bool
    SETS.has_key?(id)
  end

  private def parse_document(doc, file)
    find_element(doc, "list") do |n|
      find_element(n, "set") do |d|
        set = ArmorSet.new
        each_element(d) do |a, a_name|
          case a_name
          when "chest"
            set.chest_id = parse_int(a, "id")
          when "feet"
            set.feet << parse_int(a, "id")
          when "gloves"
            set.gloves << parse_int(a, "id")
          when "head"
            set.head << parse_int(a, "id")
          when "legs"
            set.legs << parse_int(a, "id")
          when "shield"
            set.shield << parse_int(a, "id")
          when "skill"
            id = parse_int(a, "id")
            lvl = parse_int(a, "level")
            set.skills << SkillHolder.new(id, lvl)
          when "shield_skill"
            id = parse_int(a, "id")
            lvl = parse_int(a, "level")
            set.shield_skills << SkillHolder.new(id, lvl)
          when "enchant6skill"
            id = parse_int(a, "id")
            lvl = parse_int(a, "level")
            set.enchant_6_skill << SkillHolder.new(id, lvl)
          when "con"
            set.con = parse_int(a, "val")
          when "dex"
            set.dex = parse_int(a, "val")
          when "str"
            set.str = parse_int(a, "val")
          when "men"
            set.men = parse_int(a, "val")
          when "wit"
            set.wit = parse_int(a, "val")
          when "int"
            set.int = parse_int(a, "val")
          else
            # [automatically added else]
          end
        end

        SETS[set.chest_id] = set
      end
    end
  end
end
