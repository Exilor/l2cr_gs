struct SkillChannelized
  @channelizers = Hash(Int32, Hash(Int32, L2Character)).new do |h, k|
    h[k] = {} of Int32 => L2Character
  end

  def add_channelizer(skill_id : Int32, channelizer : L2Character)
    @channelizers[skill_id][channelizer.l2id] = channelizer
  end

  def remove_channelizer(skill_id : Int32, channelizer : L2Character)
    get_channelizers(skill_id).try &.delete(channelizer.l2id)
  end

  def get_channelizers_size(skill_id : Int32) : Int32
    get_channelizers(skill_id).try &.size || 0
  end

  def abort_channelization
    # @channelizers.each_value &.each_value &.abort_cast # doesn't work well
    @channelizers.clear
  end

  private def get_channelizers(skill_id : Int32) : Hash(Int32, L2Character)?
    @channelizers[skill_id]?
  end

  def channelized? : Bool
    @channelizers.any? { |_, map| !map.empty? }
  end
end
