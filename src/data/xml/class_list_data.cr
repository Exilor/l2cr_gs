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

  private def parse_document(doc, file)
    doc.find_element("list") do |n|
      n.find_element("class") do |d|
        class_id = ClassId[d["classId"].to_i]
        class_name = d["name"]
        parent_str = d["parentClassId"]?
        parent = ClassId[parent_str.to_i] if parent_str
        CLASS_DATA[class_id] = ClassInfo.new(class_id, class_name, parent)
      end
    end
  end

  def get_class(class_id : ClassId) : ClassInfo?
    CLASS_DATA[class_id]?
  end

  def get_class(class_id : Int32) : ClassInfo?
    if id = ClassId[class_id]?
      CLASS_DATA[id]?
    end
  end

  def get_class!(arg) : ClassInfo
    unless info = get_class(arg)
      raise "No ClassInfo for #{arg.inspect}"
    end

    info
  end
end
