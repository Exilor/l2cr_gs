require "./core_ext/xml.cr"

module XMLReader
  include Loggable

  abstract def parse_document(node : XML::Node, file : File)

  def parse_datapack_file(path : String)
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

  def parse_datapack_directory(path : String)
    parse_datapack_directory(path, false)
  end

  def parse_datapack_directory(path : String, recursive : Bool)
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
      File.open(file_path) do |file|
        doc = XML.parse(file)
        parse_document(doc, file)
      end
    end
  end
end
