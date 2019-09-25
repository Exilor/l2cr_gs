struct AdminCommandAccessRight
  getter admin_command, access_level
  getter? require_confirm

  initializer admin_command : String, require_confirm : Bool,
    access_level : Int32

  def initialize(set : StatsSet)
    @admin_command = set.get_string("command")
    @require_confirm = set.get_bool("confirmDlg", false)
    @access_level = set.get_i32("accessLevel", 7)
  end

  def has_access?(lvl : AccessLevel) : Bool
    access_level = AdminData.get_access_level(@access_level)
    access_level.level == lvl.level || lvl.has_child_access?(access_level)
  end
end
