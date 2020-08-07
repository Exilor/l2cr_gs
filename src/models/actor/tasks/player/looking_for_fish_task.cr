struct LookingForFishTask
  @end_task_time : Int64

  def initialize(pc : L2PcInstance, start_time : Int, fish_guts_check : Float64, fish_group : Int32, noob : Bool, upper_grade : Bool)
    @pc = pc
    @fish_guts_check = fish_guts_check
    @fish_group = fish_group
    @noob = noob
    @upper_grade = upper_grade
    @end_task_time = Time.ms + (start_time * 1000) + 10_000
  end

  def call
    if Time.ms >= @end_task_time
      @pc.end_fishing(false)
      return
    end

    return if @fish_group == -1

    if @fish_guts_check > Rnd.rand(100)
      @pc.stop_looking_for_fish_task
      @pc.start_fish_combat(@noob, @upper_grade)
    end
  end
end
