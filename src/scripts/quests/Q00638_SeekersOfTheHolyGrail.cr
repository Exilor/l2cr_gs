class Scripts::Q00638_SeekersOfTheHolyGrail < Quest
  private class DropInfo < ItemChanceHolder
    getter key_id, key_chance, key_count

    def initialize(item_id : Int32, chance : Float64)
      initialize(item_id, chance, 0, 0, 0)
    end

    def initialize(item_id : Int32, chance : Float64, key_id : Int32, key_chance : Int32, key_count : Int32)
      super(item_id, chance)

      @key_id = key_id
      @key_chance = key_chance
      @key_count = key_count
    end
  end

  # NPC
  private INNOCENTIN = 31328
  # Items
  private TOTEM = 8068
  private ANTEROOM_KEY = 8273
  private CHAPEL_KEY = 8274
  private KEY_OF_DARKNESS = 8275
  # Misc
  private MIN_LVL = 73
  private TOTEMS_REQUIRED_COUNT = 2000
  # Rewards
  private SCROLL_ENCHANT_W_S = 959
  private SCROLL_ENCHANT_A_S = 960
  # Mobs
  private MOBS_DROP_CHANCES = {
    22136 => DropInfo.new(TOTEM, 0.55), # Gatekeeper Zombie
    22137 => DropInfo.new(TOTEM, 0.06), # Penance Guard
    22138 => DropInfo.new(TOTEM, 0.06), # Chapel Guard
    22139 => DropInfo.new(TOTEM, 0.54), # Old Aristocrat's Soldier
    22140 => DropInfo.new(TOTEM, 0.54), # Zombie Worker
    22141 => DropInfo.new(TOTEM, 0.55), # Forgotten Victim
    22142 => DropInfo.new(TOTEM, 0.54), # Triol's Layperson
    22143 => DropInfo.new(TOTEM, 0.62, CHAPEL_KEY, 100, 1), # Triol's Believer
    22144 => DropInfo.new(TOTEM, 0.54), # Resurrected Temple Knight
    22145 => DropInfo.new(TOTEM, 0.53), # Ritual Sacrifice
    22146 => DropInfo.new(TOTEM, 0.54, KEY_OF_DARKNESS, 10, 1), # Triol's Priest
    22147 => DropInfo.new(TOTEM, 0.55), # Ritual Offering
    22148 => DropInfo.new(TOTEM, 0.45), # Triol's Believer
    22149 => DropInfo.new(TOTEM, 0.54, ANTEROOM_KEY, 100, 6), # Ritual Offering
    22150 => DropInfo.new(TOTEM, 0.46), # Triol's Believer
    22151 => DropInfo.new(TOTEM, 0.62, KEY_OF_DARKNESS, 10, 1), # Triol's Priest
    22152 => DropInfo.new(TOTEM, 0.55), # Temple Guard
    22153 => DropInfo.new(TOTEM, 0.54), # Temple Guard Captain
    22154 => DropInfo.new(TOTEM, 0.53), # Ritual Sacrifice
    22155 => DropInfo.new(TOTEM, 0.75), # Triol's High Priest
    22156 => DropInfo.new(TOTEM, 0.67), # Triol's Priest
    22157 => DropInfo.new(TOTEM, 0.66), # Triol's Priest
    22158 => DropInfo.new(TOTEM, 0.67), # Triol's Believer
    22159 => DropInfo.new(TOTEM, 0.75), # Triol's High Priest
    22160 => DropInfo.new(TOTEM, 0.67), # Triol's Priest
    22161 => DropInfo.new(TOTEM, 0.78), # Ritual Sacrifice
    22162 => DropInfo.new(TOTEM, 0.67), # Triol's Believer
    22163 => DropInfo.new(TOTEM, 0.87), # Triol's High Priest
    22164 => DropInfo.new(TOTEM, 0.67), # Triol's Believer
    22165 => DropInfo.new(TOTEM, 0.66), # Triol's Priest
    22166 => DropInfo.new(TOTEM, 0.66), # Triol's Believer
    22167 => DropInfo.new(TOTEM, 0.75), # Triol's High Priest
    22168 => DropInfo.new(TOTEM, 0.66), # Triol's Priest
    22169 => DropInfo.new(TOTEM, 0.78), # Ritual Sacrifice
    22170 => DropInfo.new(TOTEM, 0.67), # Triol's Believer
    22171 => DropInfo.new(TOTEM, 0.87), # Triol's High Priest
    22172 => DropInfo.new(TOTEM, 0.78), # Ritual Sacrifice
    22173 => DropInfo.new(TOTEM, 0.66), # Triol's Priest
    22174 => DropInfo.new(TOTEM, 0.67), # Triol's Priest
    22175 => DropInfo.new(TOTEM, 0.03), # Andreas' Captain of the Royal Guard
    22176 => DropInfo.new(TOTEM, 0.03), # Andreas' Royal Guards
    22188 => DropInfo.new(TOTEM, 0.03), # Andreas' Captain of the Royal Guard
    22189 => DropInfo.new(TOTEM, 0.03), # Andreas' Royal Guards
    22190 => DropInfo.new(TOTEM, 0.03), # Ritual Sacrifice
    22191 => DropInfo.new(TOTEM, 0.03), # Andreas' Captain of the Royal Guard
    22192 => DropInfo.new(TOTEM, 0.03), # Andreas' Royal Guards
    22193 => DropInfo.new(TOTEM, 0.03), # Andreas' Royal Guards
    22194 => DropInfo.new(TOTEM, 0.03), # Penance Guard
    22195 => DropInfo.new(TOTEM, 0.03) # Ritual Sacrifice
  }

  def initialize
    super(638, self.class.simple_name, "Seekers Of The Holy Grail")

    add_start_npc(INNOCENTIN)
    add_talk_id(INNOCENTIN)
    add_kill_id(MOBS_DROP_CHANCES.keys)
    register_quest_items(TOTEM)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "31328-03.htm"
      if qs.created?
        qs.start_quest
        html = event
      end
    when "31328-06.html"
      if qs.started?
        html = event
      end
    when "reward"
      if qs.started?
        if get_quest_items_count(pc, TOTEM) >= TOTEMS_REQUIRED_COUNT
          if Rnd.rand(100) < 80
            if Rnd.bool
              reward_items(pc, SCROLL_ENCHANT_A_S, 1)
            else
              reward_items(pc, SCROLL_ENCHANT_W_S, 1)
            end
            html = "31328-07.html"
          else
            give_adena(pc, 3576000, true)
            html = "31328-08.html"
          end
          take_items(pc, TOTEM, 2000)
        end
      end
    when "31328-09.html"
      if qs.started?
        qs.exit_quest(true, true)
        html = "31328-09.html"
      end
    else
      # automatically added
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    if qs = get_random_party_member_state(killer, -1, 3, npc)
      info = MOBS_DROP_CHANCES[npc.id]
      if give_item_randomly(qs.player, npc, info.id, 1, 0, info.chance, true)
        if info.key_id > 0 && Rnd.rand(100) < info.key_chance
          npc.drop_item(qs.player, info.key_id, info.key_count.to_i64)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    if qs.created?
      html = pc.level >= MIN_LVL ? "31328-01.htm" : "31328-02.htm"
    elsif qs.started?
      if get_quest_items_count(pc, TOTEM) >= TOTEMS_REQUIRED_COUNT
        html = "31328-04.html"
      else
        html = "31328-05.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end