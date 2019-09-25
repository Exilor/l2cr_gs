struct NotifyAITask
  initializer char : L2Character, event : AI::Event

  def call
    @char.notify_event(@event)
  end
end
