require "./char_status.cr"

class DoorStatus < CharStatus
  def active_char
    super.as(L2DoorInstance)
  end
end
