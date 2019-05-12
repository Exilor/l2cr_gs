require "./abstract_player_group"

class L2CommandChannel < AbstractPlayerGroup
  @party : L2Party
  getter leader
  getter level : Int32
  getter parties : Array(L2Party)

  def_equals leader_l2id

  def initialize(leader : L2PcInstance)
    @leader = leader
    @party = leader.party
    @parties = [@party]
    @level = @party.level
    @party.command_channel = self
    @party.broadcast_message(SystemMessageId::COMMAND_CHANNEL_FORMED)
    @party.broadcast_packet(ExOpenMPCC::STATIC_PACKET)
  end

  def add_party(party : L2Party)
    broadcast_packet(ExMPCCPartyInfoUpdate.new(party, 1))
    @parties << party
    if party.level > @level
      @level = party.level
    end
    party.command_channel = self
    party.broadcast_packet(SystemMessage.joined_command_channel)
    party.broadcast_packet(ExOpenMPCC::STATIC_PACKET)
  end

  def remove_party(party : L2Party)
    @parties.delete_first(party)
    @level = @parties.max_of &.level
    party.command_channel = nil
    party.broadcast_packet(ExCloseMPCC::STATIC_PACKET)
    if @parties.size < 2
      broadcast_packet(SystemMessage.command_channel_disbanded)
      disband_channel
    else
      broadcast_packet(ExMPCCPartyInfoUpdate.new(party, 0))
    end
  end

  def disband_channel
    @parties.reverse_each do |party|
      remove_party(party)
    end
  end

  def size : Int32
    @parties.sum &.size
  end

  def members : Array(L2PcInstance)
    members = Array(L2PcInstance).new(size)
    parties.each { |party| members.concat(party.members) }
    members
  end

  def leader=(leader : L2PcInstance)
    @leader = leader
    if leader.level > @level
      @level = leader.level
    end
  end

  def meets_raid_war_condition?(obj : L2Object) : Bool
    unless obj.is_a?(L2Character) && obj.raid?
      return false
    end

    size >= Config.loot_raids_privilege_cc_size
  end

  def includes?(pc : L2PcInstance) : Bool
    @parties.any? { |party| party.includes?(pc) }
  end

  def each(&block : L2PcInstance ->)
    @parties.each { |party| party.each { |pc| yield pc } }
  end
end
