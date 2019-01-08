struct CubicDisappear
  include Runnable

  initializer cubic: L2CubicInstance

  def run
    @cubic.stop_action
    @cubic.owner.cubics.delete(@cubic.id)
    @cubic.owner.broadcast_user_info
  end
end
