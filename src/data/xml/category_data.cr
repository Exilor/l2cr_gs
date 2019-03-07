require "../../enums/category_type"

module CategoryData
  extend self
  extend XMLReader

  private CATEGORIES = EnumMap(CategoryType, Set(Int32)).new

  def load
    timer = Timer.new
    CATEGORIES.clear
    parse_datapack_file("categoryData.xml")
    info "Loaded #{CATEGORIES.size} categories in #{timer.result} s."
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |node|
      node.find_element("category") do |list_node|
        name = list_node["name"]
        if category_type = CategoryType.parse?(name)
          ids = Set(Int32).new

          list_node.find_element("id") do |c|
            ids << c.content.to_i
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

    warn "Can't find category data for #{type.inspect}."
    false
  end

  def [](type : CategoryType) : Set(Int32)
    CATEGORIES.fetch(type) { raise "No category data for #{type.inspect}" }
  end
end
