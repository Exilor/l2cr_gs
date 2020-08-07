class Packets::Outgoing::MonRaceInfo < GameServerPacket
  initializer unknown1 : Int32, unknown2 : Int32, monsters : Array(L2Npc),
    speeds : Slice(Slice(Int32))

  private def write_impl
    c 0xe3

    d @unknown1
    d @unknown2
    d 0x08

    8.times do |i|
      mon = @monsters[i]
      d mon.l2id # npcObjectID
      d mon.template.id &+ 1_000_000 # npcID
      d 14107 # origin X
      d 181875 &+ (58 &* (7 &- i)) # origin Y
      d -3566 # origin Z
      d 12080 # end X
      d 181875 &+ (58 &* (7 &- i)) # end Y
      d -3566 # end Z
      f mon.template.f_collision_height # coll. height
      f mon.template.f_collision_radius # coll. radius
      d 120 # ?? unknown
      20.times do |j|
        if @unknown1 == 0
          c @speeds[i][j]
        else
          c 0x00
        end
      end
      d 0x00
      d 0x00 # CT2.3 special effect
    end
  end
end
