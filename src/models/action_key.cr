class ActionKey
  property command_id : Int32 = 0
  property key_id : Int32 = 0
  property toggle_key1 : Int32 = 0
  property toggle_key2 : Int32 = 0
  property show_status : Int32 = 0

  getter_initializer category: Int32

  initializer category: Int32, command_id: Int32, key_id: Int32,
    toggle_key1: Int32, toggle_key2: Int32, show_status: Int32

  def get_sql_save_string(pc_id : Int, order : Int, io : IO)
    {pc_id, @category, order, @command_id, @key_id, @toggle_key1, @toggle_key2,
      @show_status}.join(", ", io)
  end
end
