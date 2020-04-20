module NpcBuffersData
  extend self
  extend XMLReader

  private NPC_BUFFERS = {} of Int32 => NpcBufferData

  def load
    parse_datapack_file("scripts/ai/npc/NpcBuffers/NpcBuffersData.xml")
    info { "Loaded #{NPC_BUFFERS.size} buffers data." }
  end

  private def parse_document(doc, file)
    find_element(doc, "list") do |n|
      find_element(n, "npc") do |d|
        npc_id = parse_int(d, "id")
        npc = NpcBufferData.new(npc_id)

        find_element(d, "skill") do |c|
          set = get_attributes(c)
          npc.add_skill(NpcBufferSkillData.new(set))
        end

        NPC_BUFFERS[npc_id] = npc
      end
    end
  end

  def get_npc_buffer(npc_id : Int) : NpcBufferData
    NPC_BUFFERS[npc_id]
  end

  def npc_buffers : Enumerable(NpcBufferData)
    NPC_BUFFERS.local_each_value
  end

  def npc_buffer_ids : Enumerable(Int32)
    NPC_BUFFERS.local_each_key
  end
end
