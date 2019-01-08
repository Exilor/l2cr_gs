class Condition
  class CategoryType < Condition
    def initialize(categories)
      @categories = Set(::CategoryType).new(categories)
    end

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      @categories.any? { |type| effector.in_category?(type) }
    end
  end
end
