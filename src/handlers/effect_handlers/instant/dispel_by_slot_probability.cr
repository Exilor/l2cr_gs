class EffectHandler::DispelBySlotProbability < AbstractEffect
  @dispel_abnormals : EnumMap(AbnormalType, Int16)?
  @rate : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super

    dispel = params.get_string("dispel", nil)
    @rate = params.get_i32("rate", 0)

    if dispel && !dispel.empty?
      abnormals = EnumMap(AbnormalType, Int16).new
      dispel.split(';') do |temp|
        ngt = temp.split(',')
        type = AbnormalType.parse(ngt[0])
        abnormals[type] = ngt.size > 1 ? ngt[1].to_i16 : Int16::MAX
      end
      @dispel_abnormals = abnormals
    end
  end

  def effect_type
    L2EffectType::DISPEL
  end

  def instant?
    true
  end

  def on_start(info)
    return unless abnormals = @dispel_abnormals

    effected = info.effected
    effect_list = effected.effect_list

    abnormals.each do |type, val|
      next unless Rnd.rand(100) < @rate

      if type.transform?
        if effected.transformed? || effected.player? || val == effected.acting_player.transformation_id || val < 0
          effected.stop_transformation(true)
          next
        end
      end

      to_dispel = effect_list.get_buff_info_by_abnormal_type(type)
      debug "Effect to dispel: #{to_dispel}."
      next unless to_dispel

      if type == to_dispel.skill.abnormal_type && val >= to_dispel.skill.abnormal_lvl
        effect_list.stop_skill_effects(true, type)
        info.effector.say "I've dispelled #{type}."
      end
    end
  end
end
