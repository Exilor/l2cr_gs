require "./char_status.cr"

class DoorStatus < CharStatus
  def active_char : L2DoorInstance
    super.as(L2DoorInstance)
  end
end
