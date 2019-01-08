require "./l2_feedable_beast_instance"

class L2TamedBeastInstance < L2FeedableBeastInstance
  private MAX_DISTANCE_FROM_HOME = 30000
  private MAX_DISTANCE_FROM_OWNER = 2000
  private MAX_DURATION = 1200000 # 20 minutes
  private DURATION_CHECK_INTERVAL = 60000 # 1 minute
  private DURATION_INCREASE_INTERVAL = 20000 # 20 secs (gained upon feeding)
  private BUFF_INTERVAL = 5000 # 5 seconds

  def instance_type : InstanceType
    InstanceType::L2TamedBeastInstance
  end
end
