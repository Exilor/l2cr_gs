class MyMutex < Mutex
  def initialize
    super(:reentrant)
  end

  def synchronize
    if owned?
      yield
    else
      super { yield }
    end
  end

  def owned?
    @mutex_fiber == Fiber.current
  end

  def locked?
    !!@mutex_fiber
  end

  def lock?
    if locked?
      return false
    end

    lock

    true
  end
end

{% if flag?(:preview_mt) %}
  module Synchronizable
    macro included
      @synchronizable_mutex = MyMutex.new

      def sync(& : ->)
        @synchronizable_mutex.synchronize { yield }
      end
    end

    macro extended
      private SYNCHRONIZABLE_MUTEX = MyMutex.new

      def self.sync(& : ->)
        SYNCHRONIZABLE_MUTEX.synchronize { yield }
      end
    end
  end
{% else %}
  module Synchronizable
    macro included
      def sync(& : ->)
        yield
      end
    end

    macro extended
      def self.sync(& : ->)
        yield
      end
    end
  end
{% end %}
