class EffectHandler::Bluff < AbstractEffect
  @chance : Int32

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super
    @chance = params.get_i32("chance", 100)
  end

  def calc_success(info : BuffInfo) : Bool
    Formulas.probability(@chance.to_f, info.effector, info.effected, info.skill)
  end

  def on_start(info : BuffInfo)
    effected = info.effected
                      # HQs
    if effected.id == 35062 || effected.raid? || effected.raid_minion?
      return
    end

    effector = info.effector

    start = StartRotation.new(effected.l2id, effected.heading, 1, 65535)
    effected.broadcast_packet(start)
    stop = StopRotation.new(effected.l2id, effector.heading, 65535)
    effected.broadcast_packet(stop)
    effected.heading = effector.heading
  end

  def instant? : Bool
    true
  end
end
