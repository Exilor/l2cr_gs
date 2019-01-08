class NpcAI::Servitors < AbstractNpcAI
  # Quest Monster
  private PAKO_THE_CAT = 27102
  private UNICORN_RACER = 27103
  private SHADOW_TUREN = 27104
  private MIMI_THE_CAT = 27105
  private UNICORN_PHANTASM = 27106
  private SILHOUETTE_TILFO = 27107
  # Items
  private CRYSTAL_OF_STARTING_1ST = 3360
  private CRYSTAL_OF_INPROGRESS_1ST = 3361
  private CRYSTAL_OF_DEFEAT_1ST = 3363
  private CRYSTAL_OF_STARTING_2ND = 3365
  private CRYSTAL_OF_INPROGRESS_2ND = 3366
  private CRYSTAL_OF_DEFEAT_2ND = 3368
  private CRYSTAL_OF_STARTING_3RD = 3370
  private CRYSTAL_OF_INPROGRESS_3RD = 3371
  private CRYSTAL_OF_DEFEAT_3RD = 3373
  private CRYSTAL_OF_STARTING_4TH = 3375
  private CRYSTAL_OF_INPROGRESS_4TH = 3376
  private CRYSTAL_OF_DEFEAT_4TH = 3378
  private CRYSTAL_OF_STARTING_5TH = 3380
  private CRYSTAL_OF_INPROGRESS_5TH = 3381
  private CRYSTAL_OF_DEFEAT_5TH = 3383
  private CRYSTAL_OF_STARTING_6TH = 3385
  private CRYSTAL_OF_INPROGRESS_6TH = 3386
  private CRYSTAL_OF_DEFEAT_6TH = 3388

  private MONSTERS = {
    PAKO_THE_CAT => {
      CRYSTAL_OF_STARTING_1ST,
      CRYSTAL_OF_INPROGRESS_1ST,
      CRYSTAL_OF_DEFEAT_1ST
    },
    UNICORN_RACER => {
      CRYSTAL_OF_STARTING_3RD,
      CRYSTAL_OF_INPROGRESS_3RD,
      CRYSTAL_OF_DEFEAT_3RD
    },
    SHADOW_TUREN => {
      CRYSTAL_OF_STARTING_5TH,
      CRYSTAL_OF_INPROGRESS_5TH,
      CRYSTAL_OF_DEFEAT_5TH
    },
    MIMI_THE_CAT => {
      CRYSTAL_OF_STARTING_2ND,
      CRYSTAL_OF_INPROGRESS_2ND,
      CRYSTAL_OF_DEFEAT_2ND
    },
    UNICORN_PHANTASM => {
      CRYSTAL_OF_STARTING_4TH,
      CRYSTAL_OF_INPROGRESS_4TH,
      CRYSTAL_OF_DEFEAT_4TH
    },
    SILHOUETTE_TILFO => {
      CRYSTAL_OF_STARTING_6TH,
      CRYSTAL_OF_INPROGRESS_6TH,
      CRYSTAL_OF_DEFEAT_6TH
    }
  }

  SUMMONS = {
    # Kat the Cat
    14111, 14112, 14113, 14114,
    # Mew the Cat
    14159, 14160, 14161, 14162,
    # Boxer the Unicorn
    14295, 14296, 14297, 14298,
    # Mirage the Unicorn
    14343, 14344, 14345, 14346,
    # Shadow
    14479, 14480, 14481, 14482,
    # Silhouette
    14527, 14528, 14529, 14530
  }

  def initialize
    super(self.class.simple_name, "ai/npc/Summons")
  end

  # register(:on_creature_kill) do
  #   Event(EventType::ON_CREATURE_KILL)
  #   Type(ListenerRegisterType::NPC)
  #   Id(14111, 14112, 14113, 14114, # Kat the Cat
  #      14159, 14160, 14161, 14162, # Mew the Cat
  #      14295, 14296, 14297, 14298, # Boxer the Unicorn
  #      14343, 14344, 14345, 14346, # Mirage the Unicorn
  #      14479, 14480, 14481, 14482, # Shadow
  #      14527, 14528, 14529, 14530  # Silhouette
  #   )
  # end

  # register_event do |evt|
  #   evt.method_name = :on_creature_kill
  #   evt.event_type = :ON_CREATURE_KILL
  #   evt.register_type = :NPC
  #   evt.ids = [
  #     14111, 14112, 14113, 14114, # Kat the Cat
  #     14159, 14160, 14161, 14162, # Mew the Cat
  #     14295, 14296, 14297, 14298, # Boxer the Unicorn
  #     14343, 14344, 14345, 14346, # Mirage the Unicorn
  #     14479, 14480, 14481, 14482, # Shadow
  #     14527, 14528, 14529, 14530  # Silhouette
  #   ]
  # end

  @[Register(event: ON_CREATURE_KILL, register: NPC, id: NpcAI::Servitors::SUMMONS)]
  def on_creature_kill(event : OnCreatureKill)
    attacker, target = event.attacker, event.target.as(L2Summon)
    debug "on_creature_kill: attacker: #{attacker}, target: #{target}"
    if MONSTERS.has_key?(attacker.id) && target.servitor?
      if Util.in_range?(1500, attacker, target, true)
        owner = target.owner
        if qs = owner.get_quest_state(Quests::Q00230_TestOfTheSummoner.simple_name)
          items = MONSTERS[attacker.id]
          if has_quest_items?(owner, items[1])
            give_items(owner, items[2], 1) # Crystal of Defeat
            play_sound(owner, Sound::ITEMSOUND_QUEST_ITEMGET)
            take_items(owner, items[1], -1 ) # Crystal of Inprogress
            take_items(owner, items[0], -1 ) # Crystal of Starting
          end
        end
      end
    end
  end
end
