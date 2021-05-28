module ColosseumFenceData
  extend self
  extend XMLReader

  private STATIC  = {} of Int32 => Array(L2ColosseumFence)
  private DYNAMIC = Concurrent::Map(Int32, Array(L2ColosseumFence)).new

  def load
    STATIC.clear
    parse_datapack_file("colosseum_fences.xml")
    info { "Loaded #{STATIC.size} static fences." }
  end

  private def parse_document(doc : XML::Node, file : File)
    find_element(doc, "list") do |list|
      find_element(list, "colosseumfence") do |fence|
        x = parse_int(fence, "x")
        y = parse_int(fence, "y")
        z = parse_int(fence, "z")
        min_z = parse_int(fence, "min_z")
        max_z = parse_int(fence, "max_z")
        width = parse_int(fence, "width")
        height = parse_int(fence, "height")
        instance = L2ColosseumFence.new(0, x, y, z, min_z, max_z, width, height, L2ColosseumFence::FenceState::CLOSED)
        region = MapRegionManager.get_map_region_loc_id(instance)
        (STATIC[region] ||= [] of L2ColosseumFence) << instance
        instance.spawn_me
      end
    end
  end

  def add_dynamic(x : Int32, y : Int32, z : Int32, min_z : Int32, max_z : Int32, width : Int32, height : Int32) : L2ColosseumFence
    fence = L2ColosseumFence.new(0, x, y, z, min_z, max_z, width, height, L2ColosseumFence::FenceState::CLOSED)
    region = MapRegionManager.get_map_region_loc_id(fence)
    (STATIC[region] ||= [] of L2ColosseumFence) << fence
    fence.spawn_me
    fence
  end

  def check_if_fences_between(x : Int32, y : Int32, z : Int32, tx : Int32, ty : Int32, tz : Int32, instance_id : Int32) : Bool
    if instance_id > 0 && (instance = InstanceManager.get_instance(instance_id))
      check_fences(instance.fences, x, y, z, tx, ty, tz)
    else
      if static = STATIC[MapRegionManager.get_map_region_loc_id(x, y)]?
        return true if check_fences(static, x, y, z, tx, ty, tz)
      end

      if dynamic = DYNAMIC[MapRegionManager.get_map_region_loc_id(x, y)]?
        return true if check_fences(dynamic, x, y, z, tx, ty, tz)
      end

      false
    end
  end

  private def check_fences(fences, x, y, z, tx, ty, tz)
    fences.any? do |fence|
      fence.fence_state.closed? &&
        fence.inside_fence?(x, y, z) != fence.inside_fence?(tx, ty, tz)
    end
  end
end
