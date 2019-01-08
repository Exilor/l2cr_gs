require "./summon_stat"

class PetStat < SummonStat
  include Packets::Outgoing

  def add_exp(value : Int64) : Bool
    pet = active_char

    return false if pet.uncontrollable? || !super

    pet.update_and_broadcast_status(1)
    pet.update_effect_icons(true)

    true
  end

  def add_exp_and_sp(exp : Int64, sp : Int32) : Bool
    pet = active_char

    return false if pet.uncontrollable? || !add_exp(exp)

    # custom (no message is sent in H5)
    sm = SystemMessage.pet_earned_s1_exp
    sm.add_long(exp)
    pet.send_packet(sm)
    #

    pet.update_and_broadcast_status(1)

    true
  end

  def add_level(value : Int8) : Bool
    return false if level + value > max_level - 1

    pet = active_char

    level_increased = super

    su = StatusUpdate.new(pet)
    su.add_level(level)
    su.add_max_hp(max_hp)
    su.add_max_mp(max_mp)
    pet.broadcast_packet(su)

    if level_increased
      pet.broadcast_packet(SocialAction.level_up(pet.l2id))
    end

    pet.update_and_broadcast_status(1)

    pet.control_item.try &.enchant_level = level

    level_increased
  end

  def get_exp_for_level(level : Int32) : Int64
    data = PetDataTable.get_pet_level_data(@active_char.id, level)

    unless data
      warn "Pet level data not found."
    end

    data.pet_max_exp
  end

  def feed_battle : Int32
    active_char.pet_level_data.pet_feed_battle
  end

  def feed_normal : Int32
    active_char.pet_level_data.pet_feed_normal
  end

  def level=(value : Int8)
    pet = active_char
    pet.pet_data = PetDataTable.get_pet_level_data(pet.template.id, value)
    unless pet.pet_level_data
      raise "no pet data for npc #{pet.template.id}"
    end
    pet.stop_feed
    super
    pet.start_feed
    pet.control_item.try &.enchant_level = level
  end

  def max_feed : Int32
    active_char.pet_level_data.pet_max_feed
  end

  def max_hp : Int32
    calc_stat(MAX_HP, active_char.pet_level_data.pet_max_hp).to_i
  end

  def max_mp : Int32
    calc_stat(MAX_MP, active_char.pet_level_data.pet_max_mp).to_i
  end

  def get_m_atk(target : L2Character? = nil, skill : Skill? = nil) : Float64
    calc_stat(MAGIC_ATTACK, active_char.pet_level_data.pet_m_atk, target, skill)
  end

  def get_m_def(target : L2Character? = nil, skill : Skill? = nil) : Float64
    calc_stat(MAGIC_DEFENCE, active_char.pet_level_data.pet_m_def, target, skill)
  end

  def get_p_atk(target : L2Character? = nil) : Float64
    calc_stat(POWER_ATTACK, active_char.pet_level_data.pet_p_atk, target)
  end

  def get_p_def(target : L2Character? = nil) : Float64
    calc_stat(POWER_DEFENCE, active_char.pet_level_data.pet_p_def, target)
  end

  def p_atk_spd : Float64
    active_char.hungry? ? super.fdiv(2) : super.to_f
  end

  def m_atk_spd : Int32
    active_char.hungry? ? super / 2 : super
  end

  def max_level : Int32
    Config.max_pet_level
  end

  def max_exp_level : Int32
    Config.max_pet_level + 1
  end

  def active_char
    super.as(L2PetInstance)
  end
end
