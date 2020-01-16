require "../enums/player_class"

class Subclass
  @class : PlayerClass = PlayerClass::HumanFighter

  getter stat
  property class_index : Int32 = 1

  def initialize(pc : L2PcInstance)
    @stat = PcStat.new(pc)
    @stat.exp = ExperienceData.get_exp_for_level(Config.base_subclass_level)
    @stat.level = Config.base_subclass_level
  end

  def class_definition : PlayerClass
    @class
  end

  def class_id : Int32
    @class.to_i
  end

  def class_id=(id : Int32)
    @class = PlayerClass[id]
  end

  def exp : Int64
    @stat.exp
  end

  def sp : Int32
    @stat.sp
  end

  def level : Int32
    @stat.level
  end

  def exp=(exp : Int64)
    @stat.exp = exp
  end

  def sp=(sp : Int32)
    @stat.sp = sp
  end

  def level=(level : Int32)
    @stat.level = level
  end

  def add_exp(exp : Int64)
    @stat.add_exp(exp)
  end
end
