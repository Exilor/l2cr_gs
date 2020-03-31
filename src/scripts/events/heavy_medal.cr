class Scripts::HeavyMedal < LongTimeEvent
  private CAT_ROY = 31228
  private CAT_WINNIE = 31229
  private GLITTERING_MEDAL = 6393

  private WIN_CHANCE = 50

  private MEDALS = {
    5,
    10,
    20,
    40
  }
  private BADGES = {
    6399,
    6400,
    6401,
    6402
  }

  def initialize
    super(self.class.simple_name, "events")

    add_start_npc(CAT_ROY, CAT_WINNIE)
    add_talk_id(CAT_ROY, CAT_WINNIE)
    add_first_talk_id(CAT_ROY, CAT_WINNIE)
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!
    pc = pc.not_nil!

    html = event
    level = check_level(pc)

    if event.casecmp?("game")
      if get_quest_items_count(pc, GLITTERING_MEDAL) < MEDALS[level]
        html = "31229-no.htm"
      else
        html = "31229-game.htm"
      end
    elsif event.casecmp?("heads") || event.casecmp?("tails")
      if get_quest_items_count(pc, GLITTERING_MEDAL) < MEDALS[level]
        html = "31229-#{event.downcase}-10.htm"
      else
        take_items(pc, GLITTERING_MEDAL, MEDALS[level])

        if Rnd.rand(100) > WIN_CHANCE
          level = 0
        else
          if level > 0
            take_items(pc, BADGES[level - 1], -1)
          end
          give_items(pc, BADGES[level], 1)
          play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
          level += 1
        end

        html = "31229-#{event.downcase}-#{level}.htm"
      end
    elsif event.casecmp?("talk")
      html = "#{npc.id}-lvl-#{level}.htm"
    end

    html
  end

  def on_first_talk(npc, pc)
    unless pc.get_quest_state(name)
      new_quest_state(pc)
    end

    "#{npc.id}.htm"
  end

  def check_level(pc)
    if has_quest_items?(pc, 6402)
      return 4
    elsif has_quest_items?(pc, 6401)
      return 3
    elsif has_quest_items?(pc, 6400)
      return 2
    elsif has_quest_items?(pc, 6399)
      return 1
    end

    0
  end
end
