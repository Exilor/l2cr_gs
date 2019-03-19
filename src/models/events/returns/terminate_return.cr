class TerminateReturn < AbstractEventReturn
  getter terminate

  def initialize(@terminate : Bool, override : Bool, abort : Bool)
    super(override, abort)
  end
end
