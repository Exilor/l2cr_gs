class Packets::Outgoing::AcquireSkillInfo < GameServerPacket
  private struct Req
    getter_initializer type : Int32, item_id : Int32, count : Int64, unk : Int32
  end

  @id : Int32
  @level : Int32
  @sp_cost : Int32
  @reqs : Array(Req)?

  def initialize(@type : AcquireSkillType, skill_learn : L2SkillLearn)
    @id = skill_learn.skill_id
    @level = skill_learn.skill_level
    @sp_cost = skill_learn.level_up_sp
    @reqs = skill_learn.required_items.map do |item|
      Req.new(99, item.id, item.count, 50)
    end
  end

  def initialize(@type : AcquireSkillType, skill_learn : L2SkillLearn, sp_cost : Int32)
    @id = skill_learn.skill_id
    @level = skill_learn.skill_level
    @sp_cost = sp_cost || skill_learn.level_up_sp

    if !type.pledge? || Config.life_crystal_needed
      reqs = [] of Req
      skill_learn.required_items.each do |item|
        if !Config.divine_sp_book_needed && @id == CommonSkill::DIVINE_INSPIRATION.id
          next
        end
        reqs << Req.new(99, item.id, item.count, 50)
      end
      @reqs = reqs
    end
  end

  private def write_impl
    c 0x91

    d @id
    d @level
    d @sp_cost
    d @type.to_i
    if reqs = @reqs
      d reqs.size
      reqs.each do |r|
        d r.type
        d r.item_id
        q r.count
        d r.unk
      end
    else
      d 0
    end
  end
end
