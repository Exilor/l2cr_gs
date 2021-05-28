require "../../enums/class_id"
require "../../models/class_info"

module ClassListData
  extend self
  extend XMLReader

  private CLASS_DATA = EnumMap(ClassId, ClassInfo).new

  def load
    timer = Timer.new
    CLASS_DATA.clear
    parse_datapack_file("stats/chars/classList.xml")
    info { "Loaded #{CLASS_DATA.size} class data in #{timer} s." }
  end

  private def parse_document(doc : XML::Node, file : File)
    find_element(doc, "list") do |n|
      find_element(n, "class") do |d|
        class_id = ClassId[parse_int(d, "classId")]
        class_name = parse_string(d, "name")
        if parent_id = parse_int(d, "parentClassId", nil)
          parent = ClassId[parent_id]
        end
        CLASS_DATA[class_id] = ClassInfo.new(class_id, class_name, parent)
      end
    end
  end

  def get_class(class_id : ClassId) : ClassInfo
    CLASS_DATA[class_id]
  end

  def get_class(class_id : Int32) : ClassInfo?
    get_class(ClassId[class_id])
  end
end
