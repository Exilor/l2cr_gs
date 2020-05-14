struct TrapTask
  include Loggable

  private TICK = 1000

  initializer trap : L2TrapInstance

  def call
    return if @trap.triggered?

    if @trap.has_life_time?
      @trap.remaining_time &-= TICK
      if @trap.remaining_time < @trap.life_time &- 15_000
        sa = Packets::Outgoing::SocialAction.new(@trap.l2id, 2)
        @trap.broadcast_packet(sa)
      end

      if @trap.remaining_time <= 0
        case @trap.skill.target_type
        when .aura?, .front_aura?, .behind_aura?
          @trap.trigger_trap(@trap)
        else
          @trap.unsummon
        end

        return
      end
    end

    @trap.known_list.each_character do |target|
      if @trap.check_target(target)
        @trap.trigger_trap(target)
        break
      end
    end
  rescue e
    error e
    @trap.unsummon
  end
end
