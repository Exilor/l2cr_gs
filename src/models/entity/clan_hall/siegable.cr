module Siegable
  abstract def start_siege : Nil
  abstract def end_siege : Nil
  abstract def get_attacker_clan?(clan_id : Int32) : L2SiegeClan?
  abstract def get_attacker_clan?(clan : L2Clan?) : L2SiegeClan?
  abstract def attacker_clans? : Array(L2SiegeClan)?
  abstract def attackers_in_zone : Array(L2SiegeClan)
  abstract def attacker?(clan : L2Clan?) : Bool
  abstract def get_defender_clan?(clan_id : Int32) : L2SiegeClan?
  abstract def get_defender_clan?(clan : L2Clan?) : L2SiegeClan?
  abstract def defender_clans? : Array(L2SiegeClan)?
  abstract def defender?(clan : L2Clan?) : Bool
  abstract def get_flag?(clan : L2Clan?) : Array(L2Npc)?
  abstract def siege_date : Calendar
  abstract def give_fame? : Bool
  abstract def fame_frequency : Int32
  abstract def fame_amount : Int32
  abstract def update_siege : Nil

  def get_attacker_clan(*args) : L2SiegeClan
    unless clan = get_attacker_clan?(*args)
      raise "No attacker clan found (args: #{args})"
    end

    clan
  end

  def attacker_clans : Array(L2SiegeClan)
    unless ret = attacker_clans?
      raise "No attacker clans for this siegable"
    end

    ret
  end

  def get_defender_clan(*args) : L2SiegeClan
    unless clan = get_defender_clan?(*args)
      raise "No defender clan found (args: #{args})"
    end

    clan
  end

  def defender_clans : Array(L2SiegeClan)
    unless ret = defender_clans?
      raise "No defender clans for this siegable"
    end

    ret
  end

  def get_flag(clan : L2Clan?) : Array(L2Npc)
    unless flag = get_flag?(clan)
      raise "No flag array found (clan: #{clan})"
    end

    flag
  end
end
