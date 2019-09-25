struct CubicDisappear
  initializer cubic : L2CubicInstance

  def call
    @cubic.stop_action
    @cubic.owner.cubics.delete(@cubic.id)
    @cubic.owner.broadcast_user_info
  end
end
