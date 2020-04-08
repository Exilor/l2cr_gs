class TaskExecutor
  private DEFAULT_ERROR_HANDLER = ->raise(Exception)

  private class WorkerPool
    private class UnboundedChannel(T) < Channel(T)
      def initialize
        @closed = false
        @queue = Deque(T).new
        @capacity = Int32::MAX
        @senders = Crystal::PointerLinkedList(Sender(T)).new
        @receivers = Crystal::PointerLinkedList(Receiver(T)).new
      end
    end

    def initialize(pool_size, error_handler : (Exception ->)?)
      @error_handler = error_handler
      @tasks = UnboundedChannel(->).new
      @fibers = Slice(Fiber).new(pool_size) { new_worker }
    end

    def shutdown
      @tasks.close
    end

    def enqueue(task : ->)
      return if @tasks.closed?
      @tasks.send(task)
    end

    def enqueue(task)
      return if @tasks.closed?
      @tasks.send(-> { task.call })
    end

    private def new_worker
      spawn do
        while task = @tasks.receive?
          begin
            task.call
          rescue e
            @error_handler.try &.call(e)
          end
        end
      end
    end
  end

  def initialize(*, pool_size = 20, error_handler = DEFAULT_ERROR_HANDLER)
    @pool = WorkerPool.new(pool_size, error_handler)
  end

  def execute(task)
    @pool.enqueue(task)
  end

  def shutdown
    @pool.shutdown
  end

  class Scheduler < self
    private struct PriorityQueue(T)
      @values = [] of T

      def peek
        @values.last?
      end

      def get
        @values.pop?
      end

      def add(val)
        index = bisect_right(val)
        @values.insert(index, val)
      end

      private def bisect_right(val)
        l = 0
        u = @values.size
        while l < u
          m = l + ((u - l) // 2)

          if @values.unsafe_fetch(m) >= val
            l = m + 1
          else
            u = m
          end
        end

        l
      end
    end

    @scheduling_worker : Fiber

    def initialize(*, pool_size = 20, error_handler = DEFAULT_ERROR_HANDLER)
      super(pool_size: pool_size, error_handler: error_handler)

      @queue = PriorityQueue(Task).new
      @queue_lock = Mutex.new
      @scheduling_worker = init_scheduler
    end

    def schedule_delayed(callable, delay)
      DelayedTask.new(self, callable, delay)
    end

    def schedule_periodic(callable, delay, interval)
      PeriodicTask.new(self, callable, delay, interval)
    end

    private def init_scheduler
      spawn do
        loop do
          delay = nil

          @queue_lock.synchronize do
            ms = nil
            while (task = @queue.peek) && (ms ||= Time.local.to_unix_ms) >= task.@execute_at
              @queue.get
              task.fire
            end
            delay = task.try &.delay
            ms = nil
          end

          if delay && delay >= 0
            sleep(delay.milliseconds)
          else
            sleep
          end
        end
      end
    end

    protected def enqueue(task)
      @queue_lock.synchronize { @queue.add(task) }
      @scheduling_worker.resume_event.add(0.seconds)
    end

    abstract class Task
      def initialize(scheduler : Scheduler, callable, delay)
        @scheduler = scheduler
        @callable = callable.as?(->) || -> { callable.call }
        @execute_at = Int64.new(Time.local.to_unix_ms + delay)
        scheduler.enqueue(self)
      end

      protected def fire
        @scheduler.try &.execute(self)
      end

      def call
        @callable.try &.call
      end

      def delay
        @execute_at - Time.local.to_unix_ms
      end

      def cancel
        @scheduler = nil
      end

      def cancelled?
        @scheduler.nil?
      end

      def done?
        @callable.nil? || @scheduler.nil?
      end

      protected def >=(other)
        @execute_at >= other.@execute_at
      end
    end

    class DelayedTask < Task
      def call
        super
        @callable = nil
      end
    end

    class PeriodicTask < Task
      def initialize(scheduler, callable, delay, interval)
        @interval = Int32.new(interval)
        super(scheduler, callable, delay)
      end

      def call
        super
      ensure
        if sch = @scheduler
          @execute_at = Time.local.to_unix_ms + @interval
          sch.enqueue(self)
        end
      end
    end
  end
end
