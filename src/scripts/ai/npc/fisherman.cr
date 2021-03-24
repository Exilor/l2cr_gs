class Scripts::Fisherman < AbstractNpcAI
  # NPC
  private FISHERMAN = {
    31562, # Klufe
    31563, # Perelin
    31564, # Mishini
    31565, # Ogord
    31566, # Ropfi
    31567, # Bleaker
    31568, # Pamfus
    31569, # Cyano
    31570, # Lanosco
    31571, # Hufs
    31572, # O'Fulle
    31573, # Monakan
    31574, # Willie
    31575, # Litulon
    31576, # Berix
    31577, # Linnaeus
    31578, # Hilgendorf
    31579, # Klaus
    31696, # Platis
    31697, # Eindarkner
    31989, # Batidae
    32007, # Galba
    32348  # Burang
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(FISHERMAN)
    add_talk_id(FISHERMAN)
    add_first_talk_id(FISHERMAN)
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!
    unless npc.is_a?(L2MerchantInstance)
      raise "#{npc} should be a L2MerchantInstance"
    end

    case event
    when "LearnFishSkill"
      Fisherman.show_fish_skill_list(pc)
    when "fishing_championship.htm"
      html = event
    when "BuySellRefund"
      npc.show_buy_window(pc, npc.id &* 100, true)
    end

    html
  end

  def on_first_talk(npc, pc)
    if pc.karma > 0 && !Config.alt_game_karma_player_can_shop
      "#{npc.id}-pk.htm"
    else
      "#{npc.id}.htm"
    end
  end

  def self.show_fish_skill_list(pc)
    skills = SkillTreesData.get_available_fishing_skills(pc)
    asl = AcquireSkillList.new(AcquireSkillType::FISHING)
    count = 0

    skills.each do |s|
      if SkillData[s.skill_id, s.skill_level]?
        count &+= 1
        asl.add_skill(s.skill_id, s.skill_level, s.skill_level, s.level_up_sp, 1)
      end
    end

    if count > 0
      pc.send_packet(asl)
    else
      tree = SkillTreesData.fishing_skill_tree
      min_lvl = SkillTreesData.get_min_level_for_new_skill(pc, tree)
      if min_lvl > 0
        sm = SystemMessage.do_not_have_further_skills_to_learn_s1
        sm.add_int(min_lvl)
        pc.send_packet(sm)
      else
        pc.send_packet(SystemMessageId::NO_MORE_SKILLS_TO_LEARN)
      end
    end
  end
end
