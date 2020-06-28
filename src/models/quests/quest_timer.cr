class QuestTimer
  @task : TaskScheduler::Task?

  getter name, npc, player, quest
  getter? active = true

  def initialize(quest : Quest, name : String, time : Int64, npc : L2Npc?, pc : L2PcInstance?)
    initialize(quest, name, time, npc, pc, false)
  end

  def initialize(qs : QuestState, name : String, time : Int64)
    initialize(qs.quest, name, time, nil, qs.player, false)
  end

  def initialize(quest : Quest, name : String, time : Int64, npc : L2Npc?, player : L2PcInstance?, repeating : Bool)
    @quest = quest
    @name = name
    @npc = npc
    @player = player
    @repeating = repeating
    @time = time

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
