require "../interfaces/script_type"

struct SummonRequestHolder
  include ScriptType
  getter_initializer requester: L2PcInstance, item_id: Int32, item_count: Int32
end
