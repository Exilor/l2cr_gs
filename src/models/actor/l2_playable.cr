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

  def instance_type : InstanceType
    InstanceType::L2Playable
  end

  def known_list : PlayableKnownList
    super.as(PlayableKnownList)
  end

  def stat : PlayableStat
    super.as(PlayableStat)
  end

  def status : PlayableStatus
    super.as(PlayableStatus)
  end

  private def init_ai : L2CharacterAI
    L2PlayableAI.new(self)
  end

  private def init_known_list
    @known_list = PlayableKnownList.new(self)
  end

  private def init_char_stat
    @stat = PlayableStat.new(self)
  end

  private def init_char_status
    @status = PlayableStatus.new(self)
  end

  def locked_target? : Bool
    !!@locked_target
  end

  def can_be_attacked? : Bool
    true
  end

  def playable? : Bool
    true
  end

  def noblesse_blessing_affected? : Bool
    affected?(EffectFlag::NOBLESS_BLESSING)
  end

  def resurrect_special_affected? : Bool
    affected?(EffectFlag::RESURRECTION_SPECIAL)
  end

  def protection_blessing_affected? : Bool
    affected?(EffectFlag::PROTECTION_BLESSING)
  end

  def silent_move_affected? : Bool
    affected?(EffectFlag::SILENT_MOVE)
  end

  def check_if_pvp(target : L2Character?) : Bool
    return false unless target
    return false if target == self
    return false unless target.playable?
    return false unless player = acting_player
    return false if player.karma != 0
    return false unless target_player = target.acting_player
    return false if target_player == self
    return false if target_player.karma != 0
    return false if target_player.pvp_flag == 0
    true
  end

  def add_level(level) : Bool
    false
  end

  def exp : Int64
    0i64
  end

  def sp : Int32
    0
  end

  def do_die(killer : L2Character?) : Bool
    evt = OnCreatureKill.new(killer, self)
    term = EventDispatcher.notify(evt, self, TerminateReturn)
    if term && term.terminate
      return false
    end

    sync do
      if dead?
        return false
      end

      self.current_hp = 0.0
      self.dead = true
    end

    self.target = nil
    stop_move(nil)

    status.stop_hp_mp_regeneration

    delete_buffs = true

    if noblesse_blessing_affected?
      stop_effects(EffectType::NOBLESSE_BLESSING)
      delete_buffs = false
    end

    if resurrect_special_affected?
      stop_effects(EffectType::RESURRECTION_SPECIAL)
      delete_buffs = true
    end

    if player? && (pc = acting_player)
      if pc.charm_of_courage?
        if pc.in_siege?
          pc.revive_request(pc, nil, false, 0, 0)
        end
        pc.charm_of_courage = false
        pc.send_packet(EtcStatusUpdate.new(pc))
      end
    end

    if delete_buffs
      stop_all_effects_except_those_that_last_through_death
    end

    broadcast_status_update

    world_region.try &.on_death(self)

    pc = acting_player.not_nil!

    unless pc.notify_quest_of_death_empty?
      pc.notify_quest_of_death.each do |qs|
        qs.quest.notify_death(killer || self, self, qs)
      end
    end

    if instance_id > 0
      if instance = InstanceManager.get_instance(instance_id)
        instance.notify_death(killer, self)
      end
    end

    if killer && (player = killer.acting_player)
      player.on_kill_update_pvp_karma(self)
    end

    notify_event(AI::DEAD)
    update_effect_icons

    true
  end

  def update_effect_icons(party_only : Bool)
    effect_list.update_effect_icons(party_only)
  end

  abstract def store_me
  abstract def do_pickup_item(object : L2Object)
  abstract def karma : Int32
  abstract def pvp_flag : Int8
  abstract def use_magic(skill : Skill, force : Bool, dont_move : Bool) : Bool
  abstract def store_effect(store_effects : Bool)
  abstract def restore_effects
end
