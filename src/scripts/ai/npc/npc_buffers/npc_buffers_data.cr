module NpcBuffersData
  extend self
  extend XMLReader

  private NPC_BUFFERS = {} of Int32 => NpcBufferData

  def load
    parse_datapack_file("scripts/ai/npc/NpcBuffers/NpcBuffersData.xml")
    info { "Loaded #{NPC_BUFFERS.size} buffers data." }
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |n|
      n.find_element("npc") do |d|
        npc_id = d["id"].to_i
        npc = NpcBufferData.new(npc_id)

        d.find_element("skill") do |c|
          set = StatsSet.new(c.attributes)
          npc.add_skill(NpcBufferSkillData.new(set))
        end

        NPC_BUFFERS[npc_id] = npc
      end
    end
  end

  def get_npc_buffer(npc_id : Int)
    NPC_BUFFERS[npc_id]
  end

  def npc_buffers
    NPC_BUFFERS.local_each_value
  end

  def npc_buffer_ids
    NPC_BUFFERS.each_key
  end
end
