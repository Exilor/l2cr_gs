class Scripts::Ballista < AbstractNpcAI
  # NPCs
  private BALLISTA = {
    35685, # Shanty Fortress
    35723, # Southern Fortress
    35754, # Hive Fortress
    35792, # Valley Fortress
    35823, # Ivory Fortress
    35854, # Narsell Fortress
    35892, # Bayou Fortress
    35923, # White Sands Fortress
    35961, # Borderland Fortress
    35999, # Swamp Fortress
    36030, # Archaic Fortress
    36068, # Floran Fortress
    36106, # Cloud Mountain)
    36137, # Tanor Fortress
    36168, # Dragonspine Fortress
    36206, # Antharas's Fortress
    36244, # Western Fortress
    36282, # Hunter's Fortress
    36313, # Aaru Fortress
    36351, # Demon Fortress
    36389  # Monastic Fortress
  }
  # Skill
  private BOMB = SkillHolder.new(2342) # Ballista Bomb
  # Misc
  private MIN_CLAN_LV = 5

  def initialize
    super(self.class.simple_name, "ai/individual")

    add_skill_see_id(BALLISTA)
    add_spawn_id(BALLISTA)
  end

  def on_skill_see(npc, caster, skill, targets, is_summon)
    if skill && caster.target == npc && Rnd.rand(100) < 40 && skill == BOMB.skill
      if npc.fort.siege.in_progress?
        clan = caster.clan
        if clan && clan.level >= MIN_CLAN_LV
          clan.add_reputation_score(Config.ballista_points, true)
          caster.send_packet(SystemMessageId::BALLISTA_DESTROYED_CLAN_REPU_INCREASED)
        end
      end

      npc.do_die(caster)
    end

    super
  end

  def on_spawn(npc)
    npc.disable_core_ai(true)
    npc.mortal = false

    super
  end
end
