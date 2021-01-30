module HtmCache
  extend self
  extend Loggable

  @@root = ""
  @@bytes_buff_len = 0u64

  class_getter loaded_files = 0
  private class_getter! cache : Concurrent::Map(String, String) | Hash(String, String)#Interfaces::Map(String, String)

  def load
    @@root = Config.datapack_root.chomp("/data")
    if Config.lazy_cache
      @@cache = Concurrent::Map(String, String).new
    else
      @@cache = {} of String => String
    end
    reload
  end

  def reload(f : String = @@root)
    if Config.lazy_cache
      cache.clear
      @@loaded_files = 0
      @@bytes_buff_len = 0u64
      info "Running lazy cache."
    else
      info "Html cache start..."
      timer = Timer.new
      parse_dir(f)
      info { "#{memory_usage.round(2)} mb from #{@@loaded_files} files loaded in #{timer} s." }
    end
  end

  def reload_path(f : String)
    parse_dir(f)
    info "Reloaded specified path"
  end

  def memory_usage : Float32
    @@bytes_buff_len.to_f32 / 1_048_576
  end

  private def parse_dir(dir : String)
    Dir.glob(dir + "/**/*.{htm,html}") do |path|
      File.open(path) { |file| load_file(file) }
    end
  end

  def load_file(file : File) : String?
    path = file.path
    unless path.ends_with?(".htm", ".html")
      return
    end

    rel_path = path.from(@@root.size &+ 1)
    content = file.gets_to_end.scrub
    content = content.gsub(/(?:\s?)<!--.*?-->/, "")

    if old = cache[rel_path]?
      @@bytes_buff_len = @@bytes_buff_len - old.bytesize + content.bytesize
    else
      @@bytes_buff_len += content.bytesize
      @@loaded_files &+= 1
    end

    cache[rel_path] = content

    content
  end

  def includes?(path : String) : Bool
    cache.has_key?(path)
  end

  def loadable?(path : String) : Bool
    path.ends_with?(".html", ".htm") && File.file?("#{@@root}/#{path}")
  end

  def get_htm(pc : L2PcInstance, path : String) : String?
    get_htm(pc.html_prefix, path)
  end

  def get_htm_force(pc : L2PcInstance, path : String) : String
    get_htm_force(pc.html_prefix, path)
  end

  def get_htm_force(path : String) : String
    get_htm_force(nil, path)
  end

  def get_htm(path : String) : String?
    get_htm(nil, path)
  end

  def get_htm_force(prefix : String?, path : String) : String
    unless content = get_htm(prefix, path)
      content = "<html><body>My text is missing:<br>#{path}</body></html>"
      warn { "Missing HTML page: '#{path}'." }
    end

    content
  end

  def get_htm(prefix : String?, path : String) : String?
    new_path = nil

    if prefix && !prefix.empty?
      new_path = prefix + path
      if content = internal_get_htm(new_path)
        return content
      end
    end

    content = internal_get_htm(path)
    if content && new_path
      cache[new_path] = content
    end

    content
  end

  private def internal_get_htm(path : String) : String?
    if path.empty?
      return ""
    end

    content = cache[path]?
    if Config.lazy_cache && content.nil?
      path2 = "#{@@root}/#{path}"
      if File.file?(path2)
        content = File.open(path2, "r") { |f| load_file(f) }
      end
    end

    content
  end
end
