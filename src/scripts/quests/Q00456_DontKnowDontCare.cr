class Scripts::Q00456_DontKnowDontCare < Quest
  # NPCs
  private SEPARATED_SOUL = {
    32864, 32865, 32866, 32867, 32868, 32869, 32870, 32891
  }
  private DRAKE_LORD_CORPSE = 32884
  private BEHEMOTH_LEADER_CORPSE = 32885
  private DRAGON_BEAST_CORPSE = 32886
  # Items
  private DRAKE_LORD_ESSENCE = 17251
  private BEHEMOTH_LEADER_ESSENCE = 17252
  private DRAGON_BEAST_ESSENCE = 17253
  # Misc
  private MIN_PLAYERS = 18
  private MIN_LEVEL = 80
  private MONSTER_NPCS = {
    25725 => DRAKE_LORD_CORPSE,
    25726 => BEHEMOTH_LEADER_CORPSE,
    25727 => DRAGON_BEAST_CORPSE
  }
  private MONSTER_ESSENCES = {
    DRAKE_LORD_CORPSE => DRAKE_LORD_ESSENCE,
    BEHEMOTH_LEADER_CORPSE => BEHEMOTH_LEADER_ESSENCE,
    DRAGON_BEAST_CORPSE => DRAGON_BEAST_ESSENCE
  }
  private TIMER_UNSPAWN_RAID_CORPSE = "TIMER_UNSPAWN_RAID_CORPSE"

  # Rewards
  private WEAPONS = {
    15558, # Periel Sword
    15559, # Skull Edge
    15560, # Vigwik Axe
    15561, # Devilish Maul
    15562, # Feather Eye Blade
    15563, # Octo Claw
    15564, # Doubletop Spear
    15565, # Rising Star
    15566, # Black Visage
    15567, # Veniplant Sword
    15568, # Skull Carnium Bow
    15569, # Gemtail Rapier
    15570, # Finale Blade
    15571  # Dominion Crossbow
  }
  private ARMOR = {
    15743, # Sealed Vorpal Helmet
    15746, # Sealed Vorpal Breastplate
    15749, # Sealed Vorpal Gaiters
    15752, # Sealed Vorpal Gauntlets
    15755, # Sealed Vorpal Boots
    15758, # Sealed Vorpal Shield
    15744, # Sealed Vorpal Leather Helmet
    15747, # Sealed Vorpal Leather Breastplate
    15750, # Sealed Vorpal Leather Leggings
    15753, # Sealed Vorpal Leather Gloves
    15756, # Sealed Vorpal Leather Boots
    15745, # Sealed Vorpal Circlet
    15748, # Sealed Vorpal Tunic
    15751, # Sealed Vorpal Stockings
    15754, # Sealed Vorpal Gloves
    15757, # Sealed Vorpal Shoes
    15759  # Sealed Vorpal Sigil
  }
  private ACCESSORIES = {
    15763, # Sealed Vorpal Ring
    15764, # Sealed Vorpal Earring
    15765  # Sealed Vorpal Necklace
  }
  private ATTRIBUTE_CRYSTALS = {
    9552, # Fire Crystal
    9553, # Water Crystal
    9554, # Earth Crystal
    9555, # Wind Crystal
    9556, # Dark Crystal
    9557  # Holy Crystal
  }
  private BLESSED_SCROLL_ENCHANT_WEAPON_S = 6577
  private BLESSED_SCROLL_ENCHANT_ARMOR_S = 6578
  private SCROLL_ENCHANT_WEAPON_S = 959
  private GEMSTONE_S = 2134
  private ALLOWED_PLAYER_MAP = {} of Int32 => Set(Int32)

  def initialize
    super(456, self.class.simple_name, "Don't Know, Don't Care")

    add_start_npc(SEPARATED_SOUL)
    add_talk_id(SEPARATED_SOUL)
    add_first_talk_id(
      DRAKE_LORD_CORPSE, BEHEMOTH_LEADER_CORPSE, DRAGON_BEAST_CORPSE
    )
    add_talk_id(DRAKE_LORD_CORPSE, BEHEMOTH_LEADER_CORPSE, DRAGON_BEAST_CORPSE)
    add_kill_id(MONSTER_NPCS.keys)
    register_quest_items(
      DRAKE_LORD_ESSENCE, BEHEMOTH_LEADER_ESSENCE, DRAGON_BEAST_ESSENCE
    )
  end

  def on_first_talk(npc, pc)
    return unless pc
    qs = get_quest_state(pc, false)
    allowed = ALLOWED_PLAYER_MAP[npc.l2id]?

    if qs.nil? || !qs.cond?(1)
      return "#{npc.id}-02.html"
    end

    if allowed.nil? || !allowed.includes?(pc.l2id)
      return "#{npc.id}-02.html"
    end

    essence = MONSTER_ESSENCES[npc.id]

    if has_quest_items?(pc, essence)
      html = "#{npc.id}-03.html"
    else
      give_items(pc, essence, 1)
      html = "#{npc.id}-01.html"

      if has_quest_items?(pc, registered_item_ids)
        qs.set_cond(2, true)
      else
        play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if SEPARATED_SOUL.includes?(npc.id)
      case qs.state
      when State::COMPLETED
        unless qs.now_available?
          html = "32864-02.html"
        end
        qs.state = State::CREATED
        # intentional fall-through
      when State::CREATED
        html = pc.level >= MIN_LEVEL ? "32864-01.htm" : "32864-03.html"
      when State::STARTED
        case qs.cond
        when 1
          if has_at_least_one_quest_item?(pc, registered_item_ids)
            html = "32864-09.html"
          else
            html = "32864-08.html"
          end
        when 2
          if has_quest_items?(pc, registered_item_ids)
            reward_player(pc, npc)
            qs.exit_quest(QuestType::DAILY, true)
            html = "32864-10.html"
          end
        end
      end
    end

    html || get_no_quest_msg(pc)
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!

    if pc
      qs = get_quest_state(pc, false)
    end

    case event
    when "32864-04.htm", "32864-05.htm", "32864-06.htm"
      if qs && qs.created?
        html = event
      end
    when "32864-07.htm"
      if qs && qs.created?
        qs.start_quest
        html = event
      end
    when TIMER_UNSPAWN_RAID_CORPSE
      ALLOWED_PLAYER_MAP.delete(npc.l2id)
      npc.delete_me
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    unless (party = killer.party) && (cc = party.command_channel)
      return super
    end

    if cc.size < MIN_PLAYERS
      return super
    end

    allowed_players = Set(Int32).new

    npc.as(L2Attackable).aggro_list.each_value do |aggro|
      unless attacker = aggro.attacker.as?(L2PcInstance)
        next
      end

      if party2 = attacker.party
        if party2.in_command_channel?  && party2.command_channel == cc # only players from the same cc are allowed
          if Util.in_range?(1500, npc, attacker, true)
            allowed_players << attacker.l2id
          end
        end
      end
    end

    unless allowed_players.empty?
      # This depends on the boss respawn delay being at least 5 minutes.
      spawned = add_spawn(MONSTER_NPCS[npc.id], npc, true, 0)
      ALLOWED_PLAYER_MAP[spawned.l2id] = allowed_players
      start_quest_timer(TIMER_UNSPAWN_RAID_CORPSE, 300000, npc, nil)
    end

    super
  end

  private def reward_player(pc, npc)
    chance = Rnd.rand(10000)
    count = 1

    if chance < 170
      reward = ARMOR.sample(random: Rnd)
    elsif chance < 200
      reward = ACCESSORIES.sample(random: Rnd)
    elsif chance < 270
      reward = WEAPONS.sample(random: Rnd)
    elsif chance < 325
      reward = BLESSED_SCROLL_ENCHANT_WEAPON_S
    elsif chance < 425
      reward = BLESSED_SCROLL_ENCHANT_ARMOR_S
    elsif chance < 925
      reward = ATTRIBUTE_CRYSTALS.sample(random: Rnd)
    elsif chance < 1100
      reward = SCROLL_ENCHANT_WEAPON_S
    else
      reward = GEMSTONE_S
      count = 3
    end

    give_items(pc, reward, count)
    item = ItemTable[reward]
    say = NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::S1_RECEIVED_A_S2_ITEM_AS_A_REWARD_FROM_THE_SEPARATED_SOUL)
    say.add_string_parameter(pc.name)
    say.add_string_parameter(item.name)
    npc.broadcast_packet(say)
  end
end
