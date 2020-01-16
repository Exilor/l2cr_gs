class EffectHandler::BlockChat < AbstractEffect
  def can_start?(info)
    effected = info.effected
    !!effected && effected.player?
  end

  def effect_type : EffectType
    EffectType::CHAT_BLOCK
  end

  def on_exit(info)
    PunishmentManager.stop_punishment(
      info.effected.l2id,
      PunishmentAffect::CHARACTER,
      PunishmentType::CHAT_BAN
    )
  end

  def on_start(info)
    PunishmentManager.start_punishment(
      PunishmentTask.new(
        0,
        info.effected.l2id,
        PunishmentAffect::CHARACTER,
        PunishmentType::CHAT_BAN,
        0,
        "Chat banned bot report",
        "system",
        true
      )
    )
  end
end
