class Scripts::ArenaManager < AbstractNpcAI
  # NPCs
  private ARENA_MANAGER = {
    31226, # Arena Director (Monster Derby Track)
    31225  # Arena Manager (Coliseum)
  }
  # Skill
  private BUFFS = {
    SkillHolder.new(6805, 1), # Arena Empower
    SkillHolder.new(6806, 1), # Arena Acumen
    SkillHolder.new(6807, 1), # Arena Concentration
    SkillHolder.new(6808, 1), # Arena Might
    SkillHolder.new(6804, 1), # Arena Wind Walk
    SkillHolder.new(6812, 1)  # Arena Berserker Spirit
  }
  private CP_RECOVERY = SkillHolder.new(4380, 1) # Arena: CP Recovery
  private HP_RECOVERY = SkillHolder.new(6817, 1) # Arena HP Recovery
  # Misc
  private CP_COST = 1000
  private HP_COST = 1000
  private BUFF_COST = 2000

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(ARENA_MANAGER)
    add_talk_id(ARENA_MANAGER)
    add_first_talk_id(ARENA_MANAGER)
  end

  def on_adv_event(event, npc, pc)
    return unless npc && pc

    case event
    when "CPrecovery"
      if pc.adena >= CP_COST
        take_items(pc, Inventory::ADENA_ID, CP_COST)
        start_quest_timer("CPrecovery_delay", 2000, npc, pc)
      else
        pc.send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
      end
    when "CPrecovery_delay"
      if pc && !pc.inside_pvp_zone?
        npc.target = pc
        npc.do_cast(CP_RECOVERY.skill)
      end
    when "HPrecovery"
      if pc.adena >= HP_COST
        take_items(pc, Inventory::ADENA_ID, HP_COST)
        start_quest_timer("HPrecovery_delay", 2000, npc, pc)
      else
        pc.send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
      end
    when "HPrecovery_delay"
      if pc && !pc.inside_pvp_zone?
        npc.target = pc
        npc.do_cast(HP_RECOVERY.skill)
      end
    when "Buff"
      if pc.adena >= BUFF_COST
        take_items(pc, Inventory::ADENA_ID, BUFF_COST)
        npc.target = pc
        BUFFS.each do |skill|
          npc.do_cast(skill.skill)
        end
      else
        pc.send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
      end
    end

    nil
  end
end
