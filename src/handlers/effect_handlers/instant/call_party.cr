class EffectHandler::CallParty < AbstractEffect
  def instant?
    true
  end

  def on_start(info)
    effector = info.effector
    return unless effector.in_party?
    pc = effector.acting_player

    dst = effector.location

    effector.party.members.each do |m|
      if pc.can_summon_target?(m)
        if effector != m
          m.tele_to_location(dst, true)
        end
      end
    end
  end
end
