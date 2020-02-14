class Scripts::FortressOfResistance < ClanHallSiegeEngine
  private MESSENGER = 35382
  private BLOODY_LORD_NURKA = 35375
  private NURKA_COORDS = {
    Location.new(45109, 112124, -1900), # 30%
    Location.new(47653, 110816, -2110), # 40%
    Location.new(47247, 109396, -2000)  # 30%
  }

  private DAMAGE_TO_NURKA = {} of Int32 => Int64

  @nurka : L2Spawn?

  def initialize
    super(self.class.simple_name, "conquerablehalls", FORTRESS_RESSISTANCE)

    add_first_talk_id(MESSENGER)
    add_kill_id(BLOODY_LORD_NURKA)
    add_attack_id(BLOODY_LORD_NURKA)

    begin
      nurka = L2Spawn.new(BLOODY_LORD_NURKA)
      nurka.amount = 1
      nurka.respawn_delay = 10800
      chance = Rnd.rand(100) + 1
      # L2J has commented this out
      # if chance <= 30
        coords = NURKA_COORDS[0]
      # elsif chance > 30 && chance <= 70
      #   coords = NURKA_COORDS[1]
      # else
      #   coords = NURKA_COORDS[2]
      # end
      nurka.location = coords
      @nurka = nurka
    rescue e
      error "Bloody Lord Nurka's spawn not found."
      error e
    end
  end

  def on_first_talk(npc, pc)
    msg = NpcHtmlMessage.new(npc.l2id)
    msg.html = HtmCache.get_htm_force(pc, "data/scripts/conquerablehalls/FortressOfResistance/partisan_ordery_brakel001.htm")
    msg["%nextSiege%"] = @hall.siege_date.time.to_s("%Y.%m.%d %H:%M:%S")
    pc.send_packet(msg)
    nil
  end

  def on_attack(npc, pc, damage, is_summon)
    unless @hall.in_siege?
      return
    end

    clan_id = pc.clan_id
    if clan_id > 0
      if tmp = DAMAGE_TO_NURKA[clan_id]?
        clan_dmg = tmp + damage
      else
        clan_dmg = damage.to_i64
      end
      DAMAGE_TO_NURKA[clan_id] = clan_dmg
    end

    nil
  end

  def on_kill(npc, killer, is_summon)
    unless @hall.in_siege?
      return
    end

    @mission_accomplished = true

    sync do
      npc.spawn.stop_respawn
      npc.delete_me
      cancel_siege_task
      end_siege
    end

    nil
  end

  def winner : L2Clan?
    winner_id = 0
    counter = 0i64
    DAMAGE_TO_NURKA.each do |id, dam|
      if dam > counter
        winner_id = id
        counter = dam
      end
    end

    ClanTable.get_clan(winner_id)
  end

  def on_siege_starts
    @nurka.not_nil!.init
  end
end
