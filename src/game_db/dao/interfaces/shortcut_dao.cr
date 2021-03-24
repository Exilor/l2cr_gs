module GameDB
  module ShortcutDAO
    macro extended
      include Loggable
    end

    abstract def delete(pc : L2PcInstance, class_index : Int32) : Bool
  end
end
