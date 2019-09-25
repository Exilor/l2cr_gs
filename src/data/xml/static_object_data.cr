module StaticObjectData
  extend self
  extend XMLReader

  private STATIC_OBJECTS = {} of Int32 => L2StaticObjectInstance

  def load
    STATIC_OBJECTS.clear
    parse_datapack_file("staticObjects.xml")
    info { "Loaded #{STATIC_OBJECTS.size} static object templates." }
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |n|
      n.find_element("object") do |d|
        add_object(StatsSet.new(d.attributes))
      end
    end
  end

  private def add_object(set)
    template = L2CharTemplate.new(set)
    id = set.get_i32("id")
    obj = L2StaticObjectInstance.new(template, id)
    obj.type = set.get_i32("type", 0)
    obj.name = set.get_string("name")
    obj.set_map(
      set.get_string("texture", "none"),
      set.get_i32("map_x", 0),
      set.get_i32("map_y", 0)
    )
    obj.spawn_me(set.get_i32("x"), set.get_i32("y"), set.get_i32("z"))
    STATIC_OBJECTS[obj.l2id] = obj
  end

  def static_objects : Enumerable(L2StaticObjectInstance)
    STATIC_OBJECTS.local_each_value
  end
end
