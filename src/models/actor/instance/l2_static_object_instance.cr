require "../l2_character"
require "../known_list/static_object_known_list"
require "../stat/static_object_stat"
require "../status/static_object_status"

class L2StaticObjectInstance < L2Character
  INTERACTION_DISTANCE = 150

  getter mesh_index = 0
  getter! map : ShowTownMap?
  property type : Int32 = -1

  def initialize(template : L2CharTemplate, @static_l2id : Int32)
    super(template)
  end

  def instance_type : InstanceType
    InstanceType::L2StaticObjectInstance
  end

  def auto_attackable?(attacker : L2Character) : Bool
    false
  end

  def level : Int32
    1
  end

  def ai : L2CharacterAI
    # no-op
    raise "L2StaticObjectInstance doesn't have an AI."
  end

  def id : Int32
    @static_l2id
  end

  private def init_known_list
    @known_list = StaticObjectKnownList.new(self)
  end

  private def init_char_stat
    @stat = StaticObjectStat.new(self)
  end

  private def init_char_status
    @status = StaticObjectStatus.new(self)
  end

  def set_map(texture : String, x : Int32, y : Int32)
    @map = ShowTownMap.new("town_map.#{texture}", x, y)
  end

  def active_weapon_instance? : L2ItemInstance?
    # return nil
  end

  def active_weapon_item? : L2Weapon?
    # return nil
  end

  def secondary_weapon_instance? : L2ItemInstance?
    # return nil
  end

  def secondary_weapon_item? : L2Weapon?
    # return nil
  end

  def mesh_index=(@mesh_index : Int32)
    broadcast_packet(StaticObject.new(self))
  end

  def update_abnormal_effect
    # no-op
  end

  def send_info(pc : L2PcInstance)
    pc.send_packet(StaticObject.new(self))
  end

  def move_to_location(x : Int32, y : Int32, z : Int32, offset : Int32)
    # no-op
  end

  def stop_move(loc : Location?)
    # no-op
  end

  def do_attack(target : L2Character?)
    # no-op
  end

  def do_cast(skill : Skill)
    # no-op
  end
end
