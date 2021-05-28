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
