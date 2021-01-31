class EffectHandler::CallParty < AbstractEffect
  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    effector = info.effector
    return unless pc = effector.acting_player
    return unless party = pc.party

    # dst = effector.location

    # party.members.each do |m|
    #   if pc.can_summon_target?(m)
    #     if effector != m
    #       m.tele_to_location(dst, true)
    #     end
    #   end
    # end

    party.members.each do |m|
      if pc.can_summon_target?(m)
        m.tele_to_location(pc, true)
      end
    end
  end
end
