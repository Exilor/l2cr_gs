struct NpcBufferData
  getter skills = [] of NpcBufferSkillData

  getter_initializer id : Int32

  def add_skill(s : NpcBufferSkillData)
    @skills << s
  end
end
