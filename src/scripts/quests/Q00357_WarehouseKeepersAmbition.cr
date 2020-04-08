class Scripts::Q00357_WarehouseKeepersAmbition < Quest
  # NPC
  private SILVA = 30686
  # Item
  private JADE_CRYSTAL = 5867
  # Monsters
  private DROP_DATA = {
    20594 => 0.577, # Forest Runner
    20595 => 0.6,   # Fline Elder
    20596 => 0.638, # Liele Elder
    20597 => 0.062  # Valley Treant Elder
  }
  # Misc
  private MIN_LVL = 47

  def initialize
    super(357, self.class.simple_name, "Warehouse Keeper's Ambition")

    add_start_npc(SILVA)
    add_talk_id(SILVA)
    add_kill_id(DROP_DATA.keys)
    register_quest_items(JADE_CRYSTAL)
  end

  def on_adv_event(event, npc, player)
    return unless player

    if qs = get_quest_state(player, false)
      case event
      when "30686-01.htm", "30686-03.htm", "30686-04.htm", "30686-10.html"
        html = event
      when "30686-05.htm"
        if qs.created?
          qs.start_quest
          html = event
        end
      when "30686-09.html"
        crystal_count = get_quest_items_count(player, JADE_CRYSTAL)
        if crystal_count > 0
          adena = crystal_count * 425
          if crystal_count < 100
            adena += 13500
            html = "30686-08.html"
          else
            adena += 40500
            html = event
          end
          give_adena(player, adena, true)
          take_items(player, JADE_CRYSTAL, -1)
        end
      when "30686-11.html"
        crystal_count = get_quest_items_count(player, JADE_CRYSTAL)
        if crystal_count > 0
          adena = (crystal_count * 425) + (crystal_count >= 100 ? 40500 : 0)
          give_adena(player, adena, true)
          take_items(player, JADE_CRYSTAL, -1)
        end
        qs.exit_quest(true, true)
        html = event
      else
        # automatically added
      end

    end

    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      html = pc.level < MIN_LVL ? "30686-01.html" : "30686-02.htm"
    elsif qs.started?
      if has_quest_items?(pc, JADE_CRYSTAL)
        html = "30686-07.html"
      else
        html = "30686-06.html"
      end
    end

    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, killer, is_summon)
    if qs = get_random_party_member_state(killer, -1, 3, npc)
      give_item_randomly(qs.player, npc, JADE_CRYSTAL, 1, 0, DROP_DATA[npc.id], true)
    end

    super
  end
end