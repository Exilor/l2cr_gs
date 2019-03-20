abstract class AbstractNode(Loc)
  property! parent : AbstractNode(Loc)?
  property! loc : Loc?
  def_equals @loc
  initializer loc: Loc?
end
