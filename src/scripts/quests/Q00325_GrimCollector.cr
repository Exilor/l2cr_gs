class Scripts::Q00325_GrimCollector < Quest
  # NPCs
  private GUARD_CURTIS = 30336
  private VARSAK = 30342
  private SAMED = 30434
  # Items
  private ANATOMY_DIAGRAM = 1349
  private ZOMBIE_HEAD = 1350
  private ZOMBIE_HEART = 1351
  private ZOMBIE_LIVER = 1352
  private SKULL = 1353
  private RIB_BONE = 1354
  private SPINE = 1355
  private ARM_BONE = 1356
  private THIGH_BONE = 1357
  private COMPLETE_SKELETON = 1358
  # Misc
  private MIN_LEVEL = 15
  # Monsters
  private MONSTER_DROPS = {
    20026 => {
      QuestItemHolder.new(ZOMBIE_HEAD, 30),
      QuestItemHolder.new(ZOMBIE_HEART, 50),
      QuestItemHolder.new(ZOMBIE_LIVER, 75)
    },
    20029 => {
      QuestItemHolder.new(ZOMBIE_HEAD, 30),
      QuestItemHolder.new(ZOMBIE_HEART, 52),
      QuestItemHolder.new(ZOMBIE_LIVER, 75)
    },
    20035 => {
      QuestItemHolder.new(SKULL, 5),
      QuestItemHolder.new(RIB_BONE, 15),
      QuestItemHolder.new(SPINE, 29),
      QuestItemHolder.new(THIGH_BONE, 79)
    },
    20042 => {
      QuestItemHolder.new(SKULL, 6),
      QuestItemHolder.new(RIB_BONE, 19),
      QuestItemHolder.new(ARM_BONE, 69),
      QuestItemHolder.new(THIGH_BONE, 86)
    },
    20045 => {
      QuestItemHolder.new(SKULL, 9),
      QuestItemHolder.new(SPINE, 59),
      QuestItemHolder.new(ARM_BONE, 77),
      QuestItemHolder.new(THIGH_BONE, 97)
    },
    20051 => {
      QuestItemHolder.new(SKULL, 9),
      QuestItemHolder.new(RIB_BONE, 59),
      QuestItemHolder.new(SPINE, 79),
      QuestItemHolder.new(ARM_BONE, 100)
    },
    20457 => {
      QuestItemHolder.new(ZOMBIE_HEAD, 40),
      QuestItemHolder.new(ZOMBIE_HEART, 60),
      QuestItemHolder.new(ZOMBIE_LIVER, 80)
    },
    20458 => {
      QuestItemHolder.new(ZOMBIE_HEAD, 40),
      QuestItemHolder.new(ZOMBIE_HEART, 70),
      QuestItemHolder.new(ZOMBIE_LIVER, 100)
    },
    20514 => {
      QuestItemHolder.new(SKULL, 6),
      QuestItemHolder.new(RIB_BONE, 21),
      QuestItemHolder.new(SPINE, 30),
      QuestItemHolder.new(ARM_BONE, 31),
      QuestItemHolder.new(THIGH_BONE, 64)
    },
    20515 => {
      QuestItemHolder.new(SKULL, 5),
      QuestItemHolder.new(RIB_BONE, 20),
      QuestItemHolder.new(SPINE, 31),
      QuestItemHolder.new(ARM_BONE, 33),
      QuestItemHolder.new(THIGH_BONE, 69)
    }
  }

  private SKELETON_PARTS = {SPINE, ARM_BONE, SKULL, RIB_BONE, THIGH_BONE}

  def initialize
    super(325, self.class.simple_name, "Grim Collector")

    add_start_npc(GUARD_CURTIS)
    add_talk_id(GUARD_CURTIS, VARSAK, SAMED)
    add_kill_id(MONSTER_DROPS.keys)
    register_quest_items(
      ANATOMY_DIAGRAM, ZOMBIE_HEAD, ZOMBIE_HEART, ZOMBIE_LIVER, SKULL, RIB_BONE,
      SPINE, ARM_BONE, THIGH_BONE, COMPLETE_SKELETON
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "30336-03.htm"
      if st.created?
        st.start_quest
        html = event
      end
    when "assembleSkeleton"
      if !has_quest_items?(pc, SPINE, ARM_BONE, SKULL, RIB_BONE, THIGH_BONE)
        html = "30342-02.html"
      else
        take_items(pc, 1, SKELETON_PARTS)
        if Rnd.rand(5) < 4
          give_items(pc, COMPLETE_SKELETON, 1)
          html = "30342-03.html"
        else
          html = "30342-04.html"
        end
      end
    when "30434-02.htm"
      html = event
    when "30434-03.html"
      st.give_items(ANATOMY_DIAGRAM, 1)
      html = event
    when "30434-06.html", "30434-07.html"
      # if has_quest_items?(pc, registered_item_ids) # original L2J
      if has_at_least_one_quest_item?(pc, registered_item_ids) # custom
        head = st.get_quest_items_count(ZOMBIE_HEAD).to_i64
        heart = st.get_quest_items_count(ZOMBIE_HEART).to_i64
        liver = st.get_quest_items_count(ZOMBIE_LIVER).to_i64
        skull = st.get_quest_items_count(SKULL).to_i64
        rib = st.get_quest_items_count(RIB_BONE).to_i64
        spine = st.get_quest_items_count(SPINE).to_i64
        arm = st.get_quest_items_count(ARM_BONE).to_i64
        thigh = st.get_quest_items_count(THIGH_BONE).to_i64
        complete = st.get_quest_items_count(COMPLETE_SKELETON).to_i64
        total_count = head + heart + liver + skull + rib + spine + arm + thigh + complete

        if total_count > 0
          sum = (head * 30) + (heart * 20) + (liver * 20) + (skull * 100)
          sum += (rib * 40) + (spine * 14) + (arm * 14) + (thigh * 14)

          if total_count >= 10
            sum += 1629
          end

          if complete > 0
            sum += 543 + (complete * 341)
          end

          st.give_adena(sum, true)
        end

        take_items(pc, -1, registered_item_ids)
      end

      if event == "30434-06.html"
        st.exit_quest(true, true)
      end

      html = event
    when "30434-09.html"
      complete = st.get_quest_items_count(COMPLETE_SKELETON)
      if complete > 0
        st.give_adena(((complete * 341) + 543), true)
        st.take_items(COMPLETE_SKELETON, -1)
      end
    else
      # [automatically added else]
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)

    if qs.nil? || !qs.started?
      return super
    end

    unless Util.in_range?(1500, killer, npc, true)
      return super
    end

    unless qs.has_quest_items?(ANATOMY_DIAGRAM)
      return super
    end

    rnd = Rnd.rand(100)
    MONSTER_DROPS[npc.id].each do |drop|
      if rnd < drop.chance
        qs.give_item_randomly(npc, drop.id, 1, 0, 1.0, true)
        break
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when GUARD_CURTIS
      case st.state
      when State::CREATED
        html = pc.level >= MIN_LEVEL ? "30336-02.htm" : "30336-01.htm"
      when State::STARTED
        if st.has_quest_items?(ANATOMY_DIAGRAM)
          html = "30336-05.html"
        else
          html = "30336-04.html"
        end
      else
        # [automatically added else]
      end
    when VARSAK
      if st.started? && st.has_quest_items?(ANATOMY_DIAGRAM)
        html = "30342-01.html"
      end
    when SAMED
      if st.started?
        if !st.has_quest_items?(ANATOMY_DIAGRAM)
          html = "30434-01.html"
        else
          if !has_at_least_one_quest_item?(pc, registered_item_ids)
            html = "30434-04.html"
          elsif !st.has_quest_items?(COMPLETE_SKELETON)
            html = "30434-05.html"
          else
            html = "30434-08.html"
          end
        end
      end
    else
      # [automatically added else]
    end

    html || get_no_quest_msg(pc)
  end
end
