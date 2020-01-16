module PlayerXpPercentLostData
  extend self
  extend XMLReader

  private DATA = [] of Float64

  def load
    DATA.clear
    (Config.max_player_level + 1).times do
      DATA << 1.0
    end
    parse_datapack_file("stats/chars/playerXpPercentLost.xml")
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |n|
      n.find_element("xpLost") do |d|
        level = d["level"].to_i
        val = d["val"].to_f
        DATA[level] = val
      end
    end
  end

  def [](level : Int) : Float64
    DATA.fetch(level) do
      max = Config.max_player_level + 1
      warn { "Unknown experience loss percent for level #{level}." }
      DATA[-1]
    end
  end
end
