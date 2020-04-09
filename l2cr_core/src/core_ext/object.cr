class Object
  macro initializer(*args)
    def initialize({{*args.map { |a| "@#{a}".id }}})
    end
  end

  macro getter_initializer(*args)
    initializer {{*args}}
    getter {{*args}}
  end

  macro setter_initializer(*args)
    initializer {{*args}}
    setter {{*args}}
  end

  macro property_initializer(*args)
    initializer {{*args}}
    property {{*args}}
  end
end
