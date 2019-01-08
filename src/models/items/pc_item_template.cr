class PcItemTemplate < ItemHolder
  getter? equipped : Bool

  def initialize(set)
    super(set.get_i32("id"), set.get_i64("count"))
    @equipped = set.get_bool("equipped", false)
  end
end
