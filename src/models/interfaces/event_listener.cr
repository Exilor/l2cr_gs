module EventListener
  abstract def on_event? : Bool
  abstract def blocking_exit? : Bool
  abstract def blocking_death_penalty? : Bool
  abstract def can_revive? : Bool
end
