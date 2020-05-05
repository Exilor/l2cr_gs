module VoicedCommandHandler::Wedding
  extend self
  extend VoicedCommandHandler

  private COMMANDS = {"divorce", "engage", "gotolove"}

  def use_voiced_command(cmd : String, pc : L2PcInstance, params : String) : Bool
    if cmd.starts_with?("engage")
      return engage(pc)
    elsif cmd.starts_with?("divorce")
      return divorce(pc)
    elsif cmd.starts_with?("gotolove")
      return go_to_love(pc)
    end

    false
  end

  def divorce(pc : L2PcInstance) : Bool
    if pc.partner_id == 0
      return false
    end

    partner_id = pc.partner_id
    couple_id = pc.couple_id
    adena_amount = 0i64

    if pc.married?
      pc.send_message("You are now divorced.")

      adena_amount = (pc.adena // 100) * Config.wedding_divorce_costs
      pc.inventory.reduce_adena("Wedding", adena_amount, pc, nil)
    else
      pc.send_message("You have broken up as a couple.")
    end


    if partner = L2World.get_player(partner_id)
      partner.partner_id = 0
      if partner.married?
        partner.send_message("Your spouse has decided to divorce you.")
      else
        partner.send_message("Your fiance has decided to break the engagement with you.")
      end

      # give adena
      if adena_amount > 0
        partner.add_adena("WEDDING", adena_amount, nil, false)
      end
    end

    CoupleManager.delete_couple(couple_id)

    true
  end

  def engage(pc : L2PcInstance) : Bool
    pc_target = pc.target

    if pc_target.nil?
      pc.send_message("You have no one targeted.")
      return false
    elsif !pc_target.is_a?(L2PcInstance)
      pc.send_message("You can only ask another player to engage you.")
      return false
    elsif pc.partner_id != 0
      pc.send_message("You are already engaged.")
      if Config.wedding_punish_infidelity
        pc.start_abnormal_visual_effect(true, AbnormalVisualEffect::BIG_HEAD)
        # lets recycle the sevensigns debuffs
        skill_lvl = 1

        if pc.level > 40
          skill_lvl = 2
        end

        if pc.mage_class?
          skill_id = 4362
        else
          skill_id = 4361
        end

        skill = SkillData[skill_id, skill_lvl]
        unless pc.affected_by_skill?(skill_id)
          skill.apply_effects(pc, pc)
        end
      end
      return false
    end
    # check if player target himself
    if pc_target.l2id == pc.l2id
      pc.send_message("Is there something wrong with you, are you trying to go out with youself?")
      return false
    end

    if pc_target.married?
      pc.send_message("Player already married.")
      return false
    end

    if pc_target.engage_request?
      pc.send_message("Player already asked by someone else.")
      return false
    end

    if pc_target.partner_id != 0
      pc.send_message("Player already engaged with someone else.")
      return false
    end

    if pc_target.appearance.sex == pc.appearance.sex && !Config.wedding_samesex
      pc.send_message("Same sex marriage is not allowed on this server.")
      return false
    end

    # Check if target has player on friend list
    found = false
    begin
      sql = "SELECT friendId FROM character_friends WHERE charId=?"
      GameDB.each(sql, pc_target.l2id) do |rs|
        if rs.get_i32("friendId") == pc.l2id
          found = true
          break
        end
      end
    rescue e
      warn e
    end

    unless found
      pc.send_message("The player you want to ask is not on your friends list, you must first be on each others friends list before you choose to engage.")
      return false
    end

    pc_target.set_engage_request(true, pc.l2id)
    pc_target.add_action(PlayerAction::USER_ENGAGE)

    dlg = ConfirmDlg.new(pc.name + " is asking to engage you. Do you want to start a new relationship?")
    dlg.time = 15 * 1000
    pc_target.send_packet(dlg)

    true
  end

  def go_to_love(pc : L2PcInstance) : Bool
    unless pc.married?
      pc.send_message("You're not married.")
      return false
    end

    if pc.partner_id == 0
      pc.send_message("Couldn't find your fiance in the Database - Inform a Gamemaster.")
      warn { "Married but couldn't find parter for " + pc.name }
      return false
    end

    if GrandBossManager.get_zone(pc)
      pc.send_message("You are inside a Boss Zone.")
      return false
    end

    if pc.combat_flag_equipped?
      pc.send_message("While you are holding a Combat Flag or Territory Ward you can't go to your love.")
      return false
    end

    if pc.cursed_weapon_equipped?
      pc.send_message("While you are holding a Cursed Weapon you can't go to your love.")
      return false
    end

    if GrandBossManager.get_zone(pc)
      pc.send_message("You are inside a Boss Zone.")
      return false
    end

    if pc.jailed?
      pc.send_message("You are in Jail.")
      return false
    end

    if pc.in_olympiad_mode?
      pc.send_message("You are in the Olympiad now.")
      return false
    end

    if L2Event.participant?(pc)
      pc.send_message("You are in an event.")
      return false
    end

    if pc.in_duel?
      pc.send_message("You are in a duel.")
      return false
    end

    if pc.in_observer_mode?
      pc.send_message("You are in the observation.")
      return false
    end

    siege = SiegeManager.get_siege(pc)
    if siege && siege.in_progress?
      pc.send_message("You are in a siege, you cannot go to your partner.")
      return false
    end

    if pc.festival_participant?
      pc.send_message("You are in a festival.")
      return false
    end

    if pc.party.try &.in_dimensional_rift?
      pc.send_message("You are in the dimensional rift.")
      return false
    end

    # unless TvTEvent.on_escape_use(pc.l2id)
    #   pc.action_failed
    #   return false
    # end

    if pc.inside_no_summon_friend_zone?
      pc.send_message("You are in area which blocks summoning.")
      return false
    end

    partner = L2World.get_player(pc.partner_id)
    if partner.nil? || !partner.online?
      pc.send_message("Your partner is not online.")
      return false
    end

    if pc.instance_id != partner.instance_id
      pc.send_message("Your partner is in another World.")
      return false
    end

    if partner.jailed?
      pc.send_message("Your partner is in Jail.")
      return false
    end

    if partner.cursed_weapon_equipped?
      pc.send_message("Your partner is holding a Cursed Weapon and you can't go to your love.")
      return false
    end

    if GrandBossManager.get_zone(partner)
      pc.send_message("Your partner is inside a Boss Zone.")
      return false
    end

    if partner.in_olympiad_mode?
      pc.send_message("Your partner is in the Olympiad now.")
      return false
    end

    if L2Event.participant?(partner)
      pc.send_message("Your partner is in an event.")
      return false
    end

    if partner.in_duel?
      pc.send_message("Your partner is in a duel.")
      return false
    end

    if partner.festival_participant?
      pc.send_message("Your partner is in a festival.")
      return false
    end

    if partner.party.try &.in_dimensional_rift?
      pc.send_message("Your partner is in dimensional rift.")
      return false
    end

    if partner.in_observer_mode?
      pc.send_message("Your partner is in the observation.")
      return false
    end

    siege = SiegeManager.get_siege(partner)
    if siege && siege.in_progress?
      pc.send_message("Your partner is in a siege, you cannot go to your partner.")
      return false
    end

    if partner.in_7s_dungeon? && !pc.in_7s_dungeon?
      cabal = SevenSigns.instance.get_player_cabal(pc.l2id)
      seal_validation_period = SevenSigns.instance.seal_validation_period?
      comp_winner = SevenSigns.instance.cabal_highest_score

      if seal_validation_period
        if cabal != comp_winner
          pc.send_message("Your Partner is in a Seven Signs Dungeon and you are not in the winner Cabal.")
          return false
        end
      else
        if cabal == SevenSigns::CABAL_NULL
          pc.send_message("Your Partner is in a Seven Signs Dungeon and you are not registered.")
          return false
        end
      end
    end

    # unless TvTEvent.on_escape_use(partner.l2id)
    #   pc.send_message("Your partner is in an event.")
    #   return false
    # end

    if partner.inside_no_summon_friend_zone?
      pc.send_message("Your partner is in area which blocks summoning.")
      return false
    end

    teleport_timer = Config.wedding_teleport_duration * 1000
    pc.send_message("After #{teleport_timer // 60000} min. you will be teleported to your partner.")
    pc.inventory.reduce_adena("Wedding", Config.wedding_teleport_price.to_i64, pc, nil)

    pc.set_intention(AI::IDLE)
    # SoE Animation section
    pc.target = pc
    pc.disable_all_skills

    msk = MagicSkillUse.new(pc, 1050, 1, teleport_timer, 0)
    Broadcast.to_self_and_known_players_in_radius(pc, msk, 900)
    sg = SetupGauge.blue(teleport_timer)
    pc.send_packet(sg)
    # End SoE Animation section

    ef = EscapeFinalizer.new(pc, partner.location, partner.in_7s_dungeon?)
    # continue execution later
    pc.skill_cast = ThreadPoolManager.schedule_general(ef, teleport_timer)
    pc.force_is_casting(GameTimer.ticks + (teleport_timer // GameTimer::MILLIS_IN_TICK))

    true
  end

  private struct EscapeFinalizer
    include Loggable

    initializer pc : L2PcInstance, partner_loc : Location, to_7s_dungeon : Bool

    def call
      return if @pc.dead?

      siege = SiegeManager.get_siege(@partner_loc)
      if siege && siege.in_progress?
        @pc.send_message("Your partner is in siege, you can't go to your partner.")
        return
      end

      @pc.in_7s_dungeon = @to_7s_dungeon
      @pc.enable_all_skills
      @pc.casting_now = false

      begin
        @pc.tele_to_location(@partner_loc)
      rescue e
        error e
      end
    end
  end

  def commands : Indexable(String)
    COMMANDS
  end
end
