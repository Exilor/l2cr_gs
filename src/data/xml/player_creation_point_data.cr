require "../../enums/class_id"

module PlayerCreationPointData
  extend self
  extend XMLReader

  private DATA = EnumMap(ClassId, Array(Location)).new

  def load
    DATA.clear
    parse_datapack_file("stats/chars/pcCreationPoints.xml")
    info { "Loaded #{DATA.size} character creation locations." }
  end

  def get_creation_point(class_id : ClassId) : Location
    DATA.fetch(class_id) { raise "No coordiantes for ClassId #{class_id}" }
    .sample(random: Rnd)
  end

  private def parse_document(doc : XML::Node, file : File)
    find_element(doc, "list") do |n|
      find_element(n, "startpoints") do |d|
        creation_points = [] of Location
        each_element(d) do |c, c_name|
          if c_name.casecmp?("spawn")
            x = parse_int(c, "x")
            y = parse_int(c, "y")
            z = parse_int(c, "z")
            creation_points << Location.new(x, y, z)
          elsif c_name.casecmp?("classid")
            id = get_content(c).to_i
            class_id = ClassId[id]
            DATA[class_id] = creation_points
          end
        end
      end
    end
  end
end
