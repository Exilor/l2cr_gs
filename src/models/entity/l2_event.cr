module L2Event
  extend self
  extend Loggable

  def participant?(pc)
    false
  end

  def restore_player_event_status(pc)
  end

  def show_event_html(*args)
    warn "TODO: show_event_html"
  end
end
