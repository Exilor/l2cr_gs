class EffectHandler::BlockDamage < AbstractEffect
  enum BlockType : UInt8
    HP
    MP
  end

  @type : BlockType

  def initialize(attach_cond, apply_cond, set, params)
    super
    @type = params.get_enum("type", BlockType, BlockType::HP)
  end

  def effect_flags
    @type.hp? ? EffectFlag::BLOCK_HP.mask : EffectFlag::BLOCK_MP.mask
  end
end
