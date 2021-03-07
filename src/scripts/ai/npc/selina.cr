class Scripts::Selina < AbstractNpcAI
  # NPC
  private SELINA = 31556
  # Items
  private GOLDEN_RAM_BADGE_RECRUIT = 7246
  private GOLDEN_RAM_BADGE_SOLDIER = 7247
  private GOLDEN_RAM_COIN = 7251
  # Skills
  private BUFFS = {
    "4359" => BuffHolder.new(4359, 2, 2), # Focus
    "4360" => BuffHolder.new(4360, 2, 2), # Death Whisper
    "4345" => BuffHolder.new(4345, 3, 3), # Might
    "4355" => BuffHolder.new(4355, 2, 3), # Acumen
    "4352" => BuffHolder.new(4352, 1, 3), # Berserker Spirit
    "4354" => BuffHolder.new(4354, 2, 3), # Vampiric Rage
    "4356" => BuffHolder.new(4356, 1, 6), # Empower
    "4357" => BuffHolder.new(4357, 2, 6)  # Haste
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(SELINA)
    add_talk_id(SELINA)
    add_first_talk_id(SELINA)
    add_spell_finished_id(SELINA)
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!

    if buff = BUFFS[event]?
      if pc.destroy_item_by_item_id("Quest", GOLDEN_RAM_COIN, buff.cost, npc, true)
        cast_skill(npc.not_nil!, pc, buff)
        return on_first_talk(npc, pc)
      end
    else
      warn { "#{pc} sent invalid event '#{event}'" }
    end

    "31556-02.html"
  end

  def on_first_talk(npc, pc)
    if has_quest_items?(pc, GOLDEN_RAM_BADGE_SOLDIER)
      "31556-08.html"
    elsif has_quest_items?(pc, GOLDEN_RAM_BADGE_RECRUIT)
      "31556-01.html"
    else
      "31556-09.html"
    end
  end

  private class BuffHolder < SkillHolder
    getter cost

    def initialize(skill_id : Int32, skill_lvl : Int32, cost : Int32)
      super(skill_id, skill_lvl)
      @cost = cost
    end
  end
end
