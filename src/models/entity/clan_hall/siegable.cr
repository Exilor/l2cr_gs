module Siegable
  abstract def start_siege
  abstract def end_siege
  abstract def get_attacker_clan(clan_id : Int32) : L2SiegeClan?
  abstract def get_attacker_clan(clan : L2Clan?) : L2SiegeClan?
  abstract def attacker_clans : Array(L2SiegeClan) | Concurrent::Array(L2SiegeClan) | Nil
  abstract def attackers_in_zone : Array(L2PcInstance) | Concurrent::Array(L2PcInstance)
  abstract def attacker?(clan : L2Clan?) : Bool
  abstract def get_defender_clan(clan_id : Int32) : L2SiegeClan?
  abstract def get_defender_clan(clan : L2Clan?) : L2SiegeClan?
  abstract def defender_clans : Array(L2SiegeClan) | Concurrent::Array(L2SiegeClan) | Nil
  abstract def defender?(clan : L2Clan?) : Bool
  abstract def get_flag(clan : L2Clan?) : Array(L2Npc) | Concurrent::Array(L2Npc) | Nil
  abstract def siege_date : Calendar
  abstract def give_fame? : Bool
  abstract def fame_frequency : Int32
  abstract def fame_amount : Int32
  abstract def update_siege
end
