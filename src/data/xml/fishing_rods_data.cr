require "../../models/fishing/l2_fishing_rod"

module FishingRodsData
  extend self
  extend XMLReader

  private FISHING_RODS = {} of Int32 => L2FishingRod

  def load
    FISHING_RODS.clear
    parse_datapack_file("stats/fishing/fishingRods.xml")
    info { "Loaded #{FISHING_RODS.size} fishing rods." }
  end

  def get_fishing_rod(item_id : Int32) : L2FishingRod
    FISHING_RODS.fetch(item_id) do
      raise "No fishing rod with item id #{item_id}"
    end
  end

  private def parse_document(doc, file)
    find_element(doc, "list") do |n|
      find_element(n, "fishingRod") do |d|
        set = get_attributes(d)
        fishing_rod = L2FishingRod.new(set)
        FISHING_RODS[fishing_rod.item_id] = fishing_rod
      end
    end
  end
end
