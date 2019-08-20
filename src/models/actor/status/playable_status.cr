require "./char_status"

class PlayableStatus < CharStatus
  def active_char : L2Playable
    super.as(L2Playable)
  end
end
