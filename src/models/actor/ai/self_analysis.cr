class SelfAnalysis
  getter general_skills = [] of Skill
  getter buff_skills = [] of Skill
  getter debuff_skills = [] of Skill
  getter cancel_skills = [] of Skill
  getter heal_skills = [] of Skill
  getter general_disablers = [] of Skill
  getter sleep_skills = [] of Skill
  getter root_skills = [] of Skill
  getter mute_skills = [] of Skill
  getter resurrect_skills = [] of Skill
  property last_debuff_tick : Int32 = 0
  property last_buff_tick : Int32 = 0
  property max_cast_range : Int32 = 0
  property? has_heal_or_resurrect : Bool = false
  property? has_long_range_skills : Bool = false
  property? has_long_range_damage_skills : Bool = false
  property? mage : Bool = false
  property? balanced : Bool = false
  property? archer : Bool = false
  property? healer : Bool = false
  property? fighter : Bool = false
  property? cannot_move_on_land : Bool = false

  initializer actor : L2Character

  def init
    case @actor.template.as(L2NpcTemplate).ai_type
    when AIType::FIGHTER
      @fighter = true
    when AIType::MAGE
      @mage = true
    when AIType::CORPSE, AIType::BALANCED
      @balanced = true
    when AIType::ARCHER
      @archer = true
    when AIType::HEALER
      @healer = true
    else
      @fighter = true
    end
    # water movement analysis
    if @actor.npc?
      case @actor.id
      when 20314, 20849 # Great White Shark, Light Worm
        @cannot_move_on_land = true
      else
        @cannot_move_on_land = false
      end
    end
    # skill analysis
    @actor.all_skills.each do |sk|
      if sk.passive?
        next
      end
      cast_range = sk.cast_range
      @has_long_range_damage_skill = false

      if sk.continuous?
        if sk.debuff?
          @debuff_skills << sk
        else
          @buff_skills << sk
        end

        next
      end

      if sk.has_effect_type?(EffectType::DISPEL)
        @cancel_skills << sk
      elsif sk.has_effect_type?(EffectType::HP)
        @heal_skills << sk
        @has_heal_or_resurrect = true
      elsif sk.has_effect_type?(EffectType::SLEEP)
        @sleep_skills << sk
      elsif sk.has_effect_type?(EffectType::STUN, EffectType::PARALYZE)
        # hardcoding petrification until improvements are made to
        # EffectTemplate... petrification is totally different for
        # AI than paralyze
        case sk.id
        when 367, 4111, 4383, 4616, 4578
          @sleep_skills << sk
        else
          @general_disablers << sk
        end
      elsif sk.has_effect_type?(EffectType::ROOT)
        @root_skills << sk
      elsif sk.has_effect_type?(EffectType::FEAR)
        @debuff_skills << sk
      elsif sk.has_effect_type?(EffectType::MUTE)
        @mute_skills << sk
      elsif sk.has_effect_type?(EffectType::RESURRECTION)
        @resurrect_skills << sk
        @has_heal_or_resurrect = true
      else
        @general_skills << sk
        @has_long_range_damage_skill = true
      end

      if cast_range > 70
        @has_long_range_skills = true
        if @has_long_range_damage_skill
          @has_long_range_damage_skills = true
        end
      end
      if cast_range > @max_cast_range
        @max_cast_range = cast_range
      end

    end
    # Because of missing skills, some mages/balanced cannot play like mages
    if !@has_long_range_damage_skills && @mage
      @balanced = true
      @mage = false
      @fighter = false
    end
    if !@has_long_range_skills && (@mage || @balanced)
      @balanced = false
      @mage = false
      @fighter = true
    end
    if @general_skills.empty? && @mage
      @balanced = true
      @mage = false
    end
  end
end
