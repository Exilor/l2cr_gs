class MagicUseTask
  property skill : Skill
  property targets : Array(L2Object)?
  property skill_time : Int32
  property count : Int32 = 0
  property phase : UInt8 = 1u8
  property? simultaneous : Bool

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
    else
      # [automatically added else]
    end

  end
end
