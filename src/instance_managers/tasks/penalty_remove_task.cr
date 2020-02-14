struct PenaltyRemoveTask
  initializer l2id : Int32

  def call
    HandysBlockCheckerManager.remove_penalty(@l2id)
  end
end
