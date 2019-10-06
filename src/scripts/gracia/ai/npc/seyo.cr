class Scripts::Seyo < AbstractNpcAI
  # NPC
  private SEYO = 32737
  # Item
  private STONE_FRAGMENT = 15486 # Spirit Stone Fragment
  # Misc
  private TEXT = {
    NpcString::NO_ONE_ELSE_DONT_WORRY_I_DONT_BITE_HAHA,
    NpcString::OK_MASTER_OF_LUCK_THATS_YOU_HAHA_WELL_ANYONE_CAN_COME_AFTER_ALL,
    NpcString::SHEDDING_BLOOD_IS_A_GIVEN_ON_THE_BATTLEFIELD_AT_LEAST_ITS_SAFE_HERE,
    NpcString::OK_WHOS_NEXT_IT_ALL_DEPENDS_ON_YOUR_FATE_AND_LUCK_RIGHT_AT_LEAST_COME_AND_TAKE_A_LOOK,
    NpcString::THERE_WAS_SOMEONE_WHO_WON_10000_FROM_ME_A_WARRIOR_SHOULDNT_JUST_BE_GOOD_AT_FIGHTING_RIGHT_YOUVE_GOTTA_BE_GOOD_IN_EVERYTHING
  }

  def initialize
    super(self.class.simple_name, "gracia/AI/NPC")

    add_start_npc(SEYO)
    add_talk_id(SEYO)
    add_first_talk_id(SEYO)
  end

  def on_adv_event(event, npc, pc)
    return unless npc

    case event
    when "TRICKERY_TIMER"
      if npc.script_value?(1)
        npc.script_value = 0
        broadcast_npc_say(npc, Say2::NPC_ALL, TEXT.sample)
      end
    when "give1"
      return unless pc
      if npc.script_value?(1)
        html = "32737-04.html"
      elsif !has_quest_items?(pc, STONE_FRAGMENT)
        html = "32737-01.html"
      else
        npc.script_value = 1
        take_items(pc, STONE_FRAGMENT, 1)
        if rand(100) == 0
          give_items(pc, STONE_FRAGMENT, 100)
          broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::AMAZING_S1_TOOK_100_OF_THESE_SOUL_STONE_FRAGMENTS_WHAT_A_COMPLETE_SWINDLER, pc.name)
        else
          broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::HMM_HEY_DID_YOU_GIVE_S1_SOMETHING_BUT_IT_WAS_JUST_1_HAHA, pc.name)
        end
        start_quest_timer("TRICKERY_TIMER", 5000, npc, nil)
      end
    when "give5"
      return unless pc
      if npc.script_value?(1)
        html = "32737-04.html"
      elsif get_quest_items_count(pc, STONE_FRAGMENT) < 5
        html = "32737-02.html"
      else
        npc.script_value = 1
        take_items(pc, STONE_FRAGMENT, 5)
        chance = rand(100)
        if chance < 20
          broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::AHEM_S1_HAS_NO_LUCK_AT_ALL_TRY_PRAYING, pc.name)
        elsif chance < 80
          give_items(pc, STONE_FRAGMENT, 1)
          broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::ITS_BETTER_THAN_LOSING_IT_ALL_RIGHT_OR_DOES_THIS_FEEL_WORSE)
        else
          item_count = rand(10..16)
          give_items(pc, STONE_FRAGMENT, item_count)
          broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::S1_PULLED_ONE_WITH_S2_DIGITS_LUCKY_NOT_BAD, pc.name, item_count.to_s)
        end
        start_quest_timer("TRICKERY_TIMER", 5000, npc, nil)
      end
    when "give20"
      return unless pc
      if npc.script_value?(1)
        html = "32737-04.html"
      elsif get_quest_items_count(pc, STONE_FRAGMENT) < 20
        html = "32737-03.html"
      else
        npc.script_value = 1
        take_items(pc, STONE_FRAGMENT, 20)
        chance = rand(10000)
        if chance == 0
          give_items(pc, STONE_FRAGMENT, 10000)
          broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::AH_ITS_OVER_WHAT_KIND_OF_GUY_IS_THAT_DAMN_FINE_YOU_S1_TAKE_IT_AND_GET_OUTTA_HERE, pc.name)
        elsif chance < 10
          give_items(pc, STONE_FRAGMENT, 1)
          broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::YOU_DONT_FEEL_BAD_RIGHT_ARE_YOU_SAD_BUT_DONT_CRY)
        else
          give_items(pc, STONE_FRAGMENT, rand(1..100))
          broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::A_BIG_PIECE_IS_MADE_UP_OF_LITTLE_PIECES_SO_HERES_A_LITTLE_PIECE)
        end
        start_quest_timer("TRICKERY_TIMER", 5000, npc, nil)
      end
    end

    html
  end
end
