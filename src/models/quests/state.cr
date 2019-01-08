enum State : UInt8
  CREATED, STARTED, COMPLETED

  def self.[](val : String) : self
    case val
    when "Started"
      STARTED
    when "Completed"
      COMPLETED
    else
      CREATED
    end
  end

  def self.[](val : self) : String
    case val
    when STARTED
      "Started"
    when COMPLETED
      "Completed"
    else
      "Created"
    end
  end
end
