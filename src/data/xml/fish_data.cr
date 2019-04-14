require "../../models/fishing/l2_fish"

module FishData
  extend self
  extend XMLReader

  private NORMAL = {} of Int32 => L2Fish
  private EASY   = {} of Int32 => L2Fish
  private HARD   = {} of Int32 => L2Fish

  def load
    EASY.clear
    NORMAL.clear
    HARD.clear
    parse_datapack_file("stats/fishing/fishes.xml")
    info "Loaded #{EASY.size + NORMAL.size + HARD.size} fishes."
  end

  def get_fish(level : Int32, group : Int32, grade : Int32) : Array(L2Fish)
    result = [] of L2Fish

    case grade
    when 0
      fish = EASY
    when 1
      fish = NORMAL
    when 2
      fish = HARD
    else
      warn { "Unknown fish grade #{grade}." }
      return result
    end

    fish.each_value do |f|
      next if f.fish_level != level || f.fish_group != group
      result << f
    end

    if result.empty?
      warn { "Couldn't find any fish for level #{level}, group #{group} and grade #{grade}." }
    end

    result
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |n|
      n.find_element("fish") do |d|
        set = StatsSet.new(d.attributes)
        fish = L2Fish.new(set)
        case fish.fish_grade
        when 0
          EASY[fish.fish_id] = fish
        when 1
          NORMAL[fish.fish_id] = fish
        when 2
          HARD[fish.fish_id] = fish
        end
      end
    end
  end
end
