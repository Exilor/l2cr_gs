class L2Fishing
  include Loggable
  include Synchronizable
  include Packets::Outgoing

  @task : Scheduler::PeriodicTask?
  @fish_max_hp : Int32
  @fish_cur_hp : Int32
  @regen_hp : Float64
  @time : Int32
  @fish_id : Int32
  @anim = 0
  @thinking = false
  @deceptive_mode : Int32
  @stop = 0
  @good_use = 0


  def initialize(@pc : L2PcInstance, fish : L2Fish, noob : Bool, @upper_grade : Bool)
    @fish_max_hp = fish.fish_hp
    @fish_cur_hp = @fish_max_hp
    @regen_hp = fish.hp_regen
    @fish_id = fish.item_id
    @time = fish.combat_duration
    if upper_grade
      @deceptive_mode = Rnd.rand(100) >= 90 ? 1 : 0
      lure_type = 2
    else
      @deceptive_mode = 0
      lure_type = noob ? 0 : 1
    end
    @mode = Rnd.rand(100) >= 80 ? 1 : 0

    ex = ExFishingStartCombat.new(pc, @time, @fish_max_hp, @mode, lure_type, @deceptive_mode)
    pc.broadcast_packet(ex)
    pc.send_packet(SystemMessageId::GOT_A_BITE)

    @task ||= ThreadPoolManager.schedule_effect_at_fixed_rate(self, 1000, 1000)
  end

  def call
    return unless pc = @pc

    if @fish_cur_hp >= @fish_max_hp * 2
      pc.send_packet(SystemMessageId::BAIT_STOLEN_BY_FISH)
      do_die(false)
    elsif @time <= 0
      pc.send_packet(SystemMessageId::FISH_SPIT_THE_HOOK)
      do_die(false)
    else
      ai_task
    end
  end

  def change_hp(hp, pen)
    @fish_cur_hp -= hp
    if @fish_cur_hp < 0
      @fish_cur_hp = 0
    end
    ex = ExFishingHpRegen.new(@pc.not_nil!, @time, @fish_cur_hp, @mode, @good_use, @anim, pen, @deceptive_mode)
    @pc.not_nil!.broadcast_packet(ex)
    @anim = 0
    if @fish_cur_hp > (@fish_max_hp * 2)
      @fish_cur_hp = @fish_max_hp * 2
      do_die(false)
    elsif @fish_cur_hp == 0
      do_die(true)
    end
  end

  def do_die(win)
    sync do
      if task = @task
        task.cancel
        @task = nil
      end

      return unless pc = @pc

      if win
        if monster = FishingMonstersData.get_fishing_monster(pc.level)
          if Rnd.rand(100) <= monster.probability
            pc.send_packet(SystemMessageId::YOU_CAUGHT_SOMETHING_SMELLY_THROW_IT_BACK)
            monster = AbstractScript.add_spawn(monster.id, pc)
            monster.target = pc
          else
            pc.send_packet(SystemMessageId::YOU_CAUGHT_SOMETHING)
            pc.add_item("Fishing", @fish_id, 1, nil, true)
          end
        end
      end

      pc.end_fishing(win)

      @pc = nil
    end
  end

  private def ai_task
    return if @thinking
    @thinking = true
    @time -= 1

    begin
      if @mode == 1
        if @deceptive_mode == 0
          @fish_cur_hp += @regen_hp.to_i
        end
      else
        if @deceptive_mode == 1
          @fish_cur_hp += @regen_hp.to_i
        end
      end

      if @stop == 0
        @stop = 1
        check = Rnd.rand(100)
        if check >= 70
          @mode = @mode == 0 ? 1 : 0
        end
        if @upper_grade
          check = Rnd.rand(100)
          if check >= 90
            @deceptive_mode = @deceptive_mode == 0 ? 1 : 0
          end
        end
      else
        @stop -= 1
      end
    ensure
      @thinking = false
      ex = ExFishingHpRegen.new(@pc.not_nil!, @time, @fish_cur_hp, @mode, 0, @anim, 0, @deceptive_mode)
      if @anim == 0
        @pc.not_nil!.send_packet(ex)
      else
        @pc.not_nil!.broadcast_packet(ex)
      end
    end
  end

  def use_reeling(dmg, pen)
    @anim = 2
    if Rnd.rand(100) > 90
      @pc.not_nil!.send_packet(SystemMessageId::FISH_RESISTED_ATTEMPT_TO_BRING_IT_IN)
      @good_use = 0
      change_hp(0, pen)
      return
    end

    return unless @pc

    if @mode == 1
      if @deceptive_mode == 0
        sm = SystemMessage.reeling_succesful_s1_damage
        sm.add_int(dmg)
        @pc.not_nil!.send_packet(sm)
        if pen > 0
          sm = SystemMessage.reeling_successful_penalty_s1
          sm.add_int(pen)
          @pc.not_nil!.send_packet(sm)
        end
        @good_use = 1
        change_hp(dmg, pen)
      else
        sm = SystemMessage.fish_resisted_reeling_s1_hp_regained
        sm.add_int(dmg)
        @pc.not_nil!.send_packet(sm)
        @good_use = 2
        change_hp(-dmg, pen)
      end
    else
      if @deceptive_mode == 0
        sm = SystemMessage.fish_resisted_reeling_s1_hp_regained
        sm.add_int(dmg)
        @pc.not_nil!.send_packet(sm)
        @good_use = 2
        change_hp(-dmg, pen)
      else
        sm = SystemMessage.reeling_succesful_s1_damage
        sm.add_int(dmg)
        @pc.not_nil!.send_packet(sm)
        if pen > 0
          sm = SystemMessage.reeling_successful_penalty_s1
          sm.add_int(pen)
          @pc.not_nil!.send_packet(sm)
        end
        @good_use = 1
        change_hp(dmg, pen)
      end
    end
  end

  def use_pumping(dmg, pen)
    @anim = 1

    if Rnd.rand(100) > 90
      @pc.not_nil!.send_packet(SystemMessageId::FISH_RESISTED_ATTEMPT_TO_BRING_IT_IN)
      @good_use = 0
      change_hp(0, pen)
      return
    end

    return unless @pc

    if @mode == 0
      if @deceptive_mode == 0
        sm = SystemMessage.pumping_succesful_s1_damage
        sm.add_int(dmg)
        @pc.not_nil!.send_packet(sm)
        if pen > 0
          sm = SystemMessage.pumping_successful_penalty_s1
          sm.add_int(pen)
          @pc.not_nil!.send_packet(sm)
        end
        @good_use = 1
        change_hp(dmg, pen)
      else
        sm = SystemMessage.fish_resisted_pumping_s1_hp_regained
        sm.add_int(dmg)
        @pc.not_nil!.send_packet(sm)
        @good_use = 2
        change_hp(-dmg, pen)
      end
    else
      if @deceptive_mode == 0
        sm = SystemMessage.fish_resisted_pumping_s1_hp_regained
        sm.add_int(dmg)
        @pc.not_nil!.send_packet(sm)
        @good_use = 2
        change_hp(-dmg, pen)
      else
        sm = SystemMessage.pumping_succesful_s1_damage
        sm.add_int(dmg)
        @pc.not_nil!.send_packet(sm)
        if pen > 0
          sm = SystemMessage.pumping_successful_penalty_s1
          sm.add_int(pen)
          @pc.not_nil!.send_packet(sm)
        end
        @good_use = 1
        change_hp(dmg, pen)
      end
    end
  end
end
