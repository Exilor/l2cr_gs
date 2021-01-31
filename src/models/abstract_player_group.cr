abstract class AbstractPlayerGroup
  include Enumerable(L2PcInstance)
  include Packets::Outgoing

  abstract def members# : Enumerable(L2PcInstance)
  abstract def leader : L2PcInstance
  abstract def leader=(pc : L2PcInstance)
  abstract def level : Int32

  delegate each, to: members
  def_equals leader_l2id

  def size : Int32
    members.size
  end

  def members_l2id : Array(Int32)
    map &.l2id
  end

  def leader_l2id : Int32
    leader.l2id
  end

  def leader?(pc : L2PcInstance)
    leader_l2id == pc.l2id
  end

  def broadcast_packet(gsp : GameServerPacket)
    each &.send_packet(gsp)
  end

  def broadcast_message(sm_id : SystemMessageId)
    broadcast_packet(SystemMessage[sm_id])
  end

  def broadcast_string(text : String)
    broadcast_packet(SystemMessage.from_string(text))
  end

  def broadcast_creature_say(creature_say : CreatureSay, broadcaster : L2PcInstance)
    each do |m|
      unless BlockList.blocked?(m, broadcaster)
        m.send_packet(creature_say)
      end
    end
  end

  def random_player : L2PcInstance
    members.sample(random: Rnd)
  end

  def each_with_summon(& : L2PcInstance | L2Summon ->) : Nil
    each do |m|
      yield m

      if s = m.summon
        yield s
      end
    end
  end

  def to_s(io : IO)
    io.print(self.class, "(leader: ", leader.name, ')')
  end

  def to_log(io : IO)
    to_s(io)
  end
end
