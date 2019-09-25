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
    doc.find_element("list") do |n|
      n.find_element("equipment") { |d| parse_equipment(d) }
    end
  end

  private def parse_equipment(d)
    id = d["classId"].to_i
    class_id = ClassId[id]
    equip_list = [] of PcItemTemplate

    d.find_element("item") do |c|
      set = StatsSet.new(c.attributes)
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
