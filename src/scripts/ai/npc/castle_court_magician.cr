class Scripts::CastleCourtMagician < AbstractNpcAI
  # NPCs
  private COURT_MAGICIAN = {
    35648, # Gludio
    35649, # Dion
    35650, # Giran
    35651, # Oren
    35652, # Aden
    35653, # Innadril
    35654, # Goddard
    35655, # Rune
    35656  # Schuttgart
  }
  # Skills
  private CLAN_GATE = 3632 # Clan Gate
  private DISPLAY_CLAN_GATE = SkillHolder.new(5109) # Production - Clan Gate
  # Items
  private EPAULETTE = 9912 # Knight's Epaulette
  private RED_MEDITATION = 9931 # Red Talisman of Meditation
  private BLUE_DIV_PROTECTION = 9932 # Blue Talisman - Divine Protection
  private BLUE_EXPLOSION = 10416 # Blue Talisman - Explosion
  private BLUE_M_EXPLOSION = 10417 # Blue Talisman - Magic Explosion
  private RED_MIN_CLARITY = 9917 # Red Talisman of Minimum Clarity
  private RED_MAX_CLARITY = 9918 # Red Talisman of Maximum Clarity
  private RED_MENTAL_REG = 9928 # Red Talisman of Mental Regeneration
  private BLUE_PROTECTION = 9929 # Blue Talisman of Protection
  private BLUE_INVIS = 9920 # Blue Talisman of Invisibility
  private BLUE_DEFENSE = 9916 # Blue Talisman of Defense
  private BLACK_ESCAPE = 9923 # Black Talisman - Escape
  private BLUE_HEALING = 9924 # Blue Talisman of Healing
  private RED_RECOVERY = 9925 # Red Talisman of Recovery
  private BLUE_DEFENSE2 = 9926 # Blue Talisman of Defense
  private BLUE_M_DEFENSE = 9927 # Blue Talisman of Magic Defense
  private RED_LIFE_FORCE = 10518 # Red Talisman - Life Force
  private BLUE_GREAT_HEAL = 10424 # Blue Talisman - Greater Healing
  private WHITE_FIRE = 10421 # White Talisman - Fire
  private COMMON_TALISMANS = {
    9914, # Blue Talisman of Power
    9915, # Blue Talisman of Wild Magic
    9920, # Blue Talisman of Invisibility
    9921, # Blue Talisman - Shield Protection
    9922, # Black Talisman - Mending
    9933, # Yellow Talisman of Power
    9934, # Yellow Talisman of Violent Haste
    9935, # Yellow Talisman of Arcane Defense
    9936, # Yellow Talisman of Arcane Power
    9937, # Yellow Talisman of Arcane Haste
    9938, # Yellow Talisman of Accuracy
    9939, # Yellow Talisman of Defense
    9940, # Yellow Talisman of Alacrity
    9941, # Yellow Talisman of Speed
    9942, # Yellow Talisman of Critical Reduction
    9943, # Yellow Talisman of Critical Damage
    9944, # Yellow Talisman of Critical Dodging
    9945, # Yellow Talisman of Evasion
    9946, # Yellow Talisman of Healing
    9947, # Yellow Talisman of CP Regeneration
    9948, # Yellow Talisman of Physical Regeneration
    9949, # Yellow Talisman of Mental Regeneration
    9950, # Grey Talisman of Weight Training
    9952, # Orange Talisman - Hot Springs CP Potion
    9953, # Orange Talisman - Elixir of Life
    9954, # Orange Talisman - Elixir of Mental Strength
    9955, # Black Talisman - Vocalization
    9956, # Black Talisman - Arcane Freedom
    9957, # Black Talisman - Physical Freedom
    9958, # Black Talisman - Rescue
    9959, # Black Talisman - Free Speech
    9960, # White Talisman of Bravery
    9961, # White Talisman of Motion
    9962, # White Talisman of Grounding
    9963, # White Talisman of Attention
    9964, # White Talisman of Bandages
    9965, # White Talisman of Protection
    10418, # White Talisman - Storm
    10420, # White Talisman - Water
    10519, # White Talisman - Earth
    10422, # White Talisman - Light
    10423, # Blue Talisman - Self-Destruction
    10419  # White Talisman - Darkness
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(COURT_MAGICIAN)
    add_talk_id(COURT_MAGICIAN)
    add_first_talk_id(COURT_MAGICIAN)
  end

  def on_adv_event(event, npc, player)
    return unless player && npc

    unless player.clan? && player.clan_id == npc.castle.owner_id
      return "courtmagician-01.html"
    end

    item_id = 0
    case event
    when "courtmagician.html", "courtmagician-03.html"
      html = event
    when "giveTalisman"
      if get_quest_items_count(player, EPAULETTE) < 10
        html = "courtmagician-06.html"
      end

      chance = rand(100)
      if chance <= 5
        chance = rand(100)
        if chance <= 25
          item_id = RED_MEDITATION
        elsif chance <= 50
          item_id = BLUE_DIV_PROTECTION
        elsif chance <= 75
          item_id = BLUE_EXPLOSION
        else
          item_id = BLUE_M_EXPLOSION
        end
      elsif chance <= 15
        chance = rand(100)
        if chance <= 20
          item_id = RED_MIN_CLARITY
        elsif chance <= 40
          item_id = RED_MAX_CLARITY
        elsif chance <= 60
          item_id = RED_MENTAL_REG
        elsif chance <= 80
          item_id = BLUE_PROTECTION
        else
          item_id = BLUE_INVIS
        end
      elsif chance <= 30
        chance = rand(100)
        if chance <= 12
          item_id = BLUE_DEFENSE
        elsif chance <= 25
          item_id = BLACK_ESCAPE
        elsif chance <= 37
          item_id = BLUE_HEALING
        elsif chance <= 50
          item_id = RED_RECOVERY
        elsif chance <= 62
          item_id = BLUE_DEFENSE2
        elsif chance <= 75
          item_id = BLUE_M_DEFENSE
        elsif chance <= 87
          item_id = RED_LIFE_FORCE
        else
          item_id = BLUE_GREAT_HEAL
        end
      else
        chance = rand(46)
        if chance <= 42
          item_id = COMMON_TALISMANS[chance]
        else
          item_id = WHITE_FIRE
        end
      end
      take_items(player, EPAULETTE, 10)
      give_items(player, item_id, 1)
      html = "courtmagician-04.html"
    when "squadSkill"
      if player.clan_leader? || player.has_clan_privilege?(ClanPrivilege::CL_TROOPS_FAME)
        Packets::Incoming::RequestAcquireSkill.show_sub_unit_skill_list(player)
      else
        html = "courtmagician-05.html"
      end
    when "clanTeleport"
      if player.clan_id == npc.castle.owner_id
        leader = player.clan.leader.player_instance?

        if leader && leader.affected_by_skill?(CLAN_GATE)
          if leader.can_summon_target?(player) # TODO: Custom one, retail dont check it but for sure lets check same conditions like when summon player by skill.
            npc.target = player
            npc.do_cast(DISPLAY_CLAN_GATE)
            player.tele_to_location(leader.location, true)
          end
        else
          html = "courtmagician-02.html"
        end
      end
    end

    html
  end

  def on_first_talk(npc, player)
    if player.clan? && player.clan_id == npc.castle.owner_id
      return "courtmagician.html"
    end

    "courtmagician-01.html"
  end
end
