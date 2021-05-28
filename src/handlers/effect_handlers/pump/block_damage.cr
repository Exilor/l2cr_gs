class EffectHandler::BlockDamage < AbstractEffect
  enum BlockType : UInt8
    HP
    MP
  end

  @type : BlockType

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super
    @type = params.get_enum("type", BlockType, BlockType::HP)
  end

  def effect_flags : UInt64
    @type.hp? ? EffectFlag::BLOCK_HP.mask : EffectFlag::BLOCK_MP.mask
  end
end
