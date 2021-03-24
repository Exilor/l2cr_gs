class Scripts::GiftOfVitality < LongTimeEvent
  # NPC
  private STEVE_SHYAGEL = 4306
  # Skills
  private GIFT_OF_VITALITY = SkillHolder.new(23179, 1)
  private JOY_OF_VITALITY = SkillHolder.new(23180, 1)

  private FIGHTER_SKILLS = {
    SkillHolder.new(5627), # Wind Walk
    SkillHolder.new(5628), # Shield
    SkillHolder.new(5637), # Magic Barrier
    SkillHolder.new(5629), # Bless the Body
    SkillHolder.new(5630), # Vampiric Rage
    SkillHolder.new(5631), # Regeneration
    SkillHolder.new(5632)  # Haste
  }

  private MAGE_SKILLS = {
    SkillHolder.new(5627), # Wind Walk
    SkillHolder.new(5628), # Shield
    SkillHolder.new(5637), # Magic Barrier
    SkillHolder.new(5633), # Bless the Soul
    SkillHolder.new(5634), # Acumen
    SkillHolder.new(5635), # Concentration
    SkillHolder.new(5636)  # Empower
  }

  private SERVITOR_SKILLS = {
    SkillHolder.new(5627), # Wind Walk
    SkillHolder.new(5628), # Shield
    SkillHolder.new(5637), # Magic Barrier
    SkillHolder.new(5629), # Bless the Body
    SkillHolder.new(5633), # Bless the Soul
    SkillHolder.new(5630), # Vampiric Rage
    SkillHolder.new(5634), # Acumen
    SkillHolder.new(5631), # Regeneration
    SkillHolder.new(5635), # Concentration
    SkillHolder.new(5632), # Haste
    SkillHolder.new(5636)  # Empower
  }

  # Misc
  private HOURS = 5 # Reuse between buffs
  private MIN_LEVEL = 75
  private REUSE = simple_name + "_reuse"

  def initialize
    super(self.class.simple_name, "events")

    add_start_npc(STEVE_SHYAGEL)
    add_first_talk_id(STEVE_SHYAGEL)
    add_talk_id(STEVE_SHYAGEL)
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!
    html = event

    case event
    when "vitality"
      reuse = pc.variables.get_i64(REUSE, 0)
      if reuse > Time.ms
        remaining_time = (reuse - Time.ms) // 1000
        hours = (remaining_time // 3600).to_i
        minutes = ((remaining_time % 3600) // 60).to_i
        sm = SystemMessage.available_after_s1_s2_hours_s3_minutes
        sm.add_skill_name(GIFT_OF_VITALITY.skill_id)
        sm.add_int(hours)
        sm.add_int(minutes)
        pc.send_packet(sm)
        html = "4306-notime.htm"
      else
        pc.do_cast(GIFT_OF_VITALITY)
        pc.do_simultaneous_cast(JOY_OF_VITALITY)
        pc.variables[REUSE] = Time.ms &+ (HOURS &* 3_600_000)
        html = "4306-okvitality.htm"
      end
    when "memories_player"
      if pc.level <= MIN_LEVEL
        html = "4306-nolevel.htm"
      else
        npc = npc.not_nil!
        skills = pc.mage_class? ? MAGE_SKILLS : FIGHTER_SKILLS
        npc.target = pc
        skills.each do |sk|
          npc.do_cast(sk)
        end
        html = "4306-okbuff.htm"
      end
    when "memories_summon"
      if pc.level <= MIN_LEVEL
        html = "4306-nolevel.htm"
      elsif !pc.has_servitor?
        html = "4306-nosummon.htm"
      else
        npc = npc.not_nil!
        npc.target = pc.summon
        SERVITOR_SKILLS.each do |sk|
          npc.do_cast(sk)
        end
        html = "4306-okbuff.htm"
      end
    end

    html
  end

  def on_first_talk(npc, pc)
    "4306.htm"
  end
end
