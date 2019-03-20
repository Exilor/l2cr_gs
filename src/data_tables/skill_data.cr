require "../data/xml/documents/skill_document"
require "../data/xml/enchant_skill_groups_data"

module SkillData
  extend self
  extend Loggable

  private SKILLS = {} of Int32 => Skill
  private SKILLS_MAX_LEVEL = {} of Int32 => Int32
  private ENCHANTABLE = Set(Int32).new

  def load
    info "Loading skills..."
    timer = Timer.new

    SKILLS.clear
    DocumentEngine.load_skills(SKILLS)
    SKILLS_MAX_LEVEL.clear
    ENCHANTABLE.clear

    SKILLS.each_value do |skill|
      id = skill.id
      level = skill.level

      if level > 99
        ENCHANTABLE << id
        next
      end

      if level > get_max_level(id)
        SKILLS_MAX_LEVEL[id] = level
      end
    end

    info "Loaded #{SKILLS.size} skills (#{ENCHANTABLE.size} enchantables) in #{timer.result} s."
  end

  def reload
    load
    SkillTreesData.load
  end

  private def fetch(id : Int, level : Int)
    if skill = SKILLS[(id * 1021) + level]?
      return skill
    end

    max_lvl = get_max_level(id)

    if max_lvl > 0 && level > max_lvl
      skill = SKILLS[(id * 1021) + max_lvl]
      warn "Nonexistent skill-level #{id}-#{level} (#{skill})."
      return skill
    end

    yield
  end

  def [](id : Int, level : Int) : Skill
    fetch(id, level) { raise "No skill found with ID #{id} and level #{level}" }
  end

  def []?(id : Int, level : Int) : Skill?
    fetch(id, level) do
      warn "No skill found for ID #{id} and level #{level}."
      nil
    end
  end

  def get_max_level(id : Int) : Int32
    SKILLS_MAX_LEVEL.fetch(id, 0)
  end

  def enchantable?(id : Int) : Bool
    ENCHANTABLE.includes?(id)
  end

  def get_siege_skills(noble : Bool, castle : Bool) : Indexable(Skill)
    ret = {
      SKILLS[SkillData.get_skill_hash(246, 1)],
      SKILLS[SkillData.get_skill_hash(247, 1)]
    }

    if noble
      ret += {SKILLS[SkillData.get_skill_hash(326, 1)]}
    end

    if castle
      ret += {
        SKILLS[SkillData.get_skill_hash(844, 1)],
        SKILLS[SkillData.get_skill_hash(845, 1)]
      }
    end

    ret
  end

  def get_skill_hash(id : Int32, lvl : Int32) : Int32
    (id * 1021) + lvl
  end
end
