class Scripts::Q00254_LegendaryTales < Quest
  # NPC
  private GILMORE = 30754

  # Monsters
  class Bosses < EnumClass
    getter id
    protected initializer id: Int32

    add(EMERALD_HORN, 25718)
    add(DUST_RIDER, 25719)
    add(BLEEDING_FLY, 25720)
    add(BLACK_DAGGER, 25721)
    add(SHADOW_SUMMONER, 25722)
    add(SPIKE_SLASHER, 25723)
    add(MUSCLE_BOMBER, 25724)

    def self.value_of(npc_id : Int32) : Bosses?
      find { |val| val.id == npc_id }
    end
  end

  private MONSTERS = {
    Bosses::EMERALD_HORN.id, Bosses::DUST_RIDER.id, Bosses::BLEEDING_FLY.id,
    Bosses::BLACK_DAGGER.id, Bosses::SHADOW_SUMMONER.id,
    Bosses::SPIKE_SLASHER.id, Bosses::MUSCLE_BOMBER.id
  }

  # Items
  private LARGE_DRAGON_SKULL = 17249

  # Misc
  private MIN_LEVEL = 80

  def initialize
    super(254, self.class.simple_name, "Legendary Tales")

    add_start_npc(GILMORE)
    add_talk_id(GILMORE)
    add_kill_id(MONSTERS)
    register_quest_items(LARGE_DRAGON_SKULL)
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case st.state
    when State::CREATED
      html = pc.level < MIN_LEVEL ? "30754-00.htm" : "30754-01.htm"
    when State::STARTED
      count = get_quest_items_count(pc, LARGE_DRAGON_SKULL)
      if st.cond?(1)
        html = count > 0 ? "30754-14.htm" : "30754-06.html"
      elsif st.cond?(2)
        html = count < 7 ? "30754-12.htm" : "30754-07.html"
      end
    when State::COMPLETED
      html = "30754-29.html"
    end

    html || get_no_quest_msg(pc)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30754-05.html"
      st.start_quest
      st.set("raids", 0)
    when "30754-02.html", "30754-03.html", "30754-04.htm", "30754-08.html",
         "30754-15.html", "30754-20.html", "30754-21.html"
      html = event
    when "25718" # Emerald Horn
      html = check_mask(st, Bosses::EMERALD_HORN) ? "30754-22.html" : "30754-16.html"
    when "25719" # Dust Rider
      html = check_mask(st, Bosses::DUST_RIDER) ? "30754-23.html" : "30754-17.html"
    when "25720" # Bleeding Fly
      html = check_mask(st, Bosses::BLEEDING_FLY) ? "30754-24.html" : "30754-18.html"
    when "25721" # Black Dagger Wing
      html = check_mask(st, Bosses::BLACK_DAGGER) ? "30754-25.html" : "30754-19.html"
    when "25722" # Shadow Summoner
      html = check_mask(st, Bosses::SHADOW_SUMMONER) ? "30754-26.html" : "30754-16.html"
    when "25723" # Spike Slasher
      html = check_mask(st, Bosses::SPIKE_SLASHER) ? "30754-27.html" : "30754-17.html"
    when "25724" # Muscle Bomber
      html = check_mask(st, Bosses::MUSCLE_BOMBER) ? "30754-28.html" : "30754-18.html"
    when "13467", # Vesper Thrower
         "13466", # Vesper Singer
         "13465", # Vesper Caster
         "13464", # Vesper Retributer
         "13463", # Vesper Avenger
         "13457", # Vesper Cutter
         "13458", # Vesper Slasher
         "13459", # Vesper Buster
         "13460", # Vesper Sharper
         "13461", # Vesper Fighter
         "13462"  # Vesper Stormer
      if st.cond?(2) && get_quest_items_count(pc, LARGE_DRAGON_SKULL) >= 7
        html = "30754-09.html"
        reward_items(pc, event.to_i, 1)
        st.exit_quest(false, true)
      end
    end

    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, pc, is_pet)
    if party = pc.party?
      party.members.each do |m|
        action_for_each_player(m, npc, false)
      end
    else
      action_for_each_player(pc, npc, false)
    end

    super
  end

  def action_for_each_player(pc, npc, is_summon)
    st = pc.get_quest_state(self.class.simple_name)

    if st && st.cond?(1)
      raids = st.get_int("raids")
      unless boss = Bosses.value_of(npc.id)
        raise "Boss with npc_id #{npc.id} not found in enum Bosses"
      end

      unless check_mask(st, boss)
        st.set("raids", raids | boss.mask)
        st.give_items(LARGE_DRAGON_SKULL, 1)

        if st.get_quest_items_count(LARGE_DRAGON_SKULL) < 7
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        else
          st.set_cond(2, true)
        end
      end
    end
  end

  private def check_mask(qs, boss)
    pos = boss.mask
    qs.get_int("raids") & pos == pos
  end
end
