abstract class AbstractNode(Loc) # Loc < AbstractNodeLoc
  property! parent : AbstractNode(Loc)?
  property! loc : Loc?

  initializer loc : Loc?

  def_equals_and_hash @loc
end
