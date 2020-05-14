enum State : UInt8
  CREATED
  STARTED
  COMPLETED

  def name : String
    case self
    when STARTED
      "Started"
    when COMPLETED
      "Completed"
    else
      "Start"
    end
  end

  def self.parse(name : String) : self
    case name
    when "Started"
      STARTED
    when "Completed"
      COMPLETED
    else
      CREATED
    end
  end
end
