module KarmaData
  extend self
  extend XMLReader

  private KARMA_TABLE = {} of Int32 => Float64

  def load
    KARMA_TABLE.clear
    parse_datapack_file("stats/chars/pcKarmaIncrease.xml")
    info { "Loaded #{KARMA_TABLE.size} karma modifiers." }
  end

  private def parse_document(doc : XML::Node, file : File)
    find_element(doc, "pcKarmaIncrease") do |n|
      find_element(n, "increase") do |d|
        lvl = parse_int(d, "lvl")
        val = parse_double(d, "val")
        KARMA_TABLE[lvl] = val
      end
    end
  end

  def get_multiplier(level : Int32) : Float64
    KARMA_TABLE.fetch(level) { raise "No karma data for level #{level}" }
  end
end
