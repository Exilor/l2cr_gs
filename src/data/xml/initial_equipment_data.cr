require "../../models/items/pc_item_template"
require "../../enums/class_id"

module InitialEquipmentData
  extend self
  extend XMLReader

  private DATA = EnumMap(ClassId, Array(PcItemTemplate)).new

  def load
    DATA.clear
    if Config.initial_equipment_event
      parse_datapack_file("stats/initialEquipmentEvent.xml")
    else
      parse_datapack_file("stats/initialEquipment.xml")
    end
    info { "Loaded #{DATA.size} initial equipment data." }
  end

  private def parse_document(doc, file)
    find_element(doc, "list") do |n|
      find_element(n, "equipment") { |d| parse_equipment(d) }
    end
  end

  private def parse_equipment(d)
    id = parse_int(d, "classId")
    class_id = ClassId[id]
    equip_list = [] of PcItemTemplate

    find_element(d, "item") do |c|
      set = get_attributes(c)
      equip_list << PcItemTemplate.new(set)
    end

    DATA[class_id] = equip_list
  end

  def [](id : Int32) : Array(PcItemTemplate)
    class_id = ClassId.fetch(id) { raise "No ClassId with id #{id}" }
    DATA.fetch(class_id) do
      raise "No initial equipment data for ClassId #{class_id}"
    end
  end

  def [](id : ClassId) : Array(PcItemTemplate)
    DATA.fetch(id) do
      raise "No initial equipment data for ClassId #{id}"
    end
  end

  def []?(id : Int32) : Array(PcItemTemplate)?
    DATA[ClassId[id]]?
  end

  def []?(id : ClassId) : Array(PcItemTemplate)?
    DATA[id]?
  end
end
