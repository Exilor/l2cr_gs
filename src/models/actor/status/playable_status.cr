require "./char_status"

class PlayableStatus < CharStatus
  def active_char
    super.as(L2Playable)
  end
end
