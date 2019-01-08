class L2NoSummonFriendZone < L2ZoneType
  def on_enter(char)
    char.inside_no_summon_friend_zone = true
  end

  def on_exit(char)
    char.inside_no_summon_friend_zone = false
  end
end
