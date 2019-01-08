class L2FortManagerInstance < L2MerchantInstance
  private COND_ALL_FALSE = 0
  private COND_BUSY_BECAUSE_OF_SIEGE = 1
  private COND_OWNER = 2

  def instance_type
    InstanceType::L2FortManagerInstance
  end

  def warehouse?
    true
  end
end
