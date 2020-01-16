require "../l2_zone_respawn"

abstract class L2ResidenceZone < L2ZoneRespawn
  property residence_id : Int32 = 0

  def banish_foreigners(owning_clan_id : Int)
    players_inside.each do |pc|
      if owning_clan_id != 0 && pc.clan_id == owning_clan_id
        next
      end

      pc.tele_to_location(banish_spawn_loc, true)
    end
  end
end
