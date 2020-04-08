class Scripts::WildBeastReserve < FlagWar
  def initialize
    @royal_flag = 35606
    @flag_red = 35607 # White flag
    @flag_yellow = 35608 # Red flag
    @flag_green = 35609 # Blue flag
    @flag_blue = 35610 # Green flag
    @flag_purple = 35611 # Black flag

    @ally_1 = 35618
    @ally_2 = 35619
    @ally_3 = 35620
    @ally_4 = 35621
    @ally_5 = 35622

    @teleport_1 = 35612

    @messenger = 35627

    @outter_doors_to_open[0] = 21150003
    @outter_doors_to_open[1] = 21150004

    @inner_doors_to_open[0] = 21150001
    @inner_doors_to_open[1] = 21150002

    @flag_coords << Location.new(56963, -92211, -1303, 60611)
    @flag_coords << Location.new(58090, -91641, -1303, 47274)
    @flag_coords << Location.new(58908, -92556, -1303, 34450)
    @flag_coords << Location.new(58336, -93600, -1303, 21100)
    @flag_coords << Location.new(57152, -93360, -1303, 8400)
    @flag_coords << Location.new(59116, -93251, -1302, 31000)
    @flag_coords << Location.new(56432, -92864, -1303, 64000)

    ZoneManager.get_all_zones(L2ResidenceHallTeleportZone) do |tele_zone|
      if tele_zone.residence_id != BEAST_FARM
        next
      end

      id = tele_zone.residence_zone_id

      if id < 0 || id >= 6
        next
      end

      @tele_zones[id] = tele_zone
    end

    @quest_reward = 0
    @center = Location.new(57762, -92696, -1359, 0)

    super(self.class.simple_name, BEAST_FARM)
  end

  def get_flag_html(flag : Int32) : String?
    case flag
    when 35607
      "messenger_flag1.htm"
    when 35608
      "messenger_flag2.htm"
    when 35609
      "messenger_flag3.htm"
    when 35610
      "messenger_flag4.htm"
    when 35611
      "messenger_flag5.htm"
    else
      # automatically added
    end

  end

  def get_ally_html(ally : Int32) : String?
    case ally
    when 35618
      "messenger_ally1result.htm"
    when 35619
      "messenger_ally2result.htm"
    when 35620
      "messenger_ally3result.htm"
    when 35621
      "messenger_ally4result.htm"
    when 35622
      "messenger_ally5result.htm"
    else
      # automatically added
    end

  end

  def can_pay_registration?
    false
  end
end