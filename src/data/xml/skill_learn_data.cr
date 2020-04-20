module SkillLearnData
  extend self
  extend XMLReader

  private SKILL_LEARN = {} of Int32 => Array(ClassId)

  def load
    SKILL_LEARN.clear
    parse_datapack_file("skillLearn.xml")
    info { "Loaded #{SKILL_LEARN.size} Skill learn data." }
  end

  private def parse_document(doc, file)
    find_element(doc, "list") do |n|
      find_element(n, "npc") do |l|
        class_ids = [] of ClassId
        find_element(l, "classId") do |c|
          cid = get_content(c).to_i
          class_ids << ClassId[cid]
        end
        id = parse_int(l, "id")
        SKILL_LEARN[id] = class_ids
      end
    end
  end

  def [](id : Int) : Array(ClassId)
    SKILL_LEARN.fetch(id) { raise "No skill learn data for id #{id}" }
  end

  def []?(id : Int) : Array(ClassId)?
    SKILL_LEARN[id]?
  end
end
