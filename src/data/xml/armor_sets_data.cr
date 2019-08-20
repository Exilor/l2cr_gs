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
    doc.find_element("list") do |n|
      n.find_element("set") do |d|
        set = ArmorSet.new
        d.each_element do |a|
          case a.name
          when "chest"
            set.chest_id = a["id"].to_i
          when "feet"
            set.feet << a["id"].to_i
          when "gloves"
            set.gloves << a["id"].to_i
          when "head"
            set.head << a["id"].to_i
          when "legs"
            set.legs << a["id"].to_i
          when "shield"
            set.shield << a["id"].to_i
          when "skill"
            id = a["id"].to_i
            lvl = a["level"].to_i
            set.skills << SkillHolder.new(id, lvl)
          when "shield_skill"
            id = a["id"].to_i
            lvl = a["level"].to_i
            set.shield_skills << SkillHolder.new(id, lvl)
          when "enchant6skill"
            id = a["id"].to_i
            lvl = a["level"].to_i
            set.enchant_6_skill << SkillHolder.new(id, lvl)
          when "con"
            set.con = a["val"].to_i
          when "dex"
            set.dex = a["val"].to_i
          when "str"
            set.str = a["val"].to_i
          when "men"
            set.men = a["val"].to_i
          when "wit"
            set.wit = a["val"].to_i
          when "int"
            set.int = a["val"].to_i
          end
        end

        SETS[set.chest_id] = set
      end
    end
  end
end
