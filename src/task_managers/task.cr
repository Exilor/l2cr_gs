abstract class Task
  include Loggable

  def init
    # no-op
  end

  def launch_special(task : ExecutedTask)
    # return nil
  end

  abstract def name : String
  abstract def on_time_elapsed(task : ExecutedTask)

  def on_destroy
    # no-op
  end

  def to_s(io : IO)
    io << {{@type.stringify}}
  end
end
