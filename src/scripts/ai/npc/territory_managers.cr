class Scripts::TerritoryManagers < AbstractNpcAI
  private PRECIOUS_SOUL1_ITEM_IDS = {
    7587,
    7588,
    7589,
    7597,
    7598,
    7599
  }
  private PRECIOUS_SOUL2_ITEM_IDS = {
    7595
  }
  private PRECIOUS_SOUL3_ITEM_IDS = {
    7678,
    7591,
    7592,
    7593
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    9.times do |i|
      add_first_talk_id(36490 &+ i)
      add_talk_id(36490 &+ i)
      add_start_npc(36490 &+ i)
    end
  end

  def on_first_talk(npc, pc)
    if pc.class_id.level < 2 || pc.level < 40
      # If the player does not have the second class transfer or is under level 40, it cannot continue.
      return "36490-08.html"
    end

    "#{npc.id}.html"
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!
    pc = pc.not_nil!

    npc_id = npc.id
    item_id = 13757 &+ (npc_id &- 36490)
    territory_id = 81 &+ (npc_id &- 36490)
    case event
    when "36490-04.html"
      # L2J Custom for minimum badges required.
      html = NpcHtmlMessage.new(npc.l2id)
      html.set_file(pc, "data/scripts/ai/npc/TerritoryManagers/36490-04.html")
      html["%badge%"] = TerritoryWarManager.min_tw_badge_for_nobless
      pc.send_packet(html)
    when "BuyProducts"
      if pc.inventory.get_item_by_item_id(item_id)
        # If the player has at least one Territory Badges then show the multisell.
        multisell_id = 364900001 + ((npc_id &- 36490) &* 10000)
        MultisellData.separate_and_send(multisell_id, pc, npc, false)
      else
        # If the player does not have Territory Badges, it cannot continue.
        htmltext = "36490-02.html"
      end
    when "MakeMeNoble"
      if pc.inventory.get_inventory_item_count(item_id, -1) < TerritoryWarManager.min_tw_badge_for_nobless
        # If the player does not have enough Territory Badges, it cannot continue.
        htmltext = "36490-02.html"
      elsif pc.noble?
        # If the player is already Noblesse, it cannot continue.
        htmltext = "36490-05.html"
      elsif pc.level < 75
        # If the player is not level 75 or greater, it cannot continue.
        htmltext = "36490-06.html"
      else
        # Complete the Noblesse related quests.
        # Possessor of a Precious Soul - 1 (241)
        process_noblesse_quest(pc, 241, PRECIOUS_SOUL1_ITEM_IDS)
        # Possessor of a Precious Soul - 2 (242)
        process_noblesse_quest(pc, 242, PRECIOUS_SOUL2_ITEM_IDS)
        # Possessor of a Precious Soul - 3 (246)
        process_noblesse_quest(pc, 246, PRECIOUS_SOUL3_ITEM_IDS)
        # Possessor of a Precious Soul - 4 (247)
        process_noblesse_quest(pc, 247, nil)

        # Take the Territory Badges.
        pc.destroy_item_by_item_id(event, item_id, TerritoryWarManager.min_tw_badge_for_nobless, npc, true)
        # Give Noblesse Tiara to the player.
        pc.add_item(event, 7694, 1, npc, true)
        # Set Noblesse status to the player.
        pc.noble = true
        pc.send_packet(UserInfo.new(pc))
        pc.send_packet(ExBrExtraUserInfo.new(pc))
        # Complete the sub-class related quest.
        # Complete quest Seeds of Chaos (236) for Kamael characters.
        # Complete quest Mimir's Elixir (235) for other races characters.
        if q = QuestManager.get_quest(pc.race.kamael? ? 236 : 235)
          unless qs = pc.get_quest_state(q.name)
            qs = q.new_quest_state(pc)
            qs.state = State::STARTED
          end
          # Completes the quest.
          qs.exit_quest(false)
        end
        # Remove the following items
        # Caradine's Letter
        delete_if_exists(pc, 7678, event, npc)
        # Caradine's Letter
        delete_if_exists(pc, 7679, event, npc)
        # Star of Destiny
        delete_if_exists(pc, 5011, event, npc)
        # Virgil's Letter
        delete_if_exists(pc, 1239, event, npc)
        # Arkenia's Letter
        delete_if_exists(pc, 1246, event, npc)
      end
    when "CalcRewards"
      reward = TerritoryWarManager.calc_reward(pc)
      html = NpcHtmlMessage.new(npc.l2id)
      prefix = pc.html_prefix
      if TerritoryWarManager.tw_in_progress? || reward[0] == 0
        html.set_file(prefix, "data/scripts/ai/npc/TerritoryManagers/reward-0a.html")
      elsif reward[0] != territory_id
        html.set_file(prefix, "data/scripts/ai/npc/TerritoryManagers/reward-0b.html")
        html["%castle%"] = CastleManager.get_castle_by_id(reward[0] &- 80).not_nil!.name
      elsif reward[1] == 0
        html.set_file(prefix, "data/scripts/ai/npc/TerritoryManagers/reward-0a.html")
      else
        html.set_file(prefix, "data/scripts/ai/npc/TerritoryManagers/reward-1.html")
        html["%castle%"] = CastleManager.get_castle_by_id(reward[0] &- 80).not_nil!.name
        html["%badge%"] = reward[1]
        html["%adena%"] = reward[1] &* 5000
      end
      html["%territoryId%"] = territory_id
      html["%objectId%"] = npc.l2id
      pc.send_packet(html)
      pc.action_failed
    when "ReceiveRewards"
      badge_id = TerritoryWarManager::TERRITORY_ITEM_IDS.fetch(territory_id, 57)
      reward = TerritoryWarManager.calc_reward(pc)
      html = NpcHtmlMessage.new(npc.l2id)
      if TerritoryWarManager.tw_in_progress? || reward[0] == 0
        html.set_file(pc, "data/scripts/ai/npc/TerritoryManagers/reward-0a.html")
      elsif reward[0] != territory_id
        html.set_file(pc, "data/scripts/ai/npc/TerritoryManagers/reward-0b.html")
        html["%castle%"] = CastleManager.get_castle_by_id(reward[0] - 80).not_nil!.name
      elsif reward[1] == 0
        html.set_file(pc, "data/scripts/ai/npc/TerritoryManagers/reward-0a.html")
      else
        html.set_file(pc, "data/scripts/ai/npc/TerritoryManagers/reward-2.html")
        count = reward[1].to_i64
        pc.add_item("ReceiveRewards", badge_id, count, npc, true)
        pc.add_adena("ReceiveRewards", count &* 5000, npc, true)
        TerritoryWarManager.reset_reward(pc)
      end

      html["%objectId%"] = npc.l2id
      pc.send_packet(html)
      pc.action_failed
    else
      htmltext = event
    end

    htmltext
  end

  private def process_noblesse_quest(pc, quest_id, item_ids)
    unless q = QuestManager.get_quest(quest_id)
      return
    end

    unless qs = pc.get_quest_state(q.name)
      qs = q.new_quest_state(pc)
      qs.state = State::STARTED
    end

    unless qs.completed?
      # Take the quest specific items.
      if item_ids
        item_ids.each { |item_id| take_items(pc, item_id, -1) }
      end
      # Completes the quest.
      qs.exit_quest(false)
    end
  end

  private def delete_if_exists(pc, item_id, event, npc)
    if item = pc.inventory.get_item_by_item_id(item_id)
      pc.destroy_item(event, item, npc, true)
    end
  end
end
