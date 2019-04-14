module KarmaData
  extend self
  extend XMLReader

  private KARMA_TABLE = {} of Int32 => Float64

  def load
    KARMA_TABLE.clear
    parse_datapack_file("stats/chars/pcKarmaIncrease.xml")
    info "Loaded #{KARMA_TABLE.size} karma modifiers."
  end

  private def parse_document(doc, file)
    doc.find_element("pcKarmaIncrease") do |n|
      n.find_element("increase") do |d|
        lvl = d["lvl"].to_i
        val = d["val"].to_f
        KARMA_TABLE[lvl] = val
      end
    end
  end

  def get_multiplier(level : Int32) : Float64
    KARMA_TABLE.fetch(level) { raise "No karma data for level #{level}" }
  end
end
