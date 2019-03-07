require "../../../enums/class_id"

module PlayerCreationPointData
  extend self
  extend XMLReader

  private DATA = EnumMap(ClassId, Array(Location)).new

  def load
    DATA.clear
    parse_datapack_file("stats/chars/pcCreationPoints.xml")
    info "Loaded #{DATA.size} character creation locations."
  end

  def get_creation_point(class_id : ClassId) : Location
    DATA[class_id].sample(random: Rnd)
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |n|
      n.find_element("startpoints") do |d|
        creation_points = [] of Location
        d.each_element do |c|
          if c.name.casecmp?("spawn")
            x = c["x"].to_i
            y = c["y"].to_i
            z = c["z"].to_i
            creation_points << Location.new(x, y, z)
          elsif c.name.casecmp?("classid")
            id = c.text.to_i
            class_id = ClassId[id]
            DATA[class_id] = creation_points
          end
        end
      end
    end
  end
end
