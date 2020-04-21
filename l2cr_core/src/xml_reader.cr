require "xml"

module XMLReader
  include Loggable

  # abstract def parse_document(node : XML::Node, file : File)

  def self.parse_file(path : String, & : XML::Node, File ->) : Nil
    File.open(path) do |file|
      yield XML.parse(file), file
    end
  end

  def self.parse_file(path : String) : XML::Node
    XML.parse(File.read(path))
  end

  private def parse_datapack_file(path : String) : Nil
    if path.starts_with?('/')
      path = Config.datapack_root + path
    else
      path = "#{Config.datapack_root}/#{path}"
    end

    File.open(path) do |file|
      doc = XML.parse(file)
      parse_document(doc, file)
    end
  end

  private def parse_datapack_directory(path : String) : Nil
    parse_datapack_directory(path, false)
  end

  private def parse_datapack_directory(path : String, recursive : Bool) : Nil
    unless path.starts_with?('/')
      path = '/' + path
    end
    unless path.ends_with?('/')
      path += '/'
    end

    if recursive
      path = "#{Config.datapack_root}#{path}**/*.xml"
    else
      path = "#{Config.datapack_root}#{path}*.xml"
    end

    Dir.glob(path) do |file_path|
      XMLReader.parse_file(file_path) do |doc, file|
        parse_document(doc, file)
      end
    end
  end

  private def get_first_child(node : XML::Node) : XML::Node
    node.children.first
  end

  private def get_first_element_child(node : XML::Node) : XML::Node?
    node.first_element_child
  end

  private def get_next_element(node : XML::Node) : XML::Node?
    node.next_element
  end

  private def find_element(node : XML::Node, name : String, & : XML::Node ->) : Nil
    each_element(node) { |e, e_name| yield(e) if e_name.casecmp?(name) }
  end

  private def each_element(node : XML::Node, & : XML::Node, String ->) : Nil
    node.children.each { |c| yield(c, c.name) if c.element? }
  end

  private def get_children(node : XML::Node) : Enumerable(XML::Node)
    node.children
  end

  private def each_attribute(node : XML::Node, & : String, String ->) : Nil
    node.attributes.each { |a| yield(a.name, a.content) }
  end

  private def get_attributes(node : XML::Node) : StatsSet
    attributes = node.attributes
    ret = StatsSet.new(initial_capacity: attributes.size)
    attributes.each { |a| ret[a.name] = a.text }
    ret
  end

  private def get_content(node : XML::Node) : String
    node.content
  end

  private def get_node_name(node : XML::Node) : String
    node.name
  end

  private def parse_string(node : XML::Node, key : String) : String
    node[key]
  end

  private def parse_string(node : XML::Node, key : String, default)
    node[key]? || default
  end

  private def parse_byte(node : XML::Node, key : String) : Int8
    parse_string(node, key).to_i8
  end

  private def parse_byte(node : XML::Node, key : String, default)
    if val = parse_string(node, key, nil)
      return val.to_i8
    end

    default
  end

  private def parse_short(node : XML::Node, key : String) : Int16
    parse_string(node, key).to_i16
  end

  private def parse_short(node : XML::Node, key : String, default)
    if val = parse_string(node, key, nil)
      return val.to_i16
    end

    default
  end

  private def parse_int(node : XML::Node, key : String) : Int32
    parse_string(node, key).to_i32
  end

  private def parse_int(node : XML::Node, key : String, default)
    if val = parse_string(node, key, nil)
      return val.to_i32
    end

    default
  end

  private def parse_long(node : XML::Node, key : String) : Int64
    parse_string(node, key).to_i64
  end

  private def parse_long(node : XML::Node, key : String, default)
    if val = parse_string(node, key, nil)
      return val.to_i64
    end

    default
  end

  private def parse_float(node : XML::Node, key : String) : Float32
    parse_string(node, key).to_f32
  end

  private def parse_float(node : XML::Node, key : String, default)
    if val = parse_string(node, key, nil)
      return val.to_f32
    end

    default
  end

  private def parse_double(node : XML::Node, key : String) : Float64
    parse_string(node, key).to_f64
  end

  private def parse_double(node : XML::Node, key : String, default)
    if val = parse_string(node, key, nil)
      return val.to_f64
    end

    default
  end

  private def parse_bool(node : XML::Node, key : String) : Bool
    Bool.new(parse_string(node, key))
  end

  private def parse_bool(node : XML::Node, key : String, default)
    if val = parse_string(node, key, nil)
      return Bool.new(val)
    end

    default
  end

  private def parse_enum(node : XML::Node, key : String, enum_type)
    enum_type.parse(parse_string(node, key))
  end

  private def parse_enum(node : XML::Node, key : String, enum_type, default)
    if val = parse_string(node, key, nil)
      return enum_type.parse(val)
    end

    default
  end

  private def add_from_node(node : XML::Node, map : StatsSet, map_key : String) : Nil
    add_from_node(node, map, map_key, map_key)
  end

  private def add_from_node(node : XML::Node, map : StatsSet, map_key : String, node_key : String) : Nil
    if val = parse_string(node, node_key, nil)
      map[map_key] = val
    end
  end
end
