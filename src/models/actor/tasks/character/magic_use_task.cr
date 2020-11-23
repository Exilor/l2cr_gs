class MagicUseTask
  getter skill : Skill
  getter? simultaneous : Bool
  property targets : Array(L2Object)?
  property skill_time : Int32
  property count : Int32 = 0
  property phase : UInt8 = 1u8

  initializer character : L2Character, targets : Array(L2Object)?,
    skill : Skill, skill_time : Int32, simultaneous : Bool

  def call
    case @phase
    when 1
      @character.on_magic_launched_timer(self)
    when 2
      @character.on_magic_hit_timer(self)
    when 3
      @character.on_magic_finalizer(self)
    end
  end
end
