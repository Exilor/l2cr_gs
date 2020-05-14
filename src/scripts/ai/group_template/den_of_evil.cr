class Scripts::DenOfEvil < AbstractNpcAI
  # private _buffer_id = 32656
  private EYE_IDS = {
    18812,
    18813,
    18814
  }
  private SKILL_ID = 6150 # others +2
  private KASHA_DESTRUCT_DELAY = 120000

  private EYE_SPAWNS = {
    Location.new(71544, -129400, -3360, 16472),
    Location.new(70954, -128854, -3360, 16),
    Location.new(72145, -128847, -3368, 32832),
    Location.new(76147, -128372, -3144, 16152),
    Location.new(71573, -128309, -3360, 49152),
    Location.new(75211, -127441, -3152, 0),
    Location.new(77005, -127406, -3144, 32784),
    Location.new(75965, -126486, -3144, 49120),
    Location.new(70972, -126429, -3016, 19208),
    Location.new(69916, -125838, -3024, 2840),
    Location.new(71658, -125459, -3016, 35136),
    Location.new(70605, -124646, -3040, 52104),
    Location.new(67283, -123237, -2912, 12376),
    Location.new(68383, -122754, -2912, 27904),
    Location.new(74137, -122733, -3024, 13272),
    Location.new(66736, -122007, -2896, 60576),
    Location.new(73289, -121769, -3024, 1024),
    Location.new(67894, -121491, -2912, 43872),
    Location.new(75530, -121477, -3008, 34424),
    Location.new(74117, -120459, -3024, 52344),
    Location.new(69608, -119855, -2534, 17251),
    Location.new(71014, -119027, -2520, 31904),
    Location.new(68944, -118964, -2527, 59874),
    Location.new(62261, -118263, -3072, 12888),
    Location.new(70300, -117942, -2528, 46208),
    Location.new(74312, -117583, -2272, 15280),
    Location.new(63276, -117409, -3064, 24760),
    Location.new(68104, -117192, -2168, 15888),
    Location.new(73758, -116945, -2216, 0),
    Location.new(74944, -116858, -2220, 30892),
    Location.new(61715, -116623, -3064, 59888),
    Location.new(69140, -116464, -2168, 28952),
    Location.new(67311, -116374, -2152, 1280),
    Location.new(62459, -116370, -3064, 48624),
    Location.new(74475, -116260, -2216, 47456),
    Location.new(68333, -115015, -2168, 45136),
    Location.new(68280, -108129, -1160, 17992),
    Location.new(62983, -107259, -2384, 12552),
    Location.new(67062, -107125, -1144, 64008),
    Location.new(68893, -106954, -1160, 36704),
    Location.new(63848, -106771, -2384, 32784),
    Location.new(62372, -106514, -2384, 0),
    Location.new(67838, -106143, -1160, 51232),
    Location.new(62905, -106109, -2384, 51288)
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_kill_id(EYE_IDS)
    add_spawn_id(EYE_IDS)
    EYE_SPAWNS.each do |loc|
      add_spawn(EYE_IDS.sample(random: Rnd), loc, false, 0)
    end
  end

  private def get_skill_id_by_npc_id(npc_id)
    diff = npc_id - EYE_IDS[0]
    diff *= 2
    SKILL_ID &+ diff
  end

  def on_spawn(npc)
    npc.disable_core_ai(true)
    npc.immobilized = true

    unless zone = ZoneManager.get_zone(npc, L2EffectZone)
      warn { "NPC #{npc} spawned in a missing zone." }
      return
    end
    skill_id = get_skill_id_by_npc_id(npc.id)
    skill_level = zone.get_skill_level(skill_id)
    zone.add_skill(skill_id, skill_level &+ 1)
    if skill_level == 3 # 3+1=4
      ThreadPoolManager.schedule_ai(KashaDestruction.new(self, zone), KASHA_DESTRUCT_DELAY)
      zone.broadcast_packet(SystemMessage.kasha_eye_pitches_tosses_explode)
    elsif skill_level == 2
      zone.broadcast_packet(SystemMessage.i_can_feel_energy_kasha_eye_getting_stronger_rapidly)
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    ThreadPoolManager.schedule_ai(-> {
        add_spawn(EYE_IDS.sample(random: Rnd), npc.location, false, 0)
      },
      15000
    )
    unless zone = ZoneManager.get_zone(npc, L2EffectZone)
      warn { "NPC #{npc} killed in a missing zone." }
      return
    end
    skill_id = get_skill_id_by_npc_id(npc.id)
    skill_level = zone.get_skill_level(skill_id)
    zone.add_skill(skill_id, skill_level - 1)

    super
  end

  private struct KashaDestruction
    private KASHAS_BETRAYAL = SkillHolder.new(6149)

    initializer owner : DenOfEvil, zone : L2EffectZone

    def call
      i = SKILL_ID
      while i <= SKILL_ID &+ 4
        # test 3 skills if some is lvl 4
        if @zone.get_skill_level(i) > 3
          destroy_zone
          break
        end
        i &+= 2
      end
    end

    private def destroy_zone
      @zone.characters_inside.each do |char|
        if char.playable?
          KASHAS_BETRAYAL.skill.apply_effects(char, char)
        else
          if char.do_die(nil)
            if char.npc?
              # respawn eye
              if EYE_IDS.bincludes?(char.id)
                ThreadPoolManager.schedule_ai(-> {
                    @owner.add_spawn(EYE_IDS.sample(random: Rnd), char.location, false, 0)
                  },
                  15000
                )
              end
            end
          end
        end
      end
      i = SKILL_ID
      while i <= SKILL_ID &+ 4
        @zone.remove_skill(i)
        i &+= 2
      end
    end
  end
end
