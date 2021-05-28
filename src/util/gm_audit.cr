module GMAudit
  def self.log(name, action, target, params = "")
    if name.is_a?(L2PcInstance)
      name = "#{name} [#{name.l2id}]"
    end
    target ||= "no-target"
    dir = Dir.current + "/logs/GMAudit"
    unless Dir.exists?(dir)
      Dir.mkdir_p(dir)
    end

    File.open("#{dir}/#{name}.txt", "a") do |io|
      Time.now.to_s(io, "%d-%m-%Y %H:%M:%S")
      io.print('>', action, '>', target, '>', params, Config::EOL)
    end
  end
end
