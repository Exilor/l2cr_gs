module Siegable
  abstract def start_siege
  abstract def end_siege
  abstract def get_attacker_clan(clan_id : Int32) : L2SiegeClan?
  abstract def get_attacker_clan(clan : L2Clan?) : L2SiegeClan?
  abstract def attacker_clans : IArray(L2SiegeClan)?
  abstract def attackers_in_zone : IArray(L2PcInstance)
  abstract def attacker?(clan : L2Clan?) : Bool
  abstract def get_defender_clan(clan_id : Int32) : L2SiegeClan?
  abstract def get_defender_clan(clan : L2Clan?) : L2SiegeClan?
  abstract def defender_clans : IArray(L2SiegeClan)?
  abstract def defender?(clan : L2Clan?) : Bool
  abstract def get_flag(clan : L2Clan?) : IArray(L2Npc)?
  abstract def siege_date : Calendar
  abstract def give_fame? : Bool
  abstract def fame_frequency : Int32
  abstract def fame_amount : Int32
  abstract def update_siege
end
