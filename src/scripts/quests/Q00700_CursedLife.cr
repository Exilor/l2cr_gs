class Scripts::Q00700_CursedLife < Quest
  # NPC
  private ORBYU = 32560
  # Monsters
  private ROK = 25624
  private MONSTERS = {
    22602 => {15, 139, 965}, # Mutant Bird lvl 1
    22603 => {15, 143, 999}, # Mutant Bird lvl 2
    25627 => {14, 125, 993}, # Mutant Bird lvl 3
    22604 => { 5,  94, 994}, # Dra Hawk lvl 1
    22605 => { 5,  99, 993}, # Dra Hawk lvl 2
    25628 => { 3,  73, 991}  # Dra Hawk lvl 3
  }
  # Items
  private SWALLOWED_BONES = 13874
  private SWALLOWED_STERNUM = 13873
  private SWALLOWED_SKULL = 13872
  # Misc
  private MIN_LVL = 75
  private SWALLOWED_BONES_ADENA = 500
  private SWALLOWED_STERNUM_ADENA = 5000
  private SWALLOWED_SKULL_ADENA = 50000
  private BONUS = 16670

  def initialize
    super(700, self.class.simple_name, "Cursed Life")

    add_start_npc(ORBYU)
    add_talk_id(ORBYU)
    add_kill_id(ROK)
    add_kill_id(MONSTERS.keys)
    register_quest_items(SWALLOWED_BONES, SWALLOWED_STERNUM, SWALLOWED_SKULL)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "32560-02.htm"
      st = pc.get_quest_state(Q10273_GoodDayToFly.simple_name)
      if pc.level < MIN_LVL || (st.nil? || !st.completed?)
        html = "32560-03.htm"
      else
        html = event
      end
    when "32560-04.htm", "32560-09.html"
      html = event
    when "32560-05.htm"
      st.start_quest
      html = event
    when "32560-10.html"
      st.exit_quest(true, true)
      html = event
    end


    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = "32560-01.htm"
    when State::STARTED
      bones = st.get_quest_items_count(SWALLOWED_BONES)
      ribs = st.get_quest_items_count(SWALLOWED_STERNUM)
      skulls = st.get_quest_items_count(SWALLOWED_SKULL)
      sum = bones + ribs + skulls
      if sum > 0
        adena = bones * SWALLOWED_BONES_ADENA
        adena += ribs * SWALLOWED_STERNUM_ADENA
        adena += skulls * SWALLOWED_SKULL_ADENA
        if sum >= 10
          adena += BONUS
        end
        st.give_adena(adena, true)
        take_items(pc, -1, {SWALLOWED_BONES, SWALLOWED_STERNUM, SWALLOWED_SKULL})
        html = sum < 10 ? "32560-07.html" : "32560-08.html"
      else
        html = "32560-06.html"
      end
    end


    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, pc, is_summon)
    if st = get_quest_state(pc, false)
      if npc.id == ROK
        amount = 0
        chance = Rnd.rand(1000)
        if chance < 700
          amount = 1
        elsif chance < 885
          amount = 2
        elsif chance < 949
          amount = 3
        elsif chance < 966
          amount = Rnd.rand(5) + 4
        elsif chance < 985
          amount = Rnd.rand(9) + 4
        elsif chance < 993
          amount = Rnd.rand(7) + 13
        elsif chance < 997
          amount = Rnd.rand(15) + 9
        elsif chance < 999
          amount = Rnd.rand(23) + 53
        else
          amount = Rnd.rand(49) + 76
        end
        st.give_items(SWALLOWED_BONES, amount)
        chance = Rnd.rand(1000)
        if chance < 520
          amount = 1
        elsif chance < 771
          amount = 2
        elsif chance < 836
          amount = 3
        elsif chance < 985
          amount = Rnd.rand(2) + 4
        elsif chance < 995
          amount = Rnd.rand(4) + 5
        else
          amount = Rnd.rand(8) + 6
        end
        st.give_items(SWALLOWED_STERNUM, amount)
        chance = Rnd.rand(1000)
        if chance < 185
          amount = Rnd.rand(2) + 1
        elsif chance < 370
          amount = Rnd.rand(6) + 2
        elsif chance < 570
          amount = Rnd.rand(6) + 7
        elsif chance < 850
          amount = Rnd.rand(6) + 12
        else
          amount = Rnd.rand(6) + 17
        end
        st.give_items(SWALLOWED_SKULL, amount)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      else
        chances = MONSTERS[npc.id]
        chance = Rnd.rand(1000)
        if chance < chances[0]
          st.give_items(SWALLOWED_BONES, 1)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        elsif chance < chances[1]
          st.give_items(SWALLOWED_STERNUM, 1)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        elsif chance < chances[2]
          st.give_items(SWALLOWED_SKULL, 1)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end
end
