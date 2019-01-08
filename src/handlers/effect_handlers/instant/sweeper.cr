class EffecyHandler::Sweeper < AbstractEffect
  def instant?
    true
  end

  def on_start(info)
    return unless mob = info.effected.as?(L2Attackable)
    return unless pc = info.effector.as?(L2PcInstance)

    unless mob.check_spoil_owner(pc, false)
      debug "#{pc.name} is not the spoil owner of #{mob.name}."
      return
    end

    mob.take_sweep.try &.each do |item|
      if party = pc.party?
        party.distribute_item(pc, item, true, mob)
      else
        pc.add_item("Sweeper", item, mob, true)
      end
    end
  end
end
