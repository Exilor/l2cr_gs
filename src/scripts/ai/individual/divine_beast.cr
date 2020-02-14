class Scripts::DivineBeast < AbstractNpcAI
  private DIVINE_BEAST = 14870
  private TRANSFORMATION_ID = 258
  private CHECK_TIME = 2 * 1000

  def initialize
    super(self.class.simple_name, "ai")
    add_summon_spawn_id(DIVINE_BEAST)
  end

  def on_summon_spawn(smn)
    start_quest_timer("VALIDATE_TRANSFORMATION", CHECK_TIME, nil, smn.acting_player, true)
  end

  def on_adv_event(event, npc, pc)
    if pc.nil? || !pc.has_servitor?
      cancel_quest_timer(event, npc, pc)
    elsif pc.transformation_id != TRANSFORMATION_ID
      cancel_quest_timer(event, npc, pc)
      pc.summon.try &.unsummon(pc)
    end

    super
  end
end
