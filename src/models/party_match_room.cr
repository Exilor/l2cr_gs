class PartyMatchRoom
  # include Identifiable
  include Packets::Outgoing

  getter party_members, id
  property min_lvl : Int32
  property max_lvl : Int32
  property loot_type : Int32
  property max_members : Int32
  property title : String
  property min_lvl : Int32
  property max_lvl : Int32

  def initialize(@id : Int32, @title : String, @loot_type : Int32, @min_lvl : Int32, @max_lvl : Int32, @max_members : Int32, owner : L2PcInstance)
    @party_members = [owner]
  end

  def add_member(pc : L2PcInstance)
    @party_members << pc
  end

  def delete_member(pc : L2PcInstance)
    if pc != owner
      @party_members.delete(pc)
      notify_members_about_exit(pc)
    elsif @party_members.size == 1
      PartyMatchRoomList.delete_room(@id)
    else
      change_leader(@party_members[1])
      delete_member(pc)
    end
  end

  def notify_members_about_exit(pc : L2PcInstance)
    sm = SystemMessage.c1_left_party_room
    sm.add_char_name(pc)
    @party_members.each do |m|
      m.send_packet(sm)
      m.send_packet(ExManagePartyRoomMember.new(pc, self, 2))
    end
  end

  def change_leader(new_leader : L2PcInstance)
    old_leader = @party_members[0]
    @party_members[0] = new_leader
    @party_members << old_leader

    sm = SystemMessageId::PARTY_ROOM_LEADER_CHANGED
    @party_members.each do |m|
      m.send_packet(ExManagePartyRoomMember.new(new_leader, self, 1))
      m.send_packet(ExManagePartyRoomMember.new(old_leader, self, 1))
      m.send_packet(sm)
    end
  end

  def members : Int32
    @party_members.size
  end

  def location : Int32
    unless temp = MapRegionManager.get_map_region(@party_members[0])
      raise "Couldn't get map region for #{@party_members[0]}."
    end
    temp.bbs
  end

  def owner : L2PcInstance
    @party_members[0]
  end
end
