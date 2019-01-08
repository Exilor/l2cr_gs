class L2ScriptZone < L2ZoneType
  def on_enter(char)
    char.inside_script_zone = true
  end

  def on_exit(char)
    char.inside_script_zone = false
  end
end
