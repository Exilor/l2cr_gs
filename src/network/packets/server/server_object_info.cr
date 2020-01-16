class Packets::Outgoing::ServerObjectInfo < GameServerPacket
  @template_id : Int32
  @is_attackable : Bool
  @collision_height : Float64
  @collision_radius : Float64
  @x : Int32
  @y : Int32
  @z : Int32
  @heading : Int32
  @name : String

  def initialize(@npc : L2Npc, char : L2Character)
    @template_id = npc.template.display_id
    @is_attackable = npc.auto_attackable?(char)
    @collision_height = npc.collision_height
    @collision_radius = npc.collision_radius
    @x, @y, @z = npc.xyz
    @heading = npc.heading
    if npc.template.using_server_side_name?
      @name = npc.template.name
    else
      @name = ""
    end
  end

  private def write_impl
    c 0x92

    d @npc.l2id
    d @template_id + 1_000_000
    s @name
    d @is_attackable ? 1 : 0
    d @x
    d @y
    d @z
    d @heading
    f 1.0 # movement multiplier
    f 1.0 # attack speed multiplier
    f @collision_radius
    f @collision_height
    d @is_attackable ? @npc.current_hp : 0
    d @is_attackable ? @npc.max_hp : 0
    d 0x01 # object type
    d 0x00 # special effects
  end
end
