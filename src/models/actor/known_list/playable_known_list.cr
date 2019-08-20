require "./char_known_list"

class PlayableKnownList < CharKnownList
  def active_char : L2Playable
    super.as(L2Playable)
  end
end
