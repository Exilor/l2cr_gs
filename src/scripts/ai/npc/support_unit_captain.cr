class Scripts::SupportUnitCaptain < AbstractNpcAI
  # NPCs
  private UNIT_CAPTAIN = {
    35662, # Shanty Fortress
    35694, # Southern Fortress
    35731, # Hive Fortress
    35763, # Valley Fortress
    35800, # Ivory Fortress
    35831, # Narsell Fortress
    35863, # Bayou Fortress
    35900, # White Sands Fortress
    35932, # Borderland Fortress
    35970, # Swamp Fortress
    36007, # Archaic Fortress
    36039, # Floran Fortress
    36077, # Cloud Mountain
    36114, # Tanor Fortress
    36145, # Dragonspine Fortress
    36177, # Antharas's Fortress
    36215, # Western Fortress
    36253, # Hunter's Fortress
    36290, # Aaru Fortress
    36322, # Demon Fortress
    36360  # Monastic Fortress
  }
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
  private BLUE_GREAT_HEALING = 10424 # Blue Talisman - Greater Healing
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
    10423  # Blue Talisman - Self-Destruction
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(UNIT_CAPTAIN)
    add_talk_id(UNIT_CAPTAIN)
    add_first_talk_id(UNIT_CAPTAIN)
  end

  def on_adv_event(event, npc, pc)
    return unless npc && pc

    fort_owner = npc.fort.owner_clan?.try &.id || 0
    if pc.clan.nil? || pc.clan_id != fort_owner
      return "unitcaptain-04.html"
    end

    item_id = 0
    case event
    when "unitcaptain.html", "unitcaptain-01.html"
      html = event
    when "giveTalisman"
      if get_quest_items_count(pc, EPAULETTE) < 10
        html = "unitcaptain-05.html"
      end

      category_chance = Rnd.rand(100)
      if category_chance <= 5
        chance = Rnd.rand(100)
        if chance <= 25
          item_id = RED_MEDITATION
        elsif chance <= 50
          item_id = BLUE_DIV_PROTECTION
        elsif chance <= 75
          item_id = BLUE_EXPLOSION
        else
          item_id = BLUE_M_EXPLOSION
        end
      elsif category_chance <= 15
        chance = Rnd.rand(100)
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
      elsif category_chance <= 30
        chance = Rnd.rand(100)
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
          item_id = BLUE_GREAT_HEALING
        end
      else
        chance = Rnd.rand(46)
        if chance <= 41
          item_id = COMMON_TALISMANS[chance]
        else
          item_id = WHITE_FIRE
        end
      end
      take_items(pc, EPAULETTE, 10)
      give_items(pc, item_id, 1)
      html = "unitcaptain-02.html"
    when "squadSkill"
      if pc.clan_leader? || pc.has_clan_privilege?(ClanPrivilege::CL_TROOPS_FAME)
        Packets::Incoming::RequestAcquireSkill.show_sub_unit_skill_list(pc)
      else
        html = "unitcaptain-03.html"
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_first_talk(npc, pc)
    fort_owner = npc.fort.owner_clan?.try &.id || 0

    if pc.clan && pc.clan_id == fort_owner
      "unitcaptain.html"
    else
      "unitcaptain-04.html"
    end
  end
end
