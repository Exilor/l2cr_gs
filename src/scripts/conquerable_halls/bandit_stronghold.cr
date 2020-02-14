require "./flag_war"

class Scripts::BanditStronghold < FlagWar
  def initialize
    @royal_flag = 35422
    @flag_red = 35423
    @flag_yellow = 35424
    @flag_green = 35425
    @flag_blue = 35426
    @flag_purple = 35427

    @ally_1 = 35428
    @ally_2 = 35429
    @ally_3 = 35430
    @ally_4 = 35431
    @ally_5 = 35432

    @teleport_1 = 35560

    @messenger = 35437

    @outter_doors_to_open[0] = 22170001
    @outter_doors_to_open[1] = 22170002

    @inner_doors_to_open[0] = 22170003
    @inner_doors_to_open[1] = 22170004

    @flag_coords << Location.new(83699, -17468, -1774, 19048)
    @flag_coords << Location.new(82053, -17060, -1784, 5432)
    @flag_coords << Location.new(82142, -15528, -1799, 58792)
    @flag_coords << Location.new(83544, -15266, -1770, 44976)
    @flag_coords << Location.new(84609, -16041, -1769, 35816)
    @flag_coords << Location.new(81981, -15708, -1858, 60392)
    @flag_coords << Location.new(84375, -17060, -1860, 27712)

    zone_list = ZoneManager.get_all_zones(L2ResidenceHallTeleportZone)
    zone_list.each do |tele_zone|
      if tele_zone.residence_id != BANDIT_STRONGHOLD
        next
      end

      id = tele_zone.residence_zone_id

      if id < 0 || id >= 6
        next
      end

      @tele_zones[id] = tele_zone
    end

    @quest_reward = 5009
    @center = Location.new(82882, -16280, -1894, 0)

    super(self.class.simple_name, BANDIT_STRONGHOLD)
  end

  def get_flag_html(flag : Int32) : String?
    case flag
    when 35423
      "messenger_flag1.htm"
    when 35424
      "messenger_flag2.htm"
    when 35425
      "messenger_flag3.htm"
    when 35426
      "messenger_flag4.htm"
    when 35427
      "messenger_flag5.htm"
    end
  end

  def get_ally_html(ally : Int32) : String?
    case ally
    when 35428
      "messenger_ally1result.htm"
    when 35429
      "messenger_ally2result.htm"
    when 35430
      "messenger_ally3result.htm"
    when 35431
      "messenger_ally4result.htm"
    when 35432
      "messenger_ally5result.htm"
    end
  end
end
