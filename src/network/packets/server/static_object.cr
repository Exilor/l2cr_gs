class Packets::Outgoing::StaticObject < GameServerPacket
  @static_l2id : Int32
  @l2id : Int32
  @mesh_index : Int32

  def initialize(obj : L2StaticObjectInstance)
    @static_l2id = obj.id
    @l2id = obj.l2id
    @mesh_index = obj.mesh_index

    @type = 0
    @targetable = 0
    @closed = false
    @enemy = false
    @max_hp = 0
    @current_hp = 0
    @show_hp = false
    @damage_grade = 0
  end

  def initialize(door : L2DoorInstance, targetable : Bool)
    @static_l2id = door.id
    @l2id = door.l2id
    @mesh_index = door.mesh_index

    @type = 1
    @targetable = door.targetable? || targetable
    @closed = !door.open?
    @enemy = door.enemy?
    @max_hp = door.max_hp
    @current_hp = door.current_hp.to_i
    @show_hp = door.show_hp?
    @damage_grade = door.damage
  end

  private def write_impl
    c 0x9f

    d @static_l2id
    d @l2id
    d @type
    d @targetable ? 1 : 0
    d @mesh_index
    d @closed ? 1 : 0
    d @enemy ? 1 : 0
    d @current_hp
    d @max_hp
    d @show_hp ? 1 : 0
    d @damage_grade
  end
end
