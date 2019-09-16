abstract class AbstractNode(Loc)
  property! parent : AbstractNode(Loc)?
  property! loc : Loc?

  initializer loc: Loc?

  def_equals @loc
end
