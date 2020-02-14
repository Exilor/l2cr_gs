class EffectHandler::SummonAgathion < AbstractEffect
  @npc_id : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super

    if params.empty?
      raise "#{self.class} must have parameters"
    end

    @npc_id = params.get_i32("npcId", 0)
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    unless pc = info.effected.as?(L2PcInstance)
      return
    end

    pc.agathion_id = @npc_id
    pc.broadcast_user_info
  end
end
