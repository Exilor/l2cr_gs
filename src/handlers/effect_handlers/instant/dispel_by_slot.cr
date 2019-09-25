class EffectHandler::DispelBySlot < AbstractEffect
  @dispel_abnormals : EnumMap(AbnormalType, Int16)?

  def initialize(attach_cond, apply_cond, set, params)
    super

    return unless dispel = params.get_string("dispel", nil)

    unless dispel.empty?
      dispel_abnormals = EnumMap(AbnormalType, Int16).new

      dispel.split(';') do |temp|
        ngt = temp.split(',')
        type = AbnormalType.parse(ngt[0])

        dispel_abnormals[type] = ngt[1].to_i16
      end

      @dispel_abnormals = dispel_abnormals
    end
  end

  def effect_type
    L2EffectType::DISPEL_BY_SLOT
  end

  def instant?
    true
  end

  def on_start(info)
    return unless dispel_abnormals = @dispel_abnormals

    char = info.effected
    effect_list = char.effect_list

    dispel_abnormals.each do |type, val|
      if type.transform?
        if char.transformed? || char.player? || val == char.acting_player.transformation_id || val < 0
          char.stop_transformation(true)
          next
        end
      end

      to_dispel = effect_list.get_buff_info_by_abnormal_type(type)
      debug "Effect to dispel: #{to_dispel}." if to_dispel
      next unless to_dispel

      if type == to_dispel.skill.abnormal_type && (val < 0 || val >= to_dispel.skill.abnormal_lvl)
        effect_list.stop_skill_effects(true, type)
        debug "Removed #{type} from #{char}."
      end
    end
  end
end
