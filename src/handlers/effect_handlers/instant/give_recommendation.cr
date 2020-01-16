class EffectHandler::GiveRecommendation < AbstractEffect
  @amount : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super

    @amount = params.get_i32("amount", 0)

    if @amount == 0
      warn { "Amount parameter is missing or is 0. ID: " + set.get_i32("id", -1).to_s }
    end
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    return unless target = info.effected.as?(L2PcInstance)

    recs_given = @amount

    if target.recom_have + @amount >= 255
      recs_given = 255 - target.recom_have
    end

    if recs_given > 0
      target.recom_have += recs_given

      sm = SystemMessage.you_obtained_s1_recommendations
      sm.add_int(recs_given)
      target.send_packet(sm)
      target.send_packet(UserInfo.new(target))
      target.send_packet(ExVoteSystemInfo.new(target))
    else
      if pc = info.effector.as?(L2PcInstance)
        pc.send_packet(SystemMessageId::NOTHING_HAPPENED)
      end
    end
  end
end
