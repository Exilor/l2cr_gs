class Scripts::MasterOfEnchanting < LongTimeEvent
  # NPC
  private MASTER_YOGI = 32599
  # Items
  private MASTER_YOGI_STAFF = 13539
  private MASTER_YOGI_SCROLL = 13540
  # Misc
  private STAFF_PRICE = 1000000
  private SCROLL_24_PRICE = 5000000
  private SCROLL_24_TIME = 6
  private SCROLL_1_PRICE = 500000
  private SCROLL_10_PRICE = 5000000

  private HAT_SHADOW_REWARD = {
    13074,
    13075,
    13076
  }
  private HAT_EVENT_REWARD = {
    13518,
    13519,
    13522
  }
  private CRYSTAL_REWARD = {
    9570,
    9571,
    9572
  }

  private EVENT_START = Time.local(2011, 7, 1)

  def initialize
    super(self.class.simple_name, "events")

    add_start_npc(MASTER_YOGI)
    add_first_talk_id(MASTER_YOGI)
    add_talk_id(MASTER_YOGI)
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!

    html = event
    if event.casecmp?("buy_staff")
      if !has_quest_items?(pc, MASTER_YOGI_STAFF) && get_quest_items_count(pc, Inventory::ADENA_ID) > STAFF_PRICE
        take_items(pc, Inventory::ADENA_ID, STAFF_PRICE)
        give_items(pc, MASTER_YOGI_STAFF, 1)
        html = "32599-staffbuyed.htm"
      else
        html = "32599-staffcant.htm"
      end
    elsif event.casecmp?("buy_scroll_24")
      if pc.create_date.after?(EVENT_START)
        return "32599-bidth.htm"
      end

      cur_time = Time.ms
      value = load_global_quest_var(pc.account_name)
      reuse = value.empty? ? 0i64 : value.to_i64

      if cur_time > reuse
        if get_quest_items_count(pc, Inventory::ADENA_ID) > SCROLL_24_PRICE
          take_items(pc, Inventory::ADENA_ID, SCROLL_24_PRICE)
          give_items(pc, MASTER_YOGI_SCROLL, 24)
          save_global_quest_var(pc.account_name, (Time.ms + (SCROLL_24_TIME * 3_600_000)).to_s)
          html = "32599-scroll24.htm"
        else
          html = "32599-s24-no.htm"
        end
      else
        remaining_time = (reuse - cur_time) // 1000
        hours = (remaining_time // 3600).to_i32
        minutes = ((remaining_time % 3600) // 60).to_i32
        if hours > 0
          sm = SystemMessage.item_purchasable_in_s1_hours_s2_minutes
          sm.add_int(hours)
          sm.add_int(minutes)
          pc.send_packet(sm)
          html = "32599-scroll24.htm"
        elsif minutes > 0
          sm = SystemMessage.item_purchasable_in_s1_minutes
          sm.add_int(minutes)
          pc.send_packet(sm)
          html = "32599-scroll24.htm"
        else
          # Little glitch. There is no SystemMessage with seconds only.
          # If time is less than 1 minute pc can buy scrolls
          if get_quest_items_count(pc, Inventory::ADENA_ID) > SCROLL_24_PRICE
            take_items(pc, Inventory::ADENA_ID, SCROLL_24_PRICE)
            give_items(pc, MASTER_YOGI_SCROLL, 24)
            save_global_quest_var(pc.account_name, (Time.ms + (SCROLL_24_TIME * 3_600_000)).to_s)
            html = "32599-scroll24.htm"
          else
            html = "32599-s24-no.htm"
          end
        end
      end
    elsif event.casecmp?("buy_scroll_1")
      if get_quest_items_count(pc, Inventory::ADENA_ID) > SCROLL_1_PRICE
        take_items(pc, Inventory::ADENA_ID, SCROLL_1_PRICE)
        give_items(pc, MASTER_YOGI_SCROLL, 1)
        html = "32599-scroll-ok.htm"
      else
        html = "32599-s1-no.htm"
      end
    elsif event.casecmp?("buy_scroll_10")
      if get_quest_items_count(pc, Inventory::ADENA_ID) > SCROLL_10_PRICE
        take_items(pc, Inventory::ADENA_ID, SCROLL_10_PRICE)
        give_items(pc, MASTER_YOGI_SCROLL, 10)
        html = "32599-scroll-ok.htm"
      else
        html = "32599-s10-no.htm"
      end
    elsif event.casecmp?("receive_reward")
      if get_item_equipped(pc, Inventory::RHAND) == MASTER_YOGI_STAFF && get_enchant_level(pc, MASTER_YOGI_STAFF) > 3
        case get_enchant_level(pc, MASTER_YOGI_STAFF)
        when 4
          give_items(pc, 6406, 1) # Firework
        when 5
          give_items(pc, 6406, 2) # Firework
          give_items(pc, 6407, 1) # Large Firework
        when 6
          give_items(pc, 6406, 3) # Firework
          give_items(pc, 6407, 2) # Large Firework
        when 7
          give_items(pc, HAT_SHADOW_REWARD.sample(random: Rnd), 1)
        when 8
          give_items(pc, 955, 1) # Scroll: Enchant Weapon (D)
        when 9
          give_items(pc, 955, 1) # Scroll: Enchant Weapon (D)
          give_items(pc, 956, 1) # Scroll: Enchant Armor (D)
        when 10
          give_items(pc, 951, 1) # Scroll: Enchant Weapon (C)
        when 11
          give_items(pc, 951, 1) # Scroll: Enchant Weapon (C)
          give_items(pc, 952, 1) # Scroll: Enchant Armor (C)
        when 12
          give_items(pc, 948, 1) # Scroll: Enchant Armor (B)
        when 13
          give_items(pc, 729, 1) # Scroll: Enchant Weapon (A)
        when 14
          give_items(pc, HAT_EVENT_REWARD.sample(random: Rnd), 1)
        when 15
          give_items(pc, 13992, 1) # Grade S Accessory Chest (Event)
        when 16
          give_items(pc, 8762, 1) # Top-Grade Life Stone: level 76
        when 17
          give_items(pc, 959, 1) # Scroll: Enchant Weapon (S)
        when 18
          give_items(pc, 13991, 1) # Grade S Armor Chest (Event)
        when 19
          give_items(pc, 13990, 1) # Grade S Weapon Chest (Event)
        when 20
          give_items(pc, CRYSTAL_REWARD.sample(random: Rnd), 1) # Red/Blue/Green Soul Crystal - Stage 14
        when 21
          give_items(pc, 8762, 1) # Top-Grade Life Stone: level 76
          give_items(pc, 8752, 1) # High-Grade Life Stone: level 76
          give_items(pc, CRYSTAL_REWARD.sample(random: Rnd), 1) # Red/Blue/Green Soul Crystal - Stage 14
        when 22
          give_items(pc, 13989, 1) # S80 Grade Armor Chest (Event)
        when 23
          give_items(pc, 13988, 1) # S80 Grade Weapon Chest (Event)
        else
          if get_enchant_level(pc, MASTER_YOGI_STAFF) > 23
            give_items(pc, 13988, 1) # S80 Grade Weapon Chest (Event)
          end
        end

        take_items(pc, MASTER_YOGI_STAFF, 1)
        html = "32599-rewardok.htm"
      else
        html = "32599-rewardnostaff.htm"
      end
    end

    html
  end

  def on_first_talk(npc, pc)
    "#{npc.id}.htm"
  end
end
