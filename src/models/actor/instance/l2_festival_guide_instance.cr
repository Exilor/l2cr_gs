class L2FestivalGuideInstance < L2Npc
  getter festival_type, festival_oracle

  def initialize(template : L2NpcTemplate)
    super

    case id
    when 31127, 31132
      @festival_type = SevenSignsFestival::FESTIVAL_LEVEL_MAX_31
      @festival_oracle = SevenSigns::CABAL_DAWN
      @blue_stones_needed = 900
      @green_stones_needed = 540
      @red_stones_needed = 270
    when 31128, 31133
      @festival_type = SevenSignsFestival::FESTIVAL_LEVEL_MAX_42
      @festival_oracle = SevenSigns::CABAL_DAWN
      @blue_stones_needed = 1500
      @green_stones_needed = 900
      @red_stones_needed = 450
    when 31129, 31134
      @festival_type = SevenSignsFestival::FESTIVAL_LEVEL_MAX_53
      @festival_oracle = SevenSigns::CABAL_DAWN
      @blue_stones_needed = 3000
      @green_stones_needed = 1800
      @red_stones_needed = 900
    when 31130, 31135
      @festival_type = SevenSignsFestival::FESTIVAL_LEVEL_MAX_64
      @festival_oracle = SevenSigns::CABAL_DAWN
      @blue_stones_needed = 4500
      @green_stones_needed = 2700
      @red_stones_needed = 1350
    when 31131, 31136
      @festival_type = SevenSignsFestival::FESTIVAL_LEVEL_MAX_NONE
      @festival_oracle = SevenSigns::CABAL_DAWN
      @blue_stones_needed = 6000
      @green_stones_needed = 3600
      @red_stones_needed = 1800
    when 31137, 31142
      @festival_type = SevenSignsFestival::FESTIVAL_LEVEL_MAX_31
      @festival_oracle = SevenSigns::CABAL_DUSK
      @blue_stones_needed = 900
      @green_stones_needed = 540
      @red_stones_needed = 270
    when 31138, 31143
      @festival_type = SevenSignsFestival::FESTIVAL_LEVEL_MAX_42
      @festival_oracle = SevenSigns::CABAL_DUSK
      @blue_stones_needed = 1500
      @green_stones_needed = 900
      @red_stones_needed = 450
    when 31139, 31144
      @festival_type = SevenSignsFestival::FESTIVAL_LEVEL_MAX_53
      @festival_oracle = SevenSigns::CABAL_DUSK
      @blue_stones_needed = 3000
      @green_stones_needed = 1800
      @red_stones_needed = 900
    when 31140, 31145
      @festival_type = SevenSignsFestival::FESTIVAL_LEVEL_MAX_64
      @festival_oracle = SevenSigns::CABAL_DUSK
      @blue_stones_needed = 4500
      @green_stones_needed = 2700
      @red_stones_needed = 1350
    when 31141, 31146
      @festival_type = SevenSignsFestival::FESTIVAL_LEVEL_MAX_NONE
      @festival_oracle = SevenSigns::CABAL_DUSK
      @blue_stones_needed = 6000
      @green_stones_needed = 3600
      @red_stones_needed = 1800
    else
      @festival_type = SevenSignsFestival::FESTIVAL_LEVEL_MAX_NONE
      @festival_oracle = SevenSigns::CABAL_NULL
      @blue_stones_needed = 0
      @green_stones_needed = 0
      @red_stones_needed = 0
    end
  end

  def get_stone_count(stone_type : Int) : Int32
    case stone_type
    when SevenSigns::SEAL_STONE_BLUE_ID
      @blue_stones_needed
    when SevenSigns::SEAL_STONE_GREEN_ID
      @green_stones_needed
    when SevenSigns::SEAL_STONE_RED_ID
      @red_stones_needed
    else
      -1
    end
  end

  def show_chat_window(pc : L2PcInstance, val : Int32, suffix : String?, is_description : Bool)
    filename = String.build do |io|
      io << SevenSigns::SEVEN_SIGNS_HTML_PATH
      io << "festival/"
      io << (is_description ? "desc_" : "festival_")
      io << val
      io << suffix if suffix
      io << ".htm"
    end

    html = NpcHtmlMessage.new(l2id)
    html.set_file(pc, filename)
    html["%objectId%"] = l2id
    html["%festivalType%"] = SevenSignsFestival.instance.get_festival_name(@festival_type)
    html["%cycleMins%"] = SevenSignsFestival.instance.mins_to_next_cycle

    if !is_description && "#{val}#{suffix}" == "2b"
      html["%minFestivalPartyMembers%"] = Config.alt_festival_min_player
    end

    if val == 5
      html["%statsTable%"] = stats_table
    end

    if val == 6
      html["%bonusTable%"] = bonus_table
    end

    if val == 1
      html["%blueStoneNeeded%"] = @blue_stones_needed
      html["%greenStoneNeeded%"] = @green_stones_needed
      html["%redStoneNeeded%"] = @red_stones_needed
    end

    pc.send_packet(html)
    pc.action_failed
  end

  private def stats_table : String
    String.build(1000) do |io|
      5.times do |i|
        dawn_score = SevenSignsFestival.instance.get_highest_score(SevenSigns::CABAL_DAWN, i)
        dusk_score = SevenSignsFestival.instance.get_highest_score(SevenSigns::CABAL_DUSK, i)
        festival_name = SevenSignsFestival.instance.get_festival_name(i)
        winning_cabal = "Children of Dusk"
        if dawn_score > dusk_score
          winning_cabal = "Children of Dawn"
        elsif dawn_score == dusk_score
          winning_cabal = "None"
        end

        io << "<tr><td width=\"100\" align=\"center\">"
        io << festival_name
        io << "</td><td align=\"center\" width=\"35\">"
        io << dusk_score
        io << "</td><td align=\"center\" width=\"35\">"
        io << dawn_score
        io << "</td><td align=\"center\" width=\"130\">"
        io << winning_cabal
        io << "</td></tr>"
      end
    end
  end

  private def bonus_table : String
    String.build(500) do |io|
      5.times do |i|
        acc_score = SevenSignsFestival.instance.get_accumulated_bonus(i)
        festival_name = SevenSignsFestival.instance.get_festival_name(i)
        io << "<tr><td align=\"center\" width=\"150\">"
        io << festival_name
        io << "</td><td align=\"center\" width=\"150\">"
        io << acc_score
        io << "</td></tr>"
      end
    end
  end

  def instance_type : InstanceType
    InstanceType::L2FestivalGuideInstance
  end
end
