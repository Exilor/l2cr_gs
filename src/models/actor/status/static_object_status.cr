require "./char_status"

class StaticObjectStatus < CharStatus
  def active_char
    super.as(L2StaticObjectInstance)
  end
end
