require "json"

module ExperienceData
  extend self

  private EXP_TABLE = {} of Int32 => Int64

  def load
    EXP_TABLE.clear
    file_path = Config.datapack_root + "/stats/expData.json"
    data = File.read(file_path)
    json = JSON.parse(data)
    json.as_h.each do |level, exp|
      EXP_TABLE[level.to_i32] = exp.as_i64
    end
  end

  def get_exp_for_level(level : Int32) : Int64
    EXP_TABLE.fetch(level) { raise "Invalid level #{level}" }
  end

  def get_percent_from_current_level(exp : Int64, level : Int32) : Float64
    exp_per_level = get_exp_for_level(level)
    exp_per_level2 = get_exp_for_level(level + 1)
    (exp - exp_per_level).fdiv(exp_per_level2 - exp_per_level)
  end
end
