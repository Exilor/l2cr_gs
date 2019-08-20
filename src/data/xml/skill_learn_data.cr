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
    doc.find_element("list") do |n|
      n.find_element("npc") do |l|
        class_ids = [] of ClassId
        l.find_element("classId") do |c|
          cid = c.text.to_i
          class_ids << ClassId[cid]
        end
        id = l["id"].to_i
        SKILL_LEARN[id] = class_ids
      end
    end
  end

  def [](id : Int) : Array(ClassId)
    SKILL_LEARN[id]
  end

  def []?(id : Int) : Array(ClassId)?
    SKILL_LEARN[id]?
  end
end
