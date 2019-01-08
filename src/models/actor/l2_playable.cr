require "./l2_character"
require "./stat/playable_stat"
require "./status/playable_status"
require "./known_list/playable_known_list"
require "./ai/l2_playable_ai"

abstract class L2Playable < L2Character
  property locked_target : L2Character?
  property transferring_damage_to : L2PcInstance?

  def initialize(l2id : Int32, template : L2CharTemplate)
    super
    self.invul = false
  end

  def initialize(template : L2CharTemplate)
    super
    self.invul = false
  end

  def instance_type
    InstanceType::L2Playable
  end

  def known_list
    super.as(PlayableKnownList)
  end

  def stat
    super.as(PlayableStat)
  end

  def status
    super.as(PlayableStatus)
  end

  def init_ai
    L2PlayableAI.new(self)
  end

  def init_known_list
    @known_list = PlayableKnownList.new(self)
  end

  def init_stat
    @stat = PlayableStat.new(self)
  end

  def init_status
    @status = PlayableStatus.new(self)
  end

  def locked_target?
    !!@locked_target
  end

  def can_be_attacked?
    true
  end

  def playable?
    true
  end

  def noblesse_blessing_affected?
    affected?(EffectFlag::NOBLESS_BLESSING)
  end

  def resurrect_special_affected?
    affected?(EffectFlag::RESURRECTION_SPECIAL)
  end

  def protection_blessing_affected?
    affected?(EffectFlag::PROTECTION_BLESSING)
  end

  def silent_move_affected?
    affected?(EffectFlag::SILENT_MOVE)
  end

  def check_if_pvp(target : L2Character?) : Bool
    return false unless target
    return false if target == self
    return false unless target.playable?
    return false unless player = acting_player?
    return false if player.karma != 0
    return false unless target_player = target.acting_player?
    return false if target_player == self
    return false if target_player.karma != 0
    return false if target_player.pvp_flag == 0
    true
  end

  def add_level(level)
    false
  end

  def exp
    0i64
  end

  def sp
    0
  end

  abstract def store_me
  abstract def do_pickup_item(object : L2Object)
  abstract def karma : Int32
  abstract def pvp_flag : UInt8
  abstract def use_magic(skill : Skill, force : Bool, dont_move : Bool) : Bool
  abstract def store_effect(store_effects : Bool)
  abstract def restore_effects
end
