module Broadcast
  extend self
  include Packets::Outgoing

  def to_known_players(char : L2Character, gsp : GameServerPacket)
    char.known_list.each_player do |pc|
      pc.send_packet(gsp)

      if gsp.is_a?(CharInfo) && char.is_a?(L2PcInstance)
        relation = char.get_relation(pc)
        old_relation = char.known_list.known_relations[pc.l2id]

        if old_relation && old_relation != relation
          rc = RelationChanged.new(char, relation, char.auto_attackable?(pc))
          pc.send_packet(rc)

          if s = char.summon
            rc = RelationChanged.new(s, relation, char.auto_attackable?(pc))
            pc.send_packet(rc)
          end
        end
      end
    end
  end

  def to_known_players_in_radius(char : L2Character, gsp : GameServerPacket, radius : Int32)
    radius = 1500 if radius < 0

    char.known_list.each_player do |pc|
      if char.inside_radius?(pc, radius, false, false)
        pc.send_packet(gsp)
      end
    end
  end

  def to_self_and_known_players(char : L2Character, gsp : GameServerPacket)
    if char.is_a?(L2PcInstance)
      char.send_packet(gsp)
    end

    to_known_players(char, gsp)
  end

  def to_self_and_known_players_in_radius(char : L2Character, gsp : GameServerPacket, radius : Int32)
    radius = 600 if radius < 0

    char.send_packet(gsp) if char.player?

    char.known_list.each_player do |pc|
      if Util.in_range?(radius, char, pc, false)
        pc.send_packet(gsp)
      end
    end
  end

  def to_all_online_players(text : String, critical : Bool = false)
    if critical
      say = Packets::Incoming::Say2::CRITICAL_ANNOUNCE
    else
      say = Packets::Incoming::Say2::ANNOUNCEMENT
    end
    gsp = CreatureSay.new(0, say, "", text)

    to_all_online_players(gsp)
  end

  def to_all_online_players(gsp : GameServerPacket)
    L2World.players.each { |pc| pc.send_packet(gsp) if pc.online? }
  end

  def to_all_online_players_on_screen(text : String)
    to_all_online_players(ExShowScreenMessage.new(text, 10_000))
  end

  def to_players_in_instance(gsp : GameServerPacket, instance_id : Int32)
    L2World.players.each do |pc|
      if pc.online? && pc.instance_id == instance_id
        pc.send_packet(gsp)
      end
    end
  end
end
