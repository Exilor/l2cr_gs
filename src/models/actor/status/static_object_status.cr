require "./char_status"

class StaticObjectStatus < CharStatus
  def active_char : L2StaticObjectInstance
    super.as(L2StaticObjectInstance)
  end
end
