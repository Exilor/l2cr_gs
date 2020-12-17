module AttackStances
  extend self

  private TASKS = Concurrent::Map(L2Character, Int64).new

  def load
    ThreadPoolManager.schedule_ai_at_fixed_rate(self, 0, 1000)
  end

  def <<(char : L2Character) : self
    char = char.acting_player.not_nil! if char.playable?

    if char.is_a?(L2PcInstance)
      char.cubics.each_value do |cubic|
        if cubic.id != L2CubicInstance::LIFE_CUBIC
          cubic.do_action
        end
      end
    end

    TASKS[char] = Time.ms

    self
  end

  def delete(char : L2Character)
    TASKS.delete(char.summon? ? char.acting_player : char)
  end

  def includes?(char : L2Character?) : Bool
    return false unless char
    TASKS.has_key?(char.summon? ? char.acting_player : char)
  end

  def call
    current = Time.ms

    TASKS.each do |char, time|
      if current - time > 15_000
        char.broadcast_packet(Packets::Outgoing::AutoAttackStop.new(char.l2id))
        char.ai.auto_attacking = false
        if s = char.summon
          s.broadcast_packet(Packets::Outgoing::AutoAttackStop.new(s.l2id))
        end

        TASKS.delete(char)
      end
    end
  end
end
