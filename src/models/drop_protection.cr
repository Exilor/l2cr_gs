class DropProtection
  include Synchronizable

  private PROTECTED_MILLIS_TIME = 15_000

  @task : TaskScheduler::DelayedTask?

  getter owner : L2PcInstance?
  getter? "protected"

  def initialize
    @protected = false
    @owner = nil
    @task = nil
  end

  def call
    sync { initialize }
  end

  def try_pick_up(pet : L2PetInstance) : Bool
    try_pick_up(pet.owner)
  end

  def try_pick_up(pc : L2PcInstance) : Bool
    sync do
      return true unless @protected
      return true if @owner == pc

      owner = @owner.not_nil!
      !!owner.party && owner.party == pc.party
    end
  end

  def unprotect
    sync do
      @task.try &.cancel
      initialize
    end
  end

  def protect(pc : L2PcInstance)
    sync do
      unprotect
      @protected = true
      @owner = pc
      @task = ThreadPoolManager.schedule_general(self, PROTECTED_MILLIS_TIME)
    end
  end
end
