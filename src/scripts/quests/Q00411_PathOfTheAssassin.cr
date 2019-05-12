class Scripts::Q00411_PathOfTheAssassin < Quest
  # NPCs
  private TRISKEL = 30416
  private GUARD_LEIKAN = 30382
  private ARKENIA = 30419
  # Items
  private SHILENS_CALL = 1245
  private ARKENIAS_LETTER = 1246
  private LEIKANS_NOTE = 1247
  private MOONSTONE_BEASTS_MOLAR = 1248
  private SHILENS_TEARS = 1250
  private ARKENIAS_RECOMMENDATION = 1251
  # Reward
  private IRON_HEART = 1252
  # Monster
  private MOONSTONE_BEAST = 20369
  # Quest Monster
  private CALPICO = 27036
  # Misc
  private MIN_LEVEL = 18

  def initialize
    super(411, self.class.simple_name, "Path Of The Assassin")

    add_start_npc(TRISKEL)
    add_talk_id(TRISKEL, GUARD_LEIKAN, ARKENIA)
    add_kill_id(MOONSTONE_BEAST, CALPICO)
    register_quest_items(
      SHILENS_CALL, ARKENIAS_LETTER, LEIKANS_NOTE, MOONSTONE_BEASTS_MOLAR,
      SHILENS_TEARS, ARKENIAS_RECOMMENDATION
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if pc.class_id.dark_fighter?
        if pc.level >= MIN_LEVEL
          if has_quest_items?(pc, IRON_HEART)
            html = "30416-04.htm"
          else
            qs.start_quest
            give_items(pc, SHILENS_CALL, 1)
            html = "30416-05.htm"
          end
        else
          html = "30416-03.htm"
        end
      elsif pc.class_id.assassin?
        html = "30416-02a.htm"
      else
        html = "30416-02.htm"
      end
    when "30382-02.html", "30382-04.html"
      html = event
    when "30382-03.html"
      if has_quest_items?(pc, ARKENIAS_LETTER)
        take_items(pc, ARKENIAS_LETTER, 1)
        give_items(pc, LEIKANS_NOTE, 1)
        qs.set_cond(3, true)
        html = event
      end
    when "30419-02.html", "30419-03.html", "30419-04.html", "30419-06.html"
      html = event
    when "30419-05.html"
      if has_quest_items?(pc, SHILENS_CALL)
        take_items(pc, SHILENS_CALL, 1)
        give_items(pc, ARKENIAS_LETTER, 1)
        qs.set_cond(2, true)
        html = event
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when MOONSTONE_BEAST
        if has_quest_items?(killer, LEIKANS_NOTE)
          if get_quest_items_count(killer, MOONSTONE_BEASTS_MOLAR) < 10
            give_items(killer, MOONSTONE_BEASTS_MOLAR, 1)
            if get_quest_items_count(killer, MOONSTONE_BEASTS_MOLAR) == 10
              qs.set_cond(4, true)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when CALPICO
        unless has_quest_items?(killer, SHILENS_TEARS)
          give_items(killer, SHILENS_TEARS, 1)
          qs.set_cond(6, true)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created? || qs.completed?
      if npc.id == TRISKEL
        if !has_quest_items?(pc, IRON_HEART)
          html = "30416-01.htm"
        else
          html = "30416-04.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when TRISKEL
        if !has_at_least_one_quest_item?(pc, ARKENIAS_LETTER, LEIKANS_NOTE, SHILENS_TEARS, IRON_HEART) && has_quest_items?(pc, ARKENIAS_RECOMMENDATION)
          give_adena(pc, 163800, true)
          give_items(pc, IRON_HEART, 1)
          level = pc.level
          if level >= 20
            add_exp_and_sp(pc, 320534, 35830)
          elsif level == 19
            add_exp_and_sp(pc, 456128, 35830)
          else
            add_exp_and_sp(pc, 591724, 42528)
          end
          qs.exit_quest(false, true)
          pc.send_packet(SocialAction.new(pc.l2id, 3))
          qs.save_global_quest_var("1ClassQuestFinished", "1")
          html = "30416-06.html"
        elsif !has_at_least_one_quest_item?(pc, LEIKANS_NOTE, SHILENS_TEARS, ARKENIAS_RECOMMENDATION, IRON_HEART, SHILENS_CALL) && has_quest_items?(pc, ARKENIAS_LETTER)
          html = "30416-07.html"
        elsif !has_at_least_one_quest_item?(pc, ARKENIAS_LETTER, SHILENS_TEARS, ARKENIAS_RECOMMENDATION, IRON_HEART, SHILENS_CALL) && has_quest_items?(pc, LEIKANS_NOTE)
          html = "30416-08.html"
        elsif !has_at_least_one_quest_item?(pc, ARKENIAS_LETTER, LEIKANS_NOTE, SHILENS_TEARS, ARKENIAS_RECOMMENDATION, IRON_HEART, SHILENS_CALL)
          html = "30416-09.html"
        elsif !has_at_least_one_quest_item?(pc, ARKENIAS_LETTER, LEIKANS_NOTE, ARKENIAS_RECOMMENDATION, IRON_HEART, SHILENS_CALL) && has_quest_items?(pc, SHILENS_TEARS)
          html = "30416-10.html"
        elsif !has_at_least_one_quest_item?(pc, ARKENIAS_LETTER, LEIKANS_NOTE, SHILENS_TEARS, ARKENIAS_RECOMMENDATION, IRON_HEART) && has_quest_items?(pc, SHILENS_CALL)
          html = "30416-11.html"
        end
      when GUARD_LEIKAN
        if !has_at_least_one_quest_item?(pc, LEIKANS_NOTE, SHILENS_TEARS, ARKENIAS_RECOMMENDATION, IRON_HEART, SHILENS_CALL, MOONSTONE_BEASTS_MOLAR) && has_quest_items?(pc, ARKENIAS_LETTER)
          html = "30382-01.html"
        elsif !has_at_least_one_quest_item?(pc, ARKENIAS_LETTER, SHILENS_TEARS, ARKENIAS_RECOMMENDATION, IRON_HEART, SHILENS_CALL, MOONSTONE_BEASTS_MOLAR) && has_quest_items?(pc, LEIKANS_NOTE)
          html = "30382-05.html"
        elsif !has_at_least_one_quest_item?(pc, ARKENIAS_LETTER, SHILENS_TEARS, ARKENIAS_RECOMMENDATION, IRON_HEART, SHILENS_CALL) && has_quest_items?(pc, LEIKANS_NOTE)
          if has_quest_items?(pc, MOONSTONE_BEASTS_MOLAR) && get_quest_items_count(pc, MOONSTONE_BEASTS_MOLAR) < 10
            html = "30382-06.html"
          else
            take_items(pc, LEIKANS_NOTE, 1)
            take_items(pc, MOONSTONE_BEASTS_MOLAR, -1)
            qs.set_cond(5, true)
            html = "30382-07.html"
          end
        elsif has_quest_items?(pc, SHILENS_TEARS)
          html = "30382-08.html"
        elsif !has_at_least_one_quest_item?(pc, ARKENIAS_LETTER, LEIKANS_NOTE, SHILENS_TEARS, ARKENIAS_RECOMMENDATION, IRON_HEART, SHILENS_CALL, MOONSTONE_BEASTS_MOLAR)
          html = "30382-09.html"
        end
      when ARKENIA
        if !has_at_least_one_quest_item?(pc, ARKENIAS_LETTER, LEIKANS_NOTE, SHILENS_TEARS, ARKENIAS_RECOMMENDATION, IRON_HEART) && has_quest_items?(pc, SHILENS_CALL)
          html = "30419-01.html"
        elsif !has_at_least_one_quest_item?(pc, LEIKANS_NOTE, SHILENS_TEARS, ARKENIAS_RECOMMENDATION, IRON_HEART, SHILENS_CALL) && has_quest_items?(pc, ARKENIAS_LETTER)
          html = "30419-07.html"
        elsif !has_at_least_one_quest_item?(pc, ARKENIAS_LETTER, LEIKANS_NOTE, ARKENIAS_RECOMMENDATION, IRON_HEART, SHILENS_CALL) && has_quest_items?(pc, SHILENS_TEARS)
          take_items(pc, SHILENS_TEARS, 1)
          give_items(pc, ARKENIAS_RECOMMENDATION, 1)
          qs.set_cond(7, true)
          html = "30419-08.html"
        elsif !has_at_least_one_quest_item?(pc, ARKENIAS_LETTER, LEIKANS_NOTE, SHILENS_TEARS, IRON_HEART, SHILENS_CALL) && has_quest_items?(pc, ARKENIAS_RECOMMENDATION)
          html = "30419-09.html"
        elsif !has_at_least_one_quest_item?(pc, ARKENIAS_LETTER, SHILENS_TEARS, ARKENIAS_RECOMMENDATION, IRON_HEART, SHILENS_CALL) && has_quest_items?(pc, LEIKANS_NOTE)
          html = "30419-10.html"
        elsif !has_at_least_one_quest_item?(pc, ARKENIAS_LETTER, LEIKANS_NOTE, SHILENS_TEARS, ARKENIAS_RECOMMENDATION, IRON_HEART, SHILENS_CALL)
          html = "30419-11.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
