class Quests::Q00103_SpiritOfCraftsman < Quest
  # NPCs
  private BLACKSMITH_KARROD = 30307
  private CECKTINON = 30132
  private HARNE = 30144
  # Items
  private KARRODS_LETTER = 968
  private CECKTINONS_VOUCHER1 = 969
  private CECKTINONS_VOUCHER2 = 970
  private SOUL_CATCHER = 971
  private PRESERVE_OIL = 972
  private ZOMBIE_HEAD = 973
  private STEELBENDERS_HEAD = 974
  private BONE_FRAGMENT = 1107
  # Monsters
  private MARSH_ZOMBIE = 20015
  private DOOM_SOLDIER = 20455
  private SKELETON_HUNTER = 20517
  private SKELETON_HUNTER_ARCHER = 20518
  # Rewards
  private BLOODSABER = 975
  private REWARDS = {
    ItemHolder.new(1060, 100), # Lesser Healing Potion
    ItemHolder.new(4412, 10),  # Echo Crystal - Theme of Battle
    ItemHolder.new(4413, 10),  # Echo Crystal - Theme of Love
    ItemHolder.new(4414, 10),  # Echo Crystal - Theme of Solitude
    ItemHolder.new(4415, 10),  # Echo Crystal - Theme of Feast
    ItemHolder.new(4416, 10)   # Echo Crystal - Theme of Celebration
  }
  # Misc
  private MIN_LVL = 10

  def initialize
    super(103, self.class.simple_name, "Spirit of Craftsman")

    add_start_npc(BLACKSMITH_KARROD)
    add_talk_id(BLACKSMITH_KARROD, CECKTINON, HARNE)
    add_kill_id(MARSH_ZOMBIE, DOOM_SOLDIER, SKELETON_HUNTER, SKELETON_HUNTER_ARCHER)
    register_quest_items(KARRODS_LETTER, CECKTINONS_VOUCHER1, CECKTINONS_VOUCHER2, SOUL_CATCHER, PRESERVE_OIL, ZOMBIE_HEAD, STEELBENDERS_HEAD, BONE_FRAGMENT)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "30307-04.htm"
      htmltext = event
    when "30307-05.htm"
      if qs.created?
        qs.start_quest
        give_items(player, KARRODS_LETTER, 1)
        htmltext = event
      end
    end

    htmltext
  end

  def on_talk(npc, talker)
    qs = get_quest_state!(talker)
    htmltext = get_no_quest_msg(talker)
    case npc.id
    when BLACKSMITH_KARROD
      if qs.created?
        if talker.race != Race::DARK_ELF
          htmltext = "30307-01.htm"
        elsif talker.level < MIN_LVL
          htmltext = "30307-02.htm"
        else
          htmltext = "30307-03.htm"
        end
      elsif qs.started?
        if has_at_least_one_quest_item?(talker, KARRODS_LETTER, CECKTINONS_VOUCHER1, CECKTINONS_VOUCHER2)
          htmltext = "30307-06.html"
        elsif has_quest_items?(talker, STEELBENDERS_HEAD)
          Q00281_HeadForTheHills.give_newbie_reward(talker)
          add_exp_and_sp(talker, 46663, 3999)
          give_adena(talker, 19799, true)
          REWARDS.each { |reward| reward_items(talker, reward) }
          reward_items(talker, BLOODSABER, 1)
          qs.exit_quest(false, true)
          talker.send_packet(SocialAction.new(talker.l2id, 3))
          htmltext = "30307-07.html"
        end
      elsif qs.completed?
        htmltext = get_already_completed_msg(talker)
      end
    when CECKTINON
      if qs.started?
        if has_quest_items?(talker, KARRODS_LETTER)
          qs.set_cond(2, true)
          take_items(talker, KARRODS_LETTER, 1)
          give_items(talker, CECKTINONS_VOUCHER1, 1)
          htmltext = "30132-01.html"
        elsif has_at_least_one_quest_item?(talker, CECKTINONS_VOUCHER1, CECKTINONS_VOUCHER2)
          htmltext = "30132-02.html"
        elsif has_quest_items?(talker, SOUL_CATCHER)
          qs.set_cond(6, true)
          take_items(talker, SOUL_CATCHER, 1)
          give_items(talker, PRESERVE_OIL, 1)
          htmltext = "30132-03.html"
        elsif has_quest_items?(talker, PRESERVE_OIL) && !has_quest_items?(talker, ZOMBIE_HEAD, STEELBENDERS_HEAD)
          htmltext = "30132-04.html"
        elsif has_quest_items?(talker, ZOMBIE_HEAD)
          qs.set_cond(8, true)
          take_items(talker, ZOMBIE_HEAD, 1)
          give_items(talker, STEELBENDERS_HEAD, 1)
          htmltext = "30132-05.html"
        elsif has_quest_items?(talker, STEELBENDERS_HEAD)
          htmltext = "30132-06.html"
        end
      end
    when HARNE
      if qs.started?
        if has_quest_items?(talker, CECKTINONS_VOUCHER1)
          qs.set_cond(3, true)
          take_items(talker, CECKTINONS_VOUCHER1, 1)
          give_items(talker, CECKTINONS_VOUCHER2, 1)
          htmltext = "30144-01.html"
        elsif has_quest_items?(talker, CECKTINONS_VOUCHER2)
          if get_quest_items_count(talker, BONE_FRAGMENT) >= 10
            qs.set_cond(5, true)
            take_items(talker, CECKTINONS_VOUCHER2, 1)
            take_items(talker, BONE_FRAGMENT, 10)
            give_items(talker, SOUL_CATCHER, 1)
            htmltext = "30144-03.html"
          else
            htmltext = "30144-02.html"
          end
        elsif has_quest_items?(talker, SOUL_CATCHER)
          htmltext = "30144-04.html"
        end
      end
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    return super unless qs = get_random_party_member_state(killer, -1, 3, npc)

    case npc.id
    when MARSH_ZOMBIE
      if has_quest_items?(killer, PRESERVE_OIL) && (rand(10) < 5) && Util.in_range?(1500, npc, killer, true)
        give_items(killer, ZOMBIE_HEAD, 1)
        take_items(killer, PRESERVE_OIL, -1)
        qs.set_cond(7, true)
      end
    when DOOM_SOLDIER, SKELETON_HUNTER, SKELETON_HUNTER_ARCHER
      if has_quest_items?(killer, CECKTINONS_VOUCHER2) && give_item_randomly(qs.player, npc, BONE_FRAGMENT, 1, 10, 1.0, true)
        qs.set_cond(4, true)
      end
    end

    super
  end
end
