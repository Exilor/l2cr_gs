require "../../models/fishing/l2_fishing_monster"

module FishingMonstersData
  extend self
  extend XMLReader

  private DATA = {} of Int32 => L2FishingMonster

  def load
    DATA.clear
    parse_datapack_file("stats/fishing/fishingMonsters.xml")
    info "Loaded #{DATA.size} fishing monsters."
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |n|
      n.find_element("fishingMonster") do |d|
        set = StatsSet.new(d.attributes)
        mob = L2FishingMonster.new(set)
        DATA[mob.id] = mob
      end
    end
  end

  def get_fishing_monster(lvl : Int32) : L2FishingMonster?
    DATA.find_value { |m| lvl.between?(m.min_level, m.max_level) }
  end

  def get_fishing_monster_by_id(id : Int32) : L2FishingMonster?
    DATA[id]?
  end
end
