class DropProtection
  include Synchronizable

  private PROTECTED_MILLIS_TIME = 15000

  @task : Scheduler::DelayedTask?
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
      unless @protected
        return true
      end

      if @owner == pc
        return true
      end

      owner = @owner.not_nil!

      !!owner.party? && owner.party == pc.party?
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

      if @owner.nil?
        raise "Tried to protect dropped item with nil owner"
      end

      @task = ThreadPoolManager.schedule_general(self, PROTECTED_MILLIS_TIME)
    end
  end
end
