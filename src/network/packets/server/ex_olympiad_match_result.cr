class Packets::Outgoing::ExOlympiadMatchResult < GameServerPacket
  @lose_team = 2

  def initialize(tie : Bool, win_team : Int32, winner_list : Array(OlympiadInfo), loser_list : Array(OlympiadInfo))
    @tie = tie
    @win_team = win_team
    @winner_list = winner_list
    @loser_list = loser_list
    if @win_team == 2
      @lose_team = 1
    elsif @win_team == 0
      @win_team = 1
    end
  end

  private def write_impl
    c 0xfe
    h 0xd4

    d 0x01 # 0: match list, 1: match result

    d @tie ? 1 : 0 # 0: win, 1: tie
    s @winner_list[0].name
    d @win_team
    d @winner_list.size

    write_info(@winner_list)
    d @lose_team
    d @loser_list.size
    write_info(@loser_list)
  end

  private def write_info(list)
    list.each do |info|
      s info.name
      s info.clan_name
      d info.clan_id
      d info.class_id
      d info.damage
      d info.current_points
      d info.diff_points
    end
  end
end
