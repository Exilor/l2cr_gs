class Scripts::Nottingale < AbstractNpcAI
  # NPC
  private NOTTINGALE = 32627
  # Misc
  private RADARS = {
    2  => RadarControl.new(0, -184545, 243120, 1581, 2),
    5  => RadarControl.new(0, -192361, 254528, 3598, 1),
    6  => RadarControl.new(0, -174600, 219711, 4424, 1),
    7  => RadarControl.new(0, -181989, 208968, 4424, 1),
    8  => RadarControl.new(0, -252898, 235845, 5343, 1),
    9  => RadarControl.new(0, -212819, 209813, 4288, 1),
    10 => RadarControl.new(0, -246899, 251918, 4352, 1)
  }

  def initialize
    super(self.class.simple_name, "gracia/AI/NPC")

    add_start_npc(NOTTINGALE)
    add_talk_id(NOTTINGALE)
    add_first_talk_id(NOTTINGALE)
  end

  def on_adv_event(event, npc, pc)
    case event
    when "32627-02.html", "32627-03.html", "32627-04.html"
      return unless pc
      if pc.clan
        if pc.has_clan_privilege?(ClanPrivilege::CL_SUMMON_AIRSHIP) && AirshipManager.has_airship_license?(pc.clan_id) && !AirshipManager.has_airship?(pc.clan_id)
          html = event
        else
          st = pc.get_quest_state(Q10273_GoodDayToFly.simple_name)
          if st && st.completed?
            html = event
          else
            pc.send_packet(RADARS[2])
            html = "32627-01.html"
          end
        end
      else
        st = pc.get_quest_state(Q10273_GoodDayToFly.simple_name)
        if st && st.completed?
          html = event
        else
          pc.send_packet(RADARS[2])
          html = "32627-01.html"
        end
      end
    when "32627-05.html", "32627-06.html", "32627-07.html", "32627-08.html",
         "32627-09.html", "32627-10.html"
      return unless pc
      pc.send_packet(RADARS[event[6...8].to_i])
      html = event
    end


    html
  end
end
