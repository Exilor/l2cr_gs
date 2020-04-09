module Cancellable
  macro included
    getter? cancelled : Bool = false

    def cancel
      @cancelled = true
    end
  end

  macro extended
    class_getter? cancelled : Bool = false

    def self.cancel
      @@cancelled = true
    end
  end
end
