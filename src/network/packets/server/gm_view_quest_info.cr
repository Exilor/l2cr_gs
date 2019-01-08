class Packets::Outgoing::GmViewQuestInfo < GameServerPacket
  initializer pc: L2PcInstance

  def write_impl
    c 0x99

    s @pc.name

    quest_list = @pc.all_active_quests

    if quest_list.empty?
      c 0
      h 0
      h 0
      return
    end

    h quest_list.size

    quest_list.each do |q|
      d q.id

      if qs = @pc.get_quest_state(q.name)
        d qs.get_int("cond")
      else
        d 0
      end
    end
  end
end
