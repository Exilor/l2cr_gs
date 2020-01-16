class QuestTimer
  @task : Scheduler::Task?
  @time : Int64

  getter name, npc, player, quest
  getter? active = true

  def initialize(quest : Quest, name : String, time : Number, npc : L2Npc?, pc : L2PcInstance?)
    initialize(quest, name, time, npc, pc, false)
  end

  def initialize(qs : QuestState, name : String, time : Number)
    initialize(qs.quest, name, time, nil, qs.player, false)
  end

  def initialize(@quest : Quest, @name : String, time : Number, @npc : L2Npc?, @player : L2PcInstance?, @repeating : Bool)
    @time = time.to_i64

    if repeating
      @task = ThreadPoolManager.schedule_general_at_fixed_rate(self, @time, @time)
    else
      @task = ThreadPoolManager.schedule_general(self, @time)
    end
  end

  def call
    return unless @active
    cancel_and_remove unless @repeating
    @quest.notify_event(@name, @npc, @player)
  end

  def cancel
    @active = false
    @task.try &.cancel
  end

  def cancel_and_remove
    cancel
    @quest.remove_quest_timer(self)
  end

  def match?(quest : Quest?, name : String?, npc : L2Npc?, pc : L2PcInstance?) : Bool
    return false unless quest && name
    return false if quest != @quest || !name.casecmp?(@name)
    npc == @npc && pc == @player
  end
end
