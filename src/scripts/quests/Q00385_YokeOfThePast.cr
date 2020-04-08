class Scripts::Q00385_YokeOfThePast < Quest
  private ZIGGURATS = {
    31095, 31096, 31097, 31098, 31099, 31100, 31101,
    31102, 31103, 31104, 31105, 31106, 31107, 31108,
    31109, 31110, 31114, 31115, 31116, 31117, 31118,
    31119, 31120, 31121, 31122, 31123, 31124, 31125
  }

  private SCROLL_OF_ANCIENT_MAGIC = 5902
  private BLANK_SCROLL = 5965
  private MIN_LVL = 20

  private MONSTER_CHANCES = {
    21144 => 0.306, # Catacomb Shadow
    21156 => 0.994, # Purgatory Shadow
    21208 => 0.146, # Hallowed Watchman
    21209 => 0.166, # Hallowed Seer
    21210 => 0.202, # Vault Guardian
    21211 => 0.212, # Vault Seer
    21213 => 0.274, # Hallowed Monk
    21214 => 0.342, # Vault Sentinel
    21215 => 0.360, # Vault Monk
    21217 => 0.460, # Hallowed Priest
    21218 => 0.558, # Vault Overlord
    21219 => 0.578, # Vault Priest
    21221 => 0.710, # Sepulcher Inquisitor
    21222 => 0.842, # Sepulcher Archon
    21223 => 0.862, # Sepulcher Inquisitor
    21224 => 0.940, # Sepulcher Guardian
    21225 => 0.970, # Sepulcher Sage
    21226 => 0.202, # Sepulcher Guardian
    21227 => 0.290, # Sepulcher Sage
    21228 => 0.316, # Sepulcher Guard
    21229 => 0.426, # Sepulcher Preacher
    21230 => 0.646, # Sepulcher Guard
    21231 => 0.654, # Sepulcher Preacher
    21236 => 0.238, # Barrow Sentinel
    21237 => 0.274, # Barrow Monk
    21238 => 0.342, # Grave Sentinel
    21239 => 0.360, # Grave Monk
    21240 => 0.410, # Barrow Overlord
    21241 => 0.460, # Barrow Priest
    21242 => 0.558, # Grave Overlord
    21243 => 0.578, # Grave Priest
    21244 => 0.642, # Crypt Archon
    21245 => 0.700, # Crypt Inquisitor
    21246 => 0.842, # Tomb Archon
    21247 => 0.862, # Tomb Inquisitor
    21248 => 0.940, # Crypt Guardian
    21249 => 0.970, # Crypt Sage
    21250 => 0.798, # Tomb Guardian
    21251 => 0.710, # Tomb Sage
    21252 => 0.684, # Crypt Guard
    21253 => 0.574, # Crypt Preacher
    21254 => 0.354, # Tomb Guard
    21255 => 0.250  # Tomb Preacher
  }

  def initialize
    super(385, self.class.simple_name, "Yoke of the Past")

    add_start_npc(ZIGGURATS)
    add_talk_id(ZIGGURATS)
    add_kill_id(MONSTER_CHANCES.keys)
    register_quest_items(SCROLL_OF_ANCIENT_MAGIC)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ziggurat-03.htm", "ziggurat-04.htm", "ziggurat-06.htm",
         "ziggurat-07.htm"
      event
    when "ziggurat-05.htm"
      if qs.created?
        qs.start_quest
      end
      event
    when "ziggurat-10.html"
      qs.exit_quest(true, true)
      event
    else
      # automatically added
    end

  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    case qs.state
    when State::CREATED
      html = pc.level >= MIN_LVL ? "ziggurat-01.htm" : "ziggurat-02.htm"
    when State::STARTED
      if has_quest_items?(pc, SCROLL_OF_ANCIENT_MAGIC)
        reward_items(
          pc,
          BLANK_SCROLL,
          get_quest_items_count(pc, SCROLL_OF_ANCIENT_MAGIC)
        )
        take_items(pc, SCROLL_OF_ANCIENT_MAGIC, -1)
        html = "ziggurat-09.html"
      else
        html = "ziggurat-08.html"
      end
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, killer, is_summon)
    if qs = get_random_party_member_state(killer, -1, 3, npc)
      give_item_randomly(
        qs.player,
        npc,
        SCROLL_OF_ANCIENT_MAGIC,
        1,
        0,
        MONSTER_CHANCES[npc.id],
        true
      )
    end

    super
  end
end