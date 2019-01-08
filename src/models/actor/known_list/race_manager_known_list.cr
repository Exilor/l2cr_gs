require "./npc_known_list"

class RaceManagerKnownList < NpcKnownList
  def remove_known_object(object : L2Object?, forget : Bool)
    return false unless super

    if object.player?
      8.times do |i|
        dl = Packets::Outgoing::DeleteObject.new(MonsterRace.monsters[i])
        object.send_packet(dl)
      end
    end

    true
  end
end
