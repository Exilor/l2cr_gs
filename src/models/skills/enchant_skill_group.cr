struct EnchantSkillGroup
  struct EnchantSkillHolder
    getter level : Int32
    getter sp_cost : Int32
    getter exp_cost : Int32
    getter adena_cost : Int32
    @rate : Slice(UInt8)

    def initialize(set : StatsSet)
      @level = set.get_i32("level")
      @sp_cost = set.get_i32("sp")
      @exp_cost = set.get_i32("exp")
      @adena_cost = set.get_i32("adena")
      @rate = Slice(UInt8).new(24) { |i| set.get_u8("chance#{i + 76}", 0) }
    end

    def get_rate(pc : L2PcInstance) : UInt8
      pc.level < 76 ? 0u8 : @rate[pc.level - 76]
    end
  end

  getter enchant_group_details = Array(EnchantSkillHolder).new

  getter_initializer id: Int32

  def add_enchant_detail(holder : EnchantSkillHolder)
    @enchant_group_details << holder
  end

  def add_enchant_detail(set : StatsSet)
    add_enchant_detail(EnchantSkillHolder.new(set))
  end
end
