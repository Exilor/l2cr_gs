class EffectHandler::BlockParty < AbstractEffect
  def can_start?(info : BuffInfo) : Bool
    info.effected.is_a?(L2PcInstance)
  end

  def on_exit(info : BuffInfo)
    PunishmentManager.stop_punishment(
      info.effected.l2id,
      PunishmentAffect::CHARACTER,
      PunishmentType::PARTY_BAN
    )
  end

  def on_start(info : BuffInfo)
    PunishmentManager.start_punishment(
      PunishmentTask.new(
        0,
        info.effected.l2id,
        PunishmentAffect::CHARACTER,
        PunishmentType::PARTY_BAN,
        0,
        "Party banned by bot report",
        "system",
        true
      )
    )
  end
end
