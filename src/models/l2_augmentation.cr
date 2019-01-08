struct L2Augmentation
  getter augmentation_id

  def initialize(@augmentation_id : Int32)
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
    @boni.@options.any? do |op|
      op.try &.has_active_skill? ||
      op.try &.has_passive_skill? ||
      op.try &.has_activation_skills?
    end
  end

  class AugmentationStatBoni
    include Loggable

    @options : {Options?, Options?}

    def initialize(id)
      @options = {0x0000FFFF & id, id >> 16}.map do |stat|
        if op = OptionData[stat]?
          op
        else
          warn "no Option found for stat with ID #{stat}."
          nil
        end
      end

      @active = false
    end

    def apply_bonus(pc : L2PcInstance)
      return if @active
      @options.each &.try &.apply(pc)
      @active = true
    end

    def remove_bonus(pc : L2PcInstance)
      return unless @active
      @options.each &.try &.remove(pc)
      @active = false
    end
  end
end
