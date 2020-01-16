class Scripts::Q00402_PathOfTheHumanKnight < Quest
  # NPCs
	private HIGH_PRIEST_BIOTIN = 30031
	private LEVIAN = 30037
	private CAPTAIN_GILBERT = 30039
	private HIGH_PRIEST_RAYMOND = 30289
	private CAPTAIN_BATHIS = 30332
	private CAPTAIN_BEZIQUE = 30379
	private SIR_KLAUS_VASPER = 30417
	private SIR_ARON_TANFORD = 30653
	# Items
	private SQUIRES_MARK = 1271
	private COIN_OF_LORDS1 = 1162
	private COIN_OF_LORDS2 = 1163
	private COIN_OF_LORDS3 = 1164
	private COIN_OF_LORDS4 = 1165
	private COIN_OF_LORDS5 = 1166
	private COIN_OF_LORDS6 = 1167
	private GLUDIO_GUARDS_1ST_BADGE = 1168
	private BUGBEAR_NECKLACE = 1169
	private EINHASADS_1ST_TEMPLE_BADGE = 1170
	private EINHASAD_CRUCIFIX = 1171
	private GLUDIO_GUARDS_2ND_BADGE = 1172
	private VENOMOUS_SPIDERS_LEG = 1173
	private EINHASADS_2ND_TEMPLE_BADGE = 1174
	private LIZARDMANS_TOTEM = 1175
	private GLUDIO_GUARDS_3RD_BADGE = 1176
	private GIANT_SPIDERS_HUSK = 1177
	private EINHASADS_3RD_TEMPLE_BADGE = 1178
	private SKULL_OF_SILENT_HORROR = 1179
	# Reward
	private SWORD_OF_RITUAL = 1161
	# Monster
	private LANGK_LIZARDMAN_WARRIOR = 20024
	private LANGK_LIZARDMAN_SCOUT = 20027
	private LANGK_LIZARDMAN = 20030
	private VENOMOUS_SPIDER = 20038
	private ARACHNID_TRACKER = 20043
	private ARACHNID_PREDATOR = 20050
	private GIANT_SPIDER = 20103
	private TALON_SPIDER = 20106
	private BLADE_SPIDER = 20108
	private SILENT_HORROR = 20404
	private BUGBEAR_RAIDER = 20775
	# Quest Monster
	private UNDEAD_PRIEST = 27024
	# Misc
	private MIN_LEVEL = 18

  def initialize
    super(402, self.class.simple_name, "Path Of The Human Knight")

    add_start_npc(SIR_KLAUS_VASPER)
		add_talk_id(
      SIR_KLAUS_VASPER, HIGH_PRIEST_BIOTIN, LEVIAN, HIGH_PRIEST_RAYMOND,
      CAPTAIN_GILBERT, CAPTAIN_BATHIS, CAPTAIN_BEZIQUE, SIR_ARON_TANFORD
    )
		add_kill_id(
      LANGK_LIZARDMAN_WARRIOR, LANGK_LIZARDMAN_SCOUT, LANGK_LIZARDMAN,
      VENOMOUS_SPIDER, ARACHNID_TRACKER, ARACHNID_PREDATOR, GIANT_SPIDER,
      TALON_SPIDER, BLADE_SPIDER, SILENT_HORROR, BUGBEAR_RAIDER, UNDEAD_PRIEST
    )
		register_quest_items(
      SQUIRES_MARK, COIN_OF_LORDS1, COIN_OF_LORDS2, COIN_OF_LORDS3,
      COIN_OF_LORDS4, COIN_OF_LORDS5, COIN_OF_LORDS6, GLUDIO_GUARDS_1ST_BADGE,
      BUGBEAR_NECKLACE, EINHASADS_1ST_TEMPLE_BADGE, EINHASAD_CRUCIFIX,
      GLUDIO_GUARDS_2ND_BADGE, VENOMOUS_SPIDERS_LEG,
      EINHASADS_2ND_TEMPLE_BADGE, LIZARDMANS_TOTEM, GLUDIO_GUARDS_3RD_BADGE,
      GIANT_SPIDERS_HUSK, EINHASADS_3RD_TEMPLE_BADGE, SKULL_OF_SILENT_HORROR
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)
    coin_count = get_quest_items_count(pc, COIN_OF_LORDS1, COIN_OF_LORDS2, COIN_OF_LORDS3, COIN_OF_LORDS4, COIN_OF_LORDS5, COIN_OF_LORDS6)

    case event
    when "ACCEPT"
      if pc.class_id.fighter?
        if pc.level >= MIN_LEVEL
          if has_quest_items?(pc, SWORD_OF_RITUAL)
            "30417-04.htm"
          else
            "30417-05.htm"
          end
        else
          "30417-02.htm"
        end
      elsif pc.class_id.knight?
        "30417-02a.htm"
      else
        "30417-03.htm"
      end
    when "30417-08.htm"
      qs.start_quest
      give_items(pc, SQUIRES_MARK, 1)
      event
    when "30289-02.html", "30417-06.html", "30417-07.htm", "30417-15.html"
      event
    when "30417-13.html"
      if has_quest_items?(pc, SQUIRES_MARK) && coin_count == 3
        give_adena(pc, 81_900, true)
        give_items(pc, SWORD_OF_RITUAL, 1)
        level = pc.level
        if level >= 20
          add_exp_and_sp(pc, 160267, 11576)
        elsif level == 19
          add_exp_and_sp(pc, 228064, 14925)
        else
          add_exp_and_sp(pc, 295862, 18274)
        end
        qs.exit_quest(false, true)
        pc.send_packet(SocialAction.new(pc.l2id, 3))
        qs.save_global_quest_var("1ClassQuestFinished", "1")
        event
      end
    when "30417-14.html"
      if has_quest_items?(pc, SQUIRES_MARK) && coin_count.between?(4, 5)
        give_adena(pc, 81_900, true)
        give_items(pc, SWORD_OF_RITUAL, 1)
        level = pc.level
        if level >= 20
          add_exp_and_sp(pc, 160267, 11576)
        elsif level == 19
          add_exp_and_sp(pc, 228064, 14925)
        else
          add_exp_and_sp(pc, 295862, 18274)
        end
        qs.exit_quest(false, true)
        pc.send_packet(SocialAction.new(pc.l2id, 3))
        qs.save_global_quest_var("1ClassQuestFinished", "1")
        event
      end
    when "30031-02.html"
      give_items(pc, EINHASADS_3RD_TEMPLE_BADGE, 1)
      event
    when "30037-02.html"
      give_items(pc, EINHASADS_2ND_TEMPLE_BADGE, 1)
      event
    when "30289-03.html"
      give_items(pc, EINHASADS_1ST_TEMPLE_BADGE, 1)
      event
    when "30039-02.html"
      give_items(pc, GLUDIO_GUARDS_3RD_BADGE, 1)
      event
    when "30379-02.html"
      give_items(pc, GLUDIO_GUARDS_2ND_BADGE, 1)
      event
    when "30332-02.html"
      give_items(pc, GLUDIO_GUARDS_1ST_BADGE, 1)
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)

    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when LANGK_LIZARDMAN_WARRIOR, LANGK_LIZARDMAN_SCOUT, LANGK_LIZARDMAN
        reward_kill(killer, EINHASADS_2ND_TEMPLE_BADGE, LIZARDMANS_TOTEM, 20, 5)
      when VENOMOUS_SPIDER, ARACHNID_TRACKER, ARACHNID_PREDATOR
        reward_kill(killer, GLUDIO_GUARDS_2ND_BADGE, VENOMOUS_SPIDERS_LEG, 20)
      when GIANT_SPIDER, TALON_SPIDER, BLADE_SPIDER
        reward_kill(killer, GLUDIO_GUARDS_3RD_BADGE, GIANT_SPIDERS_HUSK, 20, 4)
      when SILENT_HORROR
        reward_kill(killer, EINHASADS_3RD_TEMPLE_BADGE, SKULL_OF_SILENT_HORROR, 10, 4)
      when BUGBEAR_RAIDER
        reward_kill(killer, GLUDIO_GUARDS_1ST_BADGE, BUGBEAR_NECKLACE, 10)
      when UNDEAD_PRIEST
        reward_kill(killer, EINHASADS_1ST_TEMPLE_BADGE, EINHASAD_CRUCIFIX, 12, 5)
      end
    end

    super
  end

  private def reward_kill(pc, item_req, item_give, item_count, rnd = nil)
    if has_quest_items?(pc, item_req)
      debug "has required item"
      if get_quest_items_count(pc, item_give) < item_count
        debug "quest items count < item count"
        if rnd.nil? || Rnd.rand(10) < rnd
          debug "no rnd or rnd succeded"
          give_items(pc, item_give, 1)
          if get_quest_items_count(pc, item_give) == item_count
            play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      end
    end
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created? || qs.completed?
      if npc.id == SIR_KLAUS_VASPER
        html = "30417-01.htm"
      end
    elsif qs.started?
      case npc.id
      when SIR_KLAUS_VASPER
        coin_count = get_quest_items_count(pc, COIN_OF_LORDS1, COIN_OF_LORDS2, COIN_OF_LORDS3, COIN_OF_LORDS4, COIN_OF_LORDS5, COIN_OF_LORDS6)
        if has_quest_items?(pc, SQUIRES_MARK)
          if coin_count < 3
            html = "30417-09.html"
          elsif coin_count == 3
            html = "30417-10.html"
          elsif 4 <= coin_count <= 5
            html = "30417-11.html"
          else
            give_adena(pc, 163_800, true)
            give_items(pc, SWORD_OF_RITUAL, 1)

            level = pc.level

            if level >= 20
              add_exp_and_sp(pc, 320534, 23152)
            elsif level == 10
              add_exp_and_sp(pc, 456128, 29850)
            else
              add_exp_and_sp(pc, 591724, 36542)
            end

            qs.exit_quest(false, true)
            pc.send_packet(SocialAction.new(pc.l2id, 3))
            qs.save_global_quest_var("1ClassQuestFinished", "1")
            html = "30417-12.html"
          end
        end
      when HIGH_PRIEST_BIOTIN
        if has_quest_items?(pc, SQUIRES_MARK) && !has_at_least_one_quest_item?(pc, EINHASADS_3RD_TEMPLE_BADGE, COIN_OF_LORDS6)
          html = "30031-01.html"
        elsif has_quest_items?(pc, EINHASADS_3RD_TEMPLE_BADGE)
          if get_quest_items_count(pc, SKULL_OF_SILENT_HORROR) < 10
            html = "30031-03.html"
          else
            give_items(pc, COIN_OF_LORDS6, 1)
            take_items(pc, EINHASADS_3RD_TEMPLE_BADGE, 1)
            take_items(pc, SKULL_OF_SILENT_HORROR, -1)
            html = "30031-04.html"
          end
        elsif has_quest_items?(pc, COIN_OF_LORDS6)
          html = "30031-05.html"
        end
      when LEVIAN
        if has_quest_items?(pc, SQUIRES_MARK) && !has_at_least_one_quest_item?(pc, EINHASADS_2ND_TEMPLE_BADGE, COIN_OF_LORDS4)
          html = "30037-01.html"
        elsif has_quest_items?(pc, EINHASADS_2ND_TEMPLE_BADGE)
          if get_quest_items_count(pc, LIZARDMANS_TOTEM) < 20
            html = "30037-03.html"
          else
            give_items(pc, COIN_OF_LORDS4, 1)
            take_items(pc, EINHASADS_2ND_TEMPLE_BADGE, 1)
            take_items(pc, LIZARDMANS_TOTEM, -1)
            html = "30037-04.html"
          end
        elsif has_quest_items?(pc, COIN_OF_LORDS4)
          html = "30037-05.html"
        end
      when HIGH_PRIEST_RAYMOND
        if has_quest_items?(pc, SQUIRES_MARK) && !has_at_least_one_quest_item?(pc, EINHASADS_1ST_TEMPLE_BADGE, COIN_OF_LORDS2)
          html = "30289-01.html"
        elsif has_quest_items?(pc, EINHASADS_1ST_TEMPLE_BADGE)
          if get_quest_items_count(pc, EINHASAD_CRUCIFIX) < 12
            html = "30289-04.html"
          else
            give_items(pc, COIN_OF_LORDS2, 1)
            take_items(pc, EINHASADS_1ST_TEMPLE_BADGE, 1)
            take_items(pc, EINHASAD_CRUCIFIX, -1)
            html = "30289-05.html"
          end
        elsif has_quest_items?(pc, COIN_OF_LORDS2)
          html = "30289-06.html"
        end
      when CAPTAIN_GILBERT
        if has_quest_items?(pc, SQUIRES_MARK) && !has_at_least_one_quest_item?(pc, GLUDIO_GUARDS_3RD_BADGE, COIN_OF_LORDS5)
          html = "30039-01.html"
        elsif has_quest_items?(pc, GLUDIO_GUARDS_3RD_BADGE)
          if get_quest_items_count(pc, GIANT_SPIDERS_HUSK) < 20
            html = "30039-03.html"
          else
            give_items(pc, COIN_OF_LORDS5, 1)
            take_items(pc, GLUDIO_GUARDS_3RD_BADGE, 1)
            take_items(pc, GIANT_SPIDERS_HUSK, -1)
            html = "30039-04.html"
          end
        elsif has_quest_items?(pc, COIN_OF_LORDS5)
          html = "30039-05.html"
        end
      when CAPTAIN_BEZIQUE
        if has_quest_items?(pc, SQUIRES_MARK) && !has_at_least_one_quest_item?(pc, GLUDIO_GUARDS_2ND_BADGE, COIN_OF_LORDS3)
          html = "30379-01.html"
        elsif has_quest_items?(pc, GLUDIO_GUARDS_2ND_BADGE)
          if get_quest_items_count(pc, VENOMOUS_SPIDERS_LEG) < 20
            html = "30379-03.html"
          else
            give_items(pc, COIN_OF_LORDS3, 1)
            take_items(pc, GLUDIO_GUARDS_2ND_BADGE, 1)
            take_items(pc, VENOMOUS_SPIDERS_LEG, -1)
            html = "30379-04.html"
          end
        elsif has_quest_items?(pc, COIN_OF_LORDS3)
          html = "30379-05.html"
        end
      when CAPTAIN_BATHIS
        if has_quest_items?(pc, SQUIRES_MARK) && !has_at_least_one_quest_item?(pc, GLUDIO_GUARDS_1ST_BADGE, COIN_OF_LORDS1)
          html = "30332-01.html"
        elsif has_quest_items?(pc, GLUDIO_GUARDS_1ST_BADGE)
          if get_quest_items_count(pc, BUGBEAR_NECKLACE) < 10
            html = "30332-03.html"
          else
            give_items(pc, COIN_OF_LORDS1, 1)
            take_items(pc, GLUDIO_GUARDS_1ST_BADGE, 1)
            take_items(pc, BUGBEAR_NECKLACE, -1)
            html = "30332-04.html"
          end
        elsif has_quest_items?(pc, COIN_OF_LORDS1)
          html = "30332-05.html"
        end
      when SIR_ARON_TANFORD
        if has_quest_items?(pc, SQUIRES_MARK)
          html = "30653-01.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
