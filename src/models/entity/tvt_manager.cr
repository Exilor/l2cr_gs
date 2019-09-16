module TvTManager
  extend self
  extend Loggable

  def load
    if Config.tvt_event_enabled
      TvTEvent.init
      schedule_event_start
      info "Started."
    else
      info "Disabled."
    end
  end

  def schedule_event_start
  rescue e
    error e
  end
end
