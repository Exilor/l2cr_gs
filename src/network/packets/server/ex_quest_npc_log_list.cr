class Packets::Outgoing::ExQuestNpcLogList < GameServerPacket
  private record NpcHolder, npc_id : Int32, unknown : Int32, count : Int32

  @npcs = [] of NpcHolder

  initializer quest_id : Int32

  def add_npc(npc_id : Int32, count : Int32)
    @npcs << NpcHolder.new(npc_id, 0, count)
  end

  def add_npc(npc_id : Int32, unknown : Int32, count : Int32)
    @npcs << NpcHolder.new(npc_id, unknown, count)
  end

  def write_impl
    c 0xfe
    h 0xc5

    d @quest_id
    c @npcs.size
    @npcs.each do |holder|
      d holder.npc_id + 1_000_000
      c holder.unknown
      d holder.count
    end
  end
end
