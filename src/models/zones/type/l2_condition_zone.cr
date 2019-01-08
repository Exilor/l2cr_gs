class L2ConditionZone < L2ZoneType
  @no_item_drop = false
  @no_bookmark = false

  def set_parameter(name, value)
    if name.casecmp?("NoBookmark")
      @no_bookmark = Bool.new(value)
    elsif name.casecmp?("NoItemDrop")
      @no_item_drop = Bool.new(value)
    else
      super
    end
  end

  def on_enter(char)
    if char.player?
      if @no_bookmark
        char.inside_no_bookmark_zone = true
      end

      if @no_item_drop
        char.inside_no_item_drop_zone = true
      end
    end
  end

  def on_exit(char)
    if char.player?
      if @no_bookmark
        char.inside_no_bookmark_zone = false
      end

      if @no_item_drop
        char.inside_no_item_drop_zone = false
      end
    end
  end
end
