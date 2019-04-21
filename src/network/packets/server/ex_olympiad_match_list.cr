class Packets::Outgoing::ExOlympiadMatchList < GameServerPacket
  @games = [] of OlympiadGameTask

  def initialize
    OlympiadGameManager.number_of_stadiums.times do |i|
      if task = OlympiadGameManager.get_olympiad_task(i)
        if !task.game_started? || task.battle_finished?
          next
        end

        @games << task
      end
    end
  end

  def write_impl
    c 0xfe
    h 0xd4

    d 0x00

    d @games.size
    d 0x00

    @games.each do |current_game|
      if game = current_game.game?
        d game.stadium_id

        case game
        when OlympiadGameNonClassed
          d 1
        when OlympiadGameClassed
          d 2
        when OlympiadGameTeams
          d -1
        else
          d 0
        end

        d current_game.running? ? 0x02 : 0x01 # 1: standby, 2: playing
        names = game.player_names
        s names[0]
        s names[1]
      end
    end
  end
end
