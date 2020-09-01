# class EffectTickTask
#   include Runnable

#   @tick_count = Atomic(Int32).new(0)

#   getter_initializer buff_info : BuffInfo, effect : AbstractEffect

#   def run
#     @buff_info.on_tick(@effect, @tick_count.add(1) + 1)
#   end

#   def tick_count : Int32
#     @tick_count.get
#   end
# end

# @tick_count only used for debug purposes and can be ignored.
struct EffectTickTask
  getter_initializer buff_info : BuffInfo, effect : AbstractEffect

  def call
    @buff_info.on_tick(@effect, 0)
  end

  def tick_count : Int32
    0
  end
end
