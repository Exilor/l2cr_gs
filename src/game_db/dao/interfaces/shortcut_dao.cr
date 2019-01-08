module GameDB
  module ShortcutDAO
    include Loggable

    abstract def delete(pc : L2PcInstance, class_index : Int32) : Bool
  end
end
