struct NotifyAITask
  include Runnable

  initializer char: L2Character, event: AI::Event

  def run
    @char.notify_event(@event)
  end
end
