abstract class L2Decoy < L2Character
  getter owner

  def initialize(template : L2CharTemplate, @owner : L2PcInstance)
    super(template)

    set_xyz_invisible(*owner.xyz)
    self.invul = false
  end

  def acting_player?
    @owner
  end

  def level : Int32
    template.level.to_i32
  end

  def id : Int32
    template.id
  end

  def stop_decay
    DecayTaskManager.cancel(self)
  end

  def on_decay
    delete_me(@owner)
  end

  def delete_me(owner : L2PcInstance)
    decay_me
    known_list.remove_all_known_objects
    owner.decoy = nil
  end

  def unsummon(owner : L2PcInstance)
    if visible? && alive?
      @world_region.try &.remove_from_zones(self)
      owner.decoy = nil
      decay_me
      known_list.remove_all_known_objects
    end
  end

  def send_info(pc : L2PcInstance)
    pc.send_packet(CharInfo.new(self))
  end

  def send_packet(arg : GameServerPacket | SystemMessageId)
    @owner.send_packet(arg)
  end

  def update_abnormal_effect
    ci = CharInfo.new(self)
    known_list.known_players.each_value &.send_packet(ci)
  end

  def template : L2NpcTemplate
    super.as(L2NpcTemplate)
  end

  def auto_attackable?(attacker : L2Character) : Bool
    @owner.auto_attackable?(attacker)
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
end
