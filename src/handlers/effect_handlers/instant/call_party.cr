class EffectHandler::CallParty < AbstractEffect
  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    effector = info.effector
    return unless pc = effector.acting_player
    return unless party = pc.party

    party.members.each do |m|
      if pc.can_summon_target?(m)
        m.tele_to_location(pc, true)
      end
    end
  end
end
