class NpcAI::NevitsHerald < AbstractNpcAI
  private NEVITS_HERALD = 4326
  private SPAWNS = [] of L2Npc
  private NEVITS_HERALD_LOC = {
    Location.new(86971, -142772, -1336, 20480), # Town of Schuttgart
    Location.new(44165,  -48494,  -792, 32768), # Rune Township
    Location.new(148017, -55264, -2728, 49152), # Town of Goddard
    Location.new(147919,  26631, -2200, 16384), # Town of Aden
    Location.new(82325,   53278, -1488, 16384), # Town of Oren
    Location.new(81925,  148302, -3464, 49152), # Town of Giran
    Location.new(111678, 219197, -3536, 49152), # Heine
    Location.new(16254,  142808, -2696, 16384), # Town of Dion
    Location.new(-13865, 122081, -2984, 32768), # Town of Gludio
    Location.new(-83248, 150832, -3136, 32768), # Gludin Village
    Location.new(116899,  77256, -2688, 49152)  # Hunters Village
  }
  private ANTHARAS = 29068 # Antharas Strong (85)
  private VALAKAS = 29028 # Valakas (85)
  private SPAM = {
    NpcString::SHOW_RESPECT_TO_THE_HEROES_WHO_DEFEATED_THE_EVIL_DRAGON_AND_PROTECTED_THIS_ADEN_WORLD,
    NpcString::SHOUT_TO_CELEBRATE_THE_VICTORY_OF_THE_HEROES,
    NpcString::PRAISE_THE_ACHIEVEMENT_OF_THE_HEROES_AND_RECEIVE_NEVITS_BLESSING
  }
  # Skill
  private FALL_OF_THE_DRAGON = SkillHolder.new(23312)

  @active = false

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_first_talk_id(NEVITS_HERALD)
    add_start_npc(NEVITS_HERALD)
    add_talk_id(NEVITS_HERALD)
    add_kill_id(ANTHARAS, VALAKAS)
  end

  def on_first_talk(npc, player)
    "4326.html"
  end

  def on_adv_event(event, npc, pc)
    return unless npc

    htmltext = event

    if npc.id == NEVITS_HERALD
      return unless pc
      if event.casecmp?("buff")
        if pc.effect_list.get_first_effect(L2EffectType::NEVIT_HOURGLASS)
          return "4326-1.html"
        end
        npc.target = pc
        npc.do_cast(FALL_OF_THE_DRAGON)
        return
      end
    elsif event.casecmp?("text_spam")
      cancel_quest_timer("text_spam", npc, pc)
      say = NpcSay.new(NEVITS_HERALD, Say2::SHOUT, NEVITS_HERALD, SPAM.sample(random: Rnd))
      npc.broadcast_packet(say)
      start_quest_timer("text_spam", 60000, npc, pc)
      return
    elsif event.casecmp?("despawn")
      despawn_heralds
    end

    htmltext
  end

  def on_kill(npc, killer, is_pet)
    if npc.id == VALAKAS
      msg = ExShowScreenMessage.new(NpcString::THE_EVIL_FIRE_DRAGON_VALAKAS_HAS_BEEN_DEFEATED, 2, 10000)
    else
      msg = ExShowScreenMessage.new(NpcString::THE_EVIL_LAND_DRAGON_ANTHARAS_HAS_BEEN_DEFEATED, 2, 10000)
    end

    # L2World.players.each do |pc|
    #   pc.send_packet(msg)
    # end
    Broadcast.to_all_online_players(msg)

    unless @active
      @active = true

      SPAWNS.clear

      NEVITS_HERALD_LOC.each do |loc|
        herald = add_spawn(NEVITS_HERALD, loc, false, 0)
        SPAWNS << herald
      end
      start_quest_timer("despawn", 14400000, npc, killer) # 4 hours
      start_quest_timer("text_spam", 3000, npc, killer)
    end

    nil
  end

  private def despawn_heralds
    SPAWNS.each &.delete_me
    SPAWNS.clear
  end
end
