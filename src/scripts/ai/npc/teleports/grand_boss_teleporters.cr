class Scripts::GrandBossTeleporters < AbstractNpcAI
  # NPCS
  private NPCS = {
    31384, # Gatekeeper of Fire Dragon : Opening some doors
    31385, # Heart of Volcano : Teleport into Lair of Valakas
    31540, # Watcher of Valakas Klein : Teleport into Hall of Flames
    31686, # Gatekeeper of Fire Dragon : Opens doors to Heart of Volcano
    31687, # Gatekeeper of Fire Dragon : Opens doors to Heart of Volcano
    31759  # Teleportation Cubic : Teleport out of Lair of Valakas
  }
  # Items
  private VACUALITE_FLOATING_STONE = 7267
  private ENTER_HALL_OF_FLAMES = Location.new(183813, -115157, -3303)
  private TELEPORT_INTO_VALAKAS_LAIR = Location.new(204328, -111874, 70)
  private TELEPORT_OUT_OF_VALAKAS_LAIR = Location.new(150037, -57720, -2976)

  @player_count = 0

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    html = ""
    st = get_quest_state!(pc, false)

    if has_quest_items?(pc, VACUALITE_FLOATING_STONE)
      pc.tele_to_location(ENTER_HALL_OF_FLAMES)
      st.set("allowEnter", "1")
    else
      html = "31540-06.htm"
    end

    html
  end

  def on_talk(npc, pc)
    html = ""
    st = get_quest_state!(pc)

    case npc.id
    when 31385
      if ai = valakas_ai()
        status = GrandBossManager.get_boss_status(29028)

        if status == 0 || status == 1
          if @player_count >= 200
            html = "31385-03.htm"
          elsif st.get_int("allowEnter") == 1
            st.unset("allowEnter")

            if zone = GrandBossManager.get_zone(212852, -114842, -1632)
              zone.allow_player_entry(pc, 30)
            else
              warn { "Grand boss zone at 212852 -114842 -1632 not found." }
            end

            x = TELEPORT_INTO_VALAKAS_LAIR.x + rand(600)
            y = TELEPORT_INTO_VALAKAS_LAIR.y + rand(600)
            z = TELEPORT_INTO_VALAKAS_LAIR.z
            pc.tele_to_location(x, y, z)

            @player_count += 1

            if status == 0
              valakas = GrandBossManager.get_boss(29028)
              wait_time = Config.valakas_wait_time * 60000
              ai.start_quest_timer("beginning", wait_time, valakas, nil)
              GrandBossManager.set_boss_status(29028, 1)
            end
          else
            html = "31385-04.htm"
          end
        elsif status == 2
          html = "31385-02.htm"
        else
          html = "31385-01.htm"
        end
      else
        html = "31385-01.htm"
      end
    when 31384
      DoorData.get_door!(24210004).open_me
    when 31686
      DoorData.get_door!(24210006).open_me
    when 31687
      DoorData.get_door!(24210005).open_me
    when 31540
      if @player_count < 50
        html = "31540-01.htm"
      elsif @player_count < 100
        html = "31540-02.htm"
      elsif @player_count < 150
        html = "31540-03.htm"
      elsif @player_count < 200
        html = "31540-04.htm"
      else
        html = "31540-05.htm"
      end
    when 31759
      x = TELEPORT_OUT_OF_VALAKAS_LAIR.x + rand(500)
      y = TELEPORT_OUT_OF_VALAKAS_LAIR.y + rand(500)
      z = TELEPORT_OUT_OF_VALAKAS_LAIR.z
      pc.tele_to_location(x, y, z)
    end

    html
  end

  private def valakas_ai
    QuestManager.get_quest(Valakas.simple_name)
  end
end
