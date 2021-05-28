class EffectHandler::DispelBySlotProbability < AbstractEffect
  @rate : Int32
  @dispel_abnormals = Slice({AbnormalType, Int16}).empty

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super

    dispel = params.get_string("dispel", nil)
    @rate = params.get_i32("rate", 0)

    if dispel && !dispel.empty?
      abnormals = [] of {AbnormalType, Int16}
      dispel.split(';') do |temp|
        ngt = temp.split(',')
        type = AbnormalType.parse(ngt[0])

        abnormals << {type, ngt.size > 1 ? ngt[1].to_i16 : Int16::MAX}
      end
      @dispel_abnormals = abnormals.to_slice
    end
  end

  def effect_type : EffectType
    EffectType::DISPEL
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    return if @dispel_abnormals.empty?

    effected = info.effected
    effect_list = effected.effect_list

    @dispel_abnormals.each do |type, val|
      next unless Rnd.rand(100) < @rate

      if type.transform?
        if effected.transformed? || effected.player? || val == effected.acting_player.not_nil!.transformation_id || val < 0
          effected.stop_transformation(true)
          next
        end
      end

      to_dispel = effect_list.get_buff_info_by_abnormal_type(type)
      next unless to_dispel

      if type == to_dispel.skill.abnormal_type && val >= to_dispel.skill.abnormal_lvl
        effect_list.stop_skill_effects(true, type)
      end
    end
  end
end
