class EffectHandler::SoulEating < AbstractEffect
  @exp_needed : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @exp_needed = params.get_i32("expNeeded")
  end

  def on_start(info : BuffInfo)
    if info.effected.player?
      type = EventType::ON_PLAYABLE_EXP_CHANGED
      lst = ConsumerEventListener.new(info.effected, type, self) do |evt|
        evt = evt.as(OnPlayableExpChanged)
        on_experience_received(evt.active_char, evt.new_exp - evt.old_exp)
      end
      info.effected.add_listener(lst)
    end
  end

  def on_experience_received(pc, exp)
    if pc.is_a?(L2PcInstance) && exp >= @exp_needed
      if pc.charged_souls >= pc.calc_stat(Stats::MAX_SOULS, 0)
        pc.send_packet(SystemMessageId::SOUL_CANNOT_BE_ABSORBED_ANYMORE)
        return
      end

      pc.increase_souls(1)

      if npc = pc.target.as?(L2Npc)
        pc.broadcast_packet(ExSpawnEmitter.new(pc, npc), 500)
      end
    end
  end

  def on_exit(info : BuffInfo)
    if info.effected.player?
      type = EventType::ON_PLAYABLE_EXP_CHANGED
      info.effected.remove_listener_if(type) do |listener|
        listener.owner == self
      end
    end
  end
end
