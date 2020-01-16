class EffectHandler::DispelBySlot < AbstractEffect
  @dispel_abnormals = Slice({AbnormalType, Int16}).empty

  def initialize(attach_cond, apply_cond, set, params)
    super

    dispel = params.get_string("dispel", nil)

    if dispel && !dispel.empty?
      abnormals = [] of {AbnormalType, Int16}

      dispel.split(';') do |temp|
        ngt = temp.split(',')
        type = AbnormalType.parse(ngt[0])

        abnormals << {type, ngt[1].to_i16}
      end

      @dispel_abnormals = abnormals.to_slice
    end
  end

  def effect_type : EffectType
    EffectType::DISPEL_BY_SLOT
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    return if @dispel_abnormals.empty?

    char = info.effected
    effect_list = char.effect_list

    @dispel_abnormals.each do |type, val|
      if type.transform?
        if char.transformed? || char.player? || val == char.acting_player.not_nil!.transformation_id || val < 0
          char.stop_transformation(true)
          next
        end
      end

      to_dispel = effect_list.get_buff_info_by_abnormal_type(type)
      next unless to_dispel

      if type == to_dispel.skill.abnormal_type
        if val < 0 || val >= to_dispel.skill.abnormal_lvl
          effect_list.stop_skill_effects(true, type)
        end
      end
    end
  end
end
