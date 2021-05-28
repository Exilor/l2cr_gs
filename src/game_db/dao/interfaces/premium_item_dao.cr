module GameDB
  module PremiumItemDAO
    include Loggable

    abstract def load(pc : L2PcInstance)
    abstract def update(pc : L2PcInstance, item_num : Int32, new_count : Int64)
    abstract def delete(pc : L2PcInstance, item_num : Int32)
  end
end
