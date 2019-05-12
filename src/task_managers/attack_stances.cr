module AttackStances
  extend self
  extend Runnable

  TASKS = Hash(L2Character, Int64).new

  def load
    ThreadPoolManager.schedule_ai_at_fixed_rate(self, 0, 1000)
  end

  def <<(char : L2Character?) : self
    return self unless char

    char = char.acting_player if char.playable?

    if char.is_a?(L2PcInstance)
      char.cubics.each_value do |cubic|
        unless cubic.id == L2CubicInstance::LIFE_CUBIC
          cubic.do_action
        end
      end
    end

    TASKS[char] = Time.ms

    self
  end

  def delete(char : L2Character?)
    return unless char
    char = char.acting_player if char.summon?
    TASKS.delete(char)
  end

  def includes?(char : L2Character?) : Bool
    return false unless char
    char = char.acting_player if char.summon?
    TASKS.has_key?(char)
  end

  def run
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
