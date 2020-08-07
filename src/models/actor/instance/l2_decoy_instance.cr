require "../l2_decoy"
require "../known_list/decoy_known_list"

class L2DecoyInstance < L2Decoy
  getter time_remaining, total_life_time

  def initialize(template : L2NpcTemplate, owner : L2PcInstance, total_life_time : Int32)
    super(template, owner)

    @total_life_time = total_life_time
    @time_remaining = total_life_time
    skill_level = template.display_id &- 13070
    skill = SkillData[5272, skill_level]

    task1 = DecoyLifetime.new(owner, self)
    @life_task = ThreadPoolManager.schedule_general_at_fixed_rate(task1, 1000, 1000)
    task2 = HateSpam.new(self, skill)
    @hate_task = ThreadPoolManager.schedule_general_at_fixed_rate(task2, 2000, 5000)
  end

  def instance_type : InstanceType
    InstanceType::L2DecoyInstance
  end

  def do_die(killer : L2Character?) : Bool
    return false unless super

    if task = @hate_task
      task.cancel
      @hate_task = nil
    end

    @total_life_time = 0

    DecayTaskManager.add(self)

    true
  end

  private def init_known_list
    @known_list = DecoyKnownList.new(self)
  end

  private struct DecoyLifetime
    include Loggable

    initializer pc : L2PcInstance, decoy : L2DecoyInstance

    def call
      @decoy.dec_time_temaining(1000)
      if @decoy.time_remaining < 0
        @decoy.unsummon(@pc)
      end
    rescue e
      error e
    end
  end

  private struct HateSpam
    include Loggable

    initializer decoy : L2DecoyInstance, skill : Skill

    def call
      @decoy.target = @decoy
      @decoy.do_cast(@skill)
    rescue e
      error e
    end
  end

  def unsummon(owner : L2PcInstance)
    if task = @life_task
      task.cancel
      @life_task = nil
    end

    if task = @hate_task
      task.cancel
      @hate_task = nil
    end

    super
  end

  def dec_time_temaining(value : Int32)
    @time_remaining &-= value
  end
end
