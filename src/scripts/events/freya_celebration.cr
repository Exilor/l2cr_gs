require "./long_time_event"

class Scripts::FreyaCelebration < LongTimeEvent
  # NPC
  private FREYA = 13296
  # Items
  private FREYA_POTION = 15440
  private FREYA_GIFT = 17138
  # Misc
  private HOURS = 20

  private SKILLS = {
    9150,
    9151,
    9152,
    9153,
    9154,
    9155,
    9156
  }

  private FREYA_TEXT = {
    NpcString::EVEN_THOUGH_YOU_BRING_SOMETHING_CALLED_A_GIFT_AMONG_YOUR_HUMANS_IT_WOULD_JUST_BE_PROBLEMATIC_FOR_ME,
    NpcString::I_JUST_DONT_KNOW_WHAT_EXPRESSION_I_SHOULD_HAVE_IT_APPEARED_ON_ME_ARE_HUMANS_EMOTIONS_LIKE_THIS_FEELING,
    NpcString::THE_FEELING_OF_THANKS_IS_JUST_TOO_MUCH_DISTANT_MEMORY_FOR_ME,
    NpcString::BUT_I_KIND_OF_MISS_IT_LIKE_I_HAD_FELT_THIS_FEELING_BEFORE,
    NpcString::I_AM_ICE_QUEEN_FREYA_THIS_FEELING_AND_EMOTION_ARE_NOTHING_BUT_A_PART_OF_MELISSAA_MEMORIES
  }

  def initialize
    super(self.class.simple_name, "events")

    add_start_npc(FREYA)
    add_first_talk_id(FREYA)
    add_talk_id(FREYA)
    add_skill_see_id(FREYA)
  end

  def on_adv_event(event, npc, pc)
    if event.casecmp?("give_potion")
      pc = pc.not_nil!
      if pc.adena > 1
        curr_time = Time.ms
        value = load_global_quest_var(pc.account_name)
        reuse_time = value.empty? ? 0i64 : value.to_i64

        if curr_time > reuse_time
          take_items(pc, Inventory::ADENA_ID, 1)
          give_items(pc, FREYA_POTION, 1)
          save_global_quest_var(pc.account_name, (Time.ms &+ (HOURS &* 3_600_000)).to_s)
        else
          remaining_time = (reuse_time - Time.ms) // 1000
          hours = (remaining_time // 3600).to_i32
          minutes = ((remaining_time % 3600) // 60).to_i32
          sm = SystemMessage.available_after_s1_s2_hours_s3_minutes
          sm.add_item_name(FREYA_POTION)
          sm.add_int(hours)
          sm.add_int(minutes)
          pc.send_packet(sm)
        end
      else
        sm = SystemMessage.s2_unit_of_the_item_s1_required
        sm.add_item_name(Inventory::ADENA_ID)
        sm.add_int(1)
        pc.send_packet(sm)
      end
    end

    nil
  end

  def on_skill_see(npc, caster, skill, targets, is_summon)
    return unless caster && npc

    if npc.id == FREYA && targets.includes?(npc) && SKILLS.includes?(skill.id)
      if Rnd.rand(100) < 5
        cs = CreatureSay.new(npc.l2id, Say2::NPC_ALL, npc.name, NpcString::DEAR_S1_THINK_OF_THIS_AS_MY_APPRECIATION_FOR_THE_GIFT_TAKE_THIS_WITH_YOU_THERES_NOTHING_STRANGE_ABOUT_IT_ITS_JUST_A_BIT_OF_MY_CAPRICIOUSNESS)
        cs.add_string(caster.name)

        npc.broadcast_packet(cs)

        caster.add_item("FreyaCelebration", FREYA_GIFT, 1, npc, true)
      else
        if Rnd.rand(10) < 2
          npc.broadcast_packet(CreatureSay.new(npc.l2id, Say2::NPC_ALL, npc.name, FREYA_TEXT.sample))
        end
      end
    end

    super
  end

  def on_first_talk(npc, pc)
    "13296.htm"
  end
end
