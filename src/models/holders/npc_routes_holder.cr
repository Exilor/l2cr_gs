struct NpcRoutesHolder
  @correspondences = {} of String => String

  def add_route(route_name, location)
    @correspondences[get_unique_key location] = route_name
  end

  def get_route_name(npc : L2Npc) : String
    if sp = npc.spawn?
      key = get_unique_key(sp.location)
      return @correspondences.fetch(key, "")
    end

    ""
  end

  private def get_unique_key(loc)
    loc.xyz.join('-')
  end
end
