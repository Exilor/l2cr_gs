require "../../monster_race"

module AdminCommandHandler::AdminMonsterRace
  extend self
  extend AdminCommandHandler

  protected class_property state : Int32 = -1

  def use_admin_command(command, pc)
    if command.casecmp?("admin_mons")
      handle_send_packet(pc)
    end

    true
  end

  def commands
    {"admin_mons"}
  end

  private def handle_send_packet(pc)
    codes = [
      [
        -1,
        0
      ],
      [
        0,
        15322
      ],
      [
        13765,
        -1
      ],
      [
        -1,
        0
      ]
    ]

    case @@state
    when -1
      @@state += 1
      MonsterRace.new_race
      MonsterRace.new_speeds
      spk = MonRaceInfo.new(codes[@@state][0], codes[@@state][1], MonsterRace.monsters, MonsterRace.speeds)
      pc.broadcast_packet(spk)
    when 0
      @@state += 1
      sm = SystemMessageId::MONSRACE_RACE_START
      pc.send_packet(sm)
      srace = Music::S_RACE.packet
      pc.broadcast_packet(srace)
      srace2 = Sound::ITEMSOUND2_RACE_START.packet
      pc.broadcast_packet(srace2)
      spk = MonRaceInfo.new(codes[@@state][0], codes[@@state][1], MonsterRace.monsters, MonsterRace.speeds)
      pc.broadcast_packet(spk)

      ThreadPoolManager.schedule_general(RunRace.new(codes, pc), 5000)
    else
      # [automatically added else]
    end

  end

  private struct RunRace
    initializer codes : Array(Array(Int32)), pc : L2PcInstance

    def call
      spk = MonRaceInfo.new(@codes[2][0], @codes[2][1], MonsterRace.monsters, MonsterRace.speeds)
      @pc.send_packet(spk)
      @pc.broadcast_packet(spk)
      ThreadPoolManager.schedule_general(RunEnd.new(@pc), 30_000)
    end
  end

  private struct RunEnd
    initializer pc : L2PcInstance

    def call
      8.times do |i|
        dl = DeleteObject.new(MonsterRace.monsters[i])
        @pc.send_packet(dl)
        @pc.broadcast_packet(dl)
      end

      AdminMonsterRace.state = -1
    end
  end
end
