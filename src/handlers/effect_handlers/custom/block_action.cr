class EffectHandler::BlockAction < AbstractEffect
  @blocked_actions = Set(Int32).new

  def initialize(attach_cond, apply_cond, set, params)
    super

    params.get_string("blockedActions").split(',') do |action|
      @blocked_actions << action.to_i
    end
  end

  def can_start?(info : BuffInfo) : Bool
    info.effected.is_a?(L2PcInstance)
  end

  def check_condition(id : Object)
    !@blocked_actions.includes?(id)
  end

  def on_exit(info)
    if @blocked_actions.includes?(BotReportTable::PARTY_ACTION_BLOCK_ID)
			PunishmentManager.stop_punishment(
        info.effected.l2id,
        PunishmentAffect::CHARACTER,
        PunishmentType::PARTY_BAN
      )
		end
		if @blocked_actions.includes?(BotReportTable::CHAT_BLOCK_ID)
			PunishmentManager.stop_punishment(
        info.effected.l2id,
        PunishmentAffect::CHARACTER,
        PunishmentType::CHAT_BAN
      )
		end
  end

  def on_start(info)
    if @blocked_actions.includes?(BotReportTable::PARTY_ACTION_BLOCK_ID)
			PunishmentManager.start_punishment(
        PunishmentTask.new(
          0,
          info.effected.l2id,
          PunishmentAffect::CHARACTER,
          PunishmentType::PARTY_BAN,
          0,
          "block action debuff",
          "system",
          true
        )
      )
		end

		if @blocked_actions.includes?(BotReportTable::CHAT_BLOCK_ID)
			PunishmentManager.start_punishment(
        PunishmentTask.new(
          0,
          info.effected.l2id,
          PunishmentAffect::CHARACTER,
          PunishmentType::CHAT_BAN,
          0,
          "block action debuff",
          "system",
          true
        )
      )
		end
  end
end
