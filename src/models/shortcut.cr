require "../enums/shortcut_type"

class Shortcut
  property shared_reuse_group : Int32 = -1

  getter_initializer slot: Int32, page: Int32, type: ShortcutType, id: Int32,
    level: Int32, character_type: Int32

  def index : Int32
    slot + (page * 12)
  end
end
