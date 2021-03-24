class Packets::Outgoing::QuestList < GameServerPacket
  private def write_impl
    unless pc = @client.try &.active_char
      return
    end

    quests = pc.all_active_quests
    # debug "Sending #{quests.size} quests."

    c 0x86

    h quests.size

    quests.each do |q|
      d q.id

      unless qs = pc.get_quest_state(q.name)
        debug "Quest state for #{q.name} not found."
        d 0
        next
      end

      states = qs.get_int("__compltdStateFlags")
      # debug "#{q.name}: #{states}"
      if states > 0
        d states
      else
        d qs.get_int("cond")
      end
    end

    temp = uninitialized UInt8[128]
    b temp.to_slice
  end
end
