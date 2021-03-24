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
    find_element(doc, "list") do |n|
      find_element(n, "henna") do |d|
        parse_henna(d)
      end
    end
  end

  private def parse_henna(d)
    set = get_attributes(d)
    wear_class_ids = [] of ClassId

    each_element(d) do |c, c_name|
      case c_name
      when "stats"
        set.merge!(get_attributes(c))
      when "wear"
        set["wear_count"] = parse_string(c, "count")
        set["wear_fee"] = parse_string(c, "fee")
      when "cancel"
        set["cancel_count"] = parse_string(c, "count")
        set["cancel_fee"] = parse_string(c, "fee")
      when "classId"
        wear_class_ids << ClassId[get_content(c).to_i]
      end
    end

    henna = L2Henna.new(set)
    henna.wear_class = wear_class_ids
    HENNA_LIST[henna.dye_id] = henna
  end

  def get_henna(id : Int32) : L2Henna?
    HENNA_LIST[id]?
  end

  def get_henna_list(class_id : ClassId) : Array(L2Henna)
    HENNA_LIST.select_values { |henna| henna.allowed_class?(class_id) }
  end
end
