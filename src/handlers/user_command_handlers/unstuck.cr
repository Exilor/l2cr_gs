module UserCommandHandler::Unstuck
  extend self
  extend UserCommandHandler

  def use_user_command(id, pc)
    if !TvTEvent.on_escape_use(pc.l2id)
      pc.action_failed
      return false
    elsif pc.jailed?
      pc.send_message("You cannot use this function while you are jailed.")
      return false
    end

    if pc.in_olympiad_mode?
      pc.send_packet(SystemMessageId::THIS_SKILL_IS_NOT_AVAILABLE_FOR_THE_OLYMPIAD_EVENT)
      return false
    end

    return false if pc.casting_now?
    return false if pc.movement_disabled?
    return false if pc.muted?
    return false if pc.looks_dead?
    return false if pc.in_observer_mode?
    return false if pc.combat_flag_equipped?

    unstuck_timer = pc.gm? ? 1000 : Config.unstuck_interval * 1000

    pc.force_is_casting(GameTimer.ticks + (unstuck_timer // GameTimer::MILLIS_IN_TICK))

    escape = SkillData[2099, 1]?
    gm_escape = SkillData[2100, 1]?

    if pc.gm?
      if gm_escape
        pc.do_cast(gm_escape)
        return true
      end
      pc.send_message("You use Escape: 1 second.")
    elsif Config.unstuck_interval == 300 && escape
      pc.do_cast(escape)
      return true
    else
      if Config.unstuck_interval > 100
        pc.send_message("You use Escape: #{unstuck_timer // 60_000} seconds.")
      else
        pc.send_message("You use Escape: #{unstuck_timer // 1000} seconds.")
      end
    end

    pc.intention = AI::IDLE
    pc.target = pc
    pc.disable_all_skills
    msu = Packets::Outgoing::MagicSkillUse.new(pc, 1050, 1, unstuck_timer, 0)
    Broadcast.to_self_and_known_players_in_radius(pc, msu, 900)
    sg = Packets::Outgoing::SetupGauge.blue(unstuck_timer)
    pc.send_packet(sg)


    task = -> do
      if pc.alive?
        pc.in_7s_dungeon = false
        pc.enable_all_skills
        pc.casting_now = false
        pc.instance_id = 0
        pc.tele_to_location(TeleportWhereType::TOWN)
      end
    end
    pc.skill_cast = ThreadPoolManager.schedule_general(task, unstuck_timer)

    true
  end

  def commands
    {52}
  end
end
