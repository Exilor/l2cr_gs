class Scripts::ZealotOfShilen < AbstractNpcAI
  private ZEALOT = 18782
  private GUARDS = {32628, 32629}

  def initialize
    super(self.class.simple_name, "gracia/AI/NPC")

    add_spawn_id(ZEALOT, *GUARDS)
    add_first_talk_id(GUARDS)
  end

  def on_adv_event(event, npc, pc)
    return unless npc = npc.as?(L2Attackable)

    start_quest_timer("WATCHING", 10_000, npc, nil, true)

    if event == "WATCHING" && !npc.attacking_now?
      npc.known_list.each_character do |char|
        if char.is_a?(L2MonsterInstance) && char.alive? && !char.decayed?
          npc.set_running
          npc.add_damage_hate(char, 0, 999)
          npc.set_intention(AI::ATTACK, char)
        end
      end
    end

    nil
  end

  def on_first_talk(npc, pc)
    npc.attacking_now? ? "32628-01.html" : "#{npc.id}.html"
  end

  def on_spawn(npc)
    if npc.id == ZEALOT
      npc.no_random_walk = true
    else
      npc.invul = true
      npc.as(L2Attackable).can_return_to_spawn_point = false
      start_quest_timer("WATCHING", 10_000, npc, nil, true)
    end

    super
  end
end
