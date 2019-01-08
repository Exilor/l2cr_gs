# It has to be a class instead of a struct because Atomic could cause problems
# otherwise.
class BuffTimeTask
  include Runnable

  @time = Atomic(Int32).new(0)

  initializer info: BuffInfo

  def run
    if @time.add(1) + 1 > @info.abnormal_time
      @info.effected.stop_skill_effects(false, @info.skill.id)
    end
  end

  def elapsed_time : Int32
    @time.get
  end
end


# struct BuffTimeTask
#   include Runnable

#   @end_time : Time
#   @start_time = Time.now

#   def initialize(@info : BuffInfo)
#     @end_time = @start_time + @info.abnormal_time.seconds
#   end

#   def run
#     if Time.now >= @end_time
#       @info.effected.stop_skill_effects(false, @info.skill.id)
#     end
#   end

#   def elapsed_time : Int32
#     Time.s - @start_time.s
#   end
# end
