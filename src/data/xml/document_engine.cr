require "../../models/items/l2_item"
require "./documents/item_document"

module DocumentEngine
  extend self

  private ITEM_FILES = [] of File
  private SKILL_FILES = [] of File

  def load
    return if loaded?

    ITEM_FILES.each &.close
    ITEM_FILES.clear
    SKILL_FILES.each &.close
    ITEM_FILES.clear

    hash_files("stats/items", ITEM_FILES)
    if Config.custom_items_load
      hash_files("stats/items/custom", ITEM_FILES)
    end

    hash_files("stats/skills", SKILL_FILES)
    if Config.custom_skills_load
      hash_files("stats/skills/custom", SKILL_FILES)
    end
  end

  def loaded? : Bool
    !ITEM_FILES.empty? || !SKILL_FILES.empty?
  end

  private def hash_files(dir_name, array)
    Dir.glob("#{Config.datapack_root}/#{dir_name}/*.xml") do |path|
      array << File.open(path)
    end
  end

  def load_skill_file(file : File) : Array(Skill)
    doc = SkillDocument.new(file)
    doc.parse
    doc.skills
  end

  def load_skills(hash : Hash(Int32, Skill))
    SKILL_FILES.each_with_index(1) do |file, i|
      STDOUT.flush
      print "\r#{file.path} (#{i}/#{SKILL_FILES.size})"

      skills = load_skill_file(file)
      skills.each { |s| hash[s.hash] = s }
    end
    puts
    STDOUT.flush
  end

  def load_items : Array(L2Item)
    list = [] of L2Item

    ITEM_FILES.each_with_index(1) do |file, i|
      print "\r#{file.path} (#{i}/#{ITEM_FILES.size})"
      doc = ItemDocument.new(file)
      doc.parse
      list.concat(doc.item_list)
    end
    puts
    list
  end
end
