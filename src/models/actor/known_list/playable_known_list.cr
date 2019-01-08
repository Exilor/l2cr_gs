require "./char_known_list"

class PlayableKnownList < CharKnownList
  def active_char
    super.as(L2Playable)
  end
end
