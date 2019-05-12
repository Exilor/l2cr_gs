require "../../../models/holders/item_chance_holder"

class Scripts::Q00403_PathOfTheRogue < Quest
  # NPCs
	private CAPTAIN_BEZIQUE = 30379
	private NETI = 30425
	# Items
	private BEZIQUES_LETTER = 1180
	private NETIS_BOW = 1181
	private NETIS_DAGGER = 1182
	private SPARTOIS_BONES = 1183
	private HORSESHOE_OF_LIGHT = 1184
	private MOST_WANTED_LIST = 1185
	private STOLEN_JEWELRY = 1186
	private STOLEN_TOMES = 1187
	private STOLEN_RING = 1188
	private STOLEN_NECKLACE = 1189
	private STOLEN_ITEMS = {STOLEN_JEWELRY, STOLEN_TOMES,  STOLEN_RING, STOLEN_NECKLACE}
	# Reward
	private BEZIQUES_RECOMMENDATION = 1190
	# Misc
	private MIN_LEVEL = 18
	private REQUIRED_ITEM_COUNT = 10
	# Quest Monster
	private CATS_EYE_BANDIT = 27038
	# Monster
	private MONSTER_DROPS = {
		20035 => ItemChanceHolder.new(SPARTOIS_BONES, 2), # Tracker Skeleton
		20042 => ItemChanceHolder.new(SPARTOIS_BONES, 3), # Tracker Skeleton Leader
		20045 => ItemChanceHolder.new(SPARTOIS_BONES, 2), # Skeleton Scout
		20051 => ItemChanceHolder.new(SPARTOIS_BONES, 2), # Skeleton Bowman
		20054 => ItemChanceHolder.new(SPARTOIS_BONES, 8), # Ruin Spartoi
		20060 => ItemChanceHolder.new(SPARTOIS_BONES, 8)  # Raging Spartoi
	}

  def initialize
    super(403, self.class.simple_name, "Path Of The Rogue")

    add_start_npc(CAPTAIN_BEZIQUE)
		add_talk_id(CAPTAIN_BEZIQUE, NETI)
		add_attack_id(MONSTER_DROPS.keys + [CATS_EYE_BANDIT])
		add_kill_id(MONSTER_DROPS.keys + [CATS_EYE_BANDIT])
		register_quest_items(
      BEZIQUES_LETTER, NETIS_BOW, NETIS_DAGGER, SPARTOIS_BONES,
      HORSESHOE_OF_LIGHT, MOST_WANTED_LIST, STOLEN_JEWELRY, STOLEN_TOMES,
      STOLEN_RING, STOLEN_NECKLACE
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if pc.class_id.fighter?
        if pc.level >= MIN_LEVEL
          if has_quest_items?(pc, BEZIQUES_RECOMMENDATION)
            "30379-04.htm"
          else
            "30379-05.htm"
          end
        else
          "30379-03.htm"
        end
      elsif pc.class_id.rogue?
        "30379-02a.htm"
      else
        "30379-02.htm"
      end
    when "30379-06.htm"
      qs.start_quest
      give_items(pc, BEZIQUES_LETTER, 1)
      event
    when "30425-02.html", "30425-03.html", "30425-04.html"
      event
    when "30425-05.html"
      if has_quest_items?(pc, BEZIQUES_LETTER)
        take_items(pc, BEZIQUES_LETTER, 1)
        unless has_quest_items?(pc, NETIS_BOW)
          give_items(pc, NETIS_BOW, 1)
        end
        unless has_quest_items?(pc, NETIS_DAGGER)
          give_items(pc, NETIS_DAGGER, 1)
        end

        qs.set_cond(2, true)
      end

      event
    end
  end

  def on_attack(npc, attacker, damage, is_summon)
    qs = get_quest_state(attacker, false)

    if qs && qs.started?
      case npc.script_value
      when 0
        npc.variables["lastAttacker"] = attacker.l2id
        if !check_weapon(attacker)
          npc.script_value = 2
        else
          if npc.id == CATS_EYE_BANDIT
            ns = NpcString::YOU_CHILDISH_FOOL_DO_YOU_THINK_YOU_CAN_CATCH_ME
            say = NpcSay.new(npc, Say2::NPC_ALL, ns)
            attacker.send_packet(say)
          end
          npc.script_value = 1
        end
      when 1
        if !check_weapon(attacker)
          npc.script_value = 2
        elsif npc.variables.get_i32("lastAttacker") != attacker.l2id
          npc.script_value = 2
        end
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)

    if qs && qs.started? && npc.script_value?(1) && Util.in_range?(1500, npc, killer, true)
      if npc.id == CATS_EYE_BANDIT
        str = NpcString::I_MUST_DO_SOMETHING_ABOUT_THIS_SHAMEFUL_INCIDENT
        say = NpcSay.new(npc, Say2::NPC_ALL, str)
        npc.broadcast_packet(say)

        if has_quest_items?(killer, MOST_WANTED_LIST)
          random_item = STOLEN_ITEMS.sample(random: Rnd)
          unless has_quest_items?(killer, random_item)
            give_items(killer, random_item, 1)
            if has_quest_items?(killer, STOLEN_ITEMS)
              qs.set_cond(6, true)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      else
        reward = MONSTER_DROPS[npc.id]
        if get_quest_items_count(killer, reward.id) < REQUIRED_ITEM_COUNT
          if npc.script_value?(1)
            if Rnd.rand(REQUIRED_ITEM_COUNT) < reward.chance
              give_items(killer, reward.id, reward.count)
              if get_quest_items_count(killer, reward.id) >= REQUIRED_ITEM_COUNT
                qs.set_cond(3, true)
              else
                play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
              end
            end
          end
        end
      end
    end

    super
  end

  private def check_weapon(pc)
    return false unless weapon = pc.active_weapon_instance?
    weapon.id == NETIS_BOW || weapon.id == NETIS_DAGGER
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created? || qs.completed?
      if npc.id == CAPTAIN_BEZIQUE
        html = "30379-01.htm"
      end
    elsif qs.started?
      case npc.id
      when CAPTAIN_BEZIQUE
        if has_quest_items?(pc, STOLEN_JEWELRY, STOLEN_TOMES, STOLEN_RING, STOLEN_NECKLACE)
          give_adena(pc, 163800, true)
					take_items(pc, NETIS_BOW, 1)
					take_items(pc, NETIS_DAGGER, 1)
					take_items(pc, MOST_WANTED_LIST, 1)
					take_items(pc, STOLEN_JEWELRY, 1)
					take_items(pc, STOLEN_TOMES, 1)
					take_items(pc, STOLEN_RING, 1)
					take_items(pc, STOLEN_NECKLACE, 1)
					give_items(pc, BEZIQUES_RECOMMENDATION, 1)

          level = pc.level
          if level >= 20
            add_exp_and_sp(pc, 320534, 20232)
          elsif level == 19
            add_exp_and_sp(pc, 456128, 26930)
          else
            add_exp_and_sp(pc, 591724, 33628)
          end

          qs.exit_quest(false, true)
          pc.send_packet(SocialAction.new(pc.l2id, 3))
          qs.save_global_quest_var("1ClassQuestFinished", "1")
          html = "30379-09.html"
        elsif !has_quest_items?(pc, HORSESHOE_OF_LIGHT) && has_quest_items?(pc, BEZIQUES_LETTER)
					html = "30379-07.html"
        elsif has_quest_items?(pc, HORSESHOE_OF_LIGHT)
					take_items(pc, HORSESHOE_OF_LIGHT, 1)
					give_items(pc, MOST_WANTED_LIST, 1)
					qs.set_cond(5, true)
					html = "30379-08.html"
        elsif has_quest_items?(pc, NETIS_BOW, NETIS_DAGGER) && !has_quest_items?(pc, MOST_WANTED_LIST)
					html = "30379-10.html"
        elsif has_quest_items?(pc, MOST_WANTED_LIST)
					html = "30379-11.html"
        end
      when NETI
        if has_quest_items?(pc, BEZIQUES_LETTER)
          html = "30425-01.html"
        elsif !has_at_least_one_quest_item?(pc, HORSESHOE_OF_LIGHT, BEZIQUES_LETTER)
          if has_quest_items?(pc, MOST_WANTED_LIST)
            html = "30425-08.html"
          elsif get_quest_items_count(pc, SPARTOIS_BONES) < REQUIRED_ITEM_COUNT
            html = "30425-06.html"
          else
            take_items(pc, SPARTOIS_BONES, REQUIRED_ITEM_COUNT)
            give_items(pc, HORSESHOE_OF_LIGHT, 1)
            qs.set_cond(4, true)
            html = "30425-07.html"
          end
        elsif has_quest_items?(pc, HORSESHOE_OF_LIGHT)
          html = "30425-08.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
