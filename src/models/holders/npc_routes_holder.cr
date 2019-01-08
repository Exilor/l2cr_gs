struct NpcRoutesHolder
  @correspondences = {} of String => String

  def add_route(route_name, location)
    @correspondences[get_unique_key location] = route_name
  end

  def get_route_name(npc)
    if spawn = npc.spawn?
      key = get_unique_key(spawn.location)
      @correspondences.fetch(key, "")
    else
      ""
    end
  end

  private def get_unique_key(loc)
    "#{loc.x}-#{loc.y}-#{loc.z}"
  end
end
