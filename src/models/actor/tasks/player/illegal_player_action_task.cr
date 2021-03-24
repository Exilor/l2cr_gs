require "../../../../enums/illegal_action_punishment_type"

class IllegalPlayerActionTask
  def initialize(pc : L2PcInstance, msg : String, punishment : IllegalActionPunishmentType)
    @pc = pc
    @msg = msg
    @punishment = punishment

    case @punishment
    when .kick?
      pc.send_message("You will be kicked for illegal action, GM informed.")
    when .kick_ban?
      unless pc.gm?
        pc.access_level = -1
        pc.account_access_level = -1
      end

      pc.send_message("You are banned for illegal action, GM informed.")
    when .jail?
      pc.send_message("Illegal action performed")
      pc.send_message("You will be teleported to GM Consultation Service area and jailed.")
    end
  end

  def call
    Logs[:audit].info { "Illegal action #{@msg} by player #{@pc}, action taken: #{@punishment}." }

    AdminData.broadcast_message_to_gms(@msg)

    if @pc.gm?
      return
    end

    case @punishment
    when .broadcast?
      # nothing
    when .kick?
      @pc.logout(false)
    when .kick_ban?
      task = PunishmentTask.new(
        @pc.l2id,
        PunishmentAffect::CHARACTER,
        PunishmentType::BAN,
        Time.ms + (Config.default_punish_param * 1000),
        @msg,
        self.class.simple_name
      )
      PunishmentManager.start_punishment(task)
    when .jail?
      task = PunishmentTask.new(
        @pc.l2id,
        PunishmentAffect::CHARACTER,
        PunishmentType::JAIL,
        Time.ms + (Config.default_punish_param * 1000),
        @msg,
        self.class.simple_name
      )
      PunishmentManager.start_punishment(task)
    end
  end
end
