module HennaData
  extend self
  extend XMLReader

  private HENNA_LIST = {} of Int32 => L2Henna

  def load
    HENNA_LIST.clear
    parse_datapack_file("stats/hennaList.xml")
    info { "Loaded #{HENNA_LIST.size} henna data." }
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |n|
      n.find_element("henna") do |d|
        parse_henna(d)
      end
    end
  end

  private def parse_henna(d)
    set = StatsSet.new(d.attributes)
    wear_class_ids = [] of ClassId

    d.each_element do |c|
      case c.name
      when "stats"
        set.merge(c.attributes)
      when "wear"
        set["wear_count"] = c["count"]
        set["wear_fee"] = c["fee"]
      when "cancel"
        set["cancel_count"] = c["count"]
        set["cancel_fee"] = c["fee"]
      when "classId"
        wear_class_ids << ClassId[c.text.to_i]
      end
    end

    henna = L2Henna.new(set)
    henna.wear_class = wear_class_ids
    HENNA_LIST[henna.dye_id] = henna
  end

  def get_henna(id : Int32) : L2Henna?
    HENNA_LIST[id]?
  end

  def get_henna_list(class_id : ClassId) : Enumerable(L2Henna)
    HENNA_LIST.values.select! &.allowed_class?(class_id)
  end
end
