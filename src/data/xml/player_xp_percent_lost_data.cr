module PlayerXpPercentLostData
  extend self
  extend XMLReader

  private DATA = [] of Float64

  def load
    DATA.replace([1.0] * (Config.max_player_level &+ 1))
    parse_datapack_file("stats/chars/playerXpPercentLost.xml")
  end

  private def parse_document(doc, file)
    find_element(doc, "list") do |n|
      find_element(n, "xpLost") do |d|
        level = parse_int(d, "level")
        val = parse_double(d, "val")
        DATA[level] = val
      end
    end
  end

  def [](level : Int) : Float64
    DATA.fetch(level) do
      warn { "Unknown experience loss percent for level #{level}." }
      DATA[-1]
    end
  end
end
