# It has to be a class instead of a struct because Atomic could cause problems
# otherwise.
# class BuffTimeTask
#   include Runnable

#   @time = Atomic(Int32).new(0)

#   initializer info: BuffInfo

#   def run
#     if @time.add(1) + 1 > @info.abnormal_time
#       @info.effected.stop_skill_effects(false, @info.skill.id)
#     end
#   end

#   def elapsed_time : Int32
#     @time.get
#   end
# end


# Alternative implementation that should make long buffs not linger blinking on
# the screen when there has been a server slowdown.
struct BuffTimeTask
  @start_time = Time.s

  initializer info : BuffInfo

  def call
    if Time.s >= @start_time + @info.abnormal_time
      @info.effected.stop_skill_effects(false, @info.skill.id)
    end
  end

  def elapsed_time : Int32
    (Time.s - @start_time).to_i32
  end
end
