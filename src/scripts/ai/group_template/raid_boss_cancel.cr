class Scripts::RaidBossCancel < AbstractNpcAI
  RAID_BOSSES = {
    25019, # Pan Dryad
    25050, # Verfa
    25063, # Chertuba of Great Soul
    25088, # Crazy Mechanic Golem
    25098, # Sejarr's Servitor
    25102, # Shacram
    25118, # Guilotine, Warden of the Execution Grounds
    25125, # Fierce Tiger King Angel
    25126, # Longhorn Golkonda
    25127, # Langk Matriarch Rashkos
    25158, # King Tarlk
    25162, # Giant Marpanak
    25163, # Roaring Skylancer
    25169, # Ragraman
    25188, # Apepi
    25198, # Fafurion's Herald Lokness
    25229, # Storm Winged Naga
    25233, # Spirit of Andras, the Betrayer
    25234, # Ancient Drake
    25244, # Last Lesser Giant Olkuth
    25248, # Doom Blade Tanatos
    25255, # Gargoyle Lord Tiphon
    25259, # Zaken's Butcher Krantz
    25272, # Partisan Leader Talakin
    25276, # Death Lord Ipos
    25280, # Pagan Watcher Cerberon
    25281, # Anakim's Nemesis Zakaron
    25282, # Death Lord Shax
    25305, # Ketra's Chief Brakki
    25315, # Varka's Chief Horus
    25333, # Anakazel
    25334, # Anakazel
    25335, # Anakazel
    25336, # Anakazel
    25337, # Anakazel
    25338, # Anakazel
    25365, # Patriarch Kuroboros
    25372, # Discarded Guardian
    25391, # Nurka's Messenger
    25394, # Premo Prime
    25437, # Timak Orc Gosmos
    25512, # Gigantic Chaos Golem
    25523, # Plague Golem
    25527, # Uruka
    25552, # Soul Hunter Chakundel
    25553, # Durango the Crusher
    25578, # Jakard
    25588, # Immortal Muus
    25592, # Commander Koenig
    25616, # Lost Warden
    25617, # Lost Warden
    25618, # Lost Warden
    25619, # Lost Warden
    25620, # Lost Warden
    25621, # Lost Warden
    25622, # Lost Warden
    25680, # Giant Marpanak
    25709, # Lost Warden
    25753, # Guillotine Warden
    25766, # Ancient Drake
    29036, # Fenril Hound Uruz
    29040, # Wings of Flame, Ixion
    29060, # Captain of the Ice Queen's Royal Guard
    29065, # Sailren
    29095, # Gordon
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_attack_id(RAID_BOSSES)
    add_skill_see_id(RAID_BOSSES)
  end

  def on_attack(npc, attacker, damage, is_summon)
    if Util.in_range?(150, npc, attacker, true) && Rnd.rand(750) < 1
      skill = npc.template.parameters.get_object("SelfRangeCancel_a", SkillHolder)
      add_skill_cast_desire(npc, attacker, skill, 1_000_000)
    end

    super
  end

  def on_skill_see(npc, pc, skill, targets, is_summon)
    if Util.in_range?(150, npc, pc, true) && Rnd.rand(750) < 1
      skill = npc.template.parameters.get_object("SelfRangeCancel_a", SkillHolder)
      add_skill_cast_desire(npc, pc, skill, 1_000_000)
    end

    super
  end
end
