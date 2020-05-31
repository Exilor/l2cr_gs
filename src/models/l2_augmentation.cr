struct L2Augmentation
  getter augmentation_id

  def initialize(augmentation_id : Int32)
    @augmentation_id = augmentation_id
    @boni = AugmentationStatBoni.new(augmentation_id)
  end

  def apply_bonus(pc : L2PcInstance)
    @boni.apply_bonus(pc)
  end

  def remove_bonus(pc : L2PcInstance)
    @boni.remove_bonus(pc)
  end

  def attributes : Int32
    augmentation_id
  end

  # Custom, only used in use_item.cr to force an augmentation with a skill.
  def has_skill?
    @boni.@options.any? do |o|
      o.has_active_skill? || o.has_passive_skill? || o.has_activation_skills?
    end
  end

  private class AugmentationStatBoni
    @active = false
    @options : {Options, Options}

    def initialize(id)
      @options = {0x0000FFFF & id, id >> 16}.map do |stat|
        OptionData[stat] || raise "No option found for stat with id #{stat}"
      end
    end

    def apply_bonus(pc : L2PcInstance)
      return if @active
      @options.each &.apply(pc)
      @active = true
    end

    def remove_bonus(pc : L2PcInstance)
      return unless @active
      @options.each &.remove(pc)
      @active = false
    end
  end
end
