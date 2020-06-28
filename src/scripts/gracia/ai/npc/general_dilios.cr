class Scripts::GeneralDilios < AbstractNpcAI
  private GENERAL_ID = 32549
  private GUARD_ID = 32619

  private GUARDS = Concurrent::Set(L2Spawn).new

  private DILIOS_TEXT = {
    NpcString::MESSENGER_INFORM_THE_PATRONS_OF_THE_KEUCEREUS_ALLIANCE_BASE_WERE_GATHERING_BRAVE_ADVENTURERS_TO_ATTACK_TIATS_MOUNTED_TROOP_THATS_ROOTED_IN_THE_SEED_OF_DESTRUCTION,
    # NpcString::MESSENGER_INFORM_THE_PATRONS_OF_THE_KEUCEREUS_ALLIANCE_BASE_THE_SEED_OF_DESTRUCTION_IS_CURRENTLY_SECURED_UNDER_THE_FLAG_OF_THE_KEUCEREUS_ALLIANCE,
    # NpcString::MESSENGER_INFORM_THE_PATRONS_OF_THE_KEUCEREUS_ALLIANCE_BASE_TIATS_MOUNTED_TROOP_IS_CURRENTLY_TRYING_TO_RETAKE_SEED_OF_DESTRUCTION_COMMIT_ALL_THE_AVAILABLE_REINFORCEMENTS_INTO_SEED_OF_DESTRUCTION,
    NpcString::MESSENGER_INFORM_THE_BROTHERS_IN_KUCEREUS_CLAN_OUTPOST_BRAVE_ADVENTURERS_WHO_HAVE_CHALLENGED_THE_SEED_OF_INFINITY_ARE_CURRENTLY_INFILTRATING_THE_HALL_OF_EROSION_THROUGH_THE_DEFENSIVELY_WEAK_HALL_OF_SUFFERING,
    # NpcString::MESSENGER_INFORM_THE_BROTHERS_IN_KUCEREUS_CLAN_OUTPOST_SWEEPING_THE_SEED_OF_INFINITY_IS_CURRENTLY_COMPLETE_TO_THE_HEART_OF_THE_SEED_EKIMUS_IS_BEING_DIRECTLY_ATTACKED_AND_THE_UNDEAD_REMAINING_IN_THE_HALL_OF_SUFFERING_ARE_BEING_ERADICATED,
    NpcString::MESSENGER_INFORM_THE_PATRONS_OF_THE_KEUCEREUS_ALLIANCE_BASE_THE_SEED_OF_INFINITY_IS_CURRENTLY_SECURED_UNDER_THE_FLAG_OF_THE_KEUCEREUS_ALLIANCE
    # NpcString::MESSENGER_INFORM_THE_PATRONS_OF_THE_KEUCEREUS_ALLIANCE_BASE_THE_RESURRECTED_UNDEAD_IN_THE_SEED_OF_INFINITY_ARE_POURING_INTO_THE_HALL_OF_SUFFERING_AND_THE_HALL_OF_EROSION
    # NpcString::MESSENGER_INFORM_THE_BROTHERS_IN_KUCEREUS_CLAN_OUTPOST_EKIMUS_IS_ABOUT_TO_BE_REVIVED_BY_THE_RESURRECTED_UNDEAD_IN_SEED_OF_INFINITY_SEND_ALL_REINFORCEMENTS_TO_THE_HEART_AND_THE_HALL_OF_SUFFERING
  }

  private getter! general : L2Npc

  def initialize
    super(self.class.simple_name, "gracia/AI/NPC")
    add_spawn_id(GENERAL_ID, GUARD_ID)
  end

  def on_adv_event(event, npc, pc)
    if event.starts_with?("command_")
      value = event.from(8).to_i
      if value < 6
        general.broadcast_packet(NpcSay.new(general.l2id, Say2::NPC_ALL, GENERAL_ID, NpcString::STABBING_THREE_TIMES))
        start_quest_timer("guard_animation_0", 3400, nil, nil)
      else
        value = -1
        general.broadcast_packet(NpcSay.new(general.l2id, Say2::NPC_SHOUT, GENERAL_ID, DILIOS_TEXT.sample))
      end
      start_quest_timer("command_#{value + 1}", 60000, nil, nil)
    elsif event.starts_with?("guard_animation_")
      value = event.from(16).to_i
      GUARDS.each do |guard|
        if sp = guard.last_spawn
          sp.broadcast_social_action(4)
        else
          debug { "Last spawn of #{guard} not found." }
        end
      end
      if value < 2
        start_quest_timer("guard_animation_#{value + 1}", 1500, nil, nil)
      end
    end

    super
  end

  def on_spawn(npc)
    if npc.id == GENERAL_ID
      start_quest_timer("command_0", 60000, nil, nil)
      @general = npc
    elsif npc.id == GUARD_ID
      GUARDS << npc.spawn
    end

    super
  end
end
