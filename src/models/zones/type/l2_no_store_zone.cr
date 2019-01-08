class L2NoStoreZone < L2ZoneType
  def on_enter(char)
    if char.player?
      char.inside_no_store_zone = true
    end
  end

  def on_exit(char)
    if char.player?
      char.inside_no_store_zone = false
    end
  end
end
