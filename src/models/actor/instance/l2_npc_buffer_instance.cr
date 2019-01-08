class L2NpcBufferInstance < L2Npc
  @page_val = {} of Int32 => Int32

  def instance_type
    InstanceType::L2NpcBufferInstance
  end
end
