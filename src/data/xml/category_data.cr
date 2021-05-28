require "../../enums/category_type"

module CategoryData
  extend self
  extend XMLReader

  private CATEGORIES = EnumMap(CategoryType, Set(Int32)).new

  def load
    debug "Loading..."
    timer = Timer.new
    CATEGORIES.clear
    parse_datapack_file("categoryData.xml")
    info { "Loaded #{CATEGORIES.size} categories in #{timer} s." }
  end

  private def parse_document(doc : XML::Node, file : File)
    find_element(doc, "list") do |node|
      find_element(node, "category") do |list_node|
        if category_type = parse_enum(list_node, "name", CategoryType, nil)
          ids = Set(Int32).new

          find_element(list_node, "id") do |c|
            ids << get_content(c).to_i
          end

          CATEGORIES[category_type] = ids
        end
      end
    end
  end

  def in_category?(type : CategoryType, id : Int32) : Bool
    if category = CATEGORIES[type]?
      return category.includes?(id)
    end

    warn { "Can't find category data for '#{type}'." }

    false
  end

  def [](type : CategoryType) : Set(Int32)
    CATEGORIES.fetch(type) { raise "No category data for #{type}" }
  end
end
